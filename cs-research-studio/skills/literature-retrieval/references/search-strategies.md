# CS 文献检索策略参考

## 一、检索式构造方法

### 1. 概念拆解

把课题拆成 2-4 个概念块，每块列同义词/上下位词，块内 OR、块间 AND：

```
课题：大语言模型在代码生成中的幻觉问题
块A（对象）："large language model" OR LLM OR "code generation model"
块B（任务）："code generation" OR "program synthesis"
块C（问题）：hallucination OR "incorrect output" OR "functional correctness"
检索式：(A) AND (B) AND (C)
```

### 2. 时间分层

| 层 | 范围 | 找什么 |
|---|---|---|
| 前沿层 | 近 1 年 | arXiv 预印本、最新会议（NeurIPS/ICLR/ACL/CCF-A 当年录用） |
| 主干层 | 近 3 年 | 被引高、被广泛比较的方法 |
| 经典层 | 不限 | 开创性工作、综述、教科书级方法 |

### 3. 滚雪球法

拿到 1-2 篇高质量论文后：
- **向后滚**：它的参考文献（更早的基础工作）
- **向前滚**：被谁引用（Semantic Scholar 的 Cited by，找更新进展）

## 二、各检索源技巧

### arXiv API 检索语法

| 语法 | 含义 | 示例 |
|---|---|---|
| `all:"..."` | 全字段短语 | `all:"retrieval augmented generation"` |
| `ti:"..."` | 仅标题 | `ti:"mixture of experts"` |
| `au:"..."` | 作者 | `au:"vaswani"` |
| `cat:cs.XX` | 分类限定 | `cat:cs.CL`、`cat:cs.AI`、`cat:cs.SE`、`cat:cs.IoT`（无 cs.IoT，物联网用 `cs.NI`） |
| `AND / OR / ANDNOT` | 布尔组合 | `cat:cs.CL AND all:"code generation"` |
| `submittedDate` | 时间限定 | `submittedDate:[202401010000 TO 202612312359]` |

### 会议与期刊定位

- CCF 推荐目录（A/B/C 类）是判断"代表性工作"的基准：AI 看 NeurIPS/ICML/ICLR/AAAI/ACL；软件工程看 ICSE/FSE/ASE；物联网看 SenSys/IPSN/MobiCom/INFOCOM；系统看 OSDI/SOSP
- DBLP 按作者/会议/年份浏览，适合确认"某团队近三年的工作线"

### 中文文献

- CNKI 用"主题"字段而非"全文"，减少噪声
- 学位论文（博士）的综述章节是快速建立领域图景的捷径，但需注意其中文献结论必须以原始论文为准

## 三、纳入/排除标准模板

纳入一篇文献前，回答四个问题：

1. **相关性**：它研究的问题与我的课题是同一问题吗？（标题摘要判断，存疑则读引言）
2. **可信度**：发表渠道是否可靠？（顶会/期刊 > 工作坊 > 预印本；预印本需额外核实）
3. **时效性**：它代表当前技术水平还是已被超越？
4. **必要性**：它提供的是问题定义、方法、基线、数据还是结论？每篇至少要贡献一种

排除不丢人：检索记录表里写清排除理由（跑题/重复/已被取代/无法获取全文），反而是调研严谨性的证据。

## 四、数量基准

- 快速摸底：5-8 篇精读 + 10-20 篇泛读标题摘要
- 开题级调研：8-15 篇精读（本团队默认）+ 覆盖至少 2 个时间层
- 综述级：30 篇以上，需正式的系统综述方法（如 PRISMA 流程）
