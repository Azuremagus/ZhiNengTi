#!/usr/bin/env python3
"""arXiv literature search and download tool.

Uses only the Python standard library (urllib + xml.etree).
Official arXiv API: https://export.arxiv.org/api/query

Usage:
    python arxiv_fetch.py search --query "retrieval augmented generation" --max 10
    python arxiv_fetch.py search --query "mixture of experts" --max 5 --download --outdir papers
    python arxiv_fetch.py download --id 2305.06983 --outdir papers
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

API_URL = "https://export.arxiv.org/api/query"
PDF_URL = "https://arxiv.org/pdf/{id}.pdf"
ATOM_NS = "{http://www.w3.org/2005/Atom}"
ARXIV_NS = "{http://arxiv.org/schemas/atom}"

# arXiv API etiquette: no more than 1 request per 3 seconds.
REQUEST_INTERVAL = 3.0


def http_get(url, timeout=60):
    req = urllib.request.Request(
        url, headers={"User-Agent": "cs-research-studio/literature-retrieval (academic use)"}
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def parse_entry(entry):
    entry_id = entry.findtext(f"{ATOM_NS}id", "").strip()
    # id looks like http://arxiv.org/abs/2305.06983v2 -> keep version-less id
    arxiv_id = entry_id.rsplit("/abs/", 1)[-1] if "/abs/" in entry_id else entry_id
    title = re.sub(r"\s+", " ", entry.findtext(f"{ATOM_NS}title", "")).strip()
    summary = re.sub(r"\s+", " ", entry.findtext(f"{ATOM_NS}summary", "")).strip()
    published = entry.findtext(f"{ATOM_NS}published", "")[:10]
    authors = [
        a.findtext(f"{ATOM_NS}name", "").strip()
        for a in entry.findall(f"{ATOM_NS}author")
    ]
    primary_cat = entry.find(f"{ARXIV_NS}primary_category")
    category = primary_cat.get("term") if primary_cat is not None else ""
    return {
        "arxiv_id": arxiv_id,
        "title": title,
        "authors": authors,
        "published": published,
        "category": category,
        "abs_url": f"https://arxiv.org/abs/{arxiv_id}",
        "pdf_url": PDF_URL.format(id=arxiv_id),
        "summary": summary,
    }


def build_query(user_query, max_results, start=0):
    # Wrap multi-word phrases properly; arXiv search syntax: all:"..."
    terms = user_query.strip()
    if " " in terms and '"' not in terms and ":" not in terms:
        terms = f'all:"{terms}"'
    params = {
        "search_query": terms,
        "start": start,
        "max_results": max_results,
        "sortBy": "relevance",
        "sortOrder": "descending",
    }
    return f"{API_URL}?{urllib.parse.urlencode(params)}"


def search(query, max_results):
    url = build_query(query, max_results)
    raw = http_get(url)
    root = ET.fromstring(raw)
    return [parse_entry(e) for e in root.findall(f"{ATOM_NS}entry")]


def safe_filename(entry):
    first_author = entry["authors"][0].split()[-1] if entry["authors"] else "unknown"
    year = entry["published"][:4] or "0000"
    slug = re.sub(r"[^a-z0-9]+", "_", entry["title"].lower())[:40].strip("_")
    name = f"{year}_{first_author}_{slug}.pdf"
    return re.sub(r"_+", "_", name)


def download_pdf(arxiv_id, outdir):
    os.makedirs(outdir, exist_ok=True)
    data = http_get(PDF_URL.format(id=arxiv_id), timeout=120)
    return data


def cmd_search(args):
    entries = search(args.query, args.max)
    if not entries:
        print("No results found.", file=sys.stderr)
        return 1

    manifest = []
    for i, e in enumerate(entries, 1):
        print(f"[{i}] {e['title']}")
        print(f"    id={e['arxiv_id']}  {e['published']}  {e['category']}")
        print(f"    authors: {', '.join(e['authors'][:5])}{' et al.' if len(e['authors']) > 5 else ''}")
        print(f"    {e['abs_url']}")
        manifest.append(e)

    if args.download:
        os.makedirs(args.outdir, exist_ok=True)
        for e in entries:
            path = os.path.join(args.outdir, safe_filename(e))
            try:
                data = download_pdf(e["arxiv_id"], args.outdir)
                with open(path, "wb") as f:
                    f.write(data)
                print(f"downloaded -> {path} ({len(data) // 1024} KB)")
            except Exception as exc:  # noqa: BLE001
                print(f"FAILED {e['arxiv_id']}: {exc}", file=sys.stderr)
                e["download_error"] = str(exc)
            time.sleep(REQUEST_INTERVAL)

        manifest_path = os.path.join(args.outdir, "arxiv_manifest.json")
        with open(manifest_path, "w", encoding="utf-8") as f:
            json.dump(manifest, f, ensure_ascii=False, indent=2)
        print(f"manifest -> {manifest_path}")
    return 0


def cmd_download(args):
    data = download_pdf(args.id, args.outdir)
    path = os.path.join(args.outdir, f"{args.id.replace('/', '_')}.pdf")
    with open(path, "wb") as f:
        f.write(data)
    print(f"downloaded -> {path} ({len(data) // 1024} KB)")
    return 0


def main():
    parser = argparse.ArgumentParser(description="arXiv search and PDF download")
    sub = parser.add_subparsers(dest="command", required=True)

    p_search = sub.add_parser("search", help="search arXiv")
    p_search.add_argument("--query", required=True, help="search query string")
    p_search.add_argument("--max", type=int, default=10, help="max results (default 10)")
    p_search.add_argument("--download", action="store_true", help="also download PDFs")
    p_search.add_argument("--outdir", default="papers", help="output directory")
    p_search.set_defaults(func=cmd_search)

    p_dl = sub.add_parser("download", help="download one paper by arXiv id")
    p_dl.add_argument("--id", required=True, help="arXiv id, e.g. 2305.06983")
    p_dl.add_argument("--outdir", default="papers", help="output directory")
    p_dl.set_defaults(func=cmd_download)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
