#!/bin/bash

function MsgShow()
{
   if [ $# -lt 1 ] ; then
        echo "[-] 参数错误，退出脚本";
        exit 1;

    else
        case ${1} in
            PARMMISS)
                echo "[-] 请输入进程名"
                ;;
            NOPROSS)
                echo "[-] 没找到进程: [$2]!"
                ;;
            MULTIPROSS)
                echo "[-] 进程名存在多个进程: [$2]"
                ;;
            *)
                echo "[-] 未知错误"
                ;;
        esac
        exit 1;

    fi

}

function PidFind()
{
    PIDCOUNT=`ps -ef | grep $1 | grep -v "grep" | grep -v $0 | awk '{print $2}' | wc -l`;
    if [ ${PIDCOUNT} -gt 1 ] ; then
        MsgShow MULTIPROSS $1;
    elif [ ${PIDCOUNT} -le 0 ] ; then
        MsgShow NOPROSS $1;
    else
        PID=`ps -ef | grep $1 | grep -v "grep" | grep -v $0 | awk '{print $2}'` ;
        echo "[+] 找到相关进程: process:$1 PID:[${PID}] ";
    fi
    read -p "[*] 确定关闭此进程[y/n]: "
    if [ $REPLY = "y" ] || [ $REPLY = "yes" ] ; then
        echo "[*] 正在关闭此进程: $1 ...";
        kill -9  ${PID};
        echo "[+] kill -9 ${PID} done!";
    else
        echo "[*] 已退出!";
        exit 1
    fi
		echo ""
    #if we use return ,the return val must between 0 and 255
}


hasInterface(){
	if ifconfig|grep $1>/dev/null;then
		echo "[+] $1 网卡存在"
		else
		echo "[-] $1 网卡不存在"
		exit 1
	fi
}


echo "[*] 准备恢复路由配置..."
echo -n "[!] 请输入用来联网的接口(例如eth0): "
read eth_interface
hasInterface $eth_interface

echo -n "[!] 请输入用来创建钓鱼WIFI的网卡(例如wlan0): "
read wlan_interface
hasInterface $wlan_interface


echo "[*] 准备删除钓鱼AP添加的路由信息..."
# 删除路由表
route del -net 10.0.221.0 netmask 255.255.255.0
iptables -D  POSTROUTING -o $eth_interface -j MASQUERADE -t nat
iptables -D FORWARD -i $eth_interface -o $wlan_interface -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -D FORWARD -i $wlan_interface -o $eth_interface -j ACCEPT
echo 0 > /proc/sys/net/ipv4/ip_forward

printf "
┍---------------------------------------- 路由相关配置信息 ----------------------------------------┑

[*] 路由表:

`netstat -nr`

[*] iptables NAT链:

`iptables -L -n --line-number -t nat`

[*] iptables规则:

`iptables -L -n --line-number`

┕---------------------------------------- 路由相关配置信息 ----------------------------------------┙
"
echo ""

echo "[*] 准备重启网络管理服务..."
systemctl restart NetworkManager
systemctl restart wpa_supplicant

echo "[*] 准备关闭钓鱼热点相关进程..."
PidFind "php"
PidFind "dnsmasq"
PidFind "hostapd"

echo "[+] 钓鱼WIFI成功关闭"