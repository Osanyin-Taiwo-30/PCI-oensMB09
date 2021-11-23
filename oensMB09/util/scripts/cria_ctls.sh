#! /bin/bash
#--------------------------------------------------------------------#
#  Sistema de Previsão por Conjunto Global - GDAD/CPTEC/INPE - 2017  #
#--------------------------------------------------------------------#
#BOP
#
# !DESCRIPTION:
# Script para criar os arquivos ctl para a visualização dos campos 
# perturbados (com perturbações somadas e subtraídas) a partir
# da análise de EOFs.
#
# !INTERFACE:
#      ./cria_ctls.sh <opcao1> <opcao2> <opcao3> <opcao4> 
#
# !INPUT PARAMETERS:
#  Opcoes..: <opcao1> datai     -> data da análise
#                                
#            <opcao2> trunc     -> truncamento
#
#            <opcao3> nlev      -> número de níveis sigma
#            
#            <opcao4> inpert    -> número de perturbações 
#
#  Uso/Exemplos: ./cria_ctls.sh 2013010100 126 28 7
#                (cria os arquivos ctls para todas as variáveis e regiões e para 7 membros
#                na resolução TQ0126L028 para a data 2013010100)
#                ./cria_ctls.sh 2013010100 213 42 7 
#                (cria os arquivos ctls para todas as variáveis e regiões e para 7 membros
#                na resolução TQ0126L028 para a data 2013010100)
# 
# !REVISION HISTORY:
#
# 24 Agosto de 2018 - C. F. Bastarz - Versão inicial.  
# 19 Agosto de 2019 - C. F. Bastarz - Eliminadas variáveis desnecessários dos ctl's criados;
#                                     Adicionadas as datas corretas dos arquivos.
# 15 Outubro de 2019- C. F. Bastarz - Adicionada a criação de um ctl para ler todos os membros.
#
# !REMARKS:
#
# Este script deve ser alocado no diretório eof/dataout/${resolução}
#
# !TODO:
#
# Adicionar a resolução TQ0299L064.
#
# !BUGS:
#
# Nenhum.
#
#EOP  
#--------------------------------------------------------------------#
#BOC

# Descomentar para debugar
#set -o xtrace

