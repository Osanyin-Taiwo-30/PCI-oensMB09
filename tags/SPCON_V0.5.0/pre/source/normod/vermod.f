      SUBROUTINE VERMOD(NFG,GH,EPS,MATZ)
C*
      INCLUDE "resvnmd.h"
C*
      INTEGER KMAXP,KMAXM
      PARAMETER (KMAXP=KMAX+1,KMAXM=KMAX-1)
C*
      REAL EIGG(KMAX,KMAX),EIGGT(KMAX,KMAX),
     *     GH(KMAX),DOTPRO(KMAX),TOV(KMAX)
C*
      INTEGER MATZ,NFG,K,I,J
      REAL EPS,P,Z,THETA,SIMAN,SUM,DT,ER2
C*
      REAL CI(KMAXP),SI(KMAXP),DELSIG(KMAX),SL(KMAX),CL(KMAX),
     *     RPI(KMAXM),SV(KMAX),P1(KMAX),P2(KMAX),H1(KMAX),H2(KMAX)
      REAL AM(KMAX,KMAX),HM(KMAX,KMAX),TM(KMAX,KMAX),
     *     BM(KMAX,KMAX),CM(KMAX,KMAX)
      REAL G(KMAX,KMAX),GT(KMAX,KMAX)
C*
      INCLUDE "delsnmd.h"
C*
      REAL PS,GASR,ER,ZERO,ONE
      DATA PS /1000.0E0/, GASR /287.05E0/, ER /6.37E6/
      DATA ZERO /0.0E0/, ONE /1.0E0/
C*
      CALL SETSIG(CI,SI,DELSIG,SL,CL,RPI,KMAX,KMAXM,KMAXP)
C*
      DO 10 K=1,KMAX
      P=SL(K)*PS
      CALL W3FA03(P,Z,TOV(K),THETA)
   10 CONTINUE
C*
      CALL AMHMTM(DELSIG,RPI,SV,P1,P2,AM,HM,TM,KMAX,KMAXM)
C*
      DT=ONE
      CALL BMCM(TOV,P1,P2,H1,H2,DELSIG,
     *          CI,BM,CM,DT,SV,AM,KMAX,KMAXP)
C*
C*    CM=G IF A=1 AND DT=1
C*
      ER2=ER*ER
      DO 20 I=1,KMAX
      DO 20 J=1,KMAX
      CM(I,J)=GASR*TOV(I)*SV(J)
      DO 20 K=1,KMAX
      CM(I,J)=CM(I,J)+ER2*AM(I,K)*BM(K,J)
   20 CONTINUE
C*
      WRITE(*,*)' MATRIX CM:'
      DO I=1,KMAX
      WRITE(*,*)' I=',I
      WRITE(*,'(1P6G12.5)')(CM(I,J),J=1,KMAX)
      ENDDO
C*
      DO 30 I=1,KMAX
      DO 30 J=1,KMAX
      G(I,J)=CM(I,J)
      GT(I,J)=CM(J,I)
   30 CONTINUE
C*
      SIMAN=-ONE
      CALL VEREIG(G,SIMAN,AM,CL,EIGG,GH,EPS,MATZ)
      SIMAN=ONE
      CALL VEREIG(GT,SIMAN,AM,CL,EIGGT,DOTPRO,EPS,MATZ)
C*
C*    DOTPRO=INVERSE DOT PROD. OF EIGENVEC(G)*EIGENVEC(GTRANSPOSE)
C*
      DO 40 K=1,KMAX
      SUM=ZERO
      DO 50 J=1,KMAX
      SUM=SUM+EIGG(J,K)*EIGGT(J,K)
   50 CONTINUE
      DOTPRO(K)=ONE/SUM
   40 CONTINUE
C*
      DO 60 K=1,KMAX
      PRINT 100,GH(K),DOTPRO(K)
100   FORMAT(/,'G EIGENVALUE AND DOTPROD=',1P2G12.5,/)
      PRINT 101
101   FORMAT(/,'G EIGENVECTORS',/)
      PRINT 102,(EIGG (J,K),J=1,KMAX)
102   FORMAT(1X,1P6G12.5)
      PRINT 103
103   FORMAT(/,'GTRANSPOSE EIGENVECTORS',/)
      PRINT 102,(EIGGT(J,K),J=1,KMAX)
   60 CONTINUE
C*
      WRITE(NFG)EIGG,EIGGT,GH,DOTPRO,TOV
C*
      RETURN
      END