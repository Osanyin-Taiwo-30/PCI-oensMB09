#!/bin/bash -x
#help#
#*******************************************************************#
#                                                                   #
#     Name:           runrecfct.una                                 #
#                                                                   #
#     Function:       This script submits the                       #
#                     recomposition scripts.                        #
#                     It runs in Korn Shell.                        #
#                                                                   #
#     Date:           Sep    27th, 2011.                            #
#     Last change:    Sep    27th, 2011.                            #
#                                                                   #
#     Valid Arguments for runrecfct.una                             #
#                                                                   #
#     First  : COMPILE: help, make, clean or run                    #
#     Second :     TRC: three-digit triangular truncation           #
#     Third  :      LV: two-digit number of vertical sigma-layers   #
#     Fourth :   TYPES: input spectral file type                    #
#     Fifth  :  LABELI: input field start label                     #
#     Sixth  :  LABELF: input field final label                     #
#                       or none for analysis                        #
#     Seventh:  PERT: NMC, AVN CTR 01N                              #
#                                                                   #
#               TYPES : ANLAVN: for analysis                        #
#                       PERCTR: for control forecast                #
#                       PER01R: for pertubation 1 forecast          #
#                       PER02R: for pertubation 2 forecast          #
#              LABELx : yyyymmddhh                                  #
#                       yyyy = four digit year                      #
#                       mm = two digit month                        #
#                       dd = two digit day                          #
#                       hh = two digit hour                         #
#                                                                   #
#*******************************************************************#
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
if [ -z "${2}" ]
then
echo "Second argument is not set: TRC"
exit
fi
if [ -z "${3}" ]
then
echo "Third argument is not set: LV"
exit
fi
if [ "${1}" = "run" ]
then
if [ -z "${4}" ]
then
echo "Fourth argument is not set: TYPES"
exit
else
PERR=${4}
fi
if [ -z "${5}" ]
then
echo "Fifth argument is not set (LABELI: yyyymmddhh)"
exit
fi
if [ ${4} != "ANLAVN" -a -z "${6}" ]
then
echo "Sixth argument is not set (LABELF: yyyymmddhh)"
exit
fi
if [ -z "${7}" ]
then
echo "Seventh argument is not set: PERT"
exit
else
PERT=${7}
fi
if [ "$#" == 8 ]
then 
  export hold=${8}  
else 
  export hold=""
fi
echo $hold
fi
#
#   Set truncation and layers
#
TRC=`echo ${2} |awk '{ printf("%3.3d\n",$1)  }' `
LV=`echo ${3} |awk '{ printf("%2.2d\n",$1)  }' `
export RESOL=`echo ${TRC} |awk '{ printf("TQ%4.4d\n",$1)  }' `
export NIVEL=`echo ${LV} |awk '{ printf("L%3.3d\n",$1)  }' `
#
case ${TRC} in
021) MR=21 ; IR=64 ; JR=32 ; 
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
030) MR=30 ; IR=96 ; JR=48 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
042) MR=42 ; IR=128 ; JR=64 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=11 ;;
     28) KR=28 ; LR=11 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
047) MR=47 ; IR=144 ; JR=72 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
062) MR=62 ; IR=192 ; JR=96 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=11 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
079) MR=79 ; IR=240 ; JR=120 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
095) MR=95 ; IR=288 ; JR=144 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
106) MR=106 ; IR=320 ; JR=160 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
126) MR=126 ; IR=384 ; JR=192 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=11 ;;
     28) KR=28 ; LR=11 ;;
     42) KR=42 ; LR=11 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
159) MR=159 ; IR=480 ; JR=240 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
170) MR=170 ; IR=512 ; JR=256 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
213) MR=213 ; IR=640 ; JR=320 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
319) MR=319 ; IR=960 ; JR=480 ;
     case ${LV} in
     09) KR=09 ; LR=11 ;;
     18) KR=18 ; LR=13 ;;
     28) KR=28 ; LR=17 ;;
     42) KR=42 ; LR=18 ;;
     *) echo "Wrong request for vertical resolution: ${LV}" ; exit 1 ;;
     esac
;;
*) echo "Wrong request for horizontal resolution: ${TRC}" ; exit 1;
esac

CASE=`echo ${TRC} ${LV} |awk '{ printf("TQ%4.4dL%3.3d\n",$1,$2)  }' `

#
#   Set machine, Run time and Extention
#
HSTMAQ=`hostname`
MAQUI=una
MACHINE=una
QUEUE=PNT-EN
RUNTM=`date +'%y'``date +'%m'``date +'%d'``date +'%H:%M'`
EXT=out
echo ${MACHINE}
echo ${QUEUE}
echo ${RUNTM}
echo ${EXT}
#
#   Set directories
#
#   OPERM  is the directory for sources, scripts and printouts.
#   SOPERM is the directory for input and output files.
#   ROPERM is the directory for big selected output files.
#   IOPERM is the directory for the input files.
#
#
#   Set directories
#
#   OPERM  is the directory for sources, scripts and printouts.
#   SOPERM is the directory for input and output files.
#   ROPERM is the directory for big selected output files.
#   IOPERM is the directory for the input files.
#
PATHA=`pwd`
export FILEENV=`find ${PATHA} -name EnvironmentalVariablesMCGA -print`
export PATHENV=`dirname ${FILEENV}`
export PATHBASE=`cd ${PATHENV};cd ../;pwd`
. ${FILEENV} ${CASE} ${PERT}
cd ${HOME_suite}/run

