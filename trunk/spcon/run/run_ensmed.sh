#! /bin/bash 
#--------------------------------------------------------------------#
#  Sistema de Previsão por Conjunto Global - GDAD/CPTEC/INPE - 2017  #
#--------------------------------------------------------------------#
#BOP
#
# !DESCRIPTION:
# Script para o cálculo da média do conjunto de previsões em ponto de grade
# do Sistema de Previsão por Conjunto Global (SPCON) do CPTEC.
#
# !INTERFACE:
#      ./run_ensmed.sh <opcao1> <opcao2> <opcao3> <opcao4> <opcao5> 
#
# !INPUT PARAMETERS:
#  Opcoes..: <opcao1> resolucao -> resolução espectral do modelo
#
#            <opcao2> data      -> data da análise corrente (a partir
#                                  da qual as previsões foram feitas)
#
#            <opcao3> dias      -> dias de previsões que serão consideradas
#                                  a partir da data da análise
#
#            <opcao4> prefixo   -> prefixo que identifica o tipo de análise
#
#            <opcao5> membro    -> tamanho do conjunto
#            
#  Uso/Exemplos: ./run_ensmed.sh TQ0126L028 2020031300 15 NMC 7
#                (calcula a média do conjunto das previsões entre
#                2020031300 e 2020032800 considerando as 7 perturbações 
#                N e Pmembros na resolução TQ0126L028) 
#
# !REVISION HISTORY:
#
# 17 Maio de 2020 - C. F. Bastarz - Versão inicial.  
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

if [ "${1}" = "help" -o -z "${1}" ]
then
  cat < ${0} | sed -n '/^#BOP/,/^#EOP/p'
  exit 0
fi

if [ -z ${1} ]
then
  echo "RES if not set"
  exit 1
else
  export RES=${1}
fi

if [ -z ${2} ]
then
  echo "LABELI is not set"
  exit 1
else
  export LABELI=${2}
fi

if [ -z ${3} ]
then
  echo "NFCTDY is not set"
  exit 1
else
  export NFCTDY=${3}
fi

if [ -z ${4} ]
then
  echo "PREFX is not set"
  exit 1
else
  export PREFX=${4}
fi

if [ -z ${5} ]
then
  echo "NPERT is not set"
  exit 1
else
  export NPERT=${5}
fi

export FILEENV=$(find ./ -name EnvironmentalVariablesMCGA -print)
export PATHENV=$(dirname ${FILEENV})
export PATHBASE=$(cd ${PATHENV}; cd ; pwd)

. ${FILEENV} ${RES} ${PREFIC}

cd ${HOME_suite}/run

TRC=$(echo ${TRCLV} | cut -c 1-6 | tr -d "TQ0")
LV=$(echo ${TRCLV} | cut -c 7-11 | tr -d "L0")

export RESOL=${TRCLV:0:6}
export NIVEL=${TRCLV:6:4}

export NMEMBR=$((2*${NPERT}+1))

export LABELF=$(${inctime} ${LABELI} +${NFCTDY}dy %y4%m2%d2%h2)

case ${TRC} in
  021) MR=22  ; IR=64  ; JR=32  ; NPGH=93   ; DT=1800 ;;
  030) MR=31  ; IR=96  ; JR=48  ; NPGH=140  ; DT=1800 ;;
  042) MR=43  ; IR=128 ; JR=64  ; NPGH=187  ; DT=1800 ;;
  047) MR=48  ; IR=144 ; JR=72  ; NPGH=26   ; DT=1200 ;;
  062) MR=63  ; IR=192 ; JR=96  ; NPGH=315  ; DT=1200 ;;
  079) MR=80  ; IR=240 ; JR=120 ; NPGH=26   ; DT=900  ;;
  085) MR=86  ; IR=256 ; JR=128 ; NPGH=26   ; DT=720  ;;
  094) MR=95  ; IR=288 ; JR=144 ; NPGH=591  ; DT=720  ;;
  106) MR=107 ; IR=320 ; JR=160 ; NPGH=711  ; DT=600  ;;
  126) MR=127 ; IR=384 ; JR=192 ; NPGH=284  ; DT=600  ;;
  159) MR=160 ; IR=480 ; JR=240 ; NPGH=1454 ; DT=450  ;;
  170) MR=171 ; IR=512 ; JR=256 ; NPGH=1633 ; DT=450  ;;
  213) MR=214 ; IR=640 ; JR=320 ; NPGH=2466 ; DT=360  ;;
  254) MR=255 ; IR=768 ; JR=384 ; NPGH=3502 ; DT=300  ;;
  319) MR=320 ; IR=960 ; JR=480 ; NPGH=26   ; DT=240  ;;
  *) echo "Wrong request for horizontal resolution: ${TRC}" ; exit 1;
