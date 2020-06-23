#!/bin/ksh
#help#
#***********************************************************************#
#                                                                       #
#     Name:           runaccumulated.sx6                                #
#                                                                       #
#     Function:       This script evaluate the accumulated              #
#                     from CPTEC global ensemble forecasting.           #
#                     It runs in Korn Shell.                            #
#                                                                       #
#     Date:           Apr 04th, 2005.                                   #
#     Last change:    Apr 04th, 2005.                                   #
#                                                                       #
#     Valid Arguments for runaccumulated.sx6:                           #
#                                                                       #
#      First:    COMPILE: help, make, clean or run                      #
#     Second:        TRC: three-digit triangular truncation             #
#      Third:         LV: two-digit number of vertical sigma-layers     #
#     Fourth:     LABELI: initial forecasting label                     #
#      Fifth:     NFCTDY: number of forecasting days                    #
#      Sixth:     NMEMBR: total number of members of the ensemble       #
#    Seventh:      PREFX: preffix for input and output files            #
#                                                                       #
#                  LABELx: yyyymmddhh                                   #
#                          yyyy = four digit year                       #
#                            mm = two digit month                       #
#                            dd = two digit day                         #
#                            hh = two digit hour                        #
#                                                                       #
#***********************************************************************#
#            Para compilar:   runaccumulated.sx6 clean
#            Para rodar: runaccumulated.sx6 run 126 28 2008051900 15      15       AVN
#                                               TRC LV LABELI     NFCTOY  NMEMBR  PREFIX
#end#
#
#       Help:
#
#
. ../../include/config.sx6

for arq in `ls -ltr /gfs/dk22/modoper/tempo/global/oens/pos/dataout/T126L28// | grep ^l | awk '{print $9}'`; do
      echo "REMOVENDO $arq"
    rm $arq  
done

LABELI=$1
if [ -s $LABELI ]; then
      echo "ERRO: FALTA PARAMETRO.\nrunmodgmpi.sx6 YYYYMMDDHH"
      exit 1
else
      if [ ${#LABELI} -lt 10 ]; then
            echo "ERRO: PARAMETRO INCORRETO.\nrunmodgmpi.sx6 YYYYMMDDHH"
            exit 2
      else
            YYYY=`echo $LABELI |cut -c 1-4`
            MM=`echo $LABELI |cut -c 5-6`
            DD=`echo $LABELI |cut -c 7-8`
            HH=`echo $LABELI |cut -c 9-10`

            LABELF=`date -d "${NFDAYS} day ${YYYY}${MM}${DD}" +"%Y%m%d${HH}"`
            YYYYF=`echo $LABELF |cut -c 1-4`
            MMF=`echo $LABELF |cut -c 5-6`
            DDF=`echo $LABELF |cut -c 7-8`
            HHF=`echo $LABELF |cut -c 9-10`
      fi
fi

LABELS=`echo $LABELI | cut -c 1-8`
LABELF=`date -d "$LABELS 15 days" +"%Y%m%d${HH}"`

PREFX=$2
NMEMBR=`echo "${NPERT}*2+1" | bc -l`
OUT=out
NPROC=1
#
#  End of setting parameters to run
#
export LABELI LABELF
echo "LABELI="${LABELI}
echo "LABELF="${LABELF}
#
#     Select parameter for the resolution:
#

if [ "run" = "run" ]
then
case ${TRC} in
021) MR=22 ; IR=64 ; JR=32 ; NPGH=93 ;
     DT=1800
;;
030) MR=31 ; IR=96 ; JR=48 ; NPGH=140 ;
     DT=1800
;;
042) MR=43 ; IR=128 ; JR=64 ; NPGH=187 ;
     DT=1800
;;
047) MR=48 ; IR=144 ; JR=72 ; NPGH=26 ;
     DT=1200
;;
062) MR=63 ; IR=192 ; JR=96 ; NPGH=315 ;
     DT=1200
;;
079) MR=80 ; IR=240 ; JR=120 ; NPGH=26 ;
     DT=900
;;
085) MR=86 ; IR=256 ; JR=128 ; NPGH=26 ;
     DT=720
;;
094) MR=95 ; IR=288 ; JR=144 ; NPGH=591 ;
     DT=720
;;
106) MR=107 ; IR=320 ; JR=160 ; NPGH=711 ;
     DT=600
;;
126) MR=127 ; IR=384 ; JR=192 ; NPGH=284 ;
     DT=600
;;
159) MR=160 ; IR=480 ; JR=240 ; NPGH=1454 ;
     DT=450
;;
170) MR=171 ; IR=512 ; JR=256 ; NPGH=1633 ;
     DT=450
;;
213) MR=214 ; IR=640 ; JR=320 ; NPGH=2466 ;
     DT=360
;;
254) MR=255 ; IR=768 ; JR=384 ; NPGH=3502 ;
     DT=300
;;
319) MR=320 ; IR=960 ; JR=480 ; NPGH=26 ;
     DT=240
