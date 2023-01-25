#!/bin/bash
#南柯一梦 WEJ.CC & YAOHUO.ME
echo "N1搭建青龙脚本-2.10.13"
read -p "Please enter the port请输入自定义青龙端口并回车：" uport
echo "已设置青龙端口为：$uport"
docker run -dit \
  -v /mnt/mmcblk2p4/ql/config:/ql/config \
  -v /mnt/mmcblk2p4/ql/log:/ql/log \
  -v /mnt/mmcblk2p4/ql/db:/ql/db \
  -v /mnt/mmcblk2p4/ql/repo:/ql/repo \
  -v /mnt/mmcblk2p4/ql/raw:/ql/raw \
  -v /mnt/mmcblk2p4/ql/scripts:/ql/scripts \
  -v /mnt/mmcblk2p4/ql/jbot:/ql/jbot \
  -v /mnt/mmcblk2p4/ql/ninja:/ql/ninja \
  -p $uport:5700 \
  -p 5701:5701 \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  whyour/qinglong:2.10.13
echo "正在导入常用依赖文件"
wget --no-check-certificate -O /mnt/mmcblk2p4/ql/db/dependence.db https://git.wej.cc/https://raw.githubusercontent.com/nkym233/shell/main/ql/dependence.db
echo "升级pip版本"
docker exec qinglong /bin/bash -c "pip3 install --upgrade pip"
echo -e "\033[34m 安装完成 \033[0m"
echo -e "\033[34m 青龙默认安装路径 /mnt/mmcblk2p4/ql/ 
 浏览器访问N1地址:$uport
\033[0m"
