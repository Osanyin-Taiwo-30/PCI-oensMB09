#! /bin/ksh -x

. ./config.sx6

##################################################################
#
#BANGU = DIRETORIO HOME DA BANGU
#NOUP = IDENTIFICACAO DO MEMBRO (ex. 01N)
LABELI=$1
NOUP=$2
HH=$3
LABELI=$1$3
#
##################################################################

##################################################################
#
#PRODUTOS
#
#AMM DIRPRDN=/home/ensglob
#
# ---------------  VISUALIZACAO  ------------------
RMTGRU=grads
RMTGRM=cossoca
DIRGRA=/home/grads/scripts/modelos/bin
RMTVIS=desenv
RMTVIS=cossoca
DIRVIS=/home/desenv/chart/ensemble/crontab
#
# ------------------  METOP  ----------------------
#AMM RMTOPE=metop
#AMM RMTOPM=tutoya
#AMM RMHOST=rape
#AMM DIROPE=/metop1/previsao/modelos/bin
#AMM DIRREC=/previsao3/aval_t126/scripts
#
# ------------------   WAM   ----------------------
#AMM RMMWAM=tutoya
#AMM RMTWAM=wam
#AMM DIRWAM=/home/wam/t126_sx6/scripts
#--------------------------------------------------
#
##################################################################

#cd ${BANGU}
#if [ ! -L t126l28 ]
#then
#	ln -sf T126L28 t126l28
#fi

yyyy=`echo ${LABELI} | cut -c 1-4`
mm=`echo ${LABELI} | cut -c 5-6`
dd=`echo ${LABELI} | cut -c 7-8`
hh=`echo ${LABELI} | cut -c 9-10`

