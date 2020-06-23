      SUBROUTINE VEREIG(GG,SIMAN,EIGVC,COL,VEC,VAL,EPS,MATZ)
C*
      INCLUDE "resvnmd.h"
C*
      INTEGER KK(KMAX)
      REAL VEC(KMAX,KMAX),VAL(KMAX)
      REAL GG(KMAX,KMAX),EIGVR(KMAX),EIGVI(KMAX),EIGVC(KMAX,KMAX)
      REAL WK1(KMAX),WK2(KMAX),COL(KMAX)
C*
      INTEGER MATZ,K,IER,I,J,KKK
      REAL EPS,SIMAN,SUM,RMAX
C*
      REAL ZERO,ONE,E20
      DATA ZERO /0.0E0/, ONE /1.0E0/, E20/-1.0E20/
C*
      CALL RG(KMAX,KMAX,GG,EIGVR,EIGVI,MATZ,EIGVC,IER,EPS,WK1,WK2)
C*
      PRINT 101,IER
101   FORMAT(/,'IER=',I2,2X,'EIGENVALUES AND VECTORS FOLLOW',/)
      DO 20 K=1,KMAX
      PRINT 102,EIGVR(K),EIGVI(K)
      PRINT 103,(EIGVC(I,K),I=1,KMAX)
20    CONTINUE
102   FORMAT(/,1P2G12.5,/)
103   FORMAT(1X,1P6G12.5)
      PRINT 104
104   FORMAT(/,'END EIGENVALUES AND VECTORS',/)
C*
      DO 25 K=1,KMAX
      KK(K)=0
      COL(K)=SIMAN*EIGVR(K)
      SUM=ZERO
      DO 23 J=1,KMAX
      SUM=SUM+EIGVC(J,K)*EIGVC(J,K)
23    CONTINUE
C*** SUM=LENGTH OF EIGENVECTOR K
      SUM=ONE/SQRT(SUM)
      DO 24 J=1,KMAX
      EIGVC(J,K)=SUM*EIGVC(J,K)
24    CONTINUE
25    CONTINUE
C*
C*    EIGENVALUES NOW HAVE UNIT LENGTH.K TH VECTOR IS EIGVC(J,K)
C*    EIGENVALUES ARE NOW IN COL(K)
C*    NEXT ARRANGE IN DESCENDING ORDER 
C*
      PRINT 103,(COL(K),K=1,KMAX)
109   FORMAT(/,' ZERO EIGENVALUE',/)
      DO 32 J=1,KMAX
      IF(COL(J).EQ.ZERO)PRINT 109
32    CONTINUE
C*
      PRINT 106,(KK(J),J=1,KMAX)
106   FORMAT(1X,20I3)
      DO 33 J=1,KMAX
      RMAX=E20
      KKK=0
      DO 30 K=1,KMAX
      IF(ABS(COL(K)).GT.RMAX)KKK=K
      IF(ABS(COL(K)).GT.RMAX)RMAX=ABS(COL(K))
30    CONTINUE
      VAL(J)=COL(KKK)
      COL(KKK)=ZERO
      DO 35 I=1,KMAX
35    VEC(I,J)=EIGVC(I,KKK)
33    KK(J)=KKK
      PRINT 100
100   FORMAT(1X)
      PRINT 106,(KK(J),J=1,KMAX)
      PRINT 103,(VAL(K),K=1,KMAX)
      RETURN
      END