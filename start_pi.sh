#!/bin/bash
# LeRobot AlohaMini - 树莓派端（从臂端）一键启动脚本
# 用于启动从臂控制服务

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  LeRobot AlohaMini - 树莓派端启动${NC}"
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
    echo -e "${YELLOW}请先安装 Miniconda${NC}"
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
echo -e "${YELLOW}🔌 检查从臂串口设备...${NC}"
if ls /dev/ttyACM* 1> /dev/null 2>&1; then
    echo -e "${GREEN}✅ 找到串口设备：${NC}"
    ls /dev/ttyACM*
else
    echo -e "${RED}⚠️  警告: 未找到串口设备 (/dev/ttyACM*)${NC}"
    echo -e "${YELLOW}请检查：${NC}"
    echo "  1. 从臂是否已连接"
    echo "  2. 从臂是否已上电"
    echo "  3. USB 线是否连接正常"
    echo ""
    read -p "是否继续？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  启动从臂控制服务${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}配置信息：${NC}"
echo "  - 机械臂类型: so-arm-5dof"
echo "  - 监听端口: 5555 (命令), 5556 (观测)"
echo "  - 控制频率: 30 Hz"
echo "  - 看门狗超时: 1500 ms"
echo ""
echo -e "${YELLOW}⚠️  注意事项：${NC}"
echo "  1. 确保从臂已上电"
echo "  2. 确保串口连接正常"
echo "  3. 等待 Mac 端连接后开始遥操作"
echo ""
echo -e "${YELLOW}按 Ctrl+C 停止服务${NC}"
echo ""

# 运行从臂服务
python -m lerobot.robots.alohamini.lekiwi_host \
  --arm_profile so-arm-5dof

# 程序结束
echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✅ 从臂服务已退出${NC}"
echo -e "${BLUE}================================================${NC}"
