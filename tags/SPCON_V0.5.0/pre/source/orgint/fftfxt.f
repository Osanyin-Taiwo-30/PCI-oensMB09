      SUBROUTINE FFTFXT(IMAX,IFAX,TRIGS)
C
      INTEGER IMAX,IFAX(*)
      REAL TRIGS(*)
C
      CALL FAX   (IFAX ,IMAX,2)
      CALL FFTRIG(TRIGS,IMAX,2)
C
      RETURN
      END