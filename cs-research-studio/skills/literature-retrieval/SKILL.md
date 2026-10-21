---
name: literature-retrieval
description: "CS literature retrieval and download: builds search strategies for arXiv/Semantic Scholar/DBLP/CNKI, runs reproducible searches, downloads open-access PDFs, and keeps an auditable search log."
---

# 文献检索与下载

把"找文献"从随手搜索变成**可复现、可审计**的流程：检索式可回放、下载有来源记录、结果有取舍理由。

## 何时使用

- 需要为一个课题制定系统检索策略（而非随手搜两篇）
- 需要下载开放获取论文（arXiv、会议开放版、作者主页版）
- 需要向导师/评审证明"文献调研覆盖了哪些范围"（检索记录表）

## 使用边界（人在回路）

- AI 负责：构造检索式、批量检索、下载开放获取版本、整理元数据
- **人类必须决策**：纳入/排除每篇文献的最终判断；付费墙文献是否通过图书馆渠道获取；检索范围是否足够

## 检索源与适用场景

| 检索源 | 适用 | 接入方式 |
|---|---|---|
| arXiv | AI/系统/理论预印本，更新最快 | `scripts/arxiv_fetch.py`（官方 API，无需密钥） |
| Semantic Scholar | 全学科，引用关系与 TLDR | 网页 / 开放 API |
| DBLP | CS 书目权威来源，查作者与会议 | 网页检索 |
| Google Scholar | 兜底与引用追踪 | 网页检索（注意反爬） |
| CNKI / 万方 | 中文文献、学位论文 | 校园网/图书馆账号 |
| ACM DL / IEEE Xplore | 正式发表版本 | 机构订阅 |

## 标准流程

1. **锁定检索目标**：研究对象、时间窗（默认近三年 + 不限期经典）、文献类型（会议/期刊/预印本/学位论文）
2. **构造检索式**：参考 `references/search-strategies.md`，核心词 × 同义词 × 限定条件，记录每一条检索式
3. **执行检索**：arXiv 用脚本批量跑；其他源逐条记录命中数与筛选结果
4. **下载与归档**：开放获取版本直接下载 PDF，命名规范 `年份_第一作者_短标题.pdf`
5. **填写检索记录表**：用 `templates/search-log.md`，记录检索式、命中数、纳入/排除及理由
6. **交接**：PDF 与记录表一并交给精读环节，标注每篇的获取状态（已下载 / 仅摘要 / 需图书馆渠道）

## 脚本用法

```bash
# 检索 arXiv 并列出结果（不下载）
python scripts/arxiv_fetch.py search --query "retrieval augmented generation" --max 10

# 检索并下载前 5 篇 PDF 到 papers/ 目录
python scripts/arxiv_fetch.py search --query "mixture of experts" --max 5 --download --outdir papers

# 按 arXiv ID 直接下载指定论文
python scripts/arxiv_fetch.py download --id 2305.06983 --outdir papers
```

脚本仅依赖 Python 标准库（urllib + xml.etree），无第三方包要求。

## 硬性规则

- 只下载开放获取版本；付费墙论文记录 DOI 与获取途径，**不绕过版权限制**
- 每篇纳入的文献必须在检索记录表中有对应行（来源、检索式、纳入理由）
- 元数据（标题、作者、年份、出处）以检索源返回为准，不凭记忆填写
