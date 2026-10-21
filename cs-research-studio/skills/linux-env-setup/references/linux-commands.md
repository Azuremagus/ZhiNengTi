# 科研场景 Linux 命令速查

## 一、会话与后台任务（防断连）

```bash
# tmux（推荐）
tmux new -s train          # 新建会话
# Ctrl+B 然后按 D          # 脱离会话（任务继续跑）
tmux ls                    # 列出会话
tmux attach -t train       # 重连
tmux kill-session -t train # 结束会话

# nohup（轻量替代）
nohup python train.py > train.log 2>&1 &
echo $! > train.pid        # 记下 PID
tail -f train.log          # 实时看日志
```

## 二、GPU 监控

```bash
nvidia-smi                                   # 快照
watch -n 2 nvidia-smi                        # 每 2 秒刷新
nvidia-smi --query-compute-apps=pid,used_memory --format=csv  # 谁占了显存
kill -9 <PID>                                # 杀掉僵尸训练进程（先确认是自己的）
```

## 三、进程管理

```bash
ps aux | grep python                         # 找进程
top / htop                                   # 实时占用（htop 更直观）
kill <PID>                                   # 优雅终止
kill -9 <PID>                                # 强制终止（最后手段）
```

## 四、文件与磁盘

```bash
df -h                                        # 分区余量
du -sh */                                    # 各目录占用（找谁吃光了磁盘）
ls -lhS | head                               # 最大的文件
find . -name "*.ckpt" -mtime +7              # 找 7 天前的 checkpoint（清理候选）
rsync -avP src/ dst/                         # 同步目录，断点续传
scp user@host:/path/file .                   # 从服务器拉文件
```

## 五、环境管理

```bash
# conda
conda create -n myproj python=3.11 -y
conda activate myproj
conda env export > environment.yml           # 固化环境
conda env create -f environment.yml          # 复现环境

# venv + pip（无 conda 时）
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pip freeze > requirements.txt                # 锁版本

# 国内镜像加速（临时）
pip install torch -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## 六、CUDA 版本核对

```bash
nvidia-smi                                   # 看驱动支持的最高 CUDA（右上角）
nvcc --version                               # 已装 toolkit 版本
python -c "import torch; print(torch.version.cuda, torch.cuda.is_available())"
# 三者关系：驱动支持上限 >= toolkit 版本；torch 自带 cuda runtime，只需与驱动兼容
```

## 七、网络与数据下载

```bash
wget -c <url>                                # 断点续传
curl -O <url>                                # 下载
ping -c 4 mirror.example.com                 # 连通性
export HF_ENDPOINT=https://hf-mirror.com     # HuggingFace 国内镜像
```

## 八、权限红线（需要人工确认的操作）

- `sudo` 开头的所有命令（驱动安装、系统包、防火墙）
- `rm -rf` 尤其是带通配符的
- 对共享服务器：改环境变量、占满 GPU、大规模下载前，先打招呼
- 修改 `/etc/` 下任何配置
