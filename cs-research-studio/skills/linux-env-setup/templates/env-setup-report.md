# 实验环境说明

> 项目：______　配置人：______　日期：______
> 本文件随代码归档，目标是"换一台机器，照着做能复现"。

## 一、硬件

| 项 | 值 |
|---|---|
| CPU | |
| 内存 | |
| GPU 型号 × 数量 | |
| 单卡显存 | |
| 磁盘要求 | |

## 二、系统层（需 sudo，人工执行）

| 项 | 版本 | 安装方式/备注 |
|---|---|---|
| OS / 内核 | | |
| NVIDIA 驱动 | | |
| CUDA Toolkit | | |
| Docker（如用） | | |

## 三、环境层

```bash
# 复现命令（示例）
conda env create -f environment.yml
conda activate <env-name>
```

- 环境文件：`environment.yml` / `requirements.txt`（锁到补丁版本）
- Python 版本：

## 四、关键依赖与版本

| 包 | 版本 | 用途 |
|---|---|---|
| torch | | |
| transformers | | |
| 数据集 | {名称、版本、获取方式、校验和} | |

## 五、冒烟验证

```bash
# 配置完成后逐条执行，全部通过才算环境就绪
python -c "import torch; assert torch.cuda.is_available()"
python train.py --smoke-test   # 或等价的最小运行入口
```

验证结果：通过 / 未通过（附报错与解决记录）

## 六、已知坑位

| 现象 | 原因 | 解法 |
|---|---|---|
| | | |
