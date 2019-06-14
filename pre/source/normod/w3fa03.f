      SUBROUTINE W3FA03(PRESS,HEIGHT,TEMP,THETA)
C*
C*    THIS SUBROUTINE (W3FA03) COMPUTES THE STANDARD HEIGHT (METERS),
C*    TEMPERATURE (DEG K) AND POTENTIAL TEMPERATURE (DEG K) GIVEN THE
C*    PRESSURE IN MB.
C*     U. S. STANDARD ATMOSPHERE, 1962
C*    ICAO STD ATM TO 20KM
C*    PROPOSED EXTENSION TO 32KM
C*    NOT VALID FOR HEIGHT.GT.32KM OR PRESSURE.LT.8.68MB
C*
      REAL PRESS,HEIGHT,TEMP,THETA
      REAL GRAV,RSTAR,RM0,PISO,ZISO,SALP,PZERO,T0,ALP,
     *     PTROP,TSTR,HTROP,PS,TWO,SEVEN
      REAL ROVCP,GASR,ROVG,FKT,AR,PP0
C*
      DATA GRAV /9.80665E0/, RSTAR /8314.32E0/, RM0 /28.9644E0/,
     *     PISO /54.7487E0/, ZISO /20000.0E0/, SALP /-0.0010E0/,
     *     PZERO /1013.25E0/, T0 /288.15E0/, ALP /0.0065E0/,
     *     PTROP/226.321E0/, TSTR/216.65E0/, HTROP /11000.0E0/,
     *     PS /1000.0E0/, TWO /2.0E0/, SEVEN /7.0E0/
C*
      ROVCP=TWO/SEVEN
      GASR=RSTAR/RM0
      ROVG=GASR/GRAV
      FKT=ROVG*TSTR
      AR=ALP*ROVG
      PP0=PZERO**AR
C*
      IF(PRESS.LT.PISO) GOTO 12
C*
      IF(PRESS.GT.PTROP) GOTO 11
C*
C*    COMPUTE ISOTHERMAL CASES
C*
      HEIGHT=HTROP+FKT*LOG(PTROP/PRESS)
      TEMP=TSTR
      GOTO 300
C*
C*    COMPUTE LAPSE RATE=-.0010 CASES
C*
   12 AR=SALP*ROVG
      PP0=PISO**AR
      HEIGHT=(TSTR/(PP0*SALP))*(PP0-(PRESS**AR))+ZISO
      TEMP=TSTR-(HEIGHT-ZISO)*SALP
      GOTO 300
C*
   11 HEIGHT=(T0/(PP0*ALP))*(PP0-(PRESS**AR))
      TEMP=T0-HEIGHT*ALP
C*
  300 THETA=TEMP*((PS/PRESS)**ROVCP)
C*
      RETURN
      END