;;
*) echo "Wrong request for horizontal resolution: ${TRC}" ; exit 1;
esac
fi
#
#   Set host, machine, NQS Queue, Run time and Extention
#
HSTMAQ=`hostname`
MAQUI=sx6
RUNTM=`date +'%Y%m%d%T'`
EXT=${OUT}
echo ${MAQUI}
echo ${QUEUEP}
echo ${RUNTM}
echo ${EXT}
#
#   Set directories
#
#   OPERMO is the directory for sources, scripts and printouts.
#   SOPERM is the directory for input and output files.
#   ROPERM is the directory for big selected output files.
#   DIRBAN is the directory for archive files.
#
#. config.scr
#OPERM=/gfs/home1/prestrel/wgne
#SOPERM=/gfs/home1/prestrel/wgne
#ROPERM=/gfs/home1/prestrel/wgne
#OPERMOD=/gfs/home1/prestrel/wgne
echo ${OPERM}
echo ${SOPERM}
echo ${ROPERM}
#
#   Set truncation and layers
#
RESOL=T${TRC}
NIVEL=L${LV}
#
cd ${OPERM}
#
LABEL12=`date -d "${YYYY}${MM}${DD} ${HH}:00 00 hours ago" +"%Y%m%d%H"`
YYYY12=`echo $LABEL12 | cut -c 1-4`
MM12=`echo $LABEL12 | cut -c 5-6`
DD12=`echo $LABEL12 | cut -c 7-8`
#
LABEL24=`date -d "${YYYY}${MM}${DD} ${HH}:00 24 hours ago" +"%Y%m%d%H"`
YYYY24=`echo $LABEL24 | cut -c 1-4`
MM24=`echo $LABEL24 | cut -c 5-6`
DD24=`echo $LABEL24 | cut -c 7-8`
#
#echo ${BANGU}/GPOS/${YYYY12}/${MM12}/${DD12}/GPOS???${LABEL12}
#echo ${BANGU}/GPOS/${YYYY24}/${MM24}/${DD24}/GPOS???${LABEL24}

cat <<EOT0 > ${OPERM}/run/setaccumulated${RESOL}${NIVEL}.${MAQUI}
#!/bin/ksh 
#PBS -l cpunum_prc=${NPROC}
#PBS -l tasknum_prc=${NPROC}
#PBS -l memsz_job=5.0gb  
#PBS -l cputim_job=50000
#
#*****************************************************************#
#                                                                 #
#       Name:           setaccumulated${RESOL}${NIVEL}.${MAQUI}   #
#                                                                 #
#       Function:       This script file is used to set the       #
#                       environmental variables and start         #
#                       the week mean precipitation.              #
#                                                                 #
#*****************************************************************#
#
#  At SX6 Both the output (stdout) and the error
#  messages (stderr) are written to the same file
#
#
#PBS -o ${HSTMAQ}:${OPERM}/setaccumulated${RESOL}${NIVEL}.${MAQUI}.${RUNTM}.${EXT}
#PBS -j o
#
#   Set date (day,month,year) and hour (hour:minute) 
#
#   DATE=yyyymmdd
#   HOUR=hh:mn:ss
#
DATE=`date +'%Y%m%d'`
HOUR=`date +'%T'`
export DATE HOUR
#
set -x
#cp -rpf ${BANGU}/GPOS/${YYYY12}/${MM12}/${DD12}/GPOS???${LABEL12}* ${ROPERM}/pos/dataout/${RESOL}${NIVEL}/
#cp -rpf ${BANGU}/GPOS/${YYYY24}/${MM24}/${DD24}/GPOS???${LABEL24}* ${ROPERM}/pos/dataout/${RESOL}${NIVEL}/

ln -s /rede/nas/modoper/tempo/global/oens/nmc/T126L28/GPOS/${YYYY12}/${MM12}/${DD12}/GPOS???${LABEL12}* /gfs/dk22/modoper/tempo/global/oens/pos/dataout/T126L28
ln -s /rede/nas/modoper/tempo/global/oens/nmc/T126L28/GPOS/${YYYY24}/${MM24}/${DD24}/GPOS???${LABEL24}* /gfs/dk22/modoper/tempo/global/oens/pos/dataout/T126L28
set +x

