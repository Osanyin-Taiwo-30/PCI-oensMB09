say 'Enter with: resol trc labeli nblst ndacc noutpday dirbct dirfig'
pull ctime

resol   =subwrd(ctime,1)
trc     =subwrd(ctime,2)
labeli  =subwrd(ctime,3)
nblst   =subwrd(ctime,4)
ndacc   =subwrd(ctime,5)
noutpday=subwrd(ctime,6)
dirbct  =subwrd(ctime,7)
dirfig  =subwrd(ctime,8)

dirbct=dirbct%'/'
dirfig=dirfig%'/'

*
* Figures for 1st page of agriculture products (Lead times: 5, 10 and 15 days)
*

agric_time='5 10 15'

*
* Set colors for figures
*

'rgbset.gs'

*
* List of ctl files
*

flist=filefct%labeli%'.'%trc
say 'flist='flist

*
* Looping to produce all figures
*

nld=1
nf=1
while (nf <= nblst)

*
* Open Ctl
*

   rec=read(flist)
   ctlfile=sublin(rec,2)
  

     'reinit'

      ld=subwrd(agric_time,nld)

      say 'open 'dirbct''ctlfile''
     'open 'dirbct''ctlfile''

*
* Obtain the date of the forecasting
*

      ti=-(ndacc*noutpday-1)
      tf=1
      
     'set t 'ti' 'tf
     'q time'
      labelii=subwrd(result,3)
      labelff=subwrd(result,5)

     'set t 1'

      say 'labelii= 'labelii
      say 'labelff= 'labelff

      mesii=substr(labelii,6,3)
      mesff=substr(labelff,6,3)

      if (mesii = 'JAN');mmi='JAN';endif
      if (mesii = 'FEB');mmi='FEV';endif
      if (mesii = 'MAR');mmi='MAR';endif
      if (mesii = 'APR');mmi='ABR';endif
      if (mesii = 'MAY');mmi='MAI';endif
      if (mesii = 'JUN');mmi='JUN';endif
      if (mesii = 'JUL');mmi='JUL';endif
      if (mesii = 'AUG');mmi='AGO';endif
      if (mesii = 'SEP');mmi='SET';endif
      if (mesii = 'OCT');mmi='OUT';endif
      if (mesii = 'NOV');mmi='NOV';endif
      if (mesii = 'DEC');mmi='DEZ';endif

      if (mesff = 'JAN');mmf='JAN';endif
      if (mesff = 'FEB');mmf='FEV';endif
      if (mesff = 'MAR');mmf='MAR';endif
      if (mesff = 'APR');mmf='ABR';endif
      if (mesff = 'MAY');mmf='MAI';endif
      if (mesff = 'JUN');mmf='JUN';endif
      if (mesff = 'JUL');mmf='JUL';endif
      if (mesff = 'AUG');mmf='AGO';endif
      if (mesff = 'SEP');mmf='SET';endif
      if (mesff = 'OCT');mmf='OUT';endif
      if (mesff = 'NOV');mmf='NOV';endif
      if (mesff = 'DEC');mmf='DEZ';endif

      labeli=substr(labelii,4,2)%'/'%mmi%'/'%substr(labelii,9,4)%' '%substr(labelii,1,2)
      labelf=substr(labelff,4,2)%'/'%mmf%'/'%substr(labelff,9,4)%' '%substr(labelff,1,2)

*
* Set Grads environment
*

     'set grid off'
     'set display color white'
     'c'
     'set gxout shaded'
     'set mpdset brmap_mres'

     'set lat -60 15'
     'set lon -101.25 -11.25'
  
*
* Plot the figures
*

     'set grads off'
     'set clevs 5 25 50 75 95'
     'set ccols 90 91 92 93 94 95'
     'd smth9(prob10*100)'
     'run cbarn.gs'
  
     'set string 1 c 6'
     'set strsiz 0.11 0.12'
     'draw string 5.5 8.3 CPTEC/INPE/MCT - PREVISAO DE TEMPO GLOBAL POR ENSEMBLE - 'resol''
     'draw string 5.5 8.1 Previsao de Probabilidades de Precipitacao Acumulada em 5 dias > 10.0 mm' 
     'draw string 5.5 7.9 Acumalado entre: 'labeli'Z  e  'labelf'Z'
  
     'printim 'dirfig'prec_agric_large'ld'.gif gif x900 y700'
     '!convert2 'dirfig'prec_agric_large'ld'.gif 'dirfig'prec_agric_large'ld'.gif'

     'c'
     'set grads off'
     'set clevs 5 25 50 75 95'
     'set ccols 90 91 92 93 94 95'
     'd smth9(prob10*100)'
     'run cbarn.gs 2.0 1 9.50 4.25'

     'printim 'dirfig'prec_agric_small'ld'.gif gif x900 y700'
     '!convert2 -crop 0x0 -geometry 240x210 'dirfig'prec_agric_small'ld'.gif 'dirfig'prec_agric_small'ld'.gif'
      nld=nld+1
   
   nf=nf+1
endwhile
   
'quit'

   
   
   
   
   
   
   
   
   
