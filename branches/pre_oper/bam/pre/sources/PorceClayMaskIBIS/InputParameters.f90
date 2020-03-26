!
!  $Author: tomita $
!  $Date: 2007/08/01 20:09:58 $
!  $Revision: 1.1.1.1 $
!
MODULE InputParameters

   IMPLICIT NONE

   PRIVATE

   INTEGER, PARAMETER, PUBLIC :: &
            r4 = SELECTED_REAL_KIND(6)  ! Kind for 32-bits Real Numbers
   INTEGER, PARAMETER, PUBLIC :: &
            r8 = SELECTED_REAL_KIND(15) ! Kind for 64-bits Real Numbers

   INTEGER, PUBLIC :: Imax, Jmax, Idim, Jdim,Layer

   LOGICAL, PUBLIC :: PolarMean, GrADS

   LOGICAL, PUBLIC :: FlagInput(5), FlagOutput(5)

   INTEGER, DIMENSION (:,:), ALLOCATABLE, PUBLIC :: MaskInput

   CHARACTER (LEN=7), PUBLIC :: nLats='.G     '

   CHARACTER (LEN=10), PUBLIC :: mskfmt = '(      I1)'

   CHARACTER (LEN=11), PUBLIC :: NameLSM='LandSeaMask'

   CHARACTER (LEN=59), PUBLIC :: VarName='PorceClayMaskIBISClima'

   CHARACTER (LEN=16), PUBLIC :: NameLSMSSiB='ModelLandSeaMask'

   CHARACTER (LEN=24), PUBLIC :: VarNameVeg='PorceClayMaskIBIS'

   CHARACTER (LEN=49) :: NameNML='PorceClayMaskIBIS.nml'

   CHARACTER (LEN=528), PUBLIC :: DirInp, DirOut

   INTEGER, PUBLIC :: Undef=0

   REAL (KIND=r4), PUBLIC :: UndefG=-99.0

   INTEGER, PUBLIC :: nferr=0    ! Standard Error Print Out
   INTEGER, PUBLIC :: nfinp=5    ! Standard Read In
   INTEGER, PUBLIC :: nfprt=6    ! Standard Print Out
   INTEGER, PUBLIC :: nflsm=10   ! To Read Formatted Land Sea Mask
   INTEGER, PUBLIC :: nfcvm=20   ! To Read Unformatted Climatological Vegetation Mask
   INTEGER, PUBLIC :: nfvgm=30   ! To Write Unformatted Gaussian Grid Vegetation Mask
   INTEGER, PUBLIC :: nflsv=40   ! To Write Formatted Land Sea Mask Modified by Vegetation
   INTEGER, PUBLIC :: nfout=50   ! To Write GrADS Land Sea and Vegetation Mask
   INTEGER, PUBLIC :: nfctl=60   ! To Write GrADS Control File

   PUBLIC :: InitInputParameters

   INTEGER, PARAMETER, PUBLIC :: NumCat=100
   INTEGER, DIMENSION (NumCat), PUBLIC :: VegClass = &
            (/1,1,1,1,1,1,1,1,1,1,&
              2,2,2,2,2,2,2,2,2,2,&
              3,3,3,3,3,3,3,3,3,3,&
              4,4,4,4,4,4,4,4,4,4,&
              5,5,5,5,5,5,5,5,5,5,&
              6,6,6,6,6,6,6,6,6,6,&
              7,7,7,7,7,7,7,7,7,7,&
              8,8,8,8,8,8,8,8,8,8,&
              9,9,9,9,9,9,9,9,9,9,&
              2,2,2,2,2,2,2,2,2,2/)


CONTAINS


SUBROUTINE InitInputParameters ()

   IMPLICIT NONE

   INTEGER :: ios

   NAMELIST /InputDim/ Imax, Jmax, Idim, Jdim,Layer, &
                       GrADS, DirInp, DirOut

   Imax=192
   Jmax=96
   Idim=360
   Jdim=180
   Layer=6
   GrADS=.TRUE.

   OPEN (UNIT=nfinp, FILE='./'//TRIM(NameNML), &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', &
         ACTION='READ', STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              './'//TRIM(NameNML), &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfinp, NML=InputDim)
   CLOSE (UNIT=nfinp)

   WRITE (UNIT=nfprt, FMT='(/,A)')  ' &InputDim'
   WRITE (UNIT=nfprt, FMT='(A,I6)') '      Imax = ', Imax
   WRITE (UNIT=nfprt, FMT='(A,I6)') '      Jmax = ', Jmax
   WRITE (UNIT=nfprt, FMT='(A,I6)') '      Idim = ', Idim
   WRITE (UNIT=nfprt, FMT='(A,I6)') '      Jdim = ', Jdim
   WRITE (UNIT=nfprt, FMT='(A,I6)') '      Layer= ', Layer   
   WRITE (UNIT=nfprt, FMT='(A,L6)') '     GrADS = ', GrADS
   WRITE (UNIT=nfprt, FMT='(A)')    '    DirInp = '//TRIM(DirInp)
   WRITE (UNIT=nfprt, FMT='(A)')    '    DirOut = '//TRIM(DirOut)
   WRITE (UNIT=nfprt, FMT='(A,/)')  ' /'

   ALLOCATE (MaskInput(Idim,Jdim))
   MaskInput=1
   PolarMean=.FALSE.
   FlagInput(1)=.TRUE.   ! Start at North Pole
   FlagInput(2)=.TRUE.   ! Start at Prime Meridian
   FlagInput(3)=.FALSE.  ! Latitudes Are at North Edge
   FlagInput(4)=.FALSE.  ! Longitudes Are at Western Edge
   FlagInput(5)=.FALSE.  ! Regular Grid
   FlagOutput(1)=.TRUE.  ! Start at North Pole
   FlagOutput(2)=.TRUE.  ! Start at Prime Meridian
   FlagOutput(3)=.FALSE. ! Latitudes Are at North Edge of Box
   FlagOutput(4)=.TRUE.  ! Longitudes Are at Center of Box
   FlagOutput(5)=.TRUE.  ! Gaussian Grid

   WRITE (nLats(3:7), '(I5.5)') Jmax

   WRITE (mskfmt(2:7), '(I6)') Imax

END SUBROUTINE InitInputParameters


END MODULE InputParameters
