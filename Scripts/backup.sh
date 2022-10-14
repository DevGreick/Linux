#!/bin/bash
#############################################################################
#
# Este script cria um backup de todos os arquivos a partir deste diretorio
#   e cria um arquivo no diretorio $BACKUP_DIR. O nome do arquivo criado
#   possui o formato backup.YYYMMDD.HHMMSS.usuario_a.tar.gz. Para evitar
#   acidentes, os arquivos sao salvos no tar.gz com um diretorio diferente
#   do atual. Para restaurar o backup, execute: tar -xvzf arquivo.tar.gz.
#   Em seguida, copie os arquivos necessarios da pasta criada para a pasta
#   atual.
#
#############################################################################

USER=`who -m | cut -d' ' -f1`
#read -p 'Informe seu usuario: ' USER
DATE=`date +%Y%m%d.%H%M%S`
BACKUP_DIR=backups
FILE=backup.$DATE.$USER.tar.gz
PREFIX="backup.$DATE"
LABEL_OK="\e[00;32m[  OK  ]\e[00m"
LABEL_ERROR="\e[00;31m[ ERROR ]\e[00m"

tar --transform="s/^./$PREFIX/" --exclude=$BACKUP_DIR --exclude=data -cvzf $BACKUP_DIR/$FILE ./*
tar -tvzf $BACKUP_DIR/$FILE


#echo "---> Usuario Logado: $USER"
if [ -e $BACKUP_DIR/$FILE ]; then
   echo -e "$LABEL_OK Arquivo $BACKUP_DIR/$FILE criado com sucesso!"
   echo 
   echo " Atencao: verifique se todos os arquivos que serao alterados"
   echo "          estao listados no backup acima."

else

   echo -e "$LABEL_ERROR Arquivo $BACKUP_DIR/$FILE nao foi criado!"

fi