esac

export RUNTM=$(date +'%Y%m%d%T')

export OPERM=${DK_suite}
export ROPERM=${DK_suite}/produtos

cd ${OPERM}/run

export PBS_SERVER=${pbs_server1}

export SCRIPTFILEPATH=${DK_suite}/run/setensmed${RESOL}${NIVEL}.${MAQUI}

export MPPWIDTH=24
export MPPNPPN=1

cat <<EOT0 > ${SCRIPTFILEPATH}
#!/bin/bash -x
#PBS -o ${ROPERM}/ensmed/output/ensmed.${RUNTM}.out
#PBS -e ${ROPERM}/ensmed/output/ensmed.${RUNTM}.err
#PBS -l walltime=00:10:00
#PBS -l mppwidth=${MPPWIDTH}
#PBS -l mppnppn=${MPPNPPN}
#PBS -W umask=026
#PBS -A CPTEC
#PBS -V
#PBS -S /bin/bash
#PBS -N ENSMED
#PBS -q ${QUEUE}

export DATE=$(date +'%Y%m%d')
export HOUR=$(date +'%T')

# OPERMOD  is the directory for sources, scripts and printouts files.
# SOPERMOD is the directory for input and output data and bin files.

export OPERMOD=${OPERM}
export SOPERMOD=${ROPERM}

export LEV=${NIVEL}
export TRUNC=${RESOL}
export EXTS=S.unf

# Parametros a serem lidos pelo programa ensmed.f90
# NBYTE     : ( INTEGER ) number of bytes for each grib point information
# NFCTDY    : ( INTEGER ) number of forecast days
# FREQCALC  : ( INTEGER ) interval in hours for computing ensemble mean
# MEMB      : ( INTEIRO ) number of members of the ensemble
# IMAX      : ( INTEIRO ) number of points in zonal direction
# JMAX      : ( INTEIRO ) number of points in merdional direction
# DATAINDIR : ( CHAR    ) input directory (ensemble members)
# DATAOUTDIR: ( CHAR    ) output directory of ensemble mean
# RESOL     : ( CHAR    ) horizontal and vertical model resolution
# PREFX     : ( CHAR    ) preffix for input and output files 
cat <<EOT > \${SOPERMOD}/ensmed/bin/ensmed.${LABELI}.nml
NBYTE     :   2
NFCTDY    :   ${NFCTDY}
FREQCALC  :   6
MEMB      :   ${NMEMBR}
IMAX      :   ${IR}
JMAX      :   ${JR}
DATAINDIR :   \${OPERMOD}/pos/dataout/\${TRUNC}\${LEV}/\${LABELI}/
DATAOUTDIR:   \${SOPERMOD}/ensmed/dataout/\${TRUNC}\${LEV}/\${LABELI}/
RESOL     :   \${TRUNC}\${LEV}
PREFX     :   ${PREFX}
EOT

mkdir -p \${SOPERMOD}/ensmed/dataout/\${TRUNC}\${LEV}/\${LABELI}/

cd \${SOPERMOD}/ensmed/bin

#export PBS_SERVER=${pbs_server1}

time aprun -n ${MPPWIDTH} -N ${MPPNPPN} -ss \${SOPERMOD}/ensmed/bin/ensmed.x ${LABELI} > \${SOPERMOD}/ensmed/output/ensmed.${RUNTM}.log

rm \${SOPERMOD}/ensmed/bin/ensmed-${LABELI}.ok

echo "" > \${SOPERMOD}/ensmed/bin/ensmed-${LABELI}.ok
EOT0

chmod +x ${SCRIPTFILEPATH}

qsub -W block=true ${SCRIPTFILEPATH}

until [ -e "${ROPERM}/ensmed/bin/ensmed-${LABELI}.ok" ]; do sleep 1s; done

for arqctl in $(find ${ROPERM}/ensmed/dataout/${TRCLV}/${LABELI}/ -name "*.ctl")
do
  ${DIRGRADS}/gribmap -i ${arqctl}
done

exit 0
