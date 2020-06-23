      PROGRAM POSDHN
C*
      IMPLICIT NONE
C*
      include "resdhn.h"
C*
      INTEGER IDI,IDO,ICN,IDHI,IMSK,IDHN,IY,IM,ID,IH,J,M,IFDAY
      REAL TOD
      CHARACTER SKIP*1,TYPE*20,TITLE*40,CMTH(12)*3
      REAL GLAT(JMAX),USTR(IMAX,JMAX),VSTR(IMAX,JMAX)
C*
      INTEGER ITM
      CHARACTER ITC*4,DIRI*256,DIRO*256,FNDHI*256,
     *          FNICN*256,FNMSK*256,FNDHN*256
      NAMELIST /NMLDHN/ ITM,ITC,DIRI,DIRO,FNDHI,FNICN,FNMSK,FNDHN
C*
      DATA CMTH/'JAN','FEB','MAR','APR','MAY','JUN',
     *          'JUL','AUG','SEP','OCT','NOV','DEC'/
C*
      READ(*,NMLDHN)
C*
      IDI=INDEX(DIRI//' ',' ')-1
      IDO=INDEX(DIRO//' ',' ')-1
      IDHI=INDEX(FNDHI//' ',' ')-1
      ICN=INDEX(FNICN//' ',' ')-1
      IMSK=INDEX(FNMSK//' ',' ')-1
      IDHN=INDEX(FNDHN//' ',' ')-1
      READ(FNDHI(8:17),'(I4,3I2)')IY,IM,ID,IH
      IH=IH+3
      WRITE(0,'(A,I4)')' ITM   = ',ITM
      WRITE(0,'(2A)')' ITC   = ',ITC
      WRITE(0,'(2A)')' DIRI  = ',DIRI(1:IDI)
      WRITE(0,'(2A)')' DIRO  = ',DIRO(1:IDO)
      WRITE(0,'(2A)')' FNDHI = ',FNDHI(1:IDHI)
      WRITE(0,'(2A)')' FNICN = ',FNICN(1:ICN)
      WRITE(0,'(2A)')' FNMSK = ',FNMSK(1:IMSK)
      WRITE(0,'(2A)')' FNDHN = ',FNDHN(1:IDHN)
      WRITE(0,'(A,I4.4,3I2.2)')' LABEL = ',IY,IM,ID,IH
C*
C*    OPEN INPUT (90,91,92) AND OUTPUT FILES (93,94,95,96)
C*    90, 91, 93, 95 -> IEEE 32-BITS
C*
      OPEN(90,FILE=DIRI(1:IDI)//FNDHI(1:IDHI),
     *        STATUS='OLD',FORM='UNFORMATTED')
      OPEN(91,FILE=DIRO(1:IDO)//FNICN(1:ICN),
     *        STATUS='OLD',FORM='UNFORMATTED')
      OPEN(92,FILE=DIRO(1:IDO)//FNICN(1:ICN)//'.ctl',
     *        STATUS='OLD')
      OPEN(93,FILE=DIRO(1:IDO)//FNMSK(1:IMSK),
     *        STATUS='UNKNOWN',FORM='UNFORMATTED')
      OPEN(94,FILE=DIRO(1:IDO)//FNMSK(1:IMSK)//'.ctl',
     *        STATUS='UNKNOWN')
      OPEN(95,FILE=DIRO(1:IDO)//FNDHN(1:IDHN),
     *        STATUS='UNKNOWN',FORM='UNFORMATTED')
      OPEN(96,FILE=DIRO(1:IDO)//FNDHN(1:IDHN)//'.ctl',
     *        STATUS='UNKNOWN')
C*
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'DSET ^'//FNMSK(1:IMSK)
      WRITE(96,'(A)')'DSET ^'//FNDHN(1:IDHN)
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'*'
      WRITE(96,'(A)')'*'
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'OPTIONS SEQUENTIAL YREV BIG_ENDIAN'
      WRITE(96,'(A)')'OPTIONS SEQUENTIAL YREV BIG_ENDIAN'
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'*'
      WRITE(96,'(A)')'*'
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'UNDEF -2.56E+33'
      WRITE(96,'(A)')'UNDEF -2.56E+33'
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'*'
      WRITE(96,'(A)')'*'
      READ(92,'(6X,2A)')TYPE,TITLE
      WRITE(94,'(3A)')'TITLE ',TYPE,TITLE
      WRITE(96,'(3A)')'TITLE ',TYPE,TITLE
      READ(92,'(A)')SKIP
      WRITE(94,'(A)')'*'
      WRITE(96,'(A)')'*'
      READ(92,'(A)')SKIP
      WRITE(94,'(A,I3,A,F8.3,F10.5)')
     *         'XDEF ',IMAX,' LINEAR ',0.0,360.0/FLOAT(IMAX)
      WRITE(96,'(A,I3,A,F8.3,F10.5)')
     *         'XDEF ',IMAX,' LINEAR ',0.0,360.0/FLOAT(IMAX)
      READ(92,'(A)')SKIP
      WRITE(94,'(A,I3,A)')'YDEF ',JMAX,' LEVELS '
      WRITE(96,'(A,I3,A)')'YDEF ',JMAX,' LEVELS '
      READ(92,'(8F10.5)')(GLAT(J),J=1,JMAX)
      WRITE(94,'(8F10.5)')(GLAT(J),J=1,JMAX)
      WRITE(96,'(8F10.5)')(GLAT(J),J=1,JMAX)
      CLOSE(92)
      WRITE(94,'(A,I3,A)')'ZDEF ',1,' LEVELS 1000'
      WRITE(96,'(A,I3,A)')'ZDEF ',1,' LEVELS 1000'
      WRITE(94,'(A,I3,A,I2.2,A,I2.2,A,I4,A)')
     *         'TDEF ',1,' LINEAR ',IH,'Z',ID,CMTH(IM),IY,ITC
      WRITE(96,'(A,I3,A,I2.2,A,I2.2,A,I4,A)')
     *         'TDEF ',ITM,' LINEAR ',IH,'Z',ID,CMTH(IM),IY,ITC
      WRITE(94,'(A)')'*'
      WRITE(96,'(A)')'*'
      WRITE(94,'(A,I3)')'VARS ',2
      WRITE(96,'(A,I3)')'VARS ',2
      WRITE(94,'(A)')'TOPO  0 99 '//
     * 'TOPOGRAPHY                              (M               )'
      WRITE(94,'(A)')'LSMK  0 99 '//
     * 'LAND SEA MASK                           (NO DIM          )'
      WRITE(96,'(A)')'USST  0 99 '//
     * 'SURFACE ZONAL WIND STRESS               (Pa              )'
      WRITE(96,'(A)')'VSST  0 99 '//
     * 'SURFACE MERIDIONAL WIND STRESS          (Pa              )'
      WRITE(94,'(A)')'ENDVARS'
      WRITE(96,'(A)')'ENDVARS'
      CLOSE(94)
      CLOSE(96)
C*
C*    TOPOGRAPHY AND LAND-SEA MASK
C*
      READ(91)USTR
      WRITE(93)USTR
      READ(91)VSTR
      WRITE(93)VSTR
      CLOSE(91)
      CLOSE(93)
C*
C*    SURFACE ZONAL WIND STRESS AND SURFACE MERIDIONAL WIND STRESS
C*
      M=0
   10 READ(90,END=20)IFDAY,TOD
      READ(90)USTR
      WRITE(95)USTR
      READ(90)VSTR
      WRITE(95)VSTR
      M=M+1
      WRITE(0,'(2(A,I5),A,F15.4)')
     *        ' M = ',M,' IFADY = ',IFDAY,' TOD = ',TOD
      GOTO 10
   20 CLOSE(90)
      CLOSE(95)
C*
      STOP
      END