if [ ${#} -ne 4 ]
then
  echo "Uso: ./cria_ctls.sh 2013010100 126 28 7"
  exit 1 
else
  data=${1}
  truc=${2}
  nlev=${3}
  nmem=${4}
fi

data_fmt() {

  yyyy=$(echo ${1} | cut -c 1-4)
  mm=$(echo ${1} | cut -c 5-6)
  dd=$(echo ${1} | cut -c 7-8)
  hh=$(echo ${1} | cut -c 9-10)

  if [ ${mm} -eq 01 ]; then nmm="JAN"; fi
  if [ ${mm} -eq 02 ]; then nmm="FEB"; fi
  if [ ${mm} -eq 03 ]; then nmm="MAR"; fi
  if [ ${mm} -eq 04 ]; then nmm="APR"; fi
  if [ ${mm} -eq 05 ]; then nmm="MAY"; fi
  if [ ${mm} -eq 06 ]; then nmm="JUN"; fi
  if [ ${mm} -eq 07 ]; then nmm="JUL"; fi
  if [ ${mm} -eq 08 ]; then nmm="AUG"; fi
  if [ ${mm} -eq 09 ]; then nmm="SEP"; fi
  if [ ${mm} -eq 10 ]; then nmm="OCT"; fi
  if [ ${mm} -eq 11 ]; then nmm="NOV"; fi
  if [ ${mm} -eq 12 ]; then nmm="DEC"; fi

  export datafmt=${hh}Z${dd}${nmm}${yyyy}

}

Regioes=(hn tr hs nas sas)
Membros=($(seq 1 ${nmem}) ens)
Variaveis=(hum prs tem win)

data_fmt ${data}
edef="
edef ${nmem}
$(for mem in $(seq 1 ${nmem}); do memf=$(printf %02g ${mem}); echo "${memf} 1 ${datafmt}"; done)
endedef
     "

for reg in ${Regioes[@]}
do

  for mem in ${Membros[@]}
  do

    if [ ${mem} == "ens" ]
    then 
      memf=${mem}
    else
      memf=$(printf %02g ${mem})
    fi

    for var in ${Variaveis[@]}
    do

      echo "${reg} - ${memf} - ${var}"

      if [ ${var} == "prs" ]
      then
        varlist="
vars 1
prs  1 99 Surface Pressure Perturbation
endvars
        "
      elif [ ${var} == "win" ]
      then
        varlist="
vars 5
prsc  1 99 Control Surface Pressure
temc ${nlev} 99 Control Air Temperature
humc ${nlev} 99 Control Specific Humidity
uwnp ${nlev} 99 Zonal Wind Perturbation 
vwnp ${nlev} 99 Meridional Wind Perturbation
endvars
       "
      else
        varlist="
vars 1
${var} ${nlev} 99 ${var}
endvars
        "
     fi

      if [ ${truc} == "62" ]
      then
        xydef="
xdef   192 linear    0.000   1.875000000
ydef    96 levels 
 -88.57217 -86.72253 -84.86197 -82.99894 -81.13498 -79.27056 -77.40589 -75.54106
 -73.67613 -71.81113 -69.94608 -68.08099 -66.21587 -64.35073 -62.48557 -60.62040
 -58.75521 -56.89001 -55.02481 -53.15960 -51.29438 -49.42915 -47.56393 -45.69869
 -43.83346 -41.96822 -40.10298 -38.23774 -36.37249 -34.50724 -32.64199 -30.77674
 -28.91149 -27.04624 -25.18099 -23.31573 -21.45048 -19.58522 -17.71996 -15.85470
 -13.98945 -12.12419 -10.25893  -8.39367  -6.52841  -4.66315  -2.79789  -0.93263
   0.93263   2.79789   4.66315   6.52841   8.39367  10.25893  12.12419  13.98945
  15.85470  17.71996  19.58522  21.45048  23.31573  25.18099  27.04624  28.91149
  30.77674  32.64199  34.50724  36.37249  38.23774  40.10298  41.96822  43.83346
  45.69869  47.56393  49.42915  51.29438  53.15960  55.02481  56.89001  58.75521
  60.62040  62.48557  64.35073  66.21587  68.08099  69.94608  71.81113  73.67613
  75.54106  77.40589  79.27056  81.13498  82.99894  84.86197  86.72253  88.57217
        "
      elif [ ${truc} == "126" ]
      then
        xydef="
xdef   384 linear    0.000   0.9375000000
ydef   192 levels 
 -89.28423 -88.35700 -87.42430 -86.49037 -85.55596 -84.62133 -83.68657 -82.75173
 -81.81684 -80.88191 -79.94696 -79.01199 -78.07701 -77.14201 -76.20701 -75.27199
 -74.33697 -73.40195 -72.46692 -71.53189 -70.59685 -69.66182 -68.72678 -67.79173
 -66.85669 -65.92165 -64.98660 -64.05155 -63.11650 -62.18145 -61.24640 -60.31135
 -59.37630 -58.44124 -57.50619 -56.57114 -55.63608 -54.70103 -53.76597 -52.83091
 -51.89586 -50.96080 -50.02574 -49.09069 -48.15563 -47.22057 -46.28551 -45.35045
 -44.41540 -43.48034 -42.54528 -41.61022 -40.67516 -39.74010 -38.80504 -37.86998
 -36.93492 -35.99986 -35.06480 -34.12974 -33.19468 -32.25962 -31.32456 -30.38950
 -29.45444 -28.51938 -27.58431 -26.64925 -25.71419 -24.77913 -23.84407 -22.90901
 -21.97395 -21.03889 -20.10383 -19.16876 -18.23370 -17.29864 -16.36358 -15.42852
 -14.49346 -13.55839 -12.62333 -11.68827 -10.75321  -9.81815  -8.88309  -7.94802
  -7.01296  -6.07790  -5.14284  -4.20778  -3.27272  -2.33765  -1.40259  -0.46753
   0.46753   1.40259   2.33765   3.27272   4.20778   5.14284   6.07790   7.01296
   7.94802   8.88309   9.81815  10.75321  11.68827  12.62333  13.55839  14.49346
  15.42852  16.36358  17.29864  18.23370  19.16876  20.10383  21.03889  21.97395
  22.90901  23.84407  24.77913  25.71419  26.64925  27.58431  28.51938  29.45444
  30.38950  31.32456  32.25962  33.19468  34.12974  35.06480  35.99986  36.93492
  37.86998  38.80504  39.74010  40.67516  41.61022  42.54528  43.48034  44.41540
  45.35045  46.28551  47.22057  48.15563  49.09069  50.02574  50.96080  51.89586
  52.83091  53.76597  54.70103  55.63608  56.57114  57.50619  58.44124  59.37630
  60.31135  61.24640  62.18145  63.11650  64.05155  64.98660  65.92165  66.85669
  67.79173  68.72678  69.66182  70.59685  71.53189  72.46692  73.40195  74.33697
  75.27199  76.20701  77.14201  78.07701  79.01199  79.94696  80.88191  81.81684
  82.75173  83.68657  84.62133  85.55596  86.49037  87.42430  88.35700  89.28423
        "
      elif [ ${truc} == "213" ]
      then
        xydef="
xdef   640 linear    0.000000    0.562500
ydef   320 levels
-89.57009 -89.01318 -88.45297 -87.89203 -87.33080 -86.76944 -86.20800 -85.64651
-85.08499 -84.52345 -83.96190 -83.40033 -82.83876 -82.27718 -81.71559 -81.15400
-80.59240 -80.03080 -79.46920 -78.90760 -78.34600 -77.78439 -77.22278 -76.66117
-76.09956 -75.53795 -74.97634 -74.41473 -73.85311 -73.29150 -72.72988 -72.16827
-71.60665 -71.04504 -70.48342 -69.92181 -69.36019 -68.79857 -68.23695 -67.67534
-67.11372 -66.55210 -65.99048 -65.42886 -64.86725 -64.30563 -63.74401 -63.18239
-62.62077 -62.05915 -61.49753 -60.93591 -60.37429 -59.81267 -59.25105 -58.68943
-58.12781 -57.56619 -57.00457 -56.44295 -55.88133 -55.31971 -54.75809 -54.19647
-53.63485 -53.07323 -52.51161 -51.94999 -51.38837 -50.82675 -50.26513 -49.70351
-49.14189 -48.58026 -48.01864 -47.45702 -46.89540 -46.33378 -45.77216 -45.21054
-44.64892 -44.08730 -43.52567 -42.96405 -42.40243 -41.84081 -41.27919 -40.71757
-40.15595 -39.59433 -39.03270 -38.47108 -37.90946 -37.34784 -36.78622 -36.22460
-35.66298 -35.10136 -34.53973 -33.97811 -33.41649 -32.85487 -32.29325 -31.73163
-31.17000 -30.60838 -30.04676 -29.48514 -28.92352 -28.36190 -27.80028 -27.23865
-26.67703 -26.11541 -25.55379 -24.99217 -24.43055 -23.86892 -23.30730 -22.74568
-22.18406 -21.62244 -21.06082 -20.49919 -19.93757 -19.37595 -18.81433 -18.25271
-17.69109 -17.12946 -16.56784 -16.00622 -15.44460 -14.88298 -14.32136 -13.75973
-13.19811 -12.63649 -12.07487 -11.51325 -10.95162 -10.39000  -9.82838  -9.26676
 -8.70514  -8.14352  -7.58189  -7.02027  -6.45865  -5.89703  -5.33541  -4.77379
 -4.21216  -3.65054  -3.08892  -2.52730  -1.96568  -1.40405  -0.84243  -0.28081
  0.28081   0.84243   1.40405   1.96568   2.52730   3.08892   3.65054   4.21216
  4.77379   5.33541   5.89703   6.45865   7.02027   7.58189   8.14352   8.70514
  9.26676   9.82838  10.39000  10.95162  11.51325  12.07487  12.63649  13.19811
 13.75973  14.32136  14.88298  15.44460  16.00622  16.56784  17.12946  17.69109
 18.25271  18.81433  19.37595  19.93757  20.49919  21.06082  21.62244  22.18406
 22.74568  23.30730  23.86892  24.43055  24.99217  25.55379  26.11541  26.67703
 27.23865  27.80028  28.36190  28.92352  29.48514  30.04676  30.60838  31.17000
 31.73163  32.29325  32.85487  33.41649  33.97811  34.53973  35.10136  35.66298
 36.22460  36.78622  37.34784  37.90946  38.47108  39.03270  39.59433  40.15595
 40.71757  41.27919  41.84081  42.40243  42.96405  43.52567  44.08730  44.64892
 45.21054  45.77216  46.33378  46.89540  47.45702  48.01864  48.58026  49.14189
 49.70351  50.26513  50.82675  51.38837  51.94999  52.51161  53.07323  53.63485
 54.19647  54.75809  55.31971  55.88133  56.44295  57.00457  57.56619  58.12781
 58.68943  59.25105  59.81267  60.37429  60.93591  61.49753  62.05915  62.62077
 63.18239  63.74401  64.30563  64.86725  65.42886  65.99048  66.55210  67.11372
 67.67534  68.23695  68.79857  69.36019  69.92181  70.48342  71.04504  71.60665
 72.16827  72.72988  73.29150  73.85311  74.41473  74.97634  75.53795  76.09956
 76.66117  77.22278  77.78439  78.34600  78.90760  79.46920  80.03080  80.59240
 81.15400  81.71559  82.27718  82.83876  83.40033  83.96190  84.52345  85.08499
 85.64651  86.20800  86.76944  87.33080  87.89203  88.45297  89.01318  89.57009
        "
      else
        echo "Resolução não suportada (${truc})"
        exit 2
      fi

      if [ ${nlev} == 28 ]
      then
        zdef="
zdef    28 levels
0.994997  0.982082  0.964373  0.942547  0.915917  0.883844  0.845785
0.801416  0.750756  0.694265  0.632896  0.568091  0.501681  0.435679
0.372048  0.312479  0.258231  0.210057  0.168230  0.132611  0.102782
0.078152  0.058048  0.041795  0.028750  0.018336  0.010056  0.002726
        "
      elif [ ${nlev} == 42 ]
      then
        zdef="
zdef    42 levels
0.9959831 0.9873524 0.9774466 0.9661055 0.9531540 0.9384272 0.9217599 0.9029820
0.8819433 0.8585089 0.8325886 0.8041373 0.7731550 0.7397218 0.7039977 0.6662130
0.6266829 0.5857977 0.5440080 0.5018040 0.4597013 0.4182100 0.3778005 0.3389029
0.3018822 0.2670232 0.2345258 0.2045147 0.1770446 0.1521000 0.1296058 0.1094567
0.0915122 0.0756123 0.0615968 0.0492901 0.0385169 0.0291166 0.0209377 0.0138312
0.0076468 0.0020416
        "
      else
        echo "Número de níveis sigma não suportado (${nlev})"
        exit 3
      fi

      data_fmt ${data}

      if [ ${mem} == "ens" ]
      then

        if [ ${var} == "prs" ]
        then
cat << EOF > ${var}pe${reg}ens1${data}.ctl
dset ^${var}se${reg}%e1${data}

options big_endian sequential yrev template

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${edef}
${zdef}
${varlist}
EOF

cat << EOF > ${var}pn${reg}ens1${data}.ctl
dset ^${var}sn${reg}%e1${data}

options big_endian sequential yrev template 

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${edef}
${zdef}
${varlist}
EOF
        else
cat << EOF > ${var}pe${reg}ens1${data}.ctl
dset ^${var}pe${reg}%e1${data}

options big_endian sequential yrev template

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${edef}
${zdef}
${varlist}
EOF

cat << EOF > ${var}pn${reg}ens1${data}.ctl
dset ^${var}pn${reg}%e1${data}

options big_endian sequential yrev template

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${edef}
${zdef}
${varlist}
EOF
        fi

      else # outros membros (diferente de "ens")

        if [ ${var} == "prs" ]
        then
cat << EOF > ${var}pe${reg}${memf}1${data}.ctl
dset ^${var}se${reg}${memf}1${data}

options big_endian sequential yrev 

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${zdef}
${varlist}
EOF

cat << EOF > ${var}pn${reg}${memf}1${data}.ctl
dset ^${var}sn${reg}${memf}1${data}

options big_endian sequential yrev 

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${zdef}
${varlist}
EOF
        else
cat << EOF > ${var}pe${reg}${memf}1${data}.ctl
dset ^${var}pe${reg}${memf}1${data}

options big_endian sequential yrev 

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${zdef}
${varlist}
EOF

cat << EOF > ${var}pn${reg}${memf}1${data}.ctl
dset ^${var}pn${reg}${memf}1${data}

options big_endian sequential yrev 

undef -99999

title teste
${xydef}
tdef 1 linear ${datafmt} 6hr
${zdef}
${varlist}
EOF
        fi

      fi

    done

  done

done

exit 0
