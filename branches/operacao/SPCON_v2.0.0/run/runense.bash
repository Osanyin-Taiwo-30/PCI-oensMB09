#!/bin/bash -x
#help#
#******************************************************************#
#                                                                  #
#     Name:           runense.una                                  #
#                                                                  #
#     Function:       This script submits the                      #
#                     ensemble script.                             #
#                     It runs in Korn Shell.                       #
#                                                                  #
#     Date:           May    26th, 2003.                           #
#     Last change:    May    26th, 2003.                           #
#                                                                  #
#     Valid Arguments for runense.sx6                              #
#                                                                  #
#     First  :    HELP: help or nothing for getting help           #
#     First  : COMPILE: help, make, clean or run                   #
#     Second :     TRC: three-digit triangular truncation          #
#     Third  :      LV: two-digit number of vertical sigma-layers  #
#     Forth  :  LABELI: initial forecasting label                  #
#     Fifth  :  NFDAYS: number of forecasting days                 #
#     Sixth  : NUMPERT: number of random perturbations             #
#     Seventh:   HUMID: YES or NO (humidity will be perturbed)     #
#     eigth  :   PREFX: AVN    ...(humidity will be perturbed)     #
#                                                                  #
#              LABELx : yyyymmddhh                                 #
#                       yyyy = four digit year                     #
#                       mm = two digit month                       #
#                       dd = two digit day                         #
#                       hh = two digit hour                        #
#                                                                  #
#******************************************************************#
#help#
#
#       Help:
#
if [ "${1}" = "help" -o -z "${1}" ]
then
cat < ${0} | sed -n '/^#help#/,/^#help#/p'
exit 0
fi
#
#       Test of Valid Arguments
#
if [ "${1}" != "run" ]
then
if [ "${1}" != "make" ]
then
if [ "${1}" != "clean" ]
then
echo "First argument: ${1}, is wrong. Must be: make, clean or run"
exit
fi
fi
fi

if [  -z "${3}" ]
then
echo "Second argument is not set (LV)"
exit
fi
if [  -z "${4}" ]
then
echo "Third argument is not set (LABELI yyyymmddhh)"
exit
fi
if [  -z "${5}" ]
then
echo "Forth argument is not set (NFDAYS)"
exit
fi
if [  -z "${6}" ]
then
echo "Fifth argument is not set (NUMPERT)"
exit
fi
if [  -z "${7}" ]
then
echo "Sixth argument is not set (HUMID)"
exit
else
if [ "${7}" != "YES" ]
then
if [ "${7}" != "NO" ]
then
echo "Sixth argument: ${7}, is wrong. Must be: YES or NO"
exit
fi 
fi
HUMID=${7}
fi
if [ -z "${8}" ]
then
PREFX=AVN
else
PREFX=${8}
fi
#
#   Set machine, Run time and Extention
#
COMPILE=${1}
CASE=`echo ${2} ${3} |awk '{ printf("TQ%4.4dL%3.3d\n",$1,$2)  }' `
HSTMAQ=`hostname`
MACHINE=una
RUNTM=`date +'%Y'``date +'%m'``date +'%d'``date +'%H:%M'`
QUEUE=Inter
EXT=out
EXTL=S.unf
EXTR=R.unf
EXTZ=Z
echo ${MACHINE}
echo ${RUNTM}
echo ${EXT}

#
#   Set directories and remote machines
#
#   OPERM  is the directory for sources, scripts and printouts.
#   SOPERM is the directory for input and output files.
#   ROPERM is the directory for big selected output files.
#   IOPERM is the directory for the input files.
#   RMTCPR: is the remote machine to run the special products.
#   RMUSCF: is the remote archieve machine user.
#   DIRSCR: is the directory of the machine RMTCPR where there
#           are the scripts to create the archive directories.

#
#. ../include/config.sx6 #ARQUIVO DE CONFIGURACAO OS DIRETORIOS.
PATHA=`pwd`
export FILEENV=`find ${PATHA} -name EnvironmentalVariablesMCGA -print`
export PATHENV=`dirname ${FILEENV}`
export PATHBASE=`cd ${PATHENV};cd ../;pwd`
. ${FILEENV} ${CASE} ${PREFX}
cd ${HOME_suite}/run


#DIRSCR=/home/ensglob/scripts
echo ${OPERM}
echo ${SOPERM}
echo ${ROPERM}
echo ${IOPERM}
echo ${RCTROPERM}
export OPERM SOPERM ROPERM IOPERM 
export RMTCPR RMUSCF DIRSCR

#
#   Set truncation and layers
#
TRC=${2}
LV=${3}
RESOL=T${TRC}
NIVEL=L${LV}
export RESOL NIVEL
#
LABELI=${4}
#AMM LABELF=${4}
NFDAYS=${5}
NUMPERT=${6}
export LABELI NFDAYS NUMPERT

