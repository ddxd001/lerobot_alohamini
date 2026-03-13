#!/bin/bash
# LeRobot AlohaMini - Mac 端（遥控端）一键启动脚本
# 用于启动主臂遥操作程序

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  LeRobot AlohaMini - Mac 端启动${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}📁 工作目录: $SCRIPT_DIR${NC}"
echo ""

# 检测 Conda
if ! command -v conda &> /dev/null; then
    echo -e "${RED}❌ 错误: 未找到 conda 命令${NC}"
    echo -e "${YELLOW}请先安装 Anaconda/Miniconda${NC}"
    exit 1
fi

# 激活环境
echo -e "${YELLOW}🔄 激活环境: lerobot_alohamini${NC}"
source $(conda info --base)/etc/profile.d/conda.sh
conda activate lerobot_alohamini

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 错误: 无法激活环境 lerobot_alohamini${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 环境已激活${NC}"
echo ""

# 检查串口设备
echo -e "${YELLOW}🔌 检查主臂串口设备...${NC}"
LEFT_PORT="/dev/cu.usbmodem5AE60814681"
RIGHT_PORT="/dev/cu.usbmodem5AE60528341"

if [ ! -e "$LEFT_PORT" ] || [ ! -e "$RIGHT_PORT" ]; then
    echo -e "${RED}⚠️  警告: 主臂串口未完全找到${NC}"
    echo -e "${YELLOW}当前可用串口：${NC}"
    ls /dev/cu.usbmodem* 2>/dev/null || echo "  无 USB 串口设备"
    echo ""
    echo -e "${YELLOW}请检查：${NC}"
    echo "  1. 主臂是否已连接"
    echo "  2. 串口路径是否正确"
    echo "  3. 如需修改串口，编辑: examples/alohamini/teleoperate_bi.py (第 34-35 行)"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 检查网络连接
echo -e "${YELLOW}🌐 检查树莓派网络连接...${NC}"
REMOTE_IP="192.168.3.33"

if ping -c 1 -W 1 $REMOTE_IP &> /dev/null; then
    echo -e "${GREEN}✅ 树莓派在线 ($REMOTE_IP)${NC}"
else
    echo -e "${RED}⚠️  警告: 无法连接到树莓派 ($REMOTE_IP)${NC}"
    echo -e "${YELLOW}请确保：${NC}"
    echo "  1. 树莓派已开机"
    echo "  2. 网络连接正常"
    echo "  3. 树莓派端已启动 lekiwi_host 服务"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  启动遥操作程序${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}配置信息：${NC}"
echo "  - 远程 IP: $REMOTE_IP"
echo "  - 控制频率: 30 FPS"
echo "  - 左主臂: $LEFT_PORT"
echo "  - 右主臂: $RIGHT_PORT"
echo ""
echo -e "${YELLOW}⌨️  键盘控制：${NC}"
echo "  - W/S: 前进/后退"
echo "  - A/D: 左转/右转"
echo "  - Z/X: 左移/右移"
echo "  - U/J: 升降轴上升/下降"
echo "  - R/F: 加速/减速"
echo "  - Q: 退出"
echo ""
echo -e "${YELLOW}🎬 视频控制（新功能）：${NC}"
echo "  - 支持视频表情切换"
echo "  - 安全电流调整"
echo ""
echo -e "${YELLOW}按 Ctrl+C 停止程序${NC}"
echo ""

# 运行遥操作程序
python examples/alohamini/teleoperate_bi.py \
  --remote_ip $REMOTE_IP \
  --fps 30

# 程序结束
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✅ 遥操作程序已退出${NC}"
echo -e "${BLUE}================================================${NC}"
