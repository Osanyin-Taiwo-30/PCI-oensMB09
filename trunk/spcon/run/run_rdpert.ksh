#! /bin/ksh
#--------------------------------------------------------------------#
#  Sistema de Previsão por Conjunto Global - GDAD/CPTEC/INPE - 2017  #
#--------------------------------------------------------------------#
#BOP
#
# !DESCRIPTION:
# Script para a gerar um conjunto inicial de n análises randomicamente
# perturbadas a partir da análise controle do Sistema de Previsão por 
# Conjunto Global (SPCON) do CPTEC.
#
# !INTERFACE:
#      ./run_rdpert.ksh <opcao1> <opcao2> <opcao3> <opcao4> <opcao5>
#
# !INPUT PARAMETERS:
#  Opcoes..: <opcao1> resolucao -> resolução espectral do modelo
#                                
#            <opcao2> prefixo   -> prefixo que identifica o tipo de
#                                  análise
#
#            <opcao3> data      -> data da análise corrente 
#
#            <opcao4> moist_opt -> opção lógica (YES/NO) para
#                                  perturbar ou não a umidade
#
#            <opcao5> membro    -> tamanho do conjunto 
#            
#  Uso/Exemplos: ./run_rdpert.ksh TQ0126L028 NMC YES 2012111200 7
#                (perturba randomicamente um conjunto inicial de 7
#                membros a partir de uma análise controle na resolução
#                TQ0126L028; inclui a perturbação da umidade)
# 
# !REVISION HISTORY:
#
# XX Julho de 2017 - C. F. Bastarz - Versão inicial.  
# 16 Agosto de 2017 - C. F. Bastarz - Inclusão comentários.
# 07 Dezembro de 2017 - C. F. Bastarz - Corrigido no número de 
#                                       perturbações na vertical
#                                       (as perturbações da umidade
#                                       foram interpoladas a partir dos
#                                       28 valores originais)
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
export PATHBASE=$(cd ${PATHENV}; cd ../; pwd)

. ${FILEENV} ${1} ${2}

cd ${HOME_suite}/../run

TRC=$(echo ${TRCLV} | cut -c 1-6 | tr -d "TQ0")
LV=$(echo ${TRCLV} | cut -c 7-11 | tr -d "L0")

export RESOL=${TRCLV:0:6}
export NIVEL=${TRCLV:6:4}

# Verificação dos argumentos de entrada
if [ -z "${2}" ]
then
  echo "PERT: NMC, AVN CTR 01N" 
  exit
else
  PREFIC=${2}
fi

if [ -z "${3}" ]
then
  echo "Third argument is not set (HUMID)"
  exit
else
  HUMID=${3}
fi
if [ -z "${4}" ]; then
  echo "Fourth argument is not set (LABELI: yyyymmddhh)"
  exit
else
  LABELI=${4}
fi
if [ -z "${5}" ]; then
  echo "Fifth argument is not set (NPERT)"
  exit
else
  NPERT=${5}
fi

# Variáveis utilizadas no script de submissão
HSTMAQ=$(hostname)

RUNTM=$(date +'%Y')$(date +'%m')$(date +'%d')$(date +'%H:%M')
EXT=out
CASE=${TRCLV}

echo ${MAQUI}
echo ${AUX_QUEUE}
echo ${RUNTM}
echo ${EXT}

export PBS_SERVER=aux20-eth4
cd ${HOME_suite}/../run

mkdir -p ${DK_suite}/../rdpert/output

# Script de submissão
SCRIPTSFILE=setrdpt.${RESOL}${NIVEL}.${LABELI}.${MAQUI}

MONITORID=${RANDOM}

cat <<EOT0 > ${SCRIPTSFILE}
#!/bin/bash -x
#PBS -o ${DK_suite}/../rdpert/output/${SCRIPTSFILE}.${RUNTM}.out
#PBS -e ${DK_suite}/../rdpert/output/${SCRIPTSFILE}.${RUNTM}.err
#PBS -S /bin/bash
#PBS -l walltime=0:10:00
#PBS -l select=1:ncpus=1
#PBS -A CPTEC
#PBS -V
#PBS -N RDPT${PREFIC}
#PBS -q ${AUX_QUEUE}

export PBS_SERVER=aux20-eth4

cd ${HOME_suite}/../run
. ${FILEENV} ${1} ${2}

#
#  Set date (year,month,day) and hour (hour:minute) 
#
#  DATE=yyyymmdd
#  HOUR=hh:mn
#

export DATE=\$(date +'%Y')\$(date +'%m')\$(date +'%d')
export HOUR=\$(date +'%H:%M')

echo "Date: "\${DATE}
echo "Hour: "\${HOUR}

