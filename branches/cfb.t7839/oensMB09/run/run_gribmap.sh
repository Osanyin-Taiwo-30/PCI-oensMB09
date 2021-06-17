#! /bin/bash -x
#--------------------------------------------------------------------#
#  Sistema de Previsão por Conjunto Global - GDAD/CPTEC/INPE - 2017  #
#--------------------------------------------------------------------#
#BOP
#
# !DESCRIPTION:
# Script para criar os arquivos de índice a partir dos arquivos descritores
# dos pós-processamento do BAM para o Sistema de Previsão por 
# Conjunto Global (SPCON) do CPTEC.
#
# !INTERFACE:
#      ./run_gribmap.sh <opcao1> <opcao2> <opcao3> <opcao4>
#
# !INPUT PARAMETERS:
#  Opcoes..: <opcao1> resolucao -> resolução espectral do modelo
#                                
#            <opcao2> data      -> data da análise corrente (a partir
#                                  da qual as previsões foram feitas)
#
#            <opcao3> anlpert   -> número de perturbações do ensemble
#
#            <opcao4> anltype   -> prefixo da perturbação
#
#  Uso/Exemplos: ./run_gribmap.sh TQ0126L028 2012123118 7 NPT
#                (cria os arquivos ctl válidos para 2012123118 
#                na resolução TQ0126L028; serão
#                considerados as 7 perturbações com o sufixo N)
#
#                ./run_gribmap.sh TQ0126L028 2012123118 7 PPT
#                (cria os arquivos ctl válidos para 2012123118 
#                na resolução TQ0126L028; serão
#                considerados as 7 perturbações com o sufixo P)
#
#                ./run_gribmap.sh TQ0126L028 2012123118 1 NMC
#                (cria os arquivos ctl válidos para 2012123118 
#                na resolução TQ0126L028; será considerado apenas
#                o controle com o sufixo NMC)
#
# !REVISION HISTORY:
#
# 02 Setembro de 2020 - C. F. Bastarz - Versão inicial.  
#
# !REMARKS:
#
# !BUGS:
#
#EOP  
#--------------------------------------------------------------------#
#BOC

# Descomentar para debugar
#set -o xtrace

# Menu de opções/ajuda
if [ "${1}" = "help" -o -z "${1}" ]
then
  cat < ${0} | sed -n '/^#BOP/,/^#EOP/p'
  exit 0
fi

# Diretórios principais
export FILEENV=$(find ./ -name EnvironmentalVariablesMCGA -print)
export PATHENV=$(dirname ${FILEENV})
export PATHBASE=$(cd ${PATHENV}; cd ; pwd)

. ${FILEENV} ${1} ${4}

cd ${HOME_suite}/run

export RES=${TRCLV}

TRC=$(echo ${TRCLV} | cut -c 1-6 | tr -d "TQ0")
LV=$(echo ${TRCLV} | cut -c 7-11 | tr -d "L0")

export RESOL=${TRCLV:0:6}
export NIVEL=${TRCLV:6:4}

if [ -z "${2}" ]
then
  echo "Second argument is not set (LABELI: yyyymmddhh)"
  exit
else
  LABELI=${2}
fi

if [ -z "${3}" ]
then
  echo "Third argument is not set (ANLPERT)"
  exit
else
  ANLPERT=${3}
fi

if [ -z "${4}" ]
then
  echo "Fourth argument is not set (ANLTYPE)"
  exit
else
  ANLTYPE=${4}
fi

cd ${HOME_suite}/run

RUNTM=$(date +"%s")

if [ ${ANLTYPE} != CTR -a ${ANLTYPE} != NMC -a ${ANLTYPE} != EIT -a ${ANLTYPE} != EIH ]
then
  export PBSDIRECTIVENAME="#PBS -N GMAPENS${ANLTYPE}"
  export PBSDIRECTIVEARRAY="#PBS -J 1-${ANLPERT}"
  export PBSMEM="export MEM=\$(printf %02g \${PBS_ARRAY_INDEX})"
  export PBSEXECFILEPATH="export EXECFILEPATH=${DK2}/pos/dataout/${RES}/${LABELI}/\${MEM}${ANLTYPE:0:1}"
else
  export PBSDIRECTIVENAME="#PBS -N GMAP${ANLTYPE}"
  export PBSDIRECTIVEARRAY=""
  export PBSMEM=""
  export PBSEXECFILEPATH="export EXECFILEPATH=${DK2}/pos/dataout/${RES}/${LABELI}/${MEM}${ANLTYPE}"
fi

# Script de submissão
SCRIPTSFILES=setgribmap${ANLTYPE}.${RES}.${LABELI}.${MAQUI}

cat <<EOT0 > ${SCRIPTSFILES}
#! /bin/bash 
#PBS -o ${DK_suite}/run/setgribmap${ANLTYPE}${RES}${LABELI}.${MAQUI}.${RUNTM}.out
#PBS -e ${DK_suite}/run/setgribmap${ANLTYPE}${RES}${LABELI}.${MAQUI}.${RUNTM}.err
#PBS -l walltime=0:15:00
#PBS -l mppnppn=1
#PBS -A CPTEC
#PBS -V
#PBS -S /bin/bash
${PBSDIRECTIVENAME}
${PBSDIRECTIVEARRAY}
#PBS -q ${AUX_QUEUE}

export gribmap=${DIRGRADS}/gribmap

${PBSMEM}

${PBSEXECFILEPATH}

# Procura todos os arquivos *.grb
for arq in \$(find \${EXECFILEPATH} -name *.grb)
do

  arqidx=\$(echo \${arq} | sed "s,.grb,.idx,g")
  arqctl=\$(echo \${arq} | sed "s,.grb,.ctl,g")

  if [ ! -s \${arqidx} ] # não existe ou está vazio
  then

    echo "\${arqidx} não existe ou está vazio!"
    \${gribmap} -i \${arqctl}

  fi

done

echo "" > \${EXECFILEPATH}/monitor.t
EOT0

# Submete o script e aguarda o fim da execução
chmod +x ${HOME_suite}/run/${SCRIPTSFILES}

export PBS_SERVER=${pbs_server2}

qsub -W block=true ${SCRIPTSFILES}

if [ ${ANLTYPE} != CTR -a ${ANLTYPE} != NMC ]
then

  for mem in $(seq -f %02g 1 ${ANLPERT})
  do

    until [ -e "${DK2}/pos/dataout/${RES}/${LABELI}/${mem}${ANLTYPE:0:1}/monitor.t" ]; do sleep 1s; done

  done

else

  until [ -e "${DK2}/pos/dataout/${RES}/${LABELI}/${ANLTYPE}/monitor.t" ]; do sleep 1s; done

fi

exit 0
