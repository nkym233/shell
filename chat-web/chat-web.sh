#!/bin/bash

SCRIPT_NAME=$(basename "$0")
NGINX_ROOT="/root/nginx"
INDEX_HTML_URL="https://raw.githubusercontent.com/xqdoo00o/chatgpt-web/main/index.html"
DEFAULT_CONF_URL="https://raw.githubusercontent.com/nkym233/shell/main/chat-web/default.conf"
OPENAI_API_END_POINT="https://api.swesa.cn/v1/chat/completions"

help() {
  echo "Usage: ./${SCRIPT_NAME} [OPTIONS]"
  echo "Deploys a Nginx web server on Docker container"
  echo ""
  echo "Options:"
  echo "  -p, --port PORT   specify the port number (default: 8080)"
  echo "  -h, --help        print this help message"
}

retrieve_ip_address() {
  ip addr | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -f1 -d'/' | head -1
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -p|--port) port="$2"; shift ;;
    -h|--help) help; exit 0 ;;
    *) echo "Unknown parameter passed: $1"; help; exit 1 ;;
  esac
  shift
done

# Prompt user to enter port number
if [ -z "$port" ]; then
  read -p "请输入你需要使用的端口 (默认: 8080): " port
fi

# Install Nginx
mkdir -p "$NGINX_ROOT"
wget -O "${NGINX_ROOT}/index.html" "$INDEX_HTML_URL"
wget -O "${NGINX_ROOT}/default.conf" "$DEFAULT_CONF_URL"
sed -i "s|v1/chat/completions|$OPENAI_API_END_POINT|g" "${NGINX_ROOT}/index.html"

# Run Nginx in Docker container
docker run -d \
  -p ${port:-8080}:80 \
  --restart=always \
  --name nginx \
  nginx:latest

# Check if Nginx container is running
if [ "$(docker container ls -f "name=nginx" -q)" ]; then
  echo "Nginx has been installed successfully!"
  
  # Replace default.conf and index.html files in container
  docker cp "${NGINX_ROOT}/default.conf" nginx:/etc/nginx/conf.d/default.conf
  docker cp "${NGINX_ROOT}/index.html" nginx:/usr/share/nginx/html/index.html
  
  ip=$(retrieve_ip_address)
  echo "请打开浏览器访问 http://${ip}:${port:-8080} ."
  echo "如果是在服务器搭建则访问公网ip:端口"
else
  echo "Failed to install Nginx. Please check the Docker installation and try again."
fi
