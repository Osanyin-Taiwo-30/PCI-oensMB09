      SUBROUTINE QWRITE(N,QGZS,QLNP,QTMP,QDIV,QROT,QQ)
C*
C*    WRITES IN SPECTRAL COEFFICIENTS GLOBAL MODEL INITIAL CONDITION
C*
C*    ARGUMENT(DIMENSIONS)          DESCRIPTION
C*
C*    N                      INPUT: FORTRAN UNIT NUMBER FOR THE
C*                                  INITIAL CONDITION FILE
C*    GZ   (MNWV2)           INPUT: MODEL TERRAIN FIELD (SPECTRAL)
C*    QLNP (MNWV2)           INPUT: LOG OF SURFACE PRESSURE (SPECTRAL)
C*    QTMP (MNWV2,KMAX)      INPUT: TEMPERATURE (SPECTRAL)
C*    QDIV (MNWV2,KMAX)      INPUT: DIVERGENCE (SPECTRAL)
C*    QROT (MNWV2,KMAX)      INPUT: VORTICITY (SPECTRAL)
C*    QQ   (MNWV2,KQMAX      INPUT: SPECIFIC HUMIDITY (SPECTRAL)
C*
      INTEGER IMAX,JMAX,MEND,KMAX,LMAX
      PARAMETER (IMAX=384,JMAX=192,MEND=126,KMAX=28,LMAX=11)
C*
      INTEGER MEND1,MEND2,MNWV2
      PARAMETER(MEND1=MEND+1,MEND2=MEND+2,MNWV2=MEND1*MEND2)
C*
      INTEGER N
      REAL QGZS(MNWV2),QLNP(MNWV2),QTMP(MNWV2,KMAX),
     *     QDIV(MNWV2,KMAX),QROT(MNWV2,KMAX),QQ(MNWV2,KMAX)
C*
      INTEGER K,MN
      INTEGER*4 IFDAY,IDATE(4),IDATEC(4)
      REAL*4 TOD,FHOUR,SI(KMAX+1),SL(KMAX),QWK(MNWV2)
C*
      COMMON /INDATA/ IFDAY,TOD,IDATE,IDATEC,SI,SL
C*
      CALL TRANSS(QGZS,   1,-1)
      CALL TRANSS(QLNP,   1,-1)
      CALL TRANSS(QTMP,KMAX,-1)
      CALL TRANSS(QDIV,KMAX,-1)
      CALL TRANSS(QROT,KMAX,-1)
      CALL TRANSS(QQ  ,KMAX,-1)
C*
      WRITE(N)IFDAY,TOD,IDATE,IDATEC,SI,SL
C*
      DO MN=1,MNWV2
      QWK(MN)=QGZS(MN)
      ENDDO
      WRITE(N)QWK
C*
      DO MN=1,MNWV2
      QWK(MN)=QLNP(MN)
      ENDDO
      WRITE(N)QWK
C*
      DO K=1,KMAX
      DO MN=1,MNWV2
      QWK(MN)=QTMP(MN,K)
      ENDDO
      WRITE(N)QWK
      ENDDO
C*
      DO K=1,KMAX
      DO MN=1,MNWV2
      QWK(MN)=QDIV(MN,K)
      ENDDO
      WRITE(N)QWK
      DO MN=1,MNWV2
      QWK(MN)=QROT(MN,K)
      ENDDO
      WRITE(N)QWK
      ENDDO
C*
      DO K=1,KMAX
      DO MN=1,MNWV2
      QWK(MN)=QQ(MN,K)
      ENDDO
      WRITE(N)QWK
      ENDDO
C*
      RETURN
      END
