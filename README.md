# block-xmlrpc-requests
Script para adicionar bloco de código que bloqueia requisições ao arquivo xmlrpc.php, em todas as instalações WordPress de um servidor.

## Por que criei esse script?

Como administrador de uma hospedagem de sites, eu estava recebendo muitas mensagens do meu firewall com um aviso semelhante ao seguinte:

```
Time:     Wed Apr 20 20:28:17 2022 -0300
IP:       185.189.115.108 (CZ/Czechia/pc-coupons.online)
Failures: 5 (XMLRPC)
Interval: 3600 seconds
Blocked:  Permanent Block [LF_CUSTOMTRIGGER]
```

Numa rápida pesquisa, descobri que conseguiria resolver esse problema apenas implementando o código a seguir no arquivo `.htaccess`:

```
<Files xmlrpc.php>
order deny,allow
deny from all
allow from xxx.xxx.xxx.xxx
</Files>
```
Mas copiar e colar o código em cada um dos sites, de modo manual, me parecia um pouco cansativo. Por isso criei o script.

## Observações importantes

1. É o primeiro código **da minha vida** hehe por isso, atente-se aos seguintes pontos:
  - Pode existir vulnerabilidades;
  - Pode existir erros ou "pontas soltas";
  - Acho que pode ser escrito de maneira mais limpa;
  - Não tenho experiência suficiente para analisar se consome muitos recursos do servidor (o que também depende do tamanho e capacidade do seu servidor) - ou seja, não tenho certeza se é saudável rodar esse código em outros ambientes (no meu foi tranquilo).

*Conto com sua ajuda nos pontos acima :D*

2. O meu ambiente é um CentOS 7 com o [painel CWP](https://control-webpanel.com/) rodando. Pode ser que em outros ambientes você precise fazer alguma alteração no código (como a estrutura do diretório "home" ou o comando correto para reinicializar o Apache).

## Explicação do código ##

`find /home/ -type f -name "xmlrpc.php" -not -path "*wp-content*" -printf '%h\n' | sort -u >> wps.txt`

Procura por diretórios em `/home` que contenham o arquivo `xmlrpc.php`, excluindo as subpastas `wp-content`, e armazena em ordem alfabética num arquivo de texto temporário chamado `wps.txt`.

`readarray wps < wps.txt`

Lê os dados do arquivo temporário e armazena os valores num array.

```
for wp in ${wps[@]}
    do
    find $wp -maxdepth 1 -type f -name ".htaccess" -not -path "*wp-content*" | xargs -r grep -L "<Files xmlrpc.php>" >> files.txt
    readarray files < files.txt
done
```

Para cada diretório encontrado no comando anterior, executa uma busca por arquivos `.htaccess` que não contenham o código `<Files xmlrpc.php>`, adiciona-os a um arquivo temporário e armazena os valores num array.

> Reconheço que aqui existe uma "ponta solta" no sentido que apenas a primeira linha do código está sendo buscada no arquivo, enquanto deveria ser todo o trecho. Porém, ainda não consegui resolver esse empecilho, então é um começo e conto com sua participação para melhorá-lo.

```
nfiles=${#files[@]}
if [ $nfiles == 0 ]
	then
		echo "Todos os arquivos já contém o código. Até mais!"
		exit
```
Faz uma verificação do tamanho do array (quantos arquivos foram encontrados) e, se for igual a zero, finaliza o código.

```
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
```
Se tiver um ou mais arquivos encontrados, adiciona o bloco de código para bloqueio do XMLRPC Request a cada um deles.

```
while true;
do
        read -p "Necessário reiniciar o Apache para aplicar as configurações. Deseja reiniciar agora? [Y/n]" yn
        case $yn in
     [Yy]*) systemctl restart httpd.service; echo "Apache reiniciado com sucesso."; break;;
     [Nn]*) exit;;
     * ) echo "Entrada inválida.";;
    esac
done
```

Simples validação, com interação do usuário, para reiniciar o Apache após a execução das tarefas.

## Considerações finais ##

Não hesite em deixar suas críticas ou sugestões. Estou aberto a melhorias!

Fiz esse código por hobbie e para exercitar meu conhecimento em programação, mas espero de coração que ele seja útil a alguém. Se for, deixe eu ficar sabendo, por favor! :)

Dica: você pode implementar como um `cronjob` para executá-lo de tempos em tempos automaticamente no seu servidor.

## Agradecimentos ## 

- Ao [Felipe Deschamps](https://www.youtube.com/c/FilipeDeschamps), por me trazer o ânimo e a empolgação de trabalhar com código;
- Ao [Fábio da Bóson Treinamentos](https://www.youtube.com/c/bosontreinamentos), pelo [Curso de Shell Scripting](https://www.youtube.com/playlist?list=PLucm8g_ezqNrYgjXC8_CgbvHbvI7dDfhs), que foi muito útil ao escrever o meu primeiro código;
- Por toda a comunidade de programação em fóruns da internet.
