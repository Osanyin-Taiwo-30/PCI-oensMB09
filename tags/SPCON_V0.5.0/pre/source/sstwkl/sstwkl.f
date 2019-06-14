      PROGRAM SSTWKL
C*
C*   IT READS THE MEAN WEEKLY 1X1 SST GLOBAL FROM NMC,
C*   INTERPOLATES IT USING WTERP AND NTERP INTO A GAUSSIAN GRID.
C*
C*   Date:        May 15th, 1995.
C*   Last change: May 15th, 1995. 
C*
      INCLUDE "reshsst.h"
C*
      INTEGER ISST,JSST
      PARAMETER (ISST=360,JSST=180)
C*
      INTEGER LONS,LATS,MNWV2
      PARAMETER (LONS=IMAX+ISST+2,LATS=JMAX+JSST+2,
     *           MNWV2=MEND1*(MEND1+1))
C*
      INTEGER IDAY,IMON,IYR,IHR,J,I,M,LOND,LATD,JS,JN,JS1,JN1,JA,JB
      REAL SICE,UNDEF,EMAX,EMIN,FMAX,FMIN,GMAX,GMIN
C*JPB      CHARACTER FMTI*7,LABELS*6,SSTK(JSST)*6
      CHARACTER FMTI*7,LABELS*8,SSTK(JSST)*6
      LOGICAL CLMWDW
      INTEGER LSMASK(IMAX,JMAX),ICEMSK(IMAX,JMAX),MSKIN(ISST,JSST),
     *        MPLON(LONS,2),MPLAT(LATS,2)
      REAL WTLON(LONS),WTLAT(LATS),WORK(IMAX,JMAX),
     *     SSTG(IMAX,JMAX),TOPOG(IMAX,JMAX),
     *     SSTR(ISST,JSST),SSTC(ISST,JSST),
     *     FLAG(ISST,JSST),CFTOP(MNWV2)
      LOGICAL FLGIN(5),FLGOUT(5)
      DOUBLE PRECISION DWORK(2*LONS)
      INTEGER*4 IFDAY,IDATE(4),IDATEC(4)
      REAL*4 TOD
      REAL*4 SSTGRD(IMAX,JMAX),TOPGRD(IMAX,JMAX),CFTPR(MNWV2),
     *       SSTR4(ISST,JSST)
      NAMELIST /SSTNML/ CLMWDW,SICE
      DATA SICE /-1.749/
C*
      DATA CLMWDW/.FALSE./
C*
      DATA FMTI/'(   I1)'/
C*
      READ(*,SSTNML)
      WRITE(*,SSTNML)
C*
      WRITE(FMTI,'(''('',I3,''I1)'')')IMAX
C*
C*    INPUT:  UNIT 50 - sstwkl.$LABELS
C*                 23 - orgwav.$TRUNC
C*                 24 - fseald.form.$TRUNC
C*
      OPEN(50,FORM='UNFORMATTED',STATUS='UNKNOWN')
      OPEN(23,FORM='UNFORMATTED',STATUS='UNKNOWN')
      OPEN(24,FORM='FORMATTED',STATUS='UNKNOWN')
C*
C*    Output: Unit 52 - sstwkl.$TRUNC
C*                 54 - sstgwk.$TRUNC.$MACH
C*
      OPEN(52,FORM='UNFORMATTED',STATUS='UNKNOWN')
      OPEN(54,FORM='UNFORMATTED',STATUS='UNKNOWN')
C*
C*    GRID ORIENTATION:
C*    MEAN WEEKLY SST INPUT DATA: (1,1) = (0.5W,89.5N) 
C*                          (ISST,JSST) = (0.5E,89.5S)
      UNDEF=-999.0
      FLGIN(1)=.TRUE.
      FLGIN(2)=.TRUE.
      FLGIN(3)=.FALSE.
      FLGIN(4)=.FALSE.
      FLGIN(5)=.FALSE.
      FLGOUT(1)=.TRUE.
      FLGOUT(2)=.TRUE.
      FLGOUT(3)=.FALSE.
      FLGOUT(4)=.TRUE.
      FLGOUT(5)=.TRUE.
C*
      CALL WTERP(ISST,JSST,IMAX,JMAX,FLGIN,FLGOUT,WTLON,WTLAT,
     *           MPLON,MPLAT,LOND,LATD,DWORK)
