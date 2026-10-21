---
name: linux-env-setup
description: "Linux experiment environment setup: environment audit script, conda/CUDA/Docker configuration recipes, reproducible dependency pinning, and common troubleshooting for CS research workloads."
---

# Linux 实验环境配置

实验能不能复现，一半取决于代码，另一半取决于环境。本技能把环境配置从"凭记忆敲命令"变成"自检 → 配置 → 固化 → 验证"的闭环。

## 何时使用

- 新服务器/新机器上从零搭建实验环境（GPU 训练、推理、仿真）
- 复现一篇论文前，需要核对环境是否满足其要求
- 实验出现异常，怀疑是环境而非代码问题
- 需要向他人交付"能跑"的环境说明（README 级）

## 使用边界（人在回路）

- AI 负责：生成配置命令、解释报错、编写环境说明
- **人类必须执行与确认**：所有命令在真实机器上由人执行（AI 输出命令，人粘贴运行并回贴输出）；涉及 `sudo`、分区、驱动安装的操作必须人工确认；生产/共享服务器上的变更须征得管理员同意

## 标准流程

1. **环境自检**：在目标机器运行 `scripts/env-check.sh`，收集 OS/内核/GPU/驱动/CUDA/Python/磁盘/网络现状
2. **差距分析**：对照实验需求（框架版本、CUDA 版本、显存、依赖库），列出差距清单
3. **分层配置**：
   - 系统层：驱动、CUDA Toolkit（需要 sudo，给出命令但由人执行）
   - 环境层：conda/venv 虚拟环境（无 sudo，推荐方式）
   - 项目层：`pip install -r requirements.txt` 或 conda env file，**锁版本**
4. **冒烟验证**：跑最小验证（如 `python -c "import torch; print(torch.cuda.is_available())"`），确认关键链路通
5. **固化文档**：用 `templates/env-setup-report.md` 输出环境说明，随代码一起归档

## 核心原则

- **虚拟环境优先**：永远不在系统 Python 里直接装包；一个项目一个环境
- **版本锁定**：交付时必须有 `requirements.txt`（pip freeze）或 `environment.yml`（conda env export），版本精确到补丁号
- **CUDA 矩阵核对**：框架版本 ↔ CUDA 版本 ↔ 驱动版本有兼容矩阵，装之前查，不要装完再试
- **可回退**：改系统级配置前，记录原状态（如 `nvidia-smi` 输出、原驱动版本）

## 常用排障速查

| 症状 | 首选检查 |
|---|---|
| `torch.cuda.is_available()` 返回 False | 驱动（nvidia-smi）→ CUDA 版本匹配 → 是否装了 CPU 版框架 |
| `CUDA out of memory` | nvidia-smi 看显存占用；减小 batch；检查是否有僵尸进程占显存 |
| pip 装包超时/失败 | 换国内镜像源；检查代理；区分"编译失败"与"网络失败" |
| 服务器断连任务被杀 | 用 tmux/screen 或 nohup；见 `references/linux-commands.md` |
| 数据集下载慢 | 找镜像（hf-mirror、ModelScope、学校镜像站）；rsync/wget 断点续传 |

## 参考文件

- `references/linux-commands.md`：科研场景高频 Linux 命令速查（文件/进程/GPU/网络/会话管理）
- `templates/env-setup-report.md`：环境说明文档模板（交付物）
- `scripts/env-check.sh`：环境自检脚本（bash，直接在目标机器执行）
