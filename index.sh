#!/bin/sh

echo "Procurando por instalações WordPress no servidor..."
find /home/ -type f -name "xmlrpc.php" -not -path "*wp-content*" -printf '%h\n' | sort -u >> wps.txt
readarray wps < wps.txt
echo "${#wps[@]} instalações encontradas!"
echo "Procurando por arquivos .htaccess que não contenham o código <Files xmlrpx.php>..."
	for wp in ${wps[@]}
	       	do
			find $wp -maxdepth 1 -type f -name ".htaccess" | xargs -r grep -L "<Files xmlrpc.php>" >> files.txt
                        readarray files < files.txt
		done
rm files.txt wps.txt
nfiles=${#files[@]}
	if [ $nfiles == 0 ]
	then
		echo "Todos os arquivos já contém o código. Até mais!"
		exit
	else
	if [ $nfiles == 1 ]
	then
	echo "01 arquivo encontrado!"
	echo "Adicionando o código no arquivo..."
	else
	echo "${#files[@]} arquivos encontrados!"
	echo "Adicionando o código nesses arquivos..."
	fi
        for file in ${files[@]}
	       	do
		echo "		

Block WordPress xmlrpc.php requests

<Files xmlrpc.php>
order deny,allow
deny from all
</Files>" >> $file
		echo "Código adicionado em $file!"
        	done
	fi
echo "Pronto!"
while true;
do
        read -p "Necessário reiniciar o Apache para aplicar as configurações. Deseja reiniciar agora? [Y/n]" yn
        case $yn in
     [Yy]*) systemctl restart httpd.service; echo "Apache reiniciado com sucesso."; break;;
     [Nn]*) exit;;
     * ) echo "Entrada inválida.";;
    esac
done