TRUNC=T${TRC}
LEV=L${LV}
CASE=${TRUNC}${LEV}
QUEUE=${QUEUEP}
if [ $NOUP = 'ENM' ]
then
	DIRIN=${ROPERM}/ensmed/dataout/${CASE}
	COMP=`${HOME}/bin/caldate.3.0.1 ${LABELI} + 15d 'yyyymmddhh'`
	ls ${DIRIN}/*${LABELI}2* > ${DIRIN}/GPOSENM${LABELI}${COMP}P.fct.${CASE}.lst
else
	DIRIN=${ROPERM}/pos/dataout/${CASE}
fi
DIROUT=/bangu/samfs/modoper/tempo/global/oens/nmc/T126L28/GPOS
DIRGRB=${ROPERM}/produtos/grib
ARQIN=`ls ${DIRIN}/GPOS${NOUP}${LABELI}*.lst`
MODELID=cptec002
DESC='PRESSURE HISTORY    CPTEC AGCM V3.0 1999  '$CASE'  COLD'

export GAUDFT=/usr/local/grads/udf/udft
export GADDIR=/usr/local/grads/dat
export GRADSB=/usr/local/grads/bin
export GASCRP=/usr/local/grads/lib

JNAME=GRIBA${NOUP}

set -e
set -u

cat << EOF > ${OPERM}/produtos/scripts/SetGposGribOens.${NOUP}.sx6
#! /bin/ksh -x
#PBS -N ${JNAME}
#PBS -o ${OPERM}/produtos/scripts/setout/SetGposGribOens.${NOUP}.${LABELI}.out
#PBS -j o

ARQIN=${ARQIN}

##################################################################
##### LATS4D


LABELCTL=`date -d "$yyyy-$mm-$dd" +'%d%b%Y'`
cd $DIROUT/${yyyy}/${mm}/${dd}/
ln -sf GPOS${NOUP}${LABELI}${LABELI}P.icn.${CASE}.grb GPOS${NOUP}${LABELI}${LABELI}P.fct.${CASE}.grb 
cat << EOF2 > GPOS${NOUP}${LABELI}.ctl
dset ^GPOS${NOUP}${LABELI}%y4%m2%d2%h2P.fct.T126L28.grb
options template
title pressure history cptec agcm v3.0 1999 t126l28 cold
undef 1e+20
dtype grib
index ^GPOS${NOUP}${LABELI}.gmp
xdef 384 linear 0.000000 0.937500
ydef 192 levels
-89.284 -88.357 
-87.424 -86.490 -85.556 -84.621 -83.687 -82.752 -81.817 -80.882 -79.947 -79.012 
-78.077 -77.142 -76.207 -75.272 -74.337 -73.402 -72.467 -71.532 -70.597 -69.662 
-68.727 -67.792 -66.857 -65.922 -64.987 -64.052 -63.116 -62.181 -61.246 -60.311 
-59.376 -58.441 -57.506 -56.571 -55.636 -54.701 -53.766 -52.831 -51.896 -50.961 
-50.026 -49.091 -48.156 -47.221 -46.286 -45.350 -44.415 -43.480 -42.545 -41.610 
-40.675 -39.740 -38.805 -37.870 -36.935 -36.000 -35.065 -34.130 -33.195 -32.260 
-31.325 -30.389 -29.454 -28.519 -27.584 -26.649 -25.714 -24.779 -23.844 -22.909 
-21.974 -21.039 -20.104 -19.169 -18.234 -17.299 -16.364 -15.429 -14.493 -13.558 
-12.623 -11.688 -10.753  -9.818  -8.883  -7.948  -7.013  -6.078  -5.143  -4.208 
 -3.273  -2.338  -1.403  -0.468   0.468   1.403   2.338   3.273   4.208   5.143 
  6.078   7.013   7.948   8.883   9.818  10.753  11.688  12.623  13.558  14.493 
 15.429  16.364  17.299  18.234  19.169  20.104  21.039  21.974  22.909  23.844 
 24.779  25.714  26.649  27.584  28.519  29.454  30.389  31.325  32.260  33.195 
 34.130  35.065  36.000  36.935  37.870  38.805  39.740  40.675  41.610  42.545 
 43.480  44.415  45.350  46.286  47.221  48.156  49.091  50.026  50.961  51.896 
 52.831  53.766  54.701  55.636  56.571  57.506  58.441  59.376  60.311  61.246 
 62.181  63.116  64.052  64.987  65.922  66.857  67.792  68.727  69.662  70.597 
 71.532  72.467  73.402  74.337  75.272  76.207  77.142  78.077  79.012  79.947 
 80.882  81.817  82.752  83.687  84.621  85.556  86.490  87.424  88.357  89.284 

zdef 10 levels
1000 925 850 700 500 250 200 100 50 10 
tdef 31 linear ${hh}Z\$LABELCTL  12hr
vars 21
topo      0  132,  1,  0,  0 TOPOGRAPHY [m]
lsmk      0   81,  1,  0,  0 LAND SEA MASK [0,1]
pslc      0  135,  1,  0,  0 SURFACE PRESSURE [hPa]
uves      0  192,  1,  0,  0 SURFACE ZONAL WIND (U) [m/s]
vves      0  194,  1,  0,  0 SURFACE MERIDIONAL WIND (V) [m/s]
psnm      0    2,102,  0,  0 SEA LEVEL PRESSURE [hPa]
tems      0  188,  1,  0,  0 SURFACE ABSOLUTE TEMPERATURE [K]
umrs      0  226,  1,  0,  0 SURFACE RELATIVE HUMIDITY [no Dim]
agpl      0   54,200,  0,  0 INST. PRECIPITABLE WATER [Kg/m2]
tsfc      0  187,  1,  0,  0 SURFACE TEMPERATURE [K]
uvel     10   33,100 ZONAL WIND (U) [m/s]
vvel     10   34,100 MERIDIONAL WIND (V) [m/s]
omeg     10   39,100 OMEGA [Pa/s]
divg     10   44,100 DIVERGENCE [1/s]
vort     10   43,100 VORTICITY [1/s]
fcor     10   35,100 STREAM FUNCTION [m2/s]
potv     10   36,100 VELOCITY POTENTIAL [m2/s]
zgeo     10    7,100 GEOPOTENTIAL HEIGHT [gpm]
temp     10   11,100 ABSOLUTE TEMPERATURE [K]
umrl     10   52,100 RELATIVE HUMIDITY [no Dim]
umes     10   51,100 SPECIFIC HUMIDITY [kg/kg]
endvars
EOF2

/usr/local/grads/bin/gribmap -i GPOS${NOUP}${LABELI}.ctl

##################################################################
##### APAGA OS ARQUIVOS ANTIGOS

#for i in 21 22 23 24 25
#do
#	LABELR=\`%SMSFILES%/bin/caldate.3.0.1 ${LABELI} - \${i}d 'yyyymmddhh'\`
##	yyyyr=\`echo \${LABELR} | cut -c 1-4\` 
#	mmr=\`echo \${LABELR} | cut -c 5-6\` 
#	ddr=\`echo \${LABELR} | cut -c 7-8\`
#
#	echo "rm -f ${DIROUT}/\${yyyyr}/\${mmr}/\${ddr}/GPOS${NOUP}\${LABELR}*"
#	rm -f ${DIROUT}/\${yyyyr}/\${mmr}/\${ddr}/GPOS${NOUP}\${LABELR}*
#done

exit 0
EOF

set +e
set +u

##############################################################################################
# QSUB
#

chmod 755 ${OPERM}/produtos/scripts/SetGposGribOens.${NOUP}.sx6
#/usr/bin/nqsII/qsub -q ${QUEUE} ${OPERM}/produtos/scripts/SetGposGribOens.${NOUP}.sx6
${OPERM}/produtos/scripts/SetGposGribOens.${NOUP}.sx6

exit 0