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
}

docker_status() {
    echo "========================================"
    echo "           Docker 状态                  "
    echo "========================================"
    systemctl status docker 2>/dev/null || service docker status
    echo "========================================"
}

docker_start() {
    echo "========================================"
    echo "           启动 Docker                 "
    echo "========================================"
    systemctl start docker 2>/dev/null || service docker start
    echo "Docker 已启动"
    echo "========================================"
}

docker_stop() {
    echo "========================================"
    echo "           停止 Docker                 "
    echo "========================================"
    systemctl stop docker 2>/dev/null || service docker stop
    echo "Docker 已停止"
    echo "========================================"
}

docker_ps() {
    echo "========================================"
    echo "           容器列表                     "
    echo "========================================"
    docker ps -a
    echo "========================================"
}

docker_images() {
    echo "========================================"
    echo "           镜像列表                     "
    echo "========================================"
    docker images
    echo "========================================"
}

docker_df() {
    echo "========================================"
    echo "           Docker 空间                  "
    echo "========================================"
    docker system df
    echo "========================================"
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
            1) docker_status ;;
            2) docker_start ;;
            3) docker_stop ;;
            4) docker_ps ;;
            5) docker_images ;;
            6) docker_df ;;
            0) break ;;
        esac
    done
}

ssh_status() {
    echo "========================================"
    echo "           SSH 服务状态                 "
    echo "========================================"
    systemctl status sshd 2>/dev/null || service sshd status
    echo "========================================"
}

ssh_config() {
    echo "========================================"
    echo "           SSH 配置                     "
    echo "========================================"
    if [ -f /etc/ssh/sshd_config ]; then
        cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
    fi
    echo "========================================"
}

ssh_port() {
    echo "========================================"
    echo "           SSH 监听端口                 "
    echo "========================================"
    netstat -tlnp 2>/dev/null | grep ssh || ss -tlnp | grep ssh
    echo "========================================"
}

ssh_log() {
    echo "========================================"
    echo "           SSH 登录记录                 "
    echo "========================================"
    last -20
    echo "========================================"
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
            1) ssh_status ;;
            2) ssh_config ;;
            3) ssh_port ;;
            4) ssh_log ;;
            0) break ;;
        esac
    done
}

firewall_status() {
    echo "========================================"
    echo "           防火墙状态                   "
    echo "========================================"
    if command -v ufw &>/dev/null; then
        ufw status
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --state
    else
        echo "未检测到防火墙工具"
    fi
    echo "========================================"
}

firewall_list() {
    echo "========================================"
    echo "           已开放端口                   "
    echo "========================================"
    if command -v ufw &>/dev/null; then
        ufw status numbered
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --list-all
    fi
    echo "========================================"
}

firewall_open() {
    read -p "请输入端口号: " port
    echo "========================================"
    echo "           开放端口 $port               "
    echo "========================================"
    if command -v ufw &>/dev/null; then
        ufw allow $port/tcp
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --add-port=$port/tcp --permanent
        firewall-cmd --reload
    fi
    echo "========================================"
}

firewall_close() {
    read -p "请输入端口号: " port
    echo "========================================"
    echo "           关闭端口 $port               "
    echo "========================================"
    if command -v ufw &>/dev/null; then
        ufw delete allow $port/tcp
    elif command -v firewall-cmd &>/dev/null; then
        firewall-cmd --remove-port=$port/tcp --permanent
        firewall-cmd --reload
    fi
    echo "========================================"
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
            1) firewall_status ;;
            2) firewall_list ;;
            3) firewall_open ;;
            4) firewall_close ;;
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
}

reboot_sys() {
    echo "========================================"
    echo "           立即重启                    "
    echo "========================================"
    read -p "确认重启? (y/n): " confirm
    [ "$confirm" = "y" ] && reboot
}

poweroff_sys() {
    echo "========================================"
    echo "           立即关机                    "
    echo "========================================"
    read -p "确认关机? (y/n): " confirm
    [ "$confirm" = "y" ] && poweroff
}

logout_sys() {
    echo "========================================"
    echo "           注销会话                    "
    echo "========================================"
    logout
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
            1) reboot_sys ;;
            2) poweroff_sys ;;
            3) logout_sys ;;
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
}

run_direct() {
    case "$1" in
        1|sysinfo)          sys_info ;;
        2|update)           sys_update ;;
        3|clean)             sys_clean ;;
        4|docker)            docker_menu ;;
        docker\ install)     docker_start ;;
        docker\ status)      docker_status ;;
        docker\ stop)        docker_stop ;;
        docker\ ps)           docker_ps ;;
        docker\ images)       docker_images ;;
        docker\ df)          docker_df ;;
        5|ssh)               ssh_menu ;;
        ssh\ status)         ssh_status ;;
        ssh\ config)         ssh_config ;;
        ssh\ port)           ssh_port ;;
        ssh\ log)            ssh_log ;;
        6|firewall)          firewall_menu ;;
        firewall\ status)    firewall_status ;;
        firewall\ list)      firewall_list ;;
        firewall\ open)      firewall_open ;;
        firewall\ close)     firewall_close ;;
        7|tools)             install_tools ;;
        8|power)             power_menu ;;
        reboot)              reboot_sys ;;
        poweroff)           poweroff_sys ;;
        logout)              logout_sys ;;
        9|update-script)     update_script ;;
        0|uninstall)         uninstall_script ;;
        *)                   echo "未知命令: $1" ;;
    esac
}

main() {
    if [ -z "$1" ]; then
        if [ "$2" != "--installed" ]; then
            register_alias
            cp "$0" "$SCRIPT_PATH" 2>/dev/null
            chmod +x "$SCRIPT_PATH"
        fi
        while true; do
            show_logo
            show_menu
            read -p "请选择操作 [0-9]: " choice
            run_direct "$choice"
        done
    else
        run_direct "$1" "$2"
    fi
}

main "$@"