echo ${OPERM}
echo ${SOPERM}
echo ${ROPERM}
echo ${IOPERM}
#
#
export PBS_SERVER=aux20-eth4
mkdir -p ${ROPERM}/recfct/output
SCRIPTNAME=setrecfct.1.${PERR}${RESOL}${NIVEL}.${LABELI}.${MACHINE}
cat <<EOT0 > ${OPERM}/run/${SCRIPTNAME}
#!/bin/bash -x
#
#************************************************************#
#                                                            #
#     Name:        setrecfct${PERR}${RESOL}${NIVEL}.MACHINE #
#                                                            #
#     Function:    This script file is used to set the       #
#                  environmental variables and start the     #
#                  recomposition script.                     #
#                                                            #
#************************************************************#
#
#PBS -o ${HSTMAQ}:${ROPERM}/recfct/output/setrecfct.${PERR}.${LABELI}${LABELF}.${RUNTM}.${EXT}
#PBS -j oe
#PBS -l walltime=0:30:00
###############PBS -l mppwidth=1
#PBS -l mppnppn=1
#PBS -A CPTEC
#PBS -V
#PBS -S /bin/bash
#PBS -N RECFCT${PERT}
#PBS -q ${AUX_QUEUE}
export PBS_SERVER=aux20-eth4

#
#
#   Set date (year,month,day) and hour (hour:minute) 
#
#   DATE=yyyymmdd
#   HOUR=hh:mn
#
DATE=`date +'%Y'``date +'%m'``date +'%d'`
HOUR=`date +'%H:%M'`
echo 'Date: '\$DATE
echo 'Hour: '\$HOUR
export DATE HOUR
#
#   Set labels (date, UTC hour, ...)
#
TYPES=${4} 
echo \${TYPES}
export TYPES 
#   LABELI = yyyymmddhh
#   LABELI = input file start label
#
LABELI=${5}
echo \${LABELI}
export LABELI
#   LABELF = yyyymmddhh
#   LABELF = input file final label
#
LABELF=${6}
echo \${LABELF}
export LABELF
#
#   Prefix names for the FORTRAN files
#
#   NAMEL - List file name prefix
#   NAMES - Input spectral file name prefix
#   NAMER - Output gridded file name prefix
#
#   Suffix names for the FORTRAN files
#
#   EXTL - List file name suffix
#   ERSi - Input spectral file name suffix
#   ERRi - Output gridded file name suffix
#
NAMEL=G\${TYPES}
echo \${NAMEL}
export NAMEL
NAMES=G\${TYPES}
echo \${NAMES}
export NAMES
NAMER=G\${TYPES}
echo \${NAMER}
export NAMER
if [ "\${TYPES}" = ANLAVN ] 
then
EXTL=S.unf
echo \${EXTL}
export EXTL
ERS1=S.unf
echo \${ERS1}
export ERS1
ERR1=R.unf
echo \${ERR1}
export ERR1
else
EXTL=F.fct
echo \${EXTL}
export EXTL
ERS1=F.fct
echo \${ERS1}
export ERS1
ERR1=R.fct
echo \${ERR1}
export ERR1
fi
#
#   Set directories
#
#   OPERMOD  is the directory for sources, scripts and
#            printouts files.
#   SOPERMOD is the directory for input and output data
#            and bin files.
#   ROPERMOD is the directory for big selected output files.
#   IOPERMOD is the directory for input file.
#
OPERMOD=${OPERM}
SOPERMOD=${SOPERM}
ROPERMOD=${ROPERM}
IOPERMOD=${IOPERM}
export OPERMOD SOPERMOD ROPERMOD IOPERMOD
echo \${OPERMOD}
echo \${SOPERMOD}
echo \${ROPERMOD}
echo \${IOPERMOD}
#
cd ${HOME_suite}/run
#
#   Set Horizontal Truncation and Vertical Layers
#
LEV=${NIVEL}
TRUNC=${RESOL}
export TRUNC LEV
#
#   Set machine
MACH=${MACHINE}
export MACH
#
#   Set option for compiling or not the source codes.
#
#   If COMPILE=make then only the modified sources will be compiled.
#   If COMPILE=clean then the touch files will be removed and 
#              all sources will be compiled.
#             =run for run with no compilation
#
#   If COMPILE is make or clean then the script generates the binary file 
#              and exits;
#              if it is run then the script runs the existent binary file.
#
echo ${1}
COMPILE=${1}
echo \${COMPILE}
export COMPILE
#
#   Set FORTRAN compilation flags
#
#   -integer_size 64 sets the integer basic numeric size to 8 bytes
#   -real_size 64    sets the real basic numeric size to 8 bytes
#
#
#FTNFLAG='-Wf" -pvctl noaltcode -O nodiv nomove "'
#FTNFLAG='  -h byteswapio -s real64 -s integer64  '
FTNFLAG='  -byteswapio -r8 -i8'

