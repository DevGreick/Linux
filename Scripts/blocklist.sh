#!/bin/bash -f

# O script necessita do ipcalc para funcionar. 
source /usr/share/ipcalc/ipcalc

# Define o nome do arquivo de lista de IPs
list=listIP.txt

# Remove o arquivo, caso exista
rm -f $list

# Define a URL do arquivo de senhas
url='https://lists.blocklist.de/lists/mail.txt'

# Faz o download do arquivo de senhas e adiciona ao arquivo de lista de IPs
curl $url --insecure >> $list
echo >> $list

# Define o nome da chain a ser criada no iptables
chain=ips_dinamicos_sftp_sepin

# Cria a chain no iptables, caso não exista
iptables -N $chain

# Lê a lista de IPs do arquivo e adiciona cada um à chain
while read ip; do
    if [[ "$ip" == *\/* ]]; then
        # O endereço IP é uma rede, adiciona uma regra para cada IP na rede
        network=`ipcalc -n $ip | cut -d= -f2`
        broadcast=`ipcalc -b $ip | cut -d= -f2`
        for i in $(seq $(echo $network | cut -d. -f4) $(echo $broadcast | cut -d. -f4)); do
            iptables -A $chain -d $network/$i -j DROP
        done
    else
        # O endereço IP é um IP único, adiciona uma regra para ele
        iptables -A $chain -d $ip -j DROP
    fi
done < $list

# Define a interface de rede a ser utilizada (substituir "eth0" pela interface desejada)
interface=ens33

# Adiciona uma regra no iptables para permitir o tráfego da chain criada pela interface definida
iptables -A INPUT -i $interface -j $chain