# 校园 AI 智能体 · 团队协作仓库

中国联通第一届校园 AI 智能体创新应用大赛参赛项目。

本仓库同时承担两个角色：**团队协作的唯一事实来源**，以及 **WorkBuddy 专家包（智能体本体）的源码仓库**。

---

## 一、核心认知

WorkBuddy 里的"智能体"就是一个纯文本目录（专家包），没有云端托管体。目录结构：

```
<expert-name>/
├── .workbuddy-plugin/plugin.json   # 元信息：名称、类型、标签、成员、展示文案
├── agents/*.md                     # 每个角色的提示词与方法论
├── skills/                          # 原子能力（可选，可内嵌）
├── avatars/                         # 头像
└── bin/ references/ templates/     # 可选资源
```

WorkBuddy 只扫描固定位置：

```
%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins
```

因此协作的物理机制是：**仓库里的专家包是唯一事实来源，改完用 `scripts\sync-expert.cmd` 镜像到专家目录**。拉取代码后跑一次同步，即可在自己的 WorkBuddy 里使用。

> 为什么不用目录联接（junction）：官方校验脚本会把联接解析成真实路径，导致"专家不在专家目录下"的误判。镜像同步虽然多一条命令，但 100% 符合校验逻辑。

---

## 二、开发在哪做：WorkBuddy，不是仓库

三句话讲清分工：

1. **开发动作全部在 WorkBuddy 里完成。** 建专家团、改角色提示词、补技能，都在对话框里用自然语言驱动，WorkBuddy 会自动加载 `expert-manager` 技能并按规范生成文件。不需要任何人手写 `plugin.json` 的字段结构。
2. **Git 只负责一件事：让队友拿到你建的东西。** WorkBuddy 是本地客户端，队友之间不会自动同步。
3. **二者通过同步脚本无缝衔接。** 仓库是源码，专家目录是部署镜像。`git pull` 后跑一次 `scripts\sync-expert.cmd`，WorkBuddy 立刻可用；改了仓库文件后同样跑一次同步再注册。

### 在 WorkBuddy 里开发的三种方式

| 方式 | 怎么用 | 适合 |
|---|---|---|
| **对话式建包** | 直接说"帮我建一个做 XX 的专家团"，它会自动追问 4 个问题（封装形态 / 技能分发方式 / 头像 / 命名基调），答完自动生成完整专家包 | 从零起步，最快 |
| **资料转化** | 把队里写好的 SOP、角色定义、流程文档丢给它，说"把这个转成一个专家团" | 方案已成型 |
| **定点改文件** | 打开 `cs-research-studio/agents/xxx.md`，说"把主理人的第 2 步改成……"，它直接编辑仓库里的文件 | 迭代打磨 |

> 注意：专家包必须存在于 `my-experts/plugins` 才能被 WorkBuddy 检测到。日常编辑一律改仓库文件，然后跑同步脚本，**不要直接改专家目录里的副本**——那是部署镜像，下次同步会被覆盖。

### 可直接粘贴的启动提示词

```
帮我创建一个专家团（Team 型），用于 [一句话场景]。
团队结构：1 个主理人 + N 个执行角色。
主理人只做调度、分发和质量门把关，不写正文。
执行角色之间不直接通信，所有交接经主理人中转。
先给我看角色分工和 SOP 草案，确认后再生成文件。
```

方括号里填赛道场景即可。建议先让它出草案再落文件，避免命名定错后返工。

---

## 三、开工前必须锁死的东西（已定）

以下标识符**建好之后不可修改**，改了等于重建专家包。**本项目已于 10/21 锁定，任何人不得变更**：

| 字段 | 值 | 说明 |
|---|---|---|
| 专家包目录名 | `cs-research-studio` | kebab-case |
| `plugin.json` 的 `name` | `cs-research-studio` | 与目录名一致 |
| `agentName` | `cs-research-studio-team-lead` | 等于主理人 MD 文件名（不含扩展名） |
| `expertType` | `team` | 团队协作 |
| `categoryId` | `02-Engineering` | 计算机大类科研，核心产出为实验与代码；若突出写作可议但不建议 |

团队角色（展示名 / 职能 / Agent ID = agents/ 下 MD 文件名）。**展示名 10/21 起改为职能直名，不再使用花名**：

