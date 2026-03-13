#!/bin/bash

# 自动化运行脚本 - LeKiwi Host
# 功能：激活conda环境并启动lekiwi_host，自动播放视频

echo "========================================="
echo "Starting LeKiwi Host with Video Playback"
echo "========================================="

# 获取conda路径
CONDA_BASE=$(conda info --base 2>/dev/null)
if [ -z "$CONDA_BASE" ]; then
    echo "Error: Conda not found. Please install Miniconda or Anaconda."
    exit 1
fi

# 激活conda
source "$CONDA_BASE/etc/profile.d/conda.sh"

# 激活lerobot_alohamini环境
echo "Activating conda environment: lerobot_alohamini"
conda activate lerobot_alohamini

if [ $? -ne 0 ]; then
    echo "Error: Failed to activate conda environment 'lerobot_alohamini'"
    echo "Please create the environment first or check the environment name."
    exit 1
fi

echo "Environment activated successfully"
echo "Current Python: $(which python)"
echo "Current environment: $CONDA_DEFAULT_ENV"
echo ""

# 切换到项目目录
cd /home/ubuntu/lerobot_alohamini

# 设置显示环境变量（用于视频播放）
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
    echo "Setting DISPLAY=:0 for video playback"
fi

# 检查视频文件是否存在
if [ ! -f "face_video/v1.mp4" ]; then
    echo "Warning: Video file not found at face_video/v1.mp4"
    echo "Video playback may not work properly."
else
    echo "Video file found: face_video/v1.mp4"
fi

# 允许X11访问（如果需要）
xhost +local: 2>/dev/null || echo "Note: xhost not available, continuing anyway"

# 运行程序
echo "Starting lekiwi_host..."
echo "Video will play in fullscreen on DISPLAY=$DISPLAY"
echo "Press Ctrl+C to stop"
echo ""

python -m lerobot.robots.alohamini.lekiwi_host

# 捕获退出状态
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "========================================="
    echo "Program exited with error code: $EXIT_CODE"
    echo "========================================="
else
    echo ""
    echo "========================================="
    echo "Program finished successfully"
    echo "========================================="
fi

exit $EXIT_CODE
