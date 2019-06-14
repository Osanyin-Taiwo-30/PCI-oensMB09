      SUBROUTINE PLN2(SLN,COLRAD,LAT,EPS,LA1)
C*
C*     PLN2: CALCULATES THE ASSOCIATED LEGENDRE FUNCTIONS
C*           AT ONE SPECIFIED LATITUDE.
C*
C*    ARGUMENT(DIMENSIONS)        DESCRIPTION
C*
C*    SLN (MNWV1)         OUTPUT: VALUES OF ASSOCIATED LEGENDRE
C*                                FUNCTIONS AT ONE GAUSSIAN
C*                                LATITUDE SPECIFIED BY THE
C*                                ARGUMENT "LAT".
C*
C*     COLRAD(JMAXHF)      INPUT: COLATITUDES OF GAUSSIAN GRID
C*                                (IN RADIANS). CALCULATED
C*                                IN ROUTINE "GLATS".
C*     LAT                 INPUT: GAUSSIAN LATITUDE INDEX. SET
C*                                BY CALLING ROUTINE.
C*     EPS                 INPUT: FACTOR THAT APPEARS IN RECUSIO
C*                                FORMULA OF A.L.F.
C*     MEND                INPUT: TRIANGULAR TRUNCATION WAVE NUMBER
C*     MNWV1               INPUT: NUMBER OF ELEMENTS
C*     LA1(MEND1,MEND1+1)  INPUT: NUMBERING ARRAY OF SLN1
C*
C*     X(MEND1)            LOCAL: WORK AREA
C*     Y(MEND1)            LOCAL: WORK AREA
C*
#include <fftpln.h>
C*
      INTEGER MEND1,MEND2,MEND3,MNWV2,MNWV3,MNWV1,JMAXHF
      PARAMETER (MEND1=MEND+1,MEND2=MEND+2,MEND3=MEND+3,
     *           MNWV2=MEND1*MEND2,MNWV3=MNWV2+2*MEND1,
     *           MNWV1=MNWV3/2,JMAXHF=JMAX/2)
C*
      INTEGER LAT
      INTEGER LA1(MEND1,MEND2)
      REAL SLN(MNWV1),COLRAD(JMAXHF),EPS(MNWV1)
C*
      INTEGER IFP,MM,NN,MMAX,LX,LY,LZ
      REAL RTHF,COLR,SINLAT,COSLAT,PROD
      REAL X(MEND1),Y(MEND1)
C*
      SAVE IFP,X,Y,RTHF
      DATA IFP/1/
C*
      IF (IFP .EQ. 1) THEN
      IFP=0
      DO MM=1,MEND1
      X(MM)=SQRT(2.0*MM+1.0)
      Y(MM)=SQRT(1.0+0.5/FLOAT(MM))
      ENDDO
      RTHF=SQRT(0.5)
      ENDIF
C*
      COLR=COLRAD(LAT)
      SINLAT=COS(COLR)
      COSLAT=SIN(COLR)
      PROD=1.0
C*
      DO MM=1,MEND1
      SLN(MM)=RTHF*PROD
C     LINE BELOW SHOULD ONLY BE USED WHERE EXPONENT RANGE IS LIMTED
C     IF(PROD.LT.FLIM) PROD=0.0
      PROD=PROD*COSLAT*Y(MM)
      ENDDO

      DO MM=1,MEND1
      SLN(MM+MEND1)=X(MM)*SINLAT*SLN(MM)
      ENDDO
C*
      DO NN=3,MEND2
      MMAX=MEND3-NN
      DO MM=1,MMAX
      LX=LA1(MM,NN  )
      LY=LA1(MM,NN-1)
      LZ=LA1(MM,NN-2)
      SLN(LX)=(SINLAT*SLN(LY)-EPS(LY)*SLN(LZ))/EPS(LX)
      ENDDO
      ENDDO
C*
      RETURN
      END