#
#   Set directories
#
#   OPERMOD  is the directory for sources, scripts and
#            printouts files.
#   SOPERMOD is the directory for input and output data
#            and bin files.
#   ROPERMOD is the directory for big selected output files.
#
OPERMOD=${OPERM}
SOPERMOD=${ROPERM}
ROPERMOD=${ROPERM}
export OPERMOD SOPERMOD ROPERMOD
echo \${OPERMOD}
echo \${SOPERMOD}
echo \${ROPERMOD}
#
cd \${OPERMOD}
#
#   Set Horizontal Truncation and Vertical Layers
#
LEV=${NIVEL}
TRUNC=${RESOL}
export TRUNC LEV
#
#   Set machine
MACH=${MAQUI}
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
COMPILE=run
export COMPILE
echo \${COMPILE}
#
# Define variables to generate variable data file names:
#
OUT=${EXT}
export OUT
#
EXTS=S.unf
export EXTS 
#
#   Set SX6 FORTRAN variables for output time diagnostics
#
#   F_PROGINF gives the elapsed, user, system and vector instruction
#             execution time, and execution count of all instructions
#             and number of vector instruction executions.
#   F_FILEINF gives informations about I/O operations.
#
F_PROGINF=DETAIL
export F_PROGINF
#
#   Set FORTRAN compilation flags
#
#   -float0 floating-point data format IEEE is enabled
#   -ew     sets the basic numeric size to 8 bytes
#
#   Set FORTRAN environment file name
#
#   FFFn is associated with FORTRAN file unit = n
#
FFF=F_FF
export FFF
#
#   Set environmental variables to binary conversion
#
#
F_UFMTIEEE=70,71,80
export F_UFMTIEEE
F_UFMTADJUST70=TYPE2
F_UFMTADJUST71=TYPE2
F_UFMTADJUST80=TYPE2
export F_UFMTADJUST70 F_UFMTADJUST71 F_UFMTADJUST80
#
F_SETBUF=2048
export F_SETBUF
echo " F_SETBUF = \${F_SETBUF}"
#
#  Now, verify if compile or run
#
if [ "\${COMPILE}" != "run" ]
then
cd \${OPERMOD}
#make -f Makefile clean
#make -f Makefile
#
make -f Makefile_accum clean
make -f Makefile_accum

#
else
#
#   Run prcmed
#
#Parameter to be read by prcmed.f90 : namelist file
#UNDEF     : ( REAL    ) undef value set up according to original grib files
#IMAX      : ( INTEGER ) number of points in zonal direction
#JMAX      : ( INTEGER ) number of points in merdional direction
#NMEMBERS  : ( INTEGER ) number of members of the ensemble
#NFCTDY    : ( INTEGER ) number of forecast days
#FREQCALC  : ( INTEGER ) interval in hours of output ensemble forecast
#DIRINP    : ( CHAR    ) input directory (ensemble members)
#DIROUT    : ( CHAR    ) output directory (accumulated outputs)
#RESOL     : ( CHAR    ) horizontal and vertical model resolution
#PREFX     : ( CHAR    ) preffix for input and output files 
#DIRLAB=`echo ${LABELI} | cut -c1-8`
cat <<EOT > \${OPERMOD}/run/accumsetup.${LABELI}.nml
UNDEF     :   -9999
IMAX      :   ${IR}
JMAX      :   ${JR}
IMAXINT   :   144
JMAXINT   :   73
NMEMBERS  :   ${NMEMBR}
NFCTDY    :   ${FSCT}
FREQCALC  :   6
DIRINP    :   ${ROPERM}/pos/dataout/T${TRC}L${LV}/
DIROUT    :   ${ROPERM}/wgne/dataout/T${TRC}L${LV}/
RESOL     :   \${TRUNC}\${LEV}
PREFX     :   ${PREFX}
EOT
#
#DIRINP    :   /rede/nas/io_dop/tigge/pos/\${DIRLAB}/
#DIRINP    :   /gfs/dk10/prestrel/wgne/datain/
#-------------------------------------------------------------

#
#   Run the accumulated fortran program
#
cd \${OPERMOD}/run
\${OPERMOD}/wgne/bin/accumulated.exe ${LABELI}

#rm -f ${ROPERM}/pos/dataout/${RESOL}${NIVEL}/GPOS???${LABEL12}*
#rm -f ${ROPERM}/pos/dataout/${RESOL}${NIVEL}/GPOS???${LABEL24}*
#
#   Transfer files of accumulated to bangu and generate the figures
#
cd \${OPERMOD}/run
#echo "\${OPERMOD}/runtransfer.accumbab.${MAQUI} ${TRC} ${LV} ${LABELI} ${NFCTDY} ${EXP}"
#\${OPERMOD}/runtransfer.accumab.${MAQUI} ${TRC} ${LV} ${LABELI} ${NFCTDY} ${EXP}
#
fi
#
EOT0
#
chmod +x setaccumulated${RESOL}${NIVEL}.${MAQUI}
#
#   Run accumulated script
#
echo 'accumulated  -- Run script ...'
#
echo 'accumulated  -- SUBMITTED TO NQS QUEUE ...'
#
echo "/usr/bin/nqsII/qsub -q ${QUEUE} ${OPERM}/Setaccumulated${RESOL}${NIVEL}.${MAQUI}"
#/usr/bin/nqsII/qsub -q ${QUEUE} ${OPERM}/setaccumulated${RESOL}${NIVEL}.${MAQUI}
submit ${OPERM}/run/setaccumulated${RESOL}${NIVEL}.${MAQUI} ${QUEUEP}
#
exit 0