      SUBROUTINE GLATD(JMAX,GLAT)
C*
      INTEGER JMAX
      REAL GLAT(JMAX)
C*
      INTEGER JMAXHF,J
      REAL RD,EPS,DRADZ,RAD,DRAD,P2,P1
C*
      JMAXHF=JMAX/2
      EPS=1.0E-12
      RD=45.0/ATAN(1.0)
      DRADZ=ATAN(1.0)/90.0
      RAD=0.0
C*
      DO J=1,JMAXHF
      DRAD=DRADZ
C*
   10 CALL PLN0(JMAX,RAD,P2)
C*
   20 P1=P2
      RAD=RAD+DRAD
      CALL PLN0(JMAX,RAD,P2)
      IF (SIGN(1.0,P1) .EQ. SIGN(1.0,P2)) GOTO 20
C*
      IF (DRAD .GT. EPS) THEN
      RAD=RAD-DRAD
      DRAD=DRAD*0.25
      GOTO 10
      ENDIF
C*
      GLAT(J)=90.0-RAD*RD
      GLAT(JMAX+1-J)=-GLAT(J)
C*
      ENDDO
C*
      RETURN
      END