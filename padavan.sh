#!/bin/sh
#烟雨笑
url="http://code.taobao.org/svn/OpenwrtVpn/";
ip=`wget http://ipecho.net/plain -O - -q ; echo`;
clear
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+                Install OpenVPN for Padavan             +"
echo "+                                                        +"
echo "+             Author: Virus <86248425.@qq.com>           +"
echo "+                                                        +"
echo "+                     Time 2016.08.15                    +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
echo -e "\e[1;36m三秒后开始安装......\e[0m"
echo
sleep 3
echo -e "\e[1;36m开始下载文件\e[0m"
cd /etc/storage/openvpn/server
rm -f ca.crt ca.key dh1024.pem server.crt server.key ta.key
wget "$url"Padavan.tar.gz > /dev/null 2>&1
if [ -f Padavan.tar.gz ]; then
	echo
	echo -e "\e[1;36m下载成功                \e[0m[\e[1;31mOK\e[0m]"
	else
	echo
	echo -e "\e[1;31m下载失败请检查您的网络连接\e[0m"
	exit
fi
tar -xvzf Padavan.tar.gz > /dev/null 2>&1
rm -f Padavan.tar.gz
sleep 3
echo
echo -e "\e[1;36m修改服务器配置\e[0m"
sed -i '22d' /etc/storage/openvpn/server/server.conf
sed -i '21a\ ' /etc/storage/openvpn/server/server.conf
sed -i '22a\### User management' /etc/storage/openvpn/server/server.conf
sed -i '23a\script-security 3' /etc/storage/openvpn/server/server.conf
sed -i '24a\auth-user-pass-verify /etc/storage/openvpn/checkpsw.sh via-env' /etc/storage/openvpn/server/server.conf
sed -i '25a\client-cert-not-required' /etc/storage/openvpn/server/server.conf
sed -i '26a\username-as-common-name' /etc/storage/openvpn/server/server.conf
sed -i '28,$d' /etc/storage/openvpn/server/server.conf
sleep 3
cd /etc/storage/openvpn
wget "$url"checkpsw.sh > /dev/null 2>&1
chmod +x checkpsw.sh
echo
echo -e -n "\e[1;36m请输入账号:\e[0m"
read name
echo
echo -e -n "\e[1;36m请输入密码:\e[0m"
read pass
echo
echo "$name $pass">pass
echo -e "\e[1;36m开始生成新的配置文件\e[0m"
#----------------------------------------------------------------
#端口
cat /etc/openvpn/server/server.conf | grep port >>serverport
cat serverport | cut -d ' ' -f 2 >>vpnport
port=`cat vpnport`;
rm -f serverport
#----------------------------------------------------------------
sleep 3
echo "client
dev tun
proto tcp-client
remote $ip $port
resolv-retry infinite
;float
nobind
persist-key
persist-tun
auth SHA1
cipher BF-CBC
comp-lzo adaptive
nice 0
verb 3
mute 10
auth-user-pass
;ns-cert-type server
<ca>
`cat /etc/storage/openvpn/server/ca.crt`
</ca>">Padavan.ovpn
rm -f vpnport
clear 
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+                                                        +"
echo "+                 installation is complete               +"
echo "+                                                        +"
echo "+             Author: Virus <86248425.@qq.com>           +"
echo "+                                                        +"
echo "+             日志页面  路由器IP/openvpn.html            +"
echo "+                                                        +"
echo "+           /etc/storage/openvpn目录下下载配置文件       +"
echo "+                                                        +"
echo "+          查看密码:cat /etc/storage/openvpn/pass        +"
echo "+                                                        +"
echo "+                     Time 2016.08.15                    +"
echo "+                                                        +"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo
rm -f padavan.sh
echo
echo -e -n "\e[1;31m是否需要重启路由器？[y/n]：\e[0m" 
read boot
	if [ "$boot" = "y" ];then
		echo
		reboot
	fi


