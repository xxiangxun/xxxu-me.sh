#!/bin/bash

GITHUB_URL="https://raw.githubusercontent.com/xxiangxun/xxxu-me.sh/refs/heads/main/xxxu-me.sh"
SCRIPT_PATH="/usr/local/bin/xxxu-me.sh"
BLUE='\033[0;34m'
NC='\033[0m'

show_logo() {
    clear
    echo -e "${BLUE}"
    echo "  ____  ____  ____    _  _____ ____  "
    echo " |  _ \\|  _ \\|  _ \\  / \\|_   _/ ___| "
    echo " | |_) | | | | |_) |/ _ \\ | | \\___ \\ "
    echo " |  __/| |_| |  _ < / ___ \\| |  ___) |"
    echo " |_|   |____/|_| \\_/_/   \\_\\_| |____/ "
    echo "                                      "
    echo -e "${NC}"
}

show_menu() {
    echo "========================================"
    echo "           xxxu Linux 工具箱            "
    echo "========================================"
    echo ""
    echo "  1. 查看系统信息"
    echo "  2. 系统更新升级"
    echo "  3. 系统清理（释放空间）"
    echo "  4. Docker管理"
    echo "  5. SSH安全管理"
    echo "  6. 防火墙管理"
    echo "  7. 一键安装常用工具"
    echo "  8. 重启/关机/注销"
    echo "  9. 更新本脚本"
    echo "  0. 卸载本脚本"
    echo ""
    echo "========================================"
}

register_alias() {
    if ! grep -q "alias x=" /etc/profile 2>/dev/null; then
        echo "alias x='/usr/local/bin/xxxu-me.sh'" >> /etc/profile
        source /etc/profile 2>/dev/null
    fi
}

sys_info() {
    echo "========================================"
    echo "           系统信息                     "
    echo "========================================"
    echo "主机名: $(hostname)"
    echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
    echo "内核版本: $(uname -r)"
    echo "CPU型号: $(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
    echo "内存总量: $(free -h | grep Mem | awk '{print $2}')"
    echo "内存使用: $(free -h | grep Mem | awk '{print $3}')"
    echo "磁盘使用: $(df -h / | tail -1 | awk '{print $3 "/" $2}')"
    echo "系统运行时间: $(uptime -p 2>/dev/null || uptime)"
    echo "当前用户: $(whoami)"
    echo "========================================"
    read -p "按回车键返回..." key
}

sys_update() {
    echo "========================================"
    echo "        系统更新升级中...              "
    echo "========================================"
    if command -v apt-get &>/dev/null; then
        apt-get update && apt-get upgrade -y
    elif command -v yum &>/dev/null; then
        yum update -y
    elif command -v dnf &>/dev/null; then
        dnf update -y
    elif command -v pacman &>/dev/null; then
        pacman -Syu --noconfirm
    else
        echo "未检测到支持的包管理器"
    fi
    echo "========================================"
    read -p "按回车键返回..." key
}

sys_clean() {
    echo "========================================"
    echo "        系统清理中...                  "
    echo "========================================"
    if command -v apt-get &>/dev/null; then
        apt-get autoremove -y
        apt-get autoclean
        apt-get clean
    fi
    if command -v yum &>/dev/null; then
        yum clean all
    fi
    if command -v dnf &>/dev/null; then
        dnf clean all
    fi
    if [ -d /tmp ]; then
        find /tmp -type f -atime +7 -delete 2>/dev/null
    fi
    if [ -d /var/tmp ]; then
        find /var/tmp -type f -atime +7 -delete 2>/dev/null
    fi
    echo "清理完成!"
    echo "========================================"
    read -p "按回车键返回..." key
}

docker_menu() {
    while true; do
        echo "========================================"
        echo "           Docker 管理                 "
        echo "========================================"
        echo "  1. 查看Docker状态"
        echo "  2. 启动Docker"
        echo "  3. 停止Docker"
        echo "  4. 查看容器列表"
        echo "  5. 查看镜像列表"
        echo "  6. 查看Docker占用空间"
        echo "  0. 返回主菜单"
        echo "========================================"
        read -p "请选择: " choice
        case $choice in
            1) systemctl status docker 2>/dev/null || service docker status ;;
            2) systemctl start docker 2>/dev/null || service docker start ;;
            3) systemctl stop docker 2>/dev/null || service docker stop ;;
            4) docker ps -a ;;
            5) docker images ;;
            6) docker system df ;;
            0) break ;;
        esac
    done
}

