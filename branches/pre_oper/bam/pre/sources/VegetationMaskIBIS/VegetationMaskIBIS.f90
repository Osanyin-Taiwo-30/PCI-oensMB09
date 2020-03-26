!
!  $Author: tomita $
!  $Date: 2007/08/01 20:09:58 $
!  $Revision: 1.1.1.1 $
!
PROGRAM VegetationMaskIBIS

   USE InputParameters, ONLY: r4, r8, Undef, UndefG, &
                              nferr, nfprt, nflsm, nfcvm, &
                              nfvgm, nflsv, nfout, nfctl, &
                              Imax, Jmax, Idim, Jdim, &
                              nLats, mskfmt, NameLSM, VarName, &
                              NameLSMSSiB, VarNameVeg, &
                              DirOut, DirInp, &
                              GrADS, &
                              InitInputParameters

   USE AreaIntegerInterp, ONLY: gLats, InitAreaIntegerInterp, &
                                        DoAreaIntegerInterp

   IMPLICIT NONE
   ! Horizontal Areal Interpolator
   ! Interpolate Regular To Gaussian
   ! Regular Input Data is Assumed to be Oriented with
   ! the North Pole and Greenwich as the First Point

   ! Set Undefined Value for Input Data at Locations which
   ! are not to be Included in Interpolation

   INTEGER :: LRecIn, LRecOut, LRecGad, ios, &
              i, j, im, ip, jm, jp, kk, &
              k1, k2, k3, k4, k5, k6, k7, k8

   INTEGER, DIMENSION (:,:), ALLOCATABLE :: VegetationMaskIBISIn
   INTEGER, DIMENSION (:,:), ALLOCATABLE :: VegetationMaskIBISOut, VegMaskSave
   INTEGER, DIMENSION (:,:), ALLOCATABLE :: LandSeaMask, LSMaskSave
   INTEGER, DIMENSION (:,:), ALLOCATABLE :: VegetationMaskIBISInput
   INTEGER, DIMENSION (:,:), ALLOCATABLE :: VegetationMaskIBISOutput

   REAL (KIND=r4), DIMENSION (:,:), ALLOCATABLE :: Gad

   CALL InitInputParameters ()

   CALL InitAreaIntegerInterp ()

   ALLOCATE (VegetationMaskIBISInput(Idim,Jdim))
   ALLOCATE (VegetationMaskIBISOutput(Imax,Jmax))
   ALLOCATE (VegetationMaskIBISIn(Idim,Jdim))
   ALLOCATE (VegetationMaskIBISOut(Imax,Jmax), VegMaskSave(Imax,Jmax))
   ALLOCATE (LandSeaMask(Imax,Jmax), LSMaskSave(Imax,Jmax))
   ALLOCATE (Gad(Imax,Jmax))

   ! Land Sea Mask : Input
   OPEN (UNIT=nflsm, FILE=TRIM(DirOut)//'/'//NameLSM//nLats, &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', &
         ACTION='READ', STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file: ', &
              TRIM(DirOut)//'/'//NameLSM//nLats, &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nflsm, FMT=mskfmt) LandSeaMask
   LSMaskSave=LandSeaMask
   CLOSE (UNIT=nflsm)

   ! Read In Input VegetationMaskIBIS
   INQUIRE (IOLENGTH=LRecIn) VegetationMaskIBISIn
   OPEN (UNIT=nfcvm, FILE=TRIM(DirInp)//'/'//TRIM(VarName)//'.dat', &
         FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRecIn, ACTION='READ', &
         STATUS='OLD', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              TRIM(DirInp)//'/'//TRIM(VarName)//'.dat', &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   READ  (UNIT=nfcvm, REC=1) VegetationMaskIBISIn
   CLOSE (UNIT=nfcvm)

   ! Interpolate Input Regular VegetationMaskIBIS To Gaussian Grid Output
   VegetationMaskIBISInput=INT(VegetationMaskIBISIn)
   CALL DoAreaIntegerInterp (VegetationMaskIBISInput, VegetationMaskIBISOutput)
   VegMaskSave=INT(VegetationMaskIBISOutput)

   ! Fix Problems on Vegetation Mask and Land Sea Mask
   CALL VegetationMaskCheck ()
   VegetationMaskIBISOut=INT(VegetationMaskIBISOutput)
 
   ! Write Out Adjusted Interpolated VegetationMaskIBIS
   INQUIRE (IOLENGTH=LRecOut) VegetationMaskIBISOut
   OPEN (UNIT=nfvgm, FILE=TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats, &
         FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRecOut, ACTION='WRITE', &
         STATUS='REPLACE', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats, &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   WRITE (UNIT=nfvgm, REC=1) VegetationMaskIBISOut
   CLOSE (UNIT=nfvgm)

   ! Land Sea Mask : Output
   OPEN (UNIT=nflsv, FILE=TRIM(DirOut)//'/'//NameLSMSSiB//nLats, &
         FORM='FORMATTED', ACCESS='SEQUENTIAL', &
         ACTION='WRITE', STATUS='REPLACE', IOSTAT=ios)
   IF (ios /= 0) THEN
      WRITE (UNIT=nferr, FMT='(3A,I4)') &
            ' ** (Error) ** Open file ', &
              TRIM(DirOut)//'/'//NameLSMSSiB//nLats, &
            ' returned IOStat = ', ios
      STOP  ' ** (Error) **'
   END IF
   WRITE (UNIT=nflsv, FMT=mskfmt) LandSeaMask
   CLOSE (UNIT=nflsv)

   IF (GrADS) THEN
      INQUIRE (IOLENGTH=LRecGad) Gad
      OPEN (UNIT=nfout, FILE=TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats, &
            FORM='UNFORMATTED', ACCESS='DIRECT', RECL=LRecGad, ACTION='WRITE', &
            STATUS='REPLACE', IOSTAT=ios)
      IF (ios /= 0) THEN
         WRITE (UNIT=nferr, FMT='(3A,I4)') &
               ' ** (Error) ** Open file ', &
                 TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats, &
               ' returned IOStat = ', ios
         STOP  ' ** (Error) **'
      END IF
      Gad=REAL(LSMaskSave,r4)
      WRITE (UNIT=nfout, REC=1) Gad
      Gad=REAL(LandSeaMask,r4)
      WRITE (UNIT=nfout, REC=2) Gad
      Gad=REAL(VegMaskSave,r4)
      WRITE (UNIT=nfout, REC=3) Gad
      Gad=REAL(VegetationMaskIBISOut,r4)
      WRITE (UNIT=nfout, REC=4) Gad
      CLOSE (UNIT=nfout)
      ! Write GrADS Control File
      OPEN (UNIT=nfctl, FILE=TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats//'.ctl', &
            FORM='FORMATTED', ACCESS='SEQUENTIAL', &
            ACTION='WRITE', STATUS='REPLACE', IOSTAT=ios)
      IF (ios /= 0) THEN
         WRITE (UNIT=nferr, FMT='(3A,I4)') &
               ' ** (Error) ** Open file ', &
                 TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats//'.ctl', &
               ' returned IOStat = ', ios
         STOP  ' ** (Error) **'
      END IF
      WRITE (UNIT=nfctl, FMT='(A)') 'DSET '// &
             TRIM(DirOut)//'/'//TRIM(VarNameVeg)//nLats
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'OPTIONS YREV BIG_ENDIAN'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A,1PG12.5)') 'UNDEF ', UndefG
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A)') 'TITLE Vegetation Mask on a Gaussian Grid'
      WRITE (UNIT=nfctl, FMT='(A)') '*'
      WRITE (UNIT=nfctl, FMT='(A,I5,A,F8.3,F15.10)') &
                          'XDEF ',Imax,' LINEAR ',0.0_r8,360.0_r8/REAL(Imax,r8)
      WRITE (UNIT=nfctl, FMT='(A,I5,A)') 'YDEF ',Jmax,' LEVELS '
      WRITE (UNIT=nfctl, FMT='(8F10.5)') gLats(Jmax:1:-1)
      WRITE (UNIT=nfctl, FMT='(A)') 'ZDEF  1 LEVELS 1000'
      WRITE (UNIT=nfctl, FMT='(A)') 'TDEF  1 LINEAR JAN2005 1MO'
      WRITE (UNIT=nfctl, FMT='(A)') 'VARS  4'
      WRITE (UNIT=nfctl, FMT='(A)') 'LSMO  0 99 Land Sea Mask Before Fix  [0-Sea 1-Land]'
      WRITE (UNIT=nfctl, FMT='(A)') 'LSMK  0 99 Land Sea Mask For Model   [0-Sea 1-Land]'
      WRITE (UNIT=nfctl, FMT='(A)') 'VGMO  0 99 Vegetation Mask Before Fix [0 to 13]'
      WRITE (UNIT=nfctl, FMT='(A)') 'VEGM  0 99 Vegetation Mask For Model  [0 to 13]'
      WRITE (UNIT=nfctl, FMT='(A)') 'ENDVARS'
      CLOSE (UNIT=nfctl)
   END IF

PRINT *, "*** VegetationMaskIBIS ENDS NORMALLY ***"

CONTAINS


SUBROUTINE VegetationMaskCheck ()

   IMPLICIT NONE

   10 CONTINUE
   DO j=1,Jmax
     DO i=1,Imax
        IF (LandSeaMask(i,j) /= 0 .AND. VegetationMaskIBISOutput(i,j) == Undef) THEN
           IF (im == 0) THEN
              im=Imax
           ELSE
              im=i-1
           END IF
           IF (ip > Imax) THEN
              ip=1
           ELSE
              ip=i+1
           END IF
           IF (jm == 0) THEN
              jm=1
           ELSE
              jm=j-1
           END IF
           IF (jp > Jmax) THEN
              jp=Jmax
           ELSE
              jp=j+1
           END IF
           IF (LandSeaMask(im,jm) /= 0) THEN
              k1=VegetationMaskIBISOutput(im,jm)
           ELSE
              k1=0
           END IF
           IF (LandSeaMask(i,jm) /= 0) THEN
              k2=VegetationMaskIBISOutput(i,jm)
           ELSE
              k2=0
           END IF
           IF (LandSeaMask(ip,jm) /= 0) THEN
              k3=VegetationMaskIBISOutput(ip,jm)
           ELSE
              k3=0
           END IF
           IF (LandSeaMask(im,j) /= 0) THEN
              k4=VegetationMaskIBISOutput(im,j)
           ELSE
              k4=0
           END IF
           IF (LandSeaMask(ip,j) /= 0) THEN
              k5=VegetationMaskIBISOutput(ip,j)
           ELSE
              k5=0
           END IF
           IF (LandSeaMask(im,jp) /= 0) THEN
              k6=VegetationMaskIBISOutput(im,jp)
           ELSE
              k6=0
           END IF
           IF (LandSeaMask(i,jp) /= 0) THEN
              k7=VegetationMaskIBISOutput(i,jp)
           ELSE
              k7=0
           END IF
           IF (LandSeaMask(ip,jp) /= 0) THEN
              k8=VegetationMaskIBISOutput(ip,jp)
           ELSE
              k8=0
           END IF

           IF (k1+k2+k3+k4+k5+k6+k7+k8 == 0) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF
      
           IF (k1 /= 0) THEN
              kk=k1
           ELSE
              kk=-1
           END IF
           IF (k2 /= 0 .AND. kk == -1) THEN
              kk=k2
           ELSE IF (k2 /= 0 .AND. kk /= k2) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k3 /= 0 .AND. kk == -1) THEN
              kk=k3
           ELSE IF (k3 /= 0 .AND. kk /= k3) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k4 /= 0 .AND. kk == -1) THEN
              kk=k4
           ELSE IF (k4 /= 0 .AND. kk /= k4) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k5 /= 0 .AND. kk == -1) THEN
              kk=k5
           ELSE IF (k5 /= 0 .AND. kk /= k5) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k6 /= 0 .AND. kk == -1) THEN
              kk=k6
           ELSE IF (k6 /= 0 .AND. kk /= k6) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k7 /= 0 .AND. kk == -1) THEN
              kk=k7
           ELSE IF (k7 /= 0 .AND. kk /= k7) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           IF (k8 /= 0 .AND. kk == -1) THEN
              kk=k8
           ELSE IF (k8 /= 0 .AND. kk /= k8) THEN
              CALL VegetationMaskFix ()
              GO TO 10
           END IF

           VegetationMaskIBISOutput(i,j)=kk
           WRITE (UNIT=*, FMT='(A,2I4,A,I2)') &
                 ' Undefined Location i, j = ', i, j, &
                 ' Filled with Nearby Value = ', kk
         END IF

         IF (LandSeaMask(i,j) == 0) VegetationMaskIBISOutput(i,j)=Undef

      END DO
   END DO

END SUBROUTINE VegetationMaskCheck


SUBROUTINE VegetationMaskFix ()

   IMPLICIT NONE
 
   WRITE (UNIT=*, FMT='(A,2I4,/,A,/,(11X,3I3))') &
         ' At Land Point Value Undefined at i, j = ', i, j, &
         ' With no Unambigous Nearby Values.  Local Area:', &
           k1, k2, k3, k4, VegetationMaskIBISOutput(i,j), k5, k6, k7, k8

   IF (LandSeaMask(i,j) == 1) THEN
     LandSeaMask(i,j)=0
     WRITE (UNIT=*, FMT='(A)') ' Land Sea Mask Changed from 1 to 0'
   ELSE
     LandSeaMask(i,j)=1
     WRITE (UNIT=*, FMT='(A)') ' Land Sea Mask Changed from 0 to 1'
   END IF

END SUBROUTINE VegetationMaskFix


END PROGRAM VegetationMaskIBIS
