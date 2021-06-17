      SUBROUTINE GLATS(COLRAD,WGT,RCS2)
C*
C*    GLATS: CALCULATES GAUSSIAN LATITUDES AND 
C*           GAUSSIAN WEIGHTS FOR USE IN GRID-SPECTRAL 
C*           AND SPECTRAL-GRID TRANSFORMS.
C*
C*     GLATS CALLS THE SUBROUTINE POLY
C*
C*    ARGUMENT(DIMENSIONS)        DESCRIPTION
C*
C*    COLRAD(JMAXHF)      OUTPUT: CO-LATITUDES FOR GAUSSIAN
C*                                LATITUDES IN ONE HEMISPHERE.
C*    WGT(JMAXHF)         OUTPUT: GAUSSIAN WEIGHTS.
C*    RCS2(JMAXHF)        OUTPUT: 1.0/COS(GAUSSIAN LATITUDE)**2
C*    JMAXHF               INPUT: NUMBER OF GAUSSIAN LATITUDES
C*                                IN ONE HEMISPHERE.
C*
      include 'fftpln.h'
C*
      INTEGER JMAXHF
      PARAMETER (JMAXHF=JMAX/2)
C*
      REAL COLRAD(JMAXHF),WGT(JMAXHF),RCS2(JMAXHF)
C*
      INTEGER J
      REAL EPS,SCALE,DRADZ,RAD,DRAD,P2,P1
C*
      EPS=1.0E-12
      SCALE=2.0E0/(FLOAT(JMAX)*FLOAT(JMAX))
      DRADZ=ATAN(1.0E0)/90.0E0
      RAD=0.0E0
C*
      DO J=1,JMAXHF
      DRAD=DRADZ
C*
   10 CALL POLY(JMAX,RAD,P2)
C*
   20 P1=P2
      RAD=RAD+DRAD
      CALL POLY(JMAX,RAD,P2)
      IF (SIGN(1.0E0,P1) .EQ. SIGN(1.0E0,P2)) GOTO 20
C*
      IF (DRAD .GT. EPS) THEN
      RAD=RAD-DRAD
      DRAD=DRAD*0.25E0
      GOTO 10
      ENDIF
C*
      COLRAD(J)=RAD
      CALL POLY(JMAX-1,RAD,P1)
      WGT(J)=SCALE*(1.0E0-COS(RAD)*COS(RAD))/(P1*P1)
      RCS2(J)=1.0/(SIN(RAD)*SIN(RAD))
C*
      ENDDO
C*
      RETURN
      END