C*
C*    READ IN LAND-SEA MASK DATA SETS AND SPECTRAL COEF OF TOPOG
C*    TO ENSURE THAT TOPOG IS THE SAME AS USED BY MODEL.
C*
      READ(23)IFDAY,TOD,IDATE,IDATEC
      READ(23)CFTPR
      DO M=1,MNWV2
      CFTOP(M)=CFTPR(M)
      ENDDO
      CALL FFTPLN
      CALL RECTRG(CFTOP,TOPOG)
      READ(24,FMTI)LSMASK
C*
C*    WRITE GRADS TOPOG FILE:
C*
      DO J=1,JMAX
      DO I=1,IMAX
      TOPGRD(I,J)=TOPOG(I,J)
      SSTGRD(I,J)=FLOAT(1-2*LSMASK(I,J))
      ENDDO
      ENDDO
      WRITE(54) TOPGRD
      WRITE(54) SSTGRD
C*
C*    WRITE OUT LAND-SEA MASK TO UNIT 52 SST DATA SET
C*    THIS RECORD WILL BE TRANSFERED BY MODEL TO POST-P
C*
      WRITE(52)SSTGRD
C*
C*    INITIALIZE MSKIN TO 1 TO MAKE INTERPOLATION AT EVERY POINT
C*
      DO J=1,JSST
      DO I=1,ISST
      MSKIN(I,J)=1
      ENDDO
      ENDDO
C*
C*    GET SSTC CLIMATOLOGICAL AND INDEX FOR HIGH LATITUDE 
C*             SUBSTITUTION OF SST ACTUAL BY CLIMATOLOGY
C*
      IF (CLMWDW) THEN
      CALL SSTOIW(SSTC)
      CALL SSTWIN(JN,JS)
      JN1=JN-1
      JS1=JS+1
      JA=JN
      JB=JS
      ELSE
      JN=0
      JS=JSST+1
      JN1=0
      JS1=JSST+1
      JA=1
      JB=JSST
      ENDIF
C*
C*    READ MEAN WEEKLY 1 DEG X 1 DEG SST
C*
      READ(50)SSTR4
      DO J=1,JSST
      IF (J.GE.JN .AND. J.LE.JS) THEN
      SSTK(J)='WEEKLY'
      DO I=1,ISST
      SSTR(I,J)=SSTR4(I,J)-273.15
      ENDDO
      ELSE
      SSTK(J)='CLIMAT'
      DO I=1,ISST
      SSTR(I,J)=SSTC(I,J)
      ENDDO
      ENDIF
      ENDDO
      IF (JN1 .GE. 1) WRITE(*,'(6(I4,1X,A))')(J,SSTK(J),J=1,JN1)
      WRITE(*,'(6(I4,1X,A))')(J,SSTK(J),J=JA,JB)
      IF (JS1 .LE. JSST) WRITE(*,'(6(I4,1X,A))')(J,SSTK(J),J=JS1,JSST)
C*
C*    CONVERT SEA ICE INTO FLAG =1. OVER ICE, =0. OVER OPEN WATER
C*    SET INPUT SST=MIN OF -1.7 OVER NON ICE POINTS BEFORE INTERPOLATION
C*
      DO J=1,JSST
      DO I=1,ISST
      FLAG(I,J)=0.0
C*JPB IF(SSTR(I,J).LT.-1.799)THEN
C*JPB IF(SSTR(I,J).LT.-1.749)THEN
      IF(SSTR(I,J).LT.SICE)THEN
      FLAG(I,J)=1.0
      ELSE
      SSTR(I,J)=MAX(SSTR(I,J),-1.7)
      ENDIF
      ENDDO
      ENDDO
C*
C*    FIND MIN AND MAX VALUES OF INPUT SST
C*
      EMAX=-1.0E10
      EMIN=+1.0E10
      DO J=1,JSST
      DO I=1,ISST
      EMAX=MAX(EMAX,SSTR(I,J))
      EMIN=MIN(EMIN,SSTR(I,J))
      ENDDO
      ENDDO
