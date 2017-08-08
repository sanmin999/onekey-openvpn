#!/bin/sh
#烟雨笑
url="http://code.taobao.org/svn/OpenwrtVpn/";
ip=`wget http://ipecho.net/plain -O - -q ; echo`;
openvpnroute="/etc/init.d/openvpn";
clear
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+       Install OpenVPN for OpnWrt or Pandora box        +"
echo "+                                                        +"
echo "+             Author: Virus <86248425.@qq.com>           +"
echo "+                                                        +"
echo "+                     Time 2016.08.09                    +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo -e "\e[1;36m >         1. 安装 \e[0m"
echo
echo -e "\e[1;31m >         2. 卸载 \e[0m"
echo
echo -e -n "\e[1;34m请输入数字继续执行: \e[0m" 
read menu
if [ "$menu" == "1" ]; then
echo
echo -e "\e[1;36m三秒后开始安装......\e[0m"
echo
sleep 3
echo -e "\e[1;36m正在更新软件包,根据网络状态决定时长\e[0m"
rm -f /var/lock/opkg.lock
opkg update
sleep 2
echo
echo -e "\e[1;36m开始安装OpenVPN\e[0m"
if [ -f $openvpnroute ]; then
	echo -e "\e[1;31m检查到已经安装开始卸载重新安装\e[0m"
	opkg remove openvpn-openssl > /dev/null 2>&1
	rm -rf /etc/openvpn
	rm -f /etc/config/openvpn
	opkg install openvpn-openssl	
	else
	rm -rf /etc/openvpn
	rm -f /etc/config/openvpn
	opkg install openvpn-openssl
fi
echo
if [ -f $openvpnroute ]; then
	echo -e "\e[1;36mOpenVPN安装成功         \e[0m[\e[1;31mOK\e[0m]"
	else
	echo -e "\e[1;31mOpenVPN安装失败\e[0m"
	exit
fi
sleep 3
echo
echo -e "\e[1;36m下载证书\e[0m"
mkdir /etc/openvpn/keys
mkdir /etc/openvpn/log
cd /etc/openvpn/keys/
wget "$url"keys.tar.gz > /dev/null 2>&1
if [ -f keys.tar.gz ]; then
	echo
	echo -e "\e[1;36m下载成功                \e[0m[\e[1;31mOK\e[0m]"
	else
	echo
	echo -e "\e[1;31m下载失败请检查您的网络连接\e[0m"
	exit
fi
tar -xvzf keys.tar.gz > /dev/null 2>&1
rm -f keys.tar.gz
sleep 3
echo
echo -e "\e[1;36m下载认证脚本\e[0m"
mkdir /etc/openvpn/author
cd /etc/openvpn/author/
wget "$url"author.tar.gz > /dev/null 2>&1
if [ -f author.tar.gz ]; then
	echo
	echo -e "\e[1;36m下载成功                \e[0m[\e[1;31mOK\e[0m]"
	else
	echo
	echo -e "\e[1;31m下载失败请检查您的网络连接\e[0m"
	exit
fi
tar -xvzf author.tar.gz > /dev/null 2>&1
chmod +x /etc/openvpn/author/login.sh
chmod +x /etc/openvpn/author/logout.sh
rm -f author.tar.gz
sleep 3
echo
echo -e "\e[1;36m下载用户管理脚本\e[0m"
mkdir /etc/openvpn/user
cd /etc/openvpn/user/
wget "$url"user.tar.gz > /dev/null 2>&1
if [ -f user.tar.gz ]; then
	echo
	echo -e "\e[1;36m下载成功                \e[0m[\e[1;31mOK\e[0m]"
	else
	echo
	echo -e "\e[1;31m下载失败请检查您的网络连接\e[0m"
	exit
fi
tar -xvzf user.tar.gz > /dev/null 2>&1
chmod +x /etc/openvpn/user/data.sh
chmod +x /etc/openvpn/user/admin.sh
chmod +x /etc/openvpn/user/user.sh
rm -f user.tar.gz
sleep 3
cd /root
ln -s /etc/openvpn/user/user.sh user > /dev/null 2>&1
ln -s /etc/openvpn/user/data.sh data > /dev/null 2>&1
ln -s /etc/openvpn/user/admin.sh admin > /dev/null 2>&1
echo '6 */6 * * * rm -f /www/openvpn.html' > /etc/crontabs/root
/etc/init.d/cron reload
sleep 2
echo
echo -e "\e[1;36m正在生成客户端配置文件\e[0m"
sed -i '10s/0/1/' /etc/config/openvpn
echo
echo -e -n "\e[1;36m请输入VPN端口请确保没有占用: \e[0m" 
read vpnport
echo "port $vpnport
proto tcp
dev tun
ca /etc/openvpn/keys/ca.crt
cert /etc/openvpn/keys/server.crt
key /etc/openvpn/keys/server.key
dh /etc/openvpn/keys/dh1024.pem
ifconfig-pool-persist /etc/openvpn/log/ipp.txt
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
client-to-client
keepalive 10 120
comp-lzo no
max-clients 50
persist-key
persist-tun
status /etc/openvpn/log/openvpn-status.log
log /etc/openvpn/log/openvpn.log
log-append /etc/openvpn/log/openvpn.log
verb 3
script-security 3
auth-user-pass-verify /etc/openvpn/author/login.sh via-env
client-disconnect /etc/openvpn/author/logout.sh
client-cert-not-required
username-as-common-name" > /etc/openvpn/my-vpn.conf
echo
echo -e -n "\e[1;36m是否需要配置Mproxy？目前仅支持MT7620,AR71XX[y/n]：\e[0m" 
read mproxy
rm -rf /etc/mproxy
mkdir /etc/mproxy
if [ "$mproxy" = "y" ];then
	echo
	echo -e "\e[1;36m >         1. MT7620 \e[0m"
	echo
	echo -e "\e[1;36m >         2. AR71XX \e[0m"
	echo
	echo -e -n "\e[1;36m请选择您的CPU型号：\e[0m"
read mpmenu
if [ "$mpmenu" = "1" ];then
wget -P /etc/mproxy "$url"mproxy/mproxy-mt7620 > /dev/null 2>&1
if [ -f "/etc/mproxy/mproxy-mt7620" ]; then
	echo
	echo -e "\e[1;36mMproxy-MT7620下载成功  \e[0m[\e[1;31mOK\e[0m]"
	sleep 3
	mv -f /etc/mproxy/mproxy-mt7620 /etc/mproxy/mproxy
	echo
	else
	echo
	echo -e "\e[1;31mMproxy下载失败请检查您的网络信息\e[0m"
fi
fi
if [ "$mpmenu" = "2" ];then
wget -P /etc/mproxy "$url"mproxy/mproxy-ar71xx > /dev/null 2>&1
if [ -f "/etc/mproxy/mproxy-ar71xx" ]; then
	echo
	echo -e "\e[1;36mMproxy-AR71XX下载成功  \e[0m[\e[1;31mOK\e[0m]"
	sleep 3
	mv -f /etc/mproxy/mproxy-ar71xx /etc/mproxy/mproxy
	else
	echo
	echo -e "\e[1;31mMproxy下载失败请检查您的网络信息\e[0m"
fi
fi
chmod +x /etc/mproxy/mproxy
mpid=`pgrep "mproxy"`
kill -9 $mpid > /dev/null 2>&1
echo -e -n "\e[1;36m请输入Mproxy所监听的端口(请勿输入80或者8080 除非你没有封端口)：\e[0m" 
read mpip
echo
echo -e "\e[1;36m正在启动MProxy\e[0m"
/etc/mproxy/./mproxy -l $mpip -i 127.0.0.1 -p $vpnport -d > /dev/null 2>&1
echo
mproxypid=`ps  | grep mproxy | grep -v 'grep ' | awk '{print $7}'`;
if [ "$mproxypid" = "$mpip" ];then
	echo -e "\e[1;36mMproxy启动成功         \e[0m[\e[1;31mOK\e[0m]"
	echo
	else
	echo -e "\e[1;31mMproxy启动失败，请检查是否端口有问题\e[0m"
fi
echo -e "\e[1;36m打开路由器转发规则\e[0m"
uci set firewall.@defaults[0].forward=ACCEPT
uci set firewall.@zone[1].input=ACCEPT
uci set firewall.@zone[1].forward=ACCEPT
uci commit firewall
sleep 5
echo
echo -e "\e[1;36m开始生成Mproxy代理的OpenVPN配置文件\e[0m"
echo "#MProxy代理
client 
tls-client 
dev tun
proto tcp
remote wap.10086.cn 80
http-proxy $ip $mpip
resolv-retry infinite 
nobind
<ca>
`cat /etc/openvpn/keys/ca.crt`
</ca>
comp-lzo no 
persist-tun 
persist-key 
verb 3
auth-user-pass" >/root/Mproxy.ovpn
echo
sleep 3
echo -e -n "\e[1;36m是否需要配置Mproxy开启自启[y/n] ：\e[0m" 
read mpkjzq
if [ "$mpkjzq" = "y" ];then
echo "
/etc/mproxy/./mproxy -l $mpip -i 127.0.0.1 -p $vpnport -d
exit 0">/etc/rc.local
fi
fi
echo
echo -e "\e[1;36m开始生成本地代理OpenVPN配置文件\e[0m"
sleep 1
echo "#本地代理
client 
tls-client 
dev tun
proto tcp
remote $ip $vpnport
resolv-retry infinite 
nobind
<ca>
`cat /etc/openvpn/keys/ca.crt`
</ca>
comp-lzo no 
persist-tun 
persist-key 
verb 3
auth-user-pass" >/root/OpenWrt.ovpn
echo
echo -e "\e[1;36m配置防火墙规则\e[0m"
echo "iptables -I INPUT -i tun+ -j ACCEPT
iptables -I FORWARD -i tun+ -j ACCEPT
iptables -I OUTPUT -o tun+ -j ACCEPT
iptables -I FORWARD -o tun+ -j ACCEPT'" >/etc/firewall.user
echo
echo -e "\e[1;36m启动OpenVPN 重启防火墙\e[0m"
/etc/init.d/openvpn enable 
/etc/init.d/openvpn start
/etc/init.d/firewall restart  > /dev/null 2>&1 
sleep 2
echo
echo
echo -e "\e[1;36m开始创建账号\e[0m"
echo
echo -e -n "\e[1;36m请输入账号: \e[0m" 
read vpnuser
mkdir /etc/openvpn/user/$vpnuser
echo
echo -e -n "\e[1;36m请输入密码: \e[0m" 
read vpnpass
echo "$vpnpass" >/etc/openvpn/user/$vpnuser/password
echo
echo -e -n "\e[1;36m请输入流量限制(M为单位): \e[0m" 
read vpndata
echo "$vpndata" >/etc/openvpn/user/$vpnuser/data
clear 
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+                 installation is complete               +"
echo "+                                                        +"
echo "+             Author: Virus <86248425.@qq.com>           +"
echo "+                                                        +"
echo "+             日志页面  路由器IP/openvpn.html            +"
echo "+                                                        +"
echo "+                请在root目录下下载配置文件              +"
echo "+                                                        +"
echo "+                 查看账号状态命令 ./data                +"
echo "+                                                        +"
echo "+                  查看在线用户 ./admin                  +"
echo "+                                                        +"
echo "+                   用户管理命令 ./user                  +"
echo "+                                                        +"
echo "+                     Time 2016.08.09                    +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo "                 >>  OpenVPN端口：$vpnport"
echo 
echo "                 >>  Mproxy端口：$mpip"
echo  
echo "                 >>  账号：$vpnuser"
echo 
echo "                 >>  密码：$vpnpass"
echo 
echo "                 >>  流量：${vpndata}M"
echo 
rm -f openvpn.sh
fi
if [ "$menu" == "2" ]; then
echo
echo -e "\e[1;31m正在停止服务\e[0m"
kill -9 $mpid > /dev/null 2>&1
echo
echo -e "\e[1;31m开始卸载OpenVPN\e[0m"
	rm -f /var/lock/opkg.lock
	opkg remove openvpn-openssl > /dev/null 2>&1
sleep 2
echo
echo -e "\e[1;31m删除残留文件夹以及配置\e[0m"
	rm -rf /etc/openvpn
	rm -rf /etc/mproxy
	rm -f /etc/config/openvpn
	rm -f /root/Mproxy.ovpn
	rm -f /root/OpenWrt.ovpn
	rm -f /root/data
	rm -f /root/user
	rm -f /root/admin
	rm -f /www/openvpn.html
sleep 2
echo
echo -e "\e[1;31m还原防火墙配置\e[0m"
echo "# This file is interpreted as shell script.
# Put your custom iptables rules here, they will
# be executed with each firewall (re-)start.

# Internal uci firewall chains are flushed and recreated on reload, so
# put custom rules into the root chains e.g. INPUT or FORWARD or into the" >/etc/firewall.user
sleep 1
echo
echo -e "\e[1;31m去除MProxy开机自启\e[0m"
echo "# Put your custom commands here that should be executed once
# the system init finished. By default this file does nothing.

exit 0">/etc/rc.local
echo
echo -e "\e[1;31m去除计划任务\e[0m"
echo '' > /etc/crontabs/root
/etc/init.d/cron reload
sleep 1
echo
echo -e "\e[1;31m重启防火墙\e[0m"
/etc/init.d/firewall restart  > /dev/null 2>&1
rm -f openvpn.sh
echo
echo -e -n "\e[1;31m是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi
fi