#
#  LABELI = yyyymmddhh
#  LABELI = input file label
#

export NUMPERT=${NPERT}
export LABELI=${LABELI}

#
#  Prefix names for the FORTRAN files
#
#  NAMER - Recomposed input file prefix
#  NAMEP - Recomposed perturbed file prefix
#

export NAMER=GANL${PREFIC}

#
#  Suffix names for the FORTRAN files
#  EXTR - Recomposed input file extension
#

export EXTR=R.unf

#
#  Set directories
#
#  HOME_suite  is the directory for sources, scripts and
#              printouts files.
#   DK_suite is the directory for input and output data
#            and bin files.
#   DK_suite is the directory for big selected output files.
#   IHOME_suite is the directory for input file.
#

export HOME_suite DK_suite DK_suite IHOME_suite

echo \${HOME_suite}
echo \${DK_suite}
echo \${DK_suite}
echo \${DK_suite}/model/datain

echo "cp ${DK_suite}/../recanl/dataout/${RESOL}${NIVEL}/\${NAMER}\${LABELI}\${EXTR}.${RESOL}${NIVEL} ${DK_suite}/model/datain"
cp ${DK_suite}/../recanl/dataout/${RESOL}${NIVEL}/\${NAMER}\${LABELI}\${EXTR}.${RESOL}${NIVEL} ${DK_suite}/model/datain

cd ${HOME_suite}/../run

#
#  Set Horizontal Truncation and Vertical Layers
#

LEV=${NIVEL}
TRUNC=${RESOL}
export TRUNC LEV

#
#  Now, build the necessary NAMELIST input:
#  Mariane (1999) stdt=0.6 K, stdu=3 m/s
#

cat <<EOT2 > \${DK_suite}/../rdpert/datain/rdpert.nml
 &DATAIN
  FLONW=0
  FLONE=360.0 
  GLATN=90.0  
  GLATS=-90.0
 &END
 &STPRES
  STDP=1.00
 &END
 $(cat ${HOME_suite}/../include/${RESOL}${NIVEL}/temppert_rdp.nml)
 $(cat ${HOME_suite}/../include/${RESOL}${NIVEL}/uvelpert_rdp.nml)
 $(cat ${HOME_suite}/../include/${RESOL}${NIVEL}/vvelpert_rdp.nml)
 $(cat ${HOME_suite}/../include/${RESOL}${NIVEL}/umipert_rdp.nml)
 &HUMIDI
  HUM='${HUMID}'
 &END
 &DATNAM
  DIRO='\${DK_suite}/../recanl/dataout/\${TRUNC}\${LEV}/ '
  DIRP='\${DK_suite}/../rdpert/dataout/\${TRUNC}\${LEV}/ '
  GNAMEO='\${NAMER}\${LABELI}\${EXTR}.\${TRUNC}\${LEV} '
EOT2

mkdir -p \${DK_suite}/../rdpert/dataout/\${TRUNC}\${LEV}/ 

i=1

while [ \${i} -le \${NUMPERT} ]
do

  if [ \${i}  -le 9 ]
  then
cat <<EOT3 >> \${DK_suite}/../rdpert/datain/rdpert.nml
  GNAMEP(\${i})='GANL0\${i}R\${LABELI}\${EXTR}.\${TRUNC}\${LEV}'
EOT3
  else
cat <<EOT3 >> \${DK_suite}/../rdpert/datain/rdpert.nml
  GNAMEP(\${i})='GANL\${i}R\${LABELI}\${EXTR}.\${TRUNC}\${LEV}'
EOT3
  fi

  i=\$((\${i}+1))

done

cat <<EOT4 >> \${DK_suite}/../rdpert/datain/rdpert.nml
 &END
EOT4

cd ${HOME_suite}/../run

#
#  Run Random Perturbation
#

cd ${DK_suite}/../rdpert/bin/\${TRUNC}\${LEV}

./rdpert.\${TRUNC}\${LEV} < ${DK_suite}/../rdpert/datain/rdpert.nml > ${DK_suite}/../rdpert/output/rdpert.out.\${LABELI}.\${HOUR}.\${RESOL}\${NIVEL}

echo "" > ${DK_suite}/../rdpert/bin/\${RESOL}\${NIVEL}/monitor.${MONITORID}
EOT0

# Submete o script e aguarda o fim da execução
chmod +x ${SCRIPTSFILE} 

qsub ${SCRIPTSFILE}

until [ -e "${DK_suite}/../rdpert/bin/${RESOL}${NIVEL}/monitor.${MONITORID}" ]; do sleep 1s; done

rm ${DK_suite}/../rdpert/bin/${RESOL}${NIVEL}/monitor.${MONITORID}

exit 0