C*
C*    INTERPOLATE FLAG FROM 1X1 GRID TO GAUSSIAN GRID, FILL ICEMSK=1
C*    OVER INTERPOLATED POINTS WITH 50% OR MORE SEA ICE, =0 OTHERWISE
C*
      CALL NTERP(FLAG,ISST,JSST,SSTG,IMAX,JMAX,WTLON,WTLAT,
     *           MPLON,MPLAT,LOND,LATD,MSKIN,UNDEF,WORK)
      DO J=1,JMAX
      DO I=1,IMAX
      ICEMSK(I,J)=INT(SSTG(I,J)+0.5)
      ENDDO
      ENDDO
C*
C*    INTERPOLATE SST FROM 1X1 GRID TO GAUSSIAN GRID
C*
      CALL NTERP(SSTR,ISST,JSST,SSTG,IMAX,JMAX,WTLON,WTLAT,
     *           MPLON,MPLAT,LOND,LATD,MSKIN,UNDEF,WORK)
C*
C*    FIND MIN AND MAX VALUES OF GAUS GRID
C*
      FMAX=-1.0E10
      FMIN=+1.0E10
      DO J=1,JMAX
      DO I=1,IMAX
      FMAX=MAX(FMAX,SSTG(I,J))
      FMIN=MIN(FMIN,SSTG(I,J))
      ENDDO
      ENDDO
C*
      GMAX=-1.0E10
      GMIN=+1.0E10
      DO J=1,JMAX
      DO I=1,IMAX
C*
C*    SET SST = UNDEF OVER LAND
C*
      IF (LSMASK(I,J) .EQ. 1) THEN
      SSTG(I,J)=UNDEF
C*
C*    SEA ICE THRESHOLD = 271.2, SET SST = 270.2 OVER SEA ICE
      ELSEIF (ICEMSK(I,J) .EQ. 1) THEN
      SSTG(I,J)=270.2
C*
C*    CONVERT SST TO DEG K, CORRECT SST FOR TOPOGRAPHY, DO NOT CREATE OR
C*    DESTROY SEA ICE VIA TOPOGRAPHY CORRECTION
C*
      ELSE
      SSTG(I,J)=SSTG(I,J)+273.15-TOPOG(I,J)*0.0065
      IF (SSTG(I,J) .LT. 271.2) SSTG(I,J)=271.4
      ENDIF
C*
C*    FIND MIN,MAX VALUES OF CORRECTED GAUS GRID SST EXCLUDING LAND PTS
C*
      IF (SSTG(I,J) .NE. UNDEF) THEN
      GMAX=MAX(GMAX,SSTG(I,J))
      GMIN=MIN(GMIN,SSTG(I,J))
      ENDIF
C*
      ENDDO
      ENDDO
C*
      CALL GETENV('LABELS',LABELS)
C*JPB      READ(LABELS,'(3I2)')IYR,IMON,IDAY
      READ(LABELS,'(I4,2I2)')IYR,IMON,IDAY
      IHR=0
C*JPB      WRITE(6,61)IDAY,IMON,1900+IYR,IHR
      WRITE(6,61)IDAY,IMON,IYR,IHR
   61 FORMAT(' DAY= ',I2,' MONTH= ',I2,' YEAR= ',I4,' HOUR= ',I2)
      WRITE(6,62)EMIN,EMAX,FMIN,FMAX,GMIN,GMAX
   62 FORMAT(' Mean Weekly SST Interpolation:',/,
     *       ' Regular  Grid SST: Min, Max = ',2F8.2,/,
     *       ' Gaussian Grid SST: Min, Max = ',2F8.2/,
     *       ' Masked G Grid SST: Min, Max = ',2F8.2)
C*
C*    WRITE GRADS ICEMSK AND SST FILES:
C*
      DO J=1,JMAX
      DO I=1,IMAX
      IF (LSMASK(I,J) .EQ. 1) ICEMSK(I,J)=0
      SSTGRD(I,J)=FLOAT(ICEMSK(I,J))
      ENDDO
      ENDDO
      WRITE(54) SSTGRD
      DO J=1,JMAX
      DO I=1,IMAX
      SSTGRD(I,J)=SSTG(I,J)
      ENDDO
      ENDDO
      WRITE(54) SSTGRD
C*
C*    WRITE OUT GAUSSIAN GRID WEEKLY SST
C*
      WRITE(52)SSTGRD
C*
      STOP
      END
