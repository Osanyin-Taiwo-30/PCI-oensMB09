!
!  $Author: tomita $
!  $Date: 2007/08/01 20:09:58 $
!  $Revision: 1.1.1.1 $
!
PROGRAM TemperatureClima

   ! First Point of Input and Output Data is at North Pole and Greenwhich
   ! Over Sea Value is 0.001 cm

   IMPLICIT NONE

   INTEGER, PARAMETER :: &
            r4 = SELECTED_REAL_KIND(6) ! Kind for 32-bits Real Numbers

   INTEGER :: Idim, Jdim, Idim1, LRec, ios

   LOGICAL :: GrADS

   CHARACTER (LEN=20) :: VarName='TemperatureClima'

   CHARACTER (LEN=41) :: FileBCs='clmt.form'

   CHARACTER (LEN=528) :: DirBCs, DirInp, DirOut

   REAL (KIND=r4), DIMENSION (:,:,:), ALLOCATABLE :: CLMT

   INTEGER :: nferr=0    ! Standard Error Print Out
   INTEGER :: nfinp=5    ! Standard Read In
   INTEGER :: nfprt=6    ! Standard Print Out
   INTEGER :: nfclm=10   ! To Read Formatted Climatological CLMT Data
   INTEGER :: nfout=20   ! To Write Unformatted Climatological CLMT Data
   INTEGER :: nfctl=30   ! To Write Output Data Description

   NAMELIST /InputDim/ Idim, Jdim, GrADS, DirBCs, DirInp, DirOut

   Idim=144
   Jdim=73
   GrADS=.TRUE.

   OPEN (UNIT=nfinp, FILE='./'//TRIM(VarName)//'.nml', &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', &
         ACTION='READ', STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file: ', &
              './'//TRIM(VarName)//'.nml', &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfinp, NML=InputDim)
   CLOSE (UNIT=nfinp)

   WRITE (UNIT=nfprt, FMT='(/,A)')  ' &InputDim'
   WRITE (UNIT=nfprt, FMT='(A,I6)') '    Idim = ', Idim
   WRITE (UNIT=nfprt, FMT='(A,I6)') '    Jdim = ', Jdim
   WRITE (UNIT=nfprt, FMT='(A,L6)') '   GrADS = ', GrADS
   WRITE (UNIT=nfprt, FMT='(A)')    '  DirInp = '//TRIM(DirInp)
   WRITE (UNIT=nfprt, FMT='(A)')    '  DirOut = '//TRIM(DirOut)
   WRITE (UNIT=nfprt, FMT='(A)')    '  DirBCs = '//TRIM(DirBCs)
   WRITE (UNIT=nfprt, FMT='(A,/)')  ' /'

   Idim1=Idim!-1
   ALLOCATE (CLMT(Idim,Jdim,12))
   INQUIRE (IOLENGTH=LRec) CLMT(:,:,:)
   OPEN(nfclm,FILE=TRIM(DirBCs)//'/'//TRIM(FileBCs),FORM='unformatted',&
       ACCESS='DIRECT',recl=LRec,ACTION='READ',STATUS='OLD',&
       IOSTAT=ios)

   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              TRIM(DirBCs)//'/'//TRIM(FileBCs), &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfclm,rec=1) CLMT
   CLOSE (UNIT=nfclm)

   INQUIRE (IOLENGTH=LRec) CLMT(:,:,:)
   OPEN (UNIT=nfout, FILE=TRIM(DirOut)//'/'//TRIM(VarName)//'.dat', &
         FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRec, ACTION='WRITE', &
         STATUS='REPLACE', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              TRIM(DirOut)//'/'//TRIM(VarName)//'.dat', &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   WRITE (UNIT=nfout, REC=1) CLMT(1:Idim1,Jdim:1:-1,1:12)
   CLOSE (UNIT=nfout)

   IF (GrADS) THEN
      OPEN (UNIT=nfctl, FILE=TRIM(DirOut)//'/'//TRIM(VarName)//'.ctl', &
            FORM='FORMATTED', ACCESS='SEQUENTIAL', ACTION='WRITE', &
            STATUS='REPLACE', IOSTAT=ios)
      IF (ios /= 0) THEN
         WRITE (UNIT=nferr, FMT='(3A,I4)') &
               ' ** (Error) ** Open file ', &
                 TRIM(DirOut)//'/'//TRIM(VarName)//'.ctl', &
               ' returned IOStat = ', ios
         STOP  ' ** (Error) **'
      END IF
      WRITE (UNIT=nfctl, FMT='(A)') 'DSET '// &
             TRIM(DirOut)//'/'//TRIM(VarName)//'.dat'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'OPTIONS YREV BIG_ENDIAN'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'UNDEF -999.0'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'TITLE CLimatological Temp'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A,I5,A,F8.3,F15.10)') &
            'XDEF ',Idim1,' LINEAR ',0.0_r4,360.0_r4/REAL(Idim1,r4)
      WRITE (UNIT=nfctl, FMT='(A,I5,A,F8.3,F15.10)') &
            'YDEF ',Jdim,' LINEAR ',-90.0_r4,180.0_r4/REAL(Jdim,r4)
      WRITE (UNIT=nfctl, FMT='(A)') 'ZDEF 1 LEVELS 1000'
      WRITE (UNIT=nfctl, FMT='(A)') 'TDEF 12 LINEAR JAN2005 1MO'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'VARS 1'
      WRITE (UNIT=nfctl, FMT='(A)') 'clmt 0 99 TemperatureClima [%]'
      WRITE (UNIT=nfctl, FMT='(A)') 'ENDVARS'
      CLOSE (UNIT=nfctl)
   END IF
PRINT *, "*** TemperatureClima ENDS NORMALLY ***"

END PROGRAM TemperatureClima
