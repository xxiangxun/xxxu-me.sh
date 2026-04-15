#!/bin/bash

# ==================== 永久修复快捷键 x ====================
SCRIPT_PATH="/usr/local/bin/xxxu-me"
if [ ! -f "$SCRIPT_PATH" ]; then
  cp "$0" "$SCRIPT_PATH"
  chmod +x "$SCRIPT_PATH"
fi

if ! grep -q "alias x='xxxu-me'" /etc/profile; then
  echo "alias x='xxxu-me'" >> /etc/profile
  source /etc/profile
  echo -e "\033[32m[+] 快捷命令 x 已永久注册！\033[0m"
  sleep 1
fi

clear

# ==================== 你的LOGO：xxxu ====================
echo -e "\033[36m
┌─────────────────────────────────────────────┐
│                                     _       │
│                                    | |      │
│   __  ___   __  ____ _   ___ _   _| |__    │
│  \ \/ / | | | |/ / _` | / __| | | | '_ \   │
│   >  <| |_| |   < (_| | \__ \ |_| | |_) |  │
│  /_/\_\\__,_|_|\_\__,_| |___/\__,_|_.__/   │
│                                             │
│                  xxxu 超级工具箱              │
└─────────────────────────────────────────────┘
\033[0m"

# ==================== 主菜单 ====================
main_menu() {
while true; do
echo -e "\033[33m┌── 功能菜单 ────────────────────────────────┐\033[0m"
echo -e "\033[32m 1. 查看系统信息 \033[0m"
echo -e "\033[32m 2. 系统更新升级 \033[0m"
echo -e "\033[32m 3. 系统清理（释放空间） \033[0m"
echo -e "\033[32m 4. Docker 完整管理 \033[0m"
echo -e "\033[32m 5. SSH 安全管理 \033[0m"
echo -e "\033[32m 6. 防火墙管理 \033[0m"
echo -e "\033[32m 7. 一键安装常用工具 \033[0m"
echo -e "\033[32m 8. 重启/关机/注销 \033[0m"
echo -e "\033[32m 9. 更新本脚本 \033[0m"
echo -e "\033[32m 0. 卸载本脚本 \033[0m"
echo -e "\033[33m└────────────────────────────────────────────┘\033[0m"

read -p " 请输入选项 [0-9]：" num

case $num in
1) show_info ;;
2) sys_update ;;
3) sys_clean ;;
4) docker_menu ;;
5) ssh_menu ;;
6) firewall_menu ;;
7) install_tools ;;
8) power_menu ;;
9) update_script ;;
0) uninstall_script ;;
*) echo -e "\033[31m 输入错误！\033[0m"; sleep 1 ;;
esac
done
}

# ================== 脚本更新 ==================
update_script() {
clear
echo -e "\033[33m=== 从 GitHub 更新脚本 ===\033[0m"
GITHUB_URL="https://raw.githubusercontent.com/xxiangxun/xxxu-me.sh/refs/heads/main/xxxu-me.sh"
curl -sL $GITHUB_URL -o /usr/local/bin/xxxu-me
chmod +x /usr/local/bin/xxxu-me
echo -e "\033[32m[√] 更新完成！输入 x 重新启动\033[0m"
exit 0
}

# ================== 卸载脚本 ==================
uninstall_script() {
clear
echo -e "\033[31m⚠ 确定要卸载 xxxu 工具箱吗？\033[0m"
read -p "输入 y 确认卸载：" c
if [ "$c" = "y" ]; then
  sed -i '/alias x/d' /etc/profile
  rm -f /usr/local/bin/xxxu-me
  echo -e "\033[32m[√] 已完全卸载\033[0m"
  exit 0
fi
}

show_info() {
clear
echo -e "\033[33m=== 系统信息 ===\033[0m"
echo "主机名：$(hostname)"
echo "系统：$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "CPU：$(grep -c 'processor' /proc/cpuinfo) 核"
echo "内存：$(free -h | awk '/Mem/{print $3"/"$2}')"
echo "硬盘：$(df -h / | awk '/\//{print $3"/"$2" ("$5")"}')"
echo "IP：$(curl -s ipinfo.io/ip 2>/dev/null)"
read -p "按回车返回..."
}

sys_update() {
clear
echo -e "\033[33m=== 系统更新中... ===\033[0m"
apt update -y && apt upgrade -y
echo -e "\033[32m完成！\033[0m"
read -p "按回车返回..."
}

sys_clean() {
clear
echo -e "\033[33m=== 清理磁盘... ===\033[0m"
apt autoremove -y
apt clean
journalctl --vacuum-size=100M
rm -rf /tmp/* /var/tmp/*
echo -e "\033[32m完成！\033[0m"
read -p "按回车返回..."
}

docker_menu() {
clear
echo -e "\033[33m=== Docker 管理 ===\033[0m"
echo "1. 查看容器  2. 重启所有  3. 日志  4. 清理镜像"
read -p "选择：" d
if [ "$d" = 1 ]; then docker ps -a; fi
if [ "$d" = 2 ]; then docker restart $(docker ps -q 2>/dev/null); fi
if [ "$d" = 3 ]; then read -p "容器名：" n; docker logs -f $n; fi
if [ "$d" = 4 ]; then docker system prune -a -f; fi
read -p "按回车返回..."
}

ssh_menu() {
clear
echo -e "\033[33m=== SSH 管理 ===\033[0m"
echo "1. 修改端口  2. 禁用密码  3. 重启 SSH"
read -p "选择：" s
if [ "$s" = 1 ]; then read -p "端口：" p; sed -i "s/^#Port 22/Port $p/" /etc/ssh/sshd_config; systemctl restart sshd; fi
if [ "$s" = 2 ]; then sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config; systemctl restart sshd; fi
if [ "$s" = 3 ]; then systemctl restart sshd; fi
read -p "按回车返回..."
}

firewall_menu() {
clear
echo -e "\033[33m=== 防火墙 ===\033[0m"
echo "1. 放行端口  2. 状态  3. 关闭防火墙"
read -p "选择：" f
if [ "$f" = 1 ]; then read -p "端口：" pt; ufw allow $pt; fi
if [ "$f" = 2 ]; then ufw status; fi
if [ "$f" = 3 ]; then ufw disable; fi
read -p "按回车返回..."
}

install_tools() {
apt install -y curl wget htop git vim unzip zip sudo
echo -e "\033[32m完成！\033[0m"
read -p "按回车返回..."
}

power_menu() {
clear
echo "1. 重启  2. 关机  3. 注销"
read -p "选择：" p
if [ "$p" = 1 ]; then reboot; fi
if [ "$p" = 2 ]; then poweroff; fi
if [ "$p" = 3 ]; then exit; fi
}

main_menu