ssh_menu() {
    while true; do
        echo "========================================"
        echo "         SSH 安全管理                   "
        echo "========================================"
        echo "  1. 查看SSH服务状态"
        echo "  2. 查看SSH配置文件"
        echo "  3. 查看SSH监听端口"
        echo "  4. 查看最近SSH登录记录"
        echo "  0. 返回主菜单"
        echo "========================================"
        read -p "请选择: " choice
        case $choice in
            1) systemctl status sshd 2>/dev/null || service sshd status ;;
            2) [ -f /etc/ssh/sshd_config ] && cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$" ;;
            3) netstat -tlnp 2>/dev/null | grep ssh || ss -tlnp | grep ssh ;;
            4) last -20 ;;
            0) break ;;
        esac
    done
}

firewall_menu() {
    while true; do
        echo "========================================"
        echo "         防火墙管理                     "
        echo "========================================"
        echo "  1. 查看防火墙状态"
        echo "  2. 查看已开放端口"
        echo "  3. 开放端口"
        echo "  4. 关闭端口"
        echo "  0. 返回主菜单"
        echo "========================================"
        read -p "请选择: " choice
        case $choice in
            1)
                if command -v ufw &>/dev/null; then
                    ufw status
                elif command -v firewall-cmd &>/dev/null; then
                    firewall-cmd --state
                else
                    echo "未检测到防火墙工具"
                fi
                ;;
            2)
                if command -v ufw &>/dev/null; then
                    ufw status numbered
                elif command -v firewall-cmd &>/dev/null; then
                    firewall-cmd --list-all
                fi
                ;;
            3)
                read -p "请输入端口号: " port
                if command -v ufw &>/dev/null; then
                    ufw allow $port/tcp
                elif command -v firewall-cmd &>/dev/null; then
                    firewall-cmd --add-port=$port/tcp --permanent
                    firewall-cmd --reload
                fi
                ;;
            4)
                read -p "请输入端口号: " port
                if command -v ufw &>/dev/null; then
                    ufw delete allow $port/tcp
                elif command -v firewall-cmd &>/dev/null; then
                    firewall-cmd --remove-port=$port/tcp --permanent
                    firewall-cmd --reload
                fi
                ;;
            0) break ;;
        esac
    done
}

install_tools() {
    echo "========================================"
    echo "        一键安装常用工具...            "
    echo "========================================"
    TOOLS="curl wget git vim htop net-tools unzip tar"
    if command -v apt-get &>/dev/null; then
        apt-get update && apt-get install -y $TOOLS
    elif command -v yum &>/dev/null; then
        yum install -y $TOOLS
    elif command -v dnf &>/dev/null; then
        dnf install -y $TOOLS
    elif command -v pacman &>/dev/null; then
        pacman -S --noconfirm $TOOLS
    fi
    echo "========================================"
    read -p "按回车键返回..." key
}

power_menu() {
    while true; do
        echo "========================================"
        echo "         重启/关机/注销                 "
        echo "========================================"
        echo "  1. 立即重启"
        echo "  2. 立即关机"
        echo "  3. 注销当前会话"
        echo "  0. 返回主菜单"
        echo "========================================"
        read -p "请选择: " choice
        case $choice in
            1) read -p "确认重启? (y/n): " confirm; [ "$confirm" = "y" ] && reboot ;;
            2) read -p "确认关机? (y/n): " confirm; [ "$confirm" = "y" ] && poweroff ;;
            3) logout ;;
            0) break ;;
        esac
    done
}

update_script() {
    echo "========================================"
    echo "        正在更新脚本...                 "
    echo "========================================"
    if curl -fsSL "$GITHUB_URL" -o "$SCRIPT_PATH"; then
        chmod +x "$SCRIPT_PATH"
        echo "更新成功!"
    else
        echo "更新失败，请检查网络连接"
    fi
    echo "========================================"
    read -p "按回车键返回..." key
}

uninstall_script() {
    echo "========================================"
    echo "        正在卸载脚本...                 "
    echo "========================================"
    read -p "确认卸载? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        [ -f "$SCRIPT_PATH" ] && rm -f "$SCRIPT_PATH"
        sed -i '/alias x=/d' /etc/profile 2>/dev/null
        source /etc/profile 2>/dev/null
        echo "卸载完成!"
    fi
    echo "========================================"
    read -p "按回车键返回..." key
}

main() {
    if [ "$1" != "--installed" ]; then
        register_alias
        cp "$0" "$SCRIPT_PATH" 2>/dev/null
        chmod +x "$SCRIPT_PATH"
    fi

    while true; do
        show_logo
        show_menu
        read -p "请选择操作 [0-9]: " choice
        case $choice in
            1) sys_info ;;
            2) sys_update ;;
            3) sys_clean ;;
            4) docker_menu ;;
            5) ssh_menu ;;
            6) firewall_menu ;;
            7) install_tools ;;
            8) power_menu ;;
            9) update_script ;;
            0) uninstall_script ;;
            *) echo "无效选择，请重新选择" ;;
        esac
    done
}

main "$@"
