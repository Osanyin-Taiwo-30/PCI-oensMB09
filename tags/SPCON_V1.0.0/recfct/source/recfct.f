      PROGRAM RECFCT
C*
      include "recfct.h"
C*
      INTEGER MEND1,MEND2,MNWV2,MNWV3
      PARAMETER (MEND1=MEND+1,MEND2=MEND+2,
     *           MNWV2=MEND1*MEND2,
     *           MNWV3=MNWV2+2*MEND1)
C*
      INTEGER MN,J,I,K,L,IDL,IDS,IDR,IGL,IGS,IGR
      REAL RD
      REAL QGZS(MNWV2),QLNP(MNWV2),QTV(MNWV2,KMAX),
     *     QDIV(MNWV2,KMAX),QROT(MNWV2,KMAX),QQ(MNWV2,KMAX),
     *     QU(MNWV3,KMAX),QV(MNWV3,KMAX)
C*
      REAL T(IMAX,JMAX,KMAX),Q(IMAX,JMAX,KMAX),
     *     U(IMAX,JMAX,KMAX),V(IMAX,JMAX,KMAX),
     *     GLAT(JMAX),CLAT(JMAX)
      REAL*4 G(IMAX,JMAX)
      CHARACTER GNAMES(LMAX)*64,GNAMER(LMAX)*64
      INTEGER LDIM
      CHARACTER DIRL*64,DIRS*84,DIRR*64,GNAMEL*64
C*
      NAMELIST /DATAIN/ LDIM,DIRL,DIRS,DIRR,GNAMEL
C*
      READ(*,DATAIN)
      WRITE(*,DATAIN)
C*
      IDL=INDEX(DIRL//' ',' ')-1
      IDS=INDEX(DIRS//' ',' ')-1
      IDR=INDEX(DIRR//' ',' ')-1
      IGL=INDEX(GNAMEL//' ',' ')-1
C*
      write(*,*)'unit55'
      WRITE(*,'(/,A)')' OPEN: '//DIRL(1:IDL)//GNAMEL(1:IDL)
      OPEN(55,FILE=DIRL(1:IDL)//GNAMEL(1:IGL),STATUS='OLD')
      DO L=1,LDIM
      READ(55,'(A)')GNAMES(L)
      READ(55,'(A)')GNAMER(L)
      ENDDO
      CLOSE(55)
C*
      RD=ATAN(1.0)/45.0
      CALL FFTPLN(GLAT)
      DO J=1,JMAX
      CLAT(J)=COS(GLAT(J)*RD)
      ENDDO
      WRITE(*,'(8F10.5)')(GLAT(J),J=JMAX,1,-1)
C*
      DO L=1,LDIM
      IGS=INDEX(GNAMES(L)//' ',' ')-1
      IGR=INDEX(GNAMER(L)//' ',' ')-1
C*
      write(*,*)'unit10'
      WRITE(*,'(/,A)')' OPEN: '//DIRS(1:IDS)//GNAMES(L)(1:IGS)
      OPEN (10,FILE=DIRS(1:IDS)//'/'//GNAMES(L)(1:IGS),
     *  STATUS='OLD',
     *         FORM='UNFORMATTED')
      write(*,*)'vai chamar QREAD'
      CALL QREAD(10,QGZS,QLNP,QTV,QDIV,QROT,QQ)
      CLOSE(10)
C*
      CALL DZTOUV(QDIV,QROT,QU,QV)
C*
      CALL RECTRG(QTV,T,MNWV2,KMAX)
      CALL RECTRG(QQ,Q,MNWV2,KMAX)
      CALL RECTRG(QU,U,MNWV3,KMAX)
      CALL RECTRG(QV,V,MNWV3,KMAX)
      DO K=1,KMAX
      DO J=1,JMAX
      DO I=1,IMAX
      T(I,J,K)=T(I,J,K)/(1.0+0.608*Q(I,J,K))
      U(I,J,K)=U(I,J,K)/CLAT(J)
      V(I,J,K)=V(I,J,K)/CLAT(J)
      ENDDO
      ENDDO
      ENDDO
C*
      WRITE(*,'(/,A)')' OPEN: '//DIRR(1:IDR)//GNAMER(L)(1:IGR)
      write(*,*)'unit20'
      OPEN (20,FILE=DIRR(1:IDR)//GNAMER(L)(1:IGR),STATUS='UNKNOWN',
     *         FORM='UNFORMATTED')
      CALL FWRITE(20,T)
      CALL FWRITE(20,Q)
      CALL FWRITE(20,U)
      CALL FWRITE(20,V)
      CLOSE(20)
C*
      ENDDO
C*
      STOP
      END
