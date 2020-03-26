!
!  $Author: tomita $
!  $Date: 2007/08/01 20:09:58 $
!  $Revision: 1.1.1.1 $
!
PROGRAM VegetationMaskSSiB

   IMPLICIT NONE

   INTEGER, PARAMETER :: &
            r4 = SELECTED_REAL_KIND(6) ! Kind for 32-bits Real Numbers

   INTEGER :: Idim, Jdim, LRecOut, LRecGad, ios

   LOGICAL :: GrADS

   CHARACTER (LEN=19) :: VarName='VegetationMaskClima'

   CHARACTER (LEN=20) :: VarNameG='VegetationMaskClimaG'

   CHARACTER (LEN=11) :: FileBCs='sibmsk.form'

   CHARACTER (LEN=22) :: NameNML='VegetationMaskSSiB.nml'

   CHARACTER (LEN=528) :: DirInp, DirOut, DirBCs

   INTEGER :: nferr=0    ! Standard Error Print Out
   INTEGER :: nfinp=5    ! Standard Read In
   INTEGER :: nfprt=6    ! Standard Print Out
   INTEGER :: nfclm=10   ! To Read Formatted Climatological Vegetation Mask
   INTEGER :: nfvgm=20   ! To Write Unformatted Climatological Vegetation Mask
   INTEGER :: nfout=30   ! To Write GrADS Climatological Vegetation Mask
   INTEGER :: nfctl=40   ! To Write GrADS Control File

   INTEGER, DIMENSION (:,:), ALLOCATABLE :: VegetationMask

   REAL (KIND=r4), DIMENSION (:,:), ALLOCATABLE :: VegMaskGad

   NAMELIST /InputDim/ Idim, Jdim, GrADS, DirInp, DirOut, DirBCs

   Idim=360
   Jdim=180
   GrADS=.TRUE.


   OPEN (UNIT=nfinp, FILE='./'//NameNML, &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', &
         ACTION='READ', STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file: ''./'//NameNML, &
              './'//NameNML, &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfinp, NML=InputDim)
   CLOSE (UNIT=nfinp)


   WRITE (UNIT=nfprt, FMT='(/,A)')  ' &InputDim'
   WRITE (UNIT=nfprt, FMT='(A,I6)') '     Idim = ', Idim
   WRITE (UNIT=nfprt, FMT='(A,I6)') '     Jdim = ', Jdim
   WRITE (UNIT=nfprt, FMT='(A,L6)') '    GrADS = ', GrADS
   WRITE (UNIT=nfprt, FMT='(A)')    '   DirInp = '//TRIM(DirInp)
   WRITE (UNIT=nfprt, FMT='(A)')    '   DirOut = '//TRIM(DirOut)
   WRITE (UNIT=nfprt, FMT='(A)')    '   DirBCs = '//TRIM(DirBCs)
   WRITE (UNIT=nfprt, FMT='(A,/)')  ' /'

   ALLOCATE (VegetationMask(Idim,Jdim), VegMaskGad(Idim,Jdim))


   OPEN (UNIT=nfclm, FILE=TRIM(DirBCs)//'/'//FileBCs, &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', ACTION='READ', &
         STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      PRINT *, TRIM(DirBCs)//'/'//FileBCs
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file '//FileBCs, &
              TRIM(DirBCs)//'/'//FileBCs, &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfclm, FMT='(40I2)') VegetationMask
   CLOSE (UNIT=nfclm)
   CALL FlipMatrix ()

   INQUIRE (IOLENGTH=LRecOut) VegetationMask


   OPEN (UNIT=nfvgm, FILE=TRIM(DirOut)//'/'//VarName//'.dat', &
         FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRecOut, ACTION='WRITE', &
         STATUS='REPLACE', IOSTAT=ios)
   IF (ios /= 0) THEN
      PRINT *, TRIM(DirOut)//'/'//VarName//'.dat'
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file '//VarName, &
              TRIM(DirOut)//'/'//VarName//'.dat', &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   WRITE (UNIT=nfvgm, REC=1) VegetationMask
   CLOSE (UNIT=nfvgm)

   IF (GrADS) THEN
      INQUIRE (IOLENGTH=LRecGad) VegMaskGad

      OPEN (UNIT=nfout, FILE=TRIM(DirOut)//'/'//VarNameG//'.dat', &
            FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRecGad, ACTION='WRITE', &
            STATUS='REPLACE', IOSTAT=ios)
      IF (ios /= 0) THEN
         PRINT *, TRIM(DirOut)//'/'//VarNameG//'.dat'
         WRITE (UNIT=nferr, FMT='(3A,I4)') &
               ' ** (Error) ** Open file '//VarNameG//'.dat', &
                 TRIM(DirOut)//'/'//VarNameG//'.dat', &
               ' returned IOStat = ', ios
         STOP  ' ** (Error) **'
      END IF
      VegMaskGad=REAL(VegetationMask,r4)
      WRITE (UNIT=nfout, REC=1) VegMaskGad
      CLOSE (UNIT=nfout)


      OPEN (UNIT=nfctl, FILE=TRIM(DirOut)//'/'//VarNameG//'.ctl', &
            FORM='FORMATTED', ACCESS='SEQUENTIAL', &
            ACTION='WRITE', STATUS='REPLACE', IOSTAT=ios)
      IF (ios /= 0) THEN
         PRINT *, TRIM(DirOut)//'/'//VarNameG//'.ctl'
         WRITE (UNIT=nferr, FMT='(3A,I4)') &
               ' ** (Error) ** Open file '//VarNameG//'.ctl', &
                 TRIM(DirOut)//'/'//VarNameG//'.ctl', &
               ' returned IOStat = ', ios
         STOP  ' ** (Error) **'
      END IF
      WRITE (UNIT=nfctl, FMT='(A)') 'DSET '// &
             TRIM(DirOut)//'/'//VarNameG//'.dat'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'OPTIONS YREV BIG_ENDIAN'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'UNDEF -999.0'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'TITLE SSiB Vegetation Mask'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A,I5,A,F8.3,F15.10)') &
            'XDEF ',Idim,' LINEAR ',0.0_r4,360.0_r4/REAL(Idim,r4)
      WRITE (UNIT=nfctl, FMT='(A,I5,A,F8.3,F15.10)') &
            'YDEF ',Jdim,' LINEAR ',-89.5_r4,179.0_r4/REAL(Jdim-1,r4)
      WRITE (UNIT=nfctl, FMT='(A)') 'ZDEF 1 LEVELS 1000'
      WRITE (UNIT=nfctl, FMT='(A)') 'TDEF 1 LINEAR JAN2005 1MO'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'VARS 1'
      WRITE (UNIT=nfctl, FMT='(A)') 'VEGM 0 99 Vegetation Mask [No Dim]'
      WRITE (UNIT=nfctl, FMT='(A)') 'ENDVARS'
      CLOSE (UNIT=nfctl)

   END IF

PRINT *, "*** VegetationMaskSSiB ENDS NORMALLY ***"

CONTAINS


SUBROUTINE FlipMatrix ()

   ! Flips Over The Rows of a Matrix, After Flips Over
   ! I.D.L. and Greenwitch

   ! Input:
   ! VegetationMask(Idim,Jdim) - Matrix to be Flipped

   ! Output:
   ! VegetationMask(Idim,Jdim) - Flipped Matrix

   INTEGER :: Idimd, Idimd1

   INTEGER :: wk(Idim,Jdim)

   Idimd=Idim/2
   Idimd1=Idimd+1

   wk=VegetationMask
   VegetationMask(1:Idimd,:)=wk(Idimd1:Idim,:)
   VegetationMask(Idimd1:Idim,:)=wk(1:Idimd,:)

   wk=VegetationMask
   VegetationMask(:,1:Jdim)=wk(:,Jdim:1:-1)

END SUBROUTINE FlipMatrix


END PROGRAM VegetationMaskSSiB