| Agent ID | 展示名 | 职能 | 归口人 |
|---|---|---|---|
| cs-research-studio-team-lead | 科研总规划 | 科研总规划（主理人） | 队长 |
| literature-scout | 文献调研专家 | 文献调研专家 | 待认领 |
| experiment-designer | 实验设计专家 | 实验设计专家 | 待认领 |
| academic-writer | 学术写作专家 | 学术写作专家 | 待认领 |

> 违反命名规则的代价是整包返工。任何涉及上述字段的变更，必须先在群里同步、由队长确认，再动文件。

---

## 四、文件归属表（禁止越界修改）

`plugin.json` 只有一份，多人同时编辑必然冲突。因此实行**归口人制度**（本项目）：

| 文件/目录 | 归口人 | 其他人怎么做 |
|---|---|---|
| `cs-research-studio/.codebuddy-plugin/plugin.json` | 队长 | 只提需求，不直接改 |
| `agents/cs-research-studio-team-lead.md` | 队长 | 只提建议 |
| `agents/literature-scout.md` | 待认领 | 只改自己那份 |
| `agents/experiment-designer.md` | 待认领 | 只改自己那份 |
| `agents/academic-writer.md` | 待认领 | 只改自己那份 |
| `skills/<技能名>/`（后续新增） | 一人一目录 | 一人一目录 |
| `docs/`、展示页、录屏 | 待认领 | — |

**原则：按文件切分，不按"功能"切分。** 一个人可以认领多个文件，但一个文件只能有一个归口人。

---

## 五、每日操作流程

每个人在本地做任何修改，都必须走完这五步，缺一步就会出现"我改了但没生效"：

```bash
git pull                                   # 1. 先同步，避免基于旧版本改
# 2. 修改自己认领的文件（一律改仓库里的文件）
scripts\sync-expert.cmd cs-research-studio  # 3. 镜像到专家目录
python <expert-manager>/scripts/validate_expert.py "%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins\cs-research-studio"   # 4. 校验
python <expert-manager>/scripts/register_expert.py "%USERPROFILE%\.workbuddy\plugins\marketplaces\my-experts\plugins\cs-research-studio"   # 5. 注册（不跑专家中心看不到）
git add -A && git commit -m "feat: xxx" && git push   # 6. 提交
```

`expert-manager` 脚本路径：`<WorkBuddy 安装目录>\resources\app.asar.unpacked\resources\plugins\workbuddy-builtin\skills\expert-manager\scripts\`。本机完整路径太长，建议像 `check-env.cmd` 一样每人记一份；或将其复制到本仓库 `scripts\expert-manager\` 固定使用（推荐，版本随仓库走）。

---

## 六、环境准备（每台机器只做一次）

### 1. 同步仓库专家包到本机

```cmd
scripts\sync-expert.cmd cs-research-studio
```

脚本会把仓库中的 `cs-research-studio/` 镜像到 `my-experts/plugins/`（自动创建目录），之后跑校验与注册即可。

### 2. 自检

```cmd
scripts\check-env.cmd
```

检查 git、python、专家目录、同步状态、仓库根、remote 六项。

---

## 七、冲突处理

1. **`plugin.json` 冲突**：永远以队长版本为准，其他人 `git checkout --theirs` 放弃自己的改动，改走提需求。
2. **`agents/*.md` 冲突**：说明两人改了同一角色，属于违反归属表，直接回滚重做。
3. **头像/二进制文件冲突**：交给归口人重新生成，不做手工合并。
4. **推送前必须 `git pull --rebase`**，禁止强推 `main`。

---

## 八、交付物清单

比赛要求"作品以网页、个人工作台为最终成果，材料中体现可访问的智能体链接"，因此最终交付包含两件独立产物：

- [ ] **智能体本体**：`<expert-name>/` 专家包，通过校验与注册，在专家中心可召唤
- [ ] **可访问成果页**：对外可打开的工作台页面，含能力介绍、演示案例、入口链接
- [ ] **演示材料**：3 分钟以内的操作录屏
- [ ] **说明文档**：SOP、角色分工、技术方案
- [ ] **《作品提交规范》附件**：未随实施方案下发，**须向赛区索取**后逐项核对（完成度 20 分的材料要求在此附件）

> 官方成果形态要求：**作品以网页、个人工作台为最终成果**，材料中须提供**可访问的智能体链接**。四项缺一即影响完成度评分，链接务必在无痕窗口实测可打开。

评审标准与答辩准备见 [`docs/评分点对应.md`](./docs/评分点对应.md)。

---

## 九、排期

见 [`PLAN.md`](./PLAN.md)。
