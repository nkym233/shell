#!/bin/bash
#南柯一梦 WEJ.CC & YAOHUO.ME
echo -e "\033[34m 一键安装青龙脚本-2.10.13 \033[0m"
read -p "请输入自定义的路径(默认/mnt/mmcblk2p4)： " path
if [ -z "${path}" ];then
  path=/mnt/mmcblk2p4
fi
echo "安装路径:  $path"
read -p "请输入自定义青龙端口并回车(默认5700)：" uport
if [ -z "${uport}" ];then
  uport=5700
fi
echo "已设置青龙端口：$uport"
sleep 1s
docker run -dit \
  -v $path/ql/config:/ql/config \
  -v $path/ql/log:/ql/log \
  -v $path/ql/db:/ql/db \
  -v $path/ql/repo:/ql/repo \
  -v $path/ql/raw:/ql/raw \
  -v $path/ql/scripts:/ql/scripts \
  -v $path/ql/jbot:/ql/jbot \
  -v $path/ql/ninja:/ql/ninja \
  -p $uport:5700 \
  -p 5701:5701 \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  whyour/qinglong:2.10.13
echo "正在导入常用依赖文件"
wget --no-check-certificate -O $path/ql/db/dependence.db https://git.wej.cc/https://raw.githubusercontent.com/nkym233/shell/main/ql/dependence.db
echo "升级pip版本"
docker exec qinglong /bin/bash -c "pip3 install --upgrade pip"
echo -e "\033[34m 安装完成 \033[0m"
echo -e "\033[34m 青龙安装路径 $path/ 
 浏览器访问IP地址:$uport
\033[0m"
