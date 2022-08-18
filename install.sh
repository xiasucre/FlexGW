#!/bin/bash
wget https://github.com/Ostaer/FlexGW/releases/download/v1.1/flexgw-1.1.0-1.el7.centos.x86_64.rpm
sysctl -a | egrep "ipv4.*(accept|send)_redirects" | awk -F "=" '{print $1"= 0"}' >> /etc/sysctl.conf
sed -i 's/^net.ipv4.ip_forward.*//g' /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1">> /etc/sysctl.conf
sysctl -p
yum makecache fast
yum install -y strongswan openvpn zip curl wget
rpm -ivh flexgw-1.1.0-1.el7.centos.x86_64.rpm
cat >  /usr/local/flexgw/rc/strongswan.conf <<EOF
charon {
    filelog {
        charon {
            path = /var/log/strongswan.charon.log
            time_format = % b % e % T
            ike_name = yes
            append = no
            default = 1
            flush_line = yes
        }
    }
    plugins {
        include strongswan.d/charon/*.conf
        duplicheck {
            enable = yes
        }
    }
}
EOF
sed -i  's/load/#load/g' /etc/strongswan/strongswan.d/charon/dhcp.conf
> /etc/strongswan/ipsec.secrets
#add firewalld rule
#firewall
IP=`ip add | egrep "192\.168|172\.|10\."|egrep -v 'docker|br-' | grep brd | awk '{print $2}'| awk -F '/' '{print $1}'`|head -n 1
firewall-cmd --stat >>/dev/null 2>&1

if [ "$?" -eq 0 ]; then
    echo "防火墙已经打开，正在打开POSTROUTING"
    firewall-cmd --permanent --zone=public --add-port=1194/udp
    firewall-cmd --permanent --zone=public --add-port=8000/udp
    firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.10.8.0/24 -j SNAT --to-source ${IP}
    firewall-cmd --reload
    echo "防火墙端口已经打开"
fi

/etc/init.d/initflexgw 

