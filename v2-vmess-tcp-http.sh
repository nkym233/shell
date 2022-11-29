#!/bin/bash
# 南柯一梦 WEJ.CC
bash <(curl -L https://git.wej.cc/https://github.com/nkym233/shell/blob/4dd3260f6d50814adb25edd912786114b54a272d/v2ray-install.sh) --version 4.34.0
sleep 1
wget -O /usr/local/etc/v2ray/config.json https://git.wej.cc/https://github.com/nkym233/shell/blob/27ec0e8c6f4f98763328cc8fc8d40a2beca2cb5c/config.json
sleep 1
read -p "Please enter the port请输入端口并回车：" uport
echo $uport
read -p "Please enter the uuid请输入自定义uuid并回车：" uuid
echo $uuid
sed -i "s/uuid/${uuid}/g" /usr/local/etc/v2ray/config.json
sed -i "s/uport/${uport}/g" /usr/local/etc/v2ray/config.json

cat /usr/local/etc/v2ray/config.json

systemctl enable v2ray && systemctl restart v2ray
echo "v2ray已安装并添加到自启"
sleep 1
echo "输入systemctl status v2ray，可查看状态"