export FTNFLAG
#
#   Set C pre-processing flags
#
INC=\${OPERMOD}/include/\${TRUNC}\${LEV}
CPP=" -I\${INC}"
export INC CPP
#
#   Set FORTRAN compiler name
#
#F77="f90 -V -float0 -ew "
F77="ftn  "
export F77
#
#   Set FORTRAN environment file name
#
#   $FFFn is associated with FORTRAN file unit = n
#
#FFF=FORT
#export FFF
#
#   Set environmental variables to binary conversion
#
#FORT_CONVERT10=BIG_ENDIAN
#FORT_CONVERT20=BIG_ENDIAN
#export FORT_CONVERT10 FORT_CONVERT20
#
F_UFMTIEEE=10,20
F_UFMTADJUST10=TYPE2
F_UFMTADJUST20=TYPE2
export F_UFMTIEEE F_UFMTADJUST10 F_UFMTADJUST20
#export F_UFMTIEEE F_UFMTADJUST10
#
#  Now, build the necessary INCLUDE for the choosen truncation and 
#       vertical resolution.. 
#
  if [ "\${COMPILE}" != "run" ]
  then
#
cd \${INC}
#
cat <<EOT1 > recfct.n
      INTEGER IMAX,JMAX,MEND,KMAX,LMAX
      PARAMETER (IMAX=${IR},JMAX=${JR},MEND=${MR},KMAX=${KR},LMAX=${LR})
EOT1
if (diff recfct.n recfct.h > /dev/null)
then
    echo "recfct.n and recfct.h are the same"
    rm -f recfct.n
else
    echo "recfct.n and recfct.h are different"
    mv recfct.n recfct.h
fi
#
#  End of includes
#
fi
#
#  Now, build the necessary NAMELIST input:
#
GNAMEL=\${NAMEL}\${LABELI}\${LABELF}\${EXTL}.\${TRUNC}\${LEV}
echo \${GNAMEL}
echo \${SOPERMOD}/recfct/datain/\${GNAMEL}
#
cat <<EOT2 > \${SOPERMOD}/recfct/datain/\${GNAMEL}
\${NAMES}\${LABELI}\${LABELF}\${ERS1}.\${TRUNC}\${LEV}
\${NAMER}\${LABELI}\${LABELF}\${ERR1}.\${TRUNC}\${LEV}
EOT2
#
cat <<EOT3 > \${SOPERMOD}/recfct/datain/recfct\${TYPES}.nml
 &DATAIN
  LDIM=1
  DIRL='\${SOPERMOD}/recfct/datain/ '
  DIRS='\${ROPERMOD}/model/dataout/\${TRUNC}\${LEV}/\${LABELI}/  '
  DIRR='\${ROPERMOD}/recfct/dataout/\${TRUNC}\${LEV}/ '
  GNAMEL='\${GNAMEL} '
 &END
EOT3
#
#
mkdir -p \${ROPERMOD}/recfct/dataout/\${TRUNC}\${LEV}/
cd ${HOME_suite}/run
#
#   Run Decomposition
#
\${OPERMOD}/recfct/scripts/recfct.scr
#
EOT0
#
#   Change mode to be executable
#
chmod 744 ${OPERM}/run/${SCRIPTNAME}
#
#   Submit ${SCRIPTNAME} to NQS ${QUEUE}
#
#AMM echo "qsub -x -s /bin/ksh -q ${QUEUE} ${OPERM}/run/${SCRIPTNAME}"
#AMM qsub -x -s /bin/ksh -q ${QUEUE} ${OPERM}/run/${SCRIPTNAME}
#echo "${OPERM}/run/${SCRIPTNAME}"
#${OPERM}/run/${SCRIPTNAME}
echo "qsub ${OPERM}/run/${SCRIPTNAME}"
#qsub  ${OPERM}/run/${SCRIPTNAME}


if [[ ${it} -eq 1 ]];then
FIRST=`qsub  ${OPERM}/run/${SCRIPTNAME}`
export FIRST
echo $FIRST
export JID=${FIRST}
else
SECOND=`qsub -W depend=afterok:$FIRST ${OPERM}/run/${SCRIPTNAME}`
export FIRST=`qstat | grep -i RECFCT${PERT} | awk '{print $1}'`
echo $SECOND
export JID=${SECOND}
fi

if [ "$hold" == "" ]
then
echo "$hold = NO"
else 
echo "$hold = YES"
itt=2
sleep 45
while [ ${itt} -gt 0 ];do
sleep 20
itt=`qstat_aux | grep ${USER} | grep RECFCT${PERT}| wc -l`
itt2=`qstat | grep ${USER} | grep RECFCT${PERT}| wc -l`
let itt=${itt}+${itt2}
done
fi