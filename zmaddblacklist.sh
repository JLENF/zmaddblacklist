#!/bin/bash
############################################################
##                                                        ##
## Script para adicionar enderecos na blacklist do zimbra ##
## O script procura se ja existe o endereco e cadastra    ##
## somente os novos ja na formatacao do zimbra            ##
##                                                        ##
## Desenvolvido por Jairo Lenfers em 12/01/2015           ##
## Licenciamento GNU GPL 2.0                              ##
##                                                        ##
## Modo de usar: ./zmaddblacklist.sh nome_da_lista.txt    ##
## Atencao, alterar a variavel da blacklist do zimbra     ##
############################################################

# variaveis
blacklist_zimbra="/opt/zimbra/blacklist"

# removendo os arquivos temporarios
rm -rf /tmp/adicionar.txt
rm -rf /tmp/adicionar.ok
rm -rf /tmp/blacklist.txt
rm -rf /tmp/blacklist.ok
touch /tmp/adicionar.txt

lista_full=$1
lista=`echo $1 |cut -d "." -f1`
cp $blacklist_zimbra /tmp/blacklist.txt
echo "[processando o arquivo]: $lista_full"
qtd_total=`wc -l $lista_full |awk '{print $1}'`
echo "[total linhas]: $qtd_total"
qtd_atual=1
tempo_sleep=2

function proc_dominio {
    dominio_existe=`grep -o $1 /tmp/blacklist.txt | wc -l`
    if [ "$dominio_existe" = "1" ]; then # dominio existe
       echo -e "\033[31m [JA EXISTE]\033[0m"
    else
        echo -e "\033[32m [ADICIONADO]\033[0m"
        echo "$1" >> /tmp/adicionar.txt
    fi
}

while read line
do
   echo -n "[$qtd_atual/$qtd_total]: $line"
   proc_dominio $line
   qtd_atual=`expr $qtd_atual + 1`
done < $lista_full

# insere os dominios validos na blacklist
sed 's/$/\ REJECT/g' /tmp/adicionar.txt > /tmp/adicionar.ok
cat /tmp/adicionar.ok >> /tmp/blacklist.txt
sort /tmp/blacklist.txt | uniq > /tmp/blacklist.ok
cp /tmp/blacklist.ok $blacklist_zimbra
qtd_adicionados=`wc -l /tmp/adicionar.txt |awk '{print $1}'`
qtd_total=`wc -l /tmp/blacklist.ok |awk '{print $1}'`
echo " "
echo "Nao esqueca de reiniciar os servicos necessarios do zimbra"
echo "su - zimbra"
echo "zmantispamctl restart && postqueue -f"
echo " "
echo "Dominios adicionados: $qtd_adicionados"
echo "Total na blacklist: $qtd_total"
