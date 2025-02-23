#!/bin/bash

# 设置日志文件
LOG_FILE="/var/log/dns_update.log"
echo "" > "$LOG_FILE"

# 域名列表
domains=(
    "icore-hczhd.pingan.com.cn"
    "mystore-gw.watsonsvip.com.cn"
    "api.m.jd.com"
    "m.flight.qunar.com"
    "map-bizcenter.baidu.com"
    "game.meituan.com"
    "sns.amap.com"
    "wx.waimai.meituan.com"
    "api.maoyan.com"
    "cube.meituan.com"
    "m.ctrip.com"
    "ihotel.meituan.com"
    "promotion.waimai.meituan.com"
    "vip.mini189.cn"
    "ip.ddnspod.com"
)

# 配置文件路径
HOSTS_FILE="/etc/hosts"
TEMP_FILE="/tmp/temp_hosts"

# 记录日志的函数
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 使用nslookup和ping查询IP的函数
get_ip_address() {
    local domain=$1
    local ip=""
    
    # 首先尝试使用nslookup
    if command -v nslookup &> /dev/null; then
        ip=$(nslookup "$domain" | awk '/^Address: / { print $2 }' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
    fi
    
    # 如果nslookup失败，使用ping作为备选方案
    if [ -z "$ip" ] && command -v ping &> /dev/null; then
        ip=$(ping -W 1 -c 1 "$domain" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)
    fi
    
    echo "$ip"
}

# 检查是否具有root权限
if [ "$EUID" -ne 0 ]; then
    log_message "错误：需要root权限来修改hosts文件"
    exit 1
fi

# 创建hosts文件备份
cp "$HOSTS_FILE" "${HOSTS_FILE}.backup"
log_message "已创建hosts文件备份：${HOSTS_FILE}.backup"

# 复制原始hosts文件到临时文件
cp "$HOSTS_FILE" "$TEMP_FILE"

# 遍历所有域名
for domain in "${domains[@]}"; do
    log_message "开始处理域名：$domain"
    
    # 删除已存在的记录
    if grep -q "$domain" "$HOSTS_FILE"; then
        log_message "发现已存在记录："
        grep "$domain" "$HOSTS_FILE" | tee -a "$LOG_FILE"
        sed -i "/\b$domain\b/d" "$TEMP_FILE"
        log_message "已删除旧记录"
    fi
    
    # 获取新IP地址
    ip=$(get_ip_address "$domain")
    
    # 检查IP地址是否获取成功
    if [ -n "$ip" ]; then
        log_message "获取到新IP地址：$ip"
        echo -e "$ip\t$domain" >> "$TEMP_FILE"
        log_message "已添加新记录：$ip -> $domain"
    else
        log_message "警告：无法获取 $domain 的IP地址"
    fi
done

# 更新hosts文件
cp "$TEMP_FILE" "$HOSTS_FILE"
log_message "已更新hosts文件"

# 清理临时文件
rm "$TEMP_FILE"
log_message "已清理临时文件"

# 显示更新后的hosts文件内容
log_message "更新后的hosts文件内容："
cat "$HOSTS_FILE" | tee -a "$LOG_FILE"

log_message "域名解析IP更新完成"
