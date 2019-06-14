      SUBROUTINE FFT99B(WORK,A,TRIGS,INC,JUMP,N,LOT)
C
      INTEGER INC,JUMP,N,LOT
      REAL WORK(*),A(*),TRIGS(*)
C
      INTEGER NH,NX,INK,IA,IB,JA,JB,L,IABASE,JABASE,IBBASE,JBBASE,K
      REAL C,S,SCALE,ZERO,HALF,ONE,TWO
      DATA ZERO/0.0/,HALF/0.5/,ONE/1.0/,TWO/2.0/
C
      NH=N/2
      NX=N+1
      INK=INC+INC
C
      SCALE=ONE/FLOAT(N)
      IA=1
      IB=2
      JA=1
      JB=N*INC+1
      DO 10 L=1,LOT
      A(JA)=SCALE*(WORK(IA)+WORK(IB))
      A(JB)=SCALE*(WORK(IA)-WORK(IB))
      A(JA+INC)=ZERO
      IA=IA+NX
      IB=IB+NX
      JA=JA+JUMP
      JB=JB+JUMP
   10 CONTINUE
C
      SCALE=HALF*SCALE
      IABASE=3
      IBBASE=N-1
      JABASE=2*INC+1
      JBBASE=(N-2)*INC+1
C
      DO 30 K=3,NH,2
      IA=IABASE
      IB=IBBASE
      JA=JABASE
      JB=JBBASE
      C=TRIGS(N+K  )
      S=TRIGS(N+K+1)
      DO 20 L=1,LOT
      A(JA)=SCALE*((WORK(IA)+WORK(IB))
     $      +(C*(WORK(IA+1)+WORK(IB+1))+S*(WORK(IA)-WORK(IB))))
      A(JB)=SCALE*((WORK(IA)+WORK(IB))
     $      -(C*(WORK(IA+1)+WORK(IB+1))+S*(WORK(IA)-WORK(IB))))
      A(JA+INC)=SCALE*((C*(WORK(IA)-WORK(IB))-S*(WORK(IA+1)+WORK(IB+1)))
     $          +(WORK(IB+1)-WORK(IA+1)))
      A(JB+INC)=SCALE*((C*(WORK(IA)-WORK(IB))-S*(WORK(IA+1)+WORK(IB+1)))
     $          -(WORK(IB+1)-WORK(IA+1)))
      IA=IA+NX
      IB=IB+NX
      JA=JA+JUMP
      JB=JB+JUMP
   20 CONTINUE
      IABASE=IABASE+2
      IBBASE=IBBASE-2
      JABASE=JABASE+INK
      JBBASE=JBBASE-INK
   30 CONTINUE
C
      IF(IABASE.NE.IBBASE) GO TO 50
      IA=IABASE
      JA=JABASE
      SCALE=TWO*SCALE
      DO 40 L=1,LOT
      A(JA)=SCALE*WORK(IA)
      A(JA+INC)=-SCALE*WORK(IA+1)
      IA=IA+NX
      JA=JA+JUMP
   40 CONTINUE
C
   50 CONTINUE
      RETURN
C
      END
