#!/bin/bash

#########################################################################################################
#Script qui automatise la sauvgarde d'un flow d'une instance NiFi sur l'environnement de développement###
#########################################################################################################

# =======================================================================================================
#       Fonction de log
# =======================================================================================================
# Valeur d'entree   :
#                       $1      Chaine de caractere
#                       $2      logFile
# =======================================================================================================
t__LogF(){
        printf "%-25s %1s %s \n" "$(date +"%d/%m/%Y %H:%M:%S.%3N")" "|" "$1"
        printf "%-25s %1s %s \n" "$(date +"%d/%m/%Y %H:%M:%S.%3N")" "|" "$1">>$2
}

printf "%-3s %30s %1s %s \n" "#" "Script appelant" ":" "${scriptDir}/${scriptName}script_test.sh" | tee -a ${logFile}
printf "%-3s %30s %1s %s \n" "#" "Heure de lancement" ":" "$( date +"%A %d %B %Y %H:%M:%S" )" | tee -a ${logFile}
printf "%-3s %30s %1s %s \n" "#" "PID script appelant" ":" "${pidScript}" | tee -a ${logFile}
printf "%-3s %30s %1s %s \n" "#" "Utilisateur appelant" ":" "${USER}" | tee -a ${logFile}

#date du jour
DATE=$( date +"%Y%m%d%H%M%S" )

NIFI_HOME=/home/youssef/nifi-1.6.0
logFile=/home/youssef/nifi-1.6.0/logs/logs-nifi
flowNifi=$NIFI_HOME/conf/flow.xml.gz
flow_HOME=/home/youssef/arch/flow/flow_nifi/flow-$DATE
urlNifi=10.12.20.154:18485/nifi/
file=/home/youssef/nifi-1.6.0/bin/file.txt

t__LogF "# Stopping NiFi instance " ${logFile}
# On arrete l'instance nifi 
t__LogF "* Command : $NIFI_HOME/bin/nifi.sh stop" ${logFile}
# $NIFI_HOME/bin/nifi.sh stop &>> $logFile
if [[ $? -ne 0 ]]; then
	t__LogF "Check the log file $logFile for more information" ${logFile}
	exit 1
fi

t__LogF "# Check that nifi is stopped" ${logFile}
# On vérifie si l'instance nifi est arreter 
t__LogF "* Command : $NIFI_HOME/bin/nifi.sh status &> $file" ${logFile}
$NIFI_HOME/bin/nifi.sh status &> $file

# On vérifie si l'instance nifi est arretter ou bien non 
t__LogF "# check if the nifi instance is stopped" ${logFile}

t__LogF "* Command : grep -c \"Command Apache NiFi is currently running\" $file" ${logFile}

verif=$( grep -c "Command Apache NiFi is currently running" $file )
# echo $verif
if [[ "$verif" -eq 1 ]]; then
	t__LogF "try to stop nifi" ${logFile}
elif [[ "$verif" -eq 0 ]]; then
     t__LogF "Nifi is OK" ${logFile}
	 exit 
fi 

t__LogF "# Save the flow nifi" ${logFile}
# Sauvgarde du fichier flow.xml 
t__LogF "* Command : cp $flowNifi $flow_HOME" ${logFile}
cp $flowNifi $flow_HOME
if [[ $? -ne 0 ]]; then
t__LogF "see $flow_HOME to verify that the file is saved" ${logFile}
	exit 1
fi

t__LogF "# Starting nifi" ${logFile}
# On rédémarre l'instance nifi  
t__LogF "* Command : $NIFI_HOME/bin/nifi.sh start" ${logFile}
$NIFI_HOME/bin/nifi.sh start 
if [[ $? -ne 0 ]]; then
t__LogF	"Check the log file $logFile for more information" ${logFile}
	exit 1
fi

sleep 20
# On vérifie que Nifi est démarée correctement 

t__LogF "# Check that Nifi is started" ${logFile}
t__LogF "* Command : curl -sLI -o /dev/null -w \"%{http_code}\" $urlNifi" ${logFile}

codRetour=$( curl -sLI -o /dev/null -w "%{http_code}" $urlNifi )
echo $codRetour

if [[ $codRetour -eq 200 ]]; then 
t__LogF "Nifi is OK"  ${logFile}
exit
fi 

cnt=0
while [[ ($codRetour -ne 200) && ($cnt -lt 6) ]]; do 
t__LogF "waiting for nifi to start....." ${logFile}
sleep 10
codRetour=$( curl -sLI -o /dev/null -w "%{http_code}" $urlNifi )
cnt=$(( cnt + 1 ))
t__LogF "nifi not started" ${logFile}
exit
done 

#if $cnt -eq 6 alors y'a un truc qui va pas
if [[ $cnt -eq 6 ]]; then 
t__LogF "there is something wrong" ${logFile}
exit
fi

t__LogF "OK NIFI IS UP"  ${logFile}