#   Set final forecasting label and UTC Hour
caldaya ()
{
echo ${LABELI} > labeli.out
yi=`awk '{ print substr($1,1,4) }' labeli.out`
mi=`awk '{ print substr($1,5,2) }' labeli.out`
di=`awk '{ print substr($1,7,2) }' labeli.out`
hi=`awk '{ print substr($1,9,2) }' labeli.out`
rm -f labeli.out
let ybi=${yi}%4
if [ ${ybi} = 0 ]
then
declare -a md=( 31 29 31 30 31 30 31 31 30 31 30 31 )
else
declare -a md=( 31 28 31 30 31 30 31 31 30 31 30 31 )
fi
let df=${di}+1
let mf=${mi}
let yf=${yi}
let hf=${hi}+12
let n=${mi}-1
if [ ${hf} -gt 23 ]
then
let hf=${hf}-24
let df=${df}+1
fi
if [ ${df} -gt ${md[${n}]} ]
then
let df=${df}-${md[${n}]}
let mf=${mf}+1
if [ ${mf} -eq 13 ]
then
let mf=1
let yf=${yf}+1
fi
fi
if [ ${df} -lt 10 ]
then DF=0${df}
else DF=${df}
fi
if [ ${mf} -lt 10 ]
then MF=0${mf}
else MF=${mf}
fi
YF=${yf}
if [ ${hf} -lt 10 ]
then HF=0${hf}
else HF=${hf}
fi
}
#
caldaya

LABELF=${YF}${MF}${DF}${HF}
LABELS=${yi}${mi}${di}
export LABELF LABELS

cd ${OPERM}/run
#
#   Create the archive directories
#
echo "makedir.scr ${TRC} ${LV} ${LABELI}"
#ADMA 

. makedir1.scr ${TRC} ${LV} ${LABELI} > ${OPERM}/run/setout/setmakedir${RESOL}${NIVEL}.${MACHINE}.${LABELI}.${RUNTM}.${EXT}

cat <<EOT0 > ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}
#!/bin/bash -x
#
#************************************************************#
#                                                            #
#     Name:        setense${RESOL}${NIVEL}.${MACHINE}        #
#                                                            #
#     Function:    This script file is used to set the       #
#                  environmental variables and start the     #
#                  ensemble scripts.                         #
#                                                            #
#************************************************************#
#
#  At SX6 Both the output (stdout) and the error
#  messages (stderr) are written to the same file
#
#$ -o ${HSTMAQ}:${OPERM}/run/setout/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}.${RUNTM}.${EXT}
#$ -j o
#
#
cd ${OPERM}/run
#
#   Copy the initial conditions from deterministic forecast datain to
#   ensemble forecast datain
#
cp ${RCTROPERM}/model/datain/SSTWeekly${LABELS}.G* ${ROPERM}/model/datain
#PKUBOTA cp ${RCTROPERM}/model/datain/TopoVariance.G00064 ${ROPERM}/pre/dataout/${RESOL}


#cp ${SCTROPERM}/pre/dataout/${RESOL}/orgwav.${RESOL} ${SOPERM}/pre/dataout/${RESOL}
#
cd ${OPERM}/run
# Script de recomposicao da analise 
echo "\n+++\n+++ runrecanl.${MACHINE} ${COMPILE} ${TRC} ${LV} ANL${PREFX} ${LABELI}\n+++\n"
it=1
export FIRST='     '
export SECOND='     '
export it
${OPERM}/run/runrecanl.${MACHINE} ${COMPILE} ${TRC} ${LV} ANL${PREFX} ${LABELI} hold
let it=${it}+1
export it
#
sleep 30
# Script de geracao das perturbacoes randomicas
export FIRST='     '
export SECOND='     '

echo "\n+++\n+++ runrdpt.${MACHINE} ${COMPILE} ${NUMPERT} ${TRC} ${LV} ${LABELI} ${HUMID} ${PREFX}\n+++\n"
${OPERM}/run/runrdpt.${MACHINE} ${COMPILE} ${NUMPERT} ${TRC} ${LV} ${LABELI} ${HUMID} ${PREFX} hold
let it=${it}+1
export it
sleep 30
#
# Script de decomposicao das perturbacoes
export FIRST='     '
export SECOND='     '

echo "\n+++\n+++ rundrpt.${MACHINE} ${COMPILE} ${NUMPERT} ${TRC} ${LV} ${LABELI} ${HUMID}\n+++\n"
${OPERM}/run/rundrpt.${MACHINE} ${COMPILE} ${NUMPERT} ${TRC} ${LV} ${LABELI} ${HUMID} ${PREFX} hold
let it=${it}+1
export it
# 
# Script runctrpntg roda o modelo (controle)
# RODAR SEPARADO PARA USAR 4 PROCESSADORES.
#echo "\n+++\n+++ runctrpntg.${MACHINE} ${TRC} ${LV} ${LABELI} ${LABELF} sstwkl\n+++\n"
#runctrpntg1.${MACHINE} ${TRC} ${LV} ${LABELI} ${LABELF} sstwkl

exit 0
EOT0
#
echo "chmod 744  setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}"
chmod 744  ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}
#
#   Submit setense.1.${RESOL}${NIVEL}.${MACHINE} to NQS ${QUEUE}
#
echo "/usr/bin/nqsII/qsub -N CTROENS -q ${QUEUE} ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}"
#/usr/bin/nqsII/qsub -q ${QUEUE} -N PERTANL ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}

#submit ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}

. ${OPERM}/run/setense.1.${RESOL}${NIVEL}.${LABELI}.${MACHINE}
exit 0