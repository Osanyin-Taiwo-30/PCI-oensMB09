!
!  $Author: pkubota $
!  $Date: 2008/04/09 12:42:57 $
!  $Revision: 1.9 $
!
MODULE PlanBoundLayer

  USE Constants, ONLY :     &
       cp,            &
       grav,          &
       gasr,          &
       r8

  USE Options, ONLY :  &
       nferr, nfprt


  IMPLICIT NONE

  PRIVATE
  PUBLIC :: InitPlanBoundLayer
  PUBLIC :: ympbl0

  REAL(KIND=r8),    PARAMETER :: eps   =   0.608_r8
  REAL(KIND=r8),    PARAMETER :: shrmin=   1.0e-5_r8
  REAL(KIND=r8),    PARAMETER :: facl  =   0.1_r8
  INTEGER, PARAMETER :: nitr  =   2
  REAL(KIND=r8),    PARAMETER :: gkm0  =   1.00_r8
  REAL(KIND=r8),    PARAMETER :: gkh0  =   0.10_r8
  REAL(KIND=r8),    PARAMETER :: gkm1  = 300.0_r8
  REAL(KIND=r8),    PARAMETER :: gkh1  = 300.0_r8
  REAL(KIND=r8),    PARAMETER :: vk0   =   0.4_r8
  INTEGER, PARAMETER :: kmean =   1
  REAL(KIND=r8),    PARAMETER :: a1    =   0.92_r8
  REAL(KIND=r8),    PARAMETER :: a2    =   0.74_r8
  REAL(KIND=r8),    PARAMETER :: b1    =  16.6_r8
  REAL(KIND=r8),    PARAMETER :: b2    =  10.1_r8
  REAL(KIND=r8),    PARAMETER :: c1    =   0.08_r8
  REAL(KIND=r8),    PARAMETER :: deltx =   0.0_r8


  REAL(KIND=r8), PARAMETER :: x        = 1.0_r8
  REAL(KIND=r8), PARAMETER :: xx       = x*x
!  REAL(KIND=r8), PARAMETER :: g        = 1.0_r8
!  REAL(KIND=r8), PARAMETER :: gravi    = 9.81_r8
!  REAL(KIND=r8), PARAMETER :: agrav    = 1.0_r8/gravi
!  REAL(KIND=r8), PARAMETER :: rgas     = 287.0_r8
!  REAL(KIND=r8), PARAMETER :: akwnmb   = 2.5e-05_r8
!  REAL(KIND=r8), PARAMETER :: lstar    = 1.0_r8/akwnmb
!  REAL(KIND=r8), PARAMETER :: gocp     = gravi/1005.0_r8
!  INTEGER         :: nbase
!  INTEGER         :: nthin,nthinp

  REAL(KIND=r8)               :: alfa
  REAL(KIND=r8)               :: beta
  REAL(KIND=r8)               :: gama
  REAL(KIND=r8)               :: dela
  REAL(KIND=r8)               :: r1
  REAL(KIND=r8)               :: r2
  REAL(KIND=r8)               :: r3
  REAL(KIND=r8)               :: r4
  REAL(KIND=r8)               :: s1
  REAL(KIND=r8)               :: s2
  REAL(KIND=r8)               :: rfc
  REAL(KIND=r8), ALLOCATABLE  :: sigkiv(:)
  REAL(KIND=r8), ALLOCATABLE  :: sigr(:)
  REAL(KIND=r8), ALLOCATABLE  :: sigriv(:)
  REAL(KIND=r8), ALLOCATABLE  :: a0(:)
  REAL(KIND=r8), ALLOCATABLE  :: b0(:)
  REAL(KIND=r8), ALLOCATABLE  :: con0(:)
  REAL(KIND=r8), ALLOCATABLE  :: con1(:)
  REAL(KIND=r8), ALLOCATABLE  :: con2(:)
  REAL(KIND=r8), ALLOCATABLE  :: t0(:)
  REAL(KIND=r8), ALLOCATABLE  :: t1(:)
  REAL(KIND=r8)               :: c0

CONTAINS


  SUBROUTINE InitPlanBoundLayer(kmax, sig, delsig, sigml)
    INTEGER, INTENT(IN) :: kmax
    REAL(KIND=r8),    INTENT(IN) :: sig(kmax)
    REAL(KIND=r8),    INTENT(IN) :: delsig(kmax)
    REAL(KIND=r8),    INTENT(IN) :: sigml(kmax)
    INTEGER  :: k
    REAL(KIND=r8)     :: gam1
    REAL(KIND=r8)     :: gam2
    REAL(KIND=r8)     :: gbyr
    REAL(KIND=r8)     :: akappa
    REAL(KIND=r8)     :: sigk(kmax)
    ALLOCATE(sigkiv(kmax))
    ALLOCATE(sigr  (kmax))
    ALLOCATE(sigriv(kmax))
    ALLOCATE(a0    (kmax))
    ALLOCATE(b0    (kmax))
    ALLOCATE(con0  (kmax))
    ALLOCATE(con1  (kmax))
    ALLOCATE(con2  (kmax))
    ALLOCATE(t0    (kmax))
    ALLOCATE(t1    (kmax))
    gam1=1.0_r8/3.0_r8-2.0_r8*a1/b1
    gam2=(b2+6.0_r8*a1)/b1
    alfa=b1*(gam1-c1)+3.0_r8*(a2+2.0_r8*a1)
    beta=b1*(gam1-c1)
    gama=a2/a1*(b1*(gam1+gam2)-3.0_r8*a1)
    dela=a2/a1* b1* gam1
    r1  =0.5_r8*gama/alfa
    r2  =    beta/gama
    r3  =2.0_r8*(2.0_r8*alfa*dela-gama*beta)/(gama*gama)
    r4  =r2*r2
    s1  =3.0_r8*a2* gam1
    s2  =3.0_r8*a2*(gam1+gam2)
    !
    !     critical flux richardson number
    !
    rfc =s1/s2
    akappa=gasr/cp
    !
    DO k = 1, kmax
       sigk  (k)=sig(k)**akappa
       sigkiv(k)=1.0_r8/sigk(k)
       con0  (k)=gasr*delsig(k)/(grav*sig(k))
    END DO
    a0    (kmax)=0.0_r8
    b0    (   1)=0.0_r8
    sigr  (kmax)=0.0_r8
    sigriv(   1)=0.0_r8
    gbyr        =(grav/gasr)**2!(m/sec**2)/(J/(Kg*K))=(m/sec**2)/((Kg*(m/sec**2)*m)/(Kg*K))
    !(m/sec**2)/((Kg*(m**2/sec**2))/(Kg*K))
    !(m/sec**2)/(m**2/sec**2*K)=K**2/m**2
    DO k = 1, kmax-1
       con1  (   k)=grav*sigml(k+1)/(gasr*(sig(k)-sig(k+1)))
       con2  (   k)=grav*con1(k)
       con1  (   k)=con1(k)*con1(k)
       t0    (   k)=(sig(k+1)-sigml(k+1))/(sig(k+1)-sig(k))
       t1    (   k)=(sigml(k+1)-sig(k  ))/(sig(k+1)-sig(k))
       sigr  (   k)=sigk(k)*sigkiv(k+1)
       sigriv( k+1)=sigk(k+1)*sigkiv(k)
       a0(k)=gbyr*sigml(k+1)**2/(delsig(k  )*(sig(k)-sig(k+1)))
       b0(k+1)=gbyr*sigml(k+1)**2/(delsig(k+1)*(sig(k)-sig(k+1)))
    END DO
    c0=grav/(gasr*delsig(1))
  END SUBROUTINE InitPlanBoundLayer
  !----------------------------------------------------------------------
  !XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  !----------------------------------------------------------------------
  SUBROUTINE gauss1(g,ncols,kmax,ndim)
    !
    !!-----------------------------------------------------------------------
    ! ncols....number of grid points on a gaussian latitude circle
    ! kmax.....kpbl or kqpbl number of  vertical grid points..
    !          kpbl number of layers pbl process is included( for u v,t )..
    !          kqpbl  number of layers pbl process is included( for q     )
    ! ndim.....dimension of  g idim=3 or idim=4
    ! g........gmt, gmq, gmu (temperature related matrix,
    !                         specific humidity related matrix,
    !                         wind related matrix
    !!-----------------------------------------------------------------------
    INTEGER, INTENT(in   ) :: ncols
    INTEGER, INTENT(in   ) :: kmax
    INTEGER, INTENT(in   ) :: ndim
    REAL(KIND=r8),    INTENT(inout) :: g(ncols,kmax,ndim)
    INTEGER :: i
    INTEGER :: k
    DO k=2,kmax
       DO i=1,ncols
          g(i,k,3)=(g(i,k,3)-g(i,k,1)*g(i,k-1,3))/g(i,k,2)
       END DO
    END DO
    IF (ndim == 4) THEN
       DO  k=2,kmax
          DO i=1,ncols
             g(i,k,4)=(g(i,k,4)-g(i,k,1)*g(i,k-1,4))/g(i,k,2)
          END DO
       END DO
    END IF
  END SUBROUTINE gauss1
  !----------------------------------------------------------------------
  !XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  !----------------------------------------------------------------------
  SUBROUTINE ympbl0 ( &
       gu    ,gv    ,gt    ,gq    ,delsig,ncols , &
       kmax  ,delt  ,colrad ,gmt   ,gmq   ,gmu   ,gl0 ,PBL )
    !
    !
    ! ympbl0 :performs momentum, water vapour and sensible heat diffusion
    !         on planetary boundary layer.
    ! A. Vertical diffusion - Mellor-Yamada closure scheme
    ! The effects of mixing of heat, momentum and moisture by small scale
    ! turbulence is represented by vertical diffusion in the COLA GCM.
    ! The mixing coefficients are calculated according to the "level 2.0"
    ! closure scheme of Mellor and Yamada (1982). This method assumes a
    ! local balance between production and dissipation of turbulent kinetic
    ! energy. There are no explicit prognostic variables to describe
    ! the planetary boundary layer (PBL); instead, the entire atmosphere
    ! is represented in discrete layers which may or may not be part
    ! of the PBL. The prognostic equations for atmospheric temperatures
    ! and moisture are then coupled to the SSIB equations for the
    ! ground surface and canopy, and the system of coupled equations is
    ! solved simultaneously with vertical diffusion of heat, moisture,
    ! and momentum as given by the Mellor and Yamada (1982) scheme.
    !
    ! In the turbulence closure method, each prognostic variable is expressed
    ! as a sum of a large scale (resolved) part and a turbulent (sub-grid)
    ! scale part. The vertical fluxes that are expressed as quadratic terms
    ! in the turbulent quantities are assumed to be represented by vertical
    ! diffusion down the gradient of the large scale quantities, e.g.
    !-----------------------------------------------------------------------
    !
    !           input values
    !-----------------------------------------------------------------------
    !..imx.......Number of grid points on a gaussian latitude circle (ncols+ 2)
    !..ncols......Number of grid points on a gaussian latitude circle
    !..kmax......Number of grid points at vertcal
    !..cp........Specific heat of air           (j/kg/k)
    !..gasr......Gas constant of dry air        (j/kg/k)
    !..grav......gravity constant               (m/s**2)
    !..gu,gv,gt,gq is at time level t-dt
    !
    !..gu    (zonal      velocity)*sin(colat)
    !..gv    (meridional velocity)*sin(colat)
    !..gt    temperature
    !..gq    specific humidity
    !..fsen  sensible heat flux in w/m**2
    !..flat  latent   heat fulx in w/m**2
    !..fmom  momentum flux      in n/m**2
    !
    !..delsig     k=2  ****gu,gv,gt,gq,gyu,gyv,gtd,gqd,sig*** } delsig(2)
    !             k=3/2----si,ric,rf,km,kh,b,l -----------
    !             k=1  ****gu,gv,gt,gq,gyu,gyv,gtd,gqd,sig*** } delsig(1)
    !             k=1/2----si ----------------------------
    !..delt   time interval
    !..gl0    maximum mixing length l0 in blackerdar's formula
    !                                  l=k0*z/(1+k0*z/l0)
    !..csqiv  1./sin(colat)**2
    !..ncols   number of grid points on a gaussian latitude circle
    !..kpbl   number of layers pbl process is included( for u v,t )
    !..kqpbl  number of layers pbl process is included( for q     )
    !-----------------------------------------------------------------------
    !           work arrays
    !-----------------------------------------------------------------------
    !..gwrk
    !..gld
    !..gln
    !-----------------------------------------------------------------------
    !           output values
    !-----------------------------------------------------------------------
    !..gmt    temperature related matrix
    !         gmt(i,k,1)*d(gt(i,k-1))/dt+gmt(i,k,2)*d(gt(i,k))/dt=gmt(i,k,3)
    !         gmt(i,1,1)=0.
    !     gmt(*,*,1)...dimensionless
    !     gmt(*,*,2)...dimensionless
    !     gmt(*,*,3)...deg/sec
    !..gmq    specific humidity related matrix
    !         gmq(i,k,1)*d(gq(i,k-1))/dt+gmq(i,k,2)*d(gq(i,k))/dt=gmq(i,k,3)
    !         gmq(i,1,1)=0.
    !     gmq(*,*,1)...dimensionless
    !     gmq(*,*,2)...dimensionless
    !     gmq(*,*,3)...kg/kg/sec
    !..gmu    wind related matrix
    !         gmu(i,k,1)*d(gu(i,k-1))/dt+gmu(i,k,2)*d(gu(i,k))/dt=gmu(i,k,3)
    !         gmu(i,k,1)*d(gv(i,k-1))/dt+gmu(i,k,2)*d(gv(i,k))/dt=gmu(i,k,4)
    !         gmu(i,1,1)=0.
    !     gmu(*,*,1)...dimensionless
    !     gmu(*,*,2)...dimensionless
    !     gmu(*,*,3)...m/sec**2
    !     gmu(*,*,4)...m/sec**2
    !..gl0    maximum mixing length l0 in blackerdar's formula
    !         this is retained as a first guess for next time step
    !
    INTEGER, INTENT(in   ) :: ncols
    INTEGER, INTENT(in   ) :: kmax
    INTEGER, INTENT(in   ) :: PBL
    REAL(KIND=r8),    INTENT(in   ) :: gu    (ncols,kmax)
    REAL(KIND=r8),    INTENT(in   ) :: gv    (ncols,kmax)
    REAL(KIND=r8),    INTENT(in   ) :: gt    (ncols,kmax)
    REAL(KIND=r8),    INTENT(in   ) :: gq    (ncols,kmax)
    REAL(KIND=r8),    INTENT(in   ) :: delsig(kmax)
    REAL(KIND=r8),    INTENT(in   ) :: delt
    REAL(KIND=r8),    INTENT(in   ) :: colrad(ncols)
    REAL(KIND=r8),    INTENT(inout) :: gmt   (ncols,kmax,3)
    REAL(KIND=r8),    INTENT(inout) :: gmq   (ncols,kmax,3)
    REAL(KIND=r8),    INTENT(inout) :: gmu   (ncols,kmax,4)
    REAL(KIND=r8),    INTENT(inout) :: gl0   (ncols)

    REAL(KIND=r8) :: a   (kmax)
    REAL(KIND=r8) :: b   (kmax)
    REAL(KIND=r8) :: Pbl_NRich(ncols,kmax)
    REAL(KIND=r8) :: Pbl_ATemp(ncols,kmax)
    REAL(KIND=r8) :: Pbl_ITemp(ncols,kmax)
    REAL(KIND=r8) :: Pbl_Shear(ncols,kmax)  !square of vertical wind shear
    REAL(KIND=r8) :: Pbl_Sqrtw(ncols,kmax)  !sqrt(w) or b/l
    REAL(KIND=r8) :: Pbl_MixLgh(ncols,kmax) !mixing length
    REAL(KIND=r8) :: Pbl_BRich(ncols,kmax)
    REAL(KIND=r8) :: Pbl_SmBar(ncols,kmax)
    REAL(KIND=r8) :: Pbl_ShBar(ncols,kmax)
    REAL(KIND=r8) :: Pbl_KmMixl(ncols,kmax)
    REAL(KIND=r8) :: Pbl_KhMixl(ncols,kmax)
    REAL(KIND=r8) :: Pbl_PotTep(ncols,kmax)
    REAL(KIND=r8) :: Pbl_Stabil(ncols,kmax)
    REAL(KIND=r8) :: Pbl_EddEner(ncols,kmax)
    REAL(KIND=r8) :: Pbl_CoefKh(ncols,kmax)
    REAL(KIND=r8) :: Pbl_CoefKm(ncols,kmax)
    REAL(KIND=r8) :: Pbl_HgtLyI(ncols,kmax)
    REAL(KIND=r8) :: gld (ncols)
    REAL(KIND=r8) :: gln (ncols)
    REAL(KIND=r8) :: csqiv(ncols)
    REAL(KIND=r8) :: Pbl_KM(ncols,kmax)
    REAL(KIND=r8) :: Pbl_KH(ncols,kmax)

    !
    !     eps   ; virtual temperature correction factor
    !     shrmin; squre of minimum wind shear, this is in order to avoid
    !     large richardson number   (1.0_r8/sec**2)
    !     facl  ; appears in l0 computation
    !     nitr  ; number of iteration computing l0
    !     gkm0  ; minimum value of eddy diffusion coefficient for momentm
    !     (m/sec**2)
    !     gkh0  ; minimum value of eddy diffusion coefficient for sensible heat
    !     (m/sec**2)
    !     gkm1  ; maximum value of eddy diffusion coefficient for momentm
    !     (m/sec**2)
    !     gkh1  ; maximum value of eddy diffusion coefficient for sensible heat
    !     (m/sec**2)
    !     vk0   ; von-karman constant
    !

    INTEGER :: k
    INTEGER :: i
    INTEGER :: itr
    INTEGER :: icnt(ncols)
    REAL(KIND=r8)    :: s1ms2g
    REAL(KIND=r8)    :: x
    REAL(KIND=r8)    :: y
    REAL(KIND=r8)    :: fac
    REAL(KIND=r8)    :: rfx
    INTEGER :: kpbl
    INTEGER :: kqpbl
    !
    !     ichk(kmax) is flag to vectorize.
    !
    INTEGER :: ichk(ncols,kmax)
    REAL(KIND=r8)    :: c
    REAL(KIND=r8)    :: twodt
    REAL(KIND=r8)    :: twodti
    !
    !     constants concerning mixing length scaling
    !     (mellor & yamada '82 rev.geophys.space sci. p851-874)
    !
    IF (delt == deltx) THEN
       WRITE(UNIT=nfprt, FMT="(' ERROR - delt == 0  in ympbl0' )")
       STOP "**(ymbpl0)"
    END IF
    IF(PBL == 1)THEN
       DO i=1,ncols,1
          csqiv(i)   = 1.0e0_r8/SIN(colrad(i))**2
       END DO

       twodt =2.0_r8*delt
       twodti=1.0_r8/twodt
       DO k = 1, kmax
          !                 --                  --
          !    1      1    | g       si(k+1)      |     con1(k)
          !  ------ =--- * |--- * ----------------| = ----------
          !    DZ     T    | R     sl(k) -sl(k+1) |       T
          !                 --                  --
          !                -- --
          !    DA      d  |     |
          !  ------ =---- | W'A'|
          !    DT      dZ |     |
          !                -- --
          !
          !                          ----
          !    DA      d         d  |    |
          !  ------ =---- * K * --- | A  |
          !    DT      dZ        dZ |    |
          !                          ----
          !
          !    DA         d      dA
          !  ------ =K * ---- * ----
          !    DT         dZ     dZ
          !
          !
          !
          !a0(k)  =gbyr*sigml(k+1)**2/(delsig(k  )*(sig(k)-sig(k+1)))
          !
          !                grav **2
          !              --------    * si(k+1)**2
          !                gasr**2
          !a0(k)  = ---------------------------------
          !          ((si(k)-si(k+1))) * (sl(k)-sl(k+1)))
          !
          !         --  -- 2                             -- -- 2
          !        |   g  |       si(k+1)**2            |  1  |
          !a0(k)  =| -----| * --------------------    = | --- |
          !        |   R  |     ((si(k)-si(k+1))  )     |  dZ |
          !         --  --                               -- --
          !                   --   --      -- -- 2            --                   -- 2
          !                  |       |    |  1  |            |      m       kg * K   |
          a(k)=twodt*a0(k)!  |  2*Dt |  * | --- |    ==> s * |   ------- * --------  |
          !                  |       |    |  dZ |            |     s**2       J      |
          !                   --   --      -- --              --                   --
          !J = F*DX = kg m/s**2 *m = kg * m**2/s**2
          !                   --   --      -- -- 2            --                       -- 2
          !                  |       |    |  1  |            |    m         kg * K *s**2 |    K**2 * s
          !a(k)=twodt*a0(k)! |  2*Dt |  * | --- |    ==> s * | ------- * --------------- | = -----------
          !                  |       |    |  dZ |            |   s**2     kg * m**2      |    m**2
          !                   --   --      -- --              --                       --
          !                   --   --      -- -- 2
          !                  |       |    |  1  |         K**2 * s
          !a(k)=twodt*a0(k)! |  2*Dt |  * | --- |    ==> -----------
          !                  |       |    |  dZ |           m**2
          !                   --   --      -- --

          !
          !                   gbyr*sigml(k+1)**2
          !    b0(k) = -----------------------------------------------
          !               (((si(k+1)-si(k+1+1))  ) *(sig(k)-sig(k+1)))

          b(k)=twodt*b0(k)! s * K**2/m**2
       END DO
       c=twodt*c0
       !
       !     Pbl_PotTep(3)   virtual potential temperature
       !     Pbl_ATemp (7)   temperature at the interface of two adjacent layers
       !
       !             k=2  ****gu,gv,gt,gq,gyu,gyv,gtd,gqd,sl*** } delsig(2)
       !             k=3/2----si,ric,rf,km,kh,b,l -----------
       !             k=1  ****gu,gv,gt,gq,gyu,gyv,gtd,gqd,sl*** } delsig(1)
       !             k=1/2----si ----------------------------
       !
       !                      sl(k+1)-si(k+1)
       !       t0    (   k)=-------------------
       !                      sl(k+1)-sl(k  )
       !
       !                      si(k+1)-sl(k  )
       !       t1    (   k)=-------------------
       !                      sl(k+1)-sl(k  )
       !
       !
       !                      sl(k+1)-si(k+1)              si(k+1)-sl(k  )
       !   Pbl_ATemp(i,k)  =-------------------*gt(i,k) + ------------------*gt(i,k+1)
       !                      sl(k+1)-sl(k  )              sl(k+1)-sl(k  )
       !
       !
       !
       !
       DO k = 1, kmax-1
          DO i = 1, ncols
             Pbl_ATemp(i,k)  = t0(k)*gt(i,k) + t1(k)*gt(i,k+1)
          END DO
       END DO
       !                      si(k+1)-sl(k  )
       !       t1    (   k)=-------------------
       !                      sl(k+1)-sl(k  )
       !
       !                          1
       !      sigkiv(k   )=--------------------
       !                      (sl(k)**akappa)
       !
       !                       --                       --
       !                      | grav        si(k+1)       |
       !   con2  (   k)=grav* |------- * ---------------- |
       !                      | gasr      sl(k)-sl(k+1))  |
       !                       --                       --
       !
       !                --                       --  2
       !               |   grav        si(k+1)     |
       !   con1  (k) = |------- * ---------------- |
       !               |  gasr      sl(k)-sl(k+1)) |
       !                --                       --
       !
       ! sl.........sigma value at midpoint of                  gasr/cp
       !                                         each layer : (k=287/1005)=R/cp
       !
       !                                                                     1
       !                                             +-                   + ---
       !                                             !     k+1         k+1!  k
       !                                             !si(l)   - si(l+1)   !
       !                                     sl(l) = !--------------------!
       !                                             !(k+1) (si(l)-si(l+1)!
       !             --   --  -(R/Cp)                +-                  -+
       !            |  P    |
       !Thetav = Tv |-------|
       !            |  P0   |
       !             --   --
       !
       !             --   --  -(R/Cp)        --   --  -(R/Cp)
       !            |  P    |               |       |
       !sigkiv(k) = |-------|            == |sl(k)  |
       !            |  P0   |               |       |
       !             --   --                 --   --
       !  --   --      --   --
       ! |  P    |    |       |
       ! |-------| =  |sl(k)  |
       ! |  P0   |    |       |
       !  --   --      --   --
       !  --          --      --           --
       ! |  P(k)-P(k+1) |    |               |
       ! |--------------| =  |sl(k)-sl(k+1)  |
       ! |      P0      |    |               |
       !  --          --      --           --




       DO k = 1, kmax
          DO i = 1, ncols
             Pbl_PotTep(i,k)=sigkiv(k)*gt(i,k)*(1.0_r8+eps*gq(i,k))
          END DO
       END DO
       !
       !     Pbl_Stabil(2)   stability
       !     Pbl_Shear (6)   square of vertical wind shear
       !
       gln =1.0e-5_r8
       DO k = 1, kmax-1
          DO i = 1, ncols
             !
             !
             !                 g         D (Theta)
             !Pbl_Stabil(2) =------- * -------------
             !                Theta      D (Z)
             !
             !
             ! P =rho*R*T and P = rho*g*Z
             !
             !                           P
             ! DP = rho*g*DZ and rho = ----
             !                          R*T
             !        P
             ! DP = ----*g*DZ
             !       R*T
             !
             !        R*T
             ! DZ = ------*DP
             !        g*P
             !
             !    1       g*P       1
             !  ------ = ------ * ------
             !    DZ      R*T       DP
             !
             !    T       g         P
             !  ------ = ------ * ------
             !    DZ      R         DP
             !
             !  --   --      --   --
             ! |  P    |    |       |
             ! |-------| =  |sl(k)  |
             ! |  P0   |    |       |
             !  --   --      --   --
             !
             !    T       g            si(k+1)
             !  ------ = ------ * ----------------- =con1(k)
             !    DZ      R         sl(k) -sl(k+1)
             !
             !                 --                  --
             !    1      1    | g       si(k+1)      |     con1(k)
             !  ------ =--- * |--- * ----------------| = ----------
             !    DZ     T    | R     sl(k) -sl(k+1) |       T
             !                 --                  --
             !                                  --                  --
             !                    g       1    | g       si(k+1)      |
             ! Pbl_Stabil(2) = ------- * --- * |--- * ----------------|* D(Theta)
             !                  Theta     T    | R     sl(k) -sl(k+1) |
             !                                  --                  --
             !
             !                   con2(k)*(Pbl_PotTep(i,k+1)-Pbl_PotTep(i,k))
             !Pbl_Stabil(i,k)=-----------------------------------------------------------------
             !                  ((t0(k)*Pbl_PotTep(i,k)+t1(k)*Pbl_PotTep(i,k+1))*Pbl_ATemp(i,k))

             Pbl_Stabil(i,k)=con2(k)*(Pbl_PotTep(i,k+1)-Pbl_PotTep(i,k)) &
                  /((t0(k)*Pbl_PotTep(i,k)+t1(k)*Pbl_PotTep(i,k+1))*Pbl_ATemp(i,k))
             Pbl_ITemp(i,k)=1.0_r8/(Pbl_ATemp(i,k)*Pbl_ATemp(i,k))
             !
             !                  --  -- 2    --  -- 2
             !                 |  dU  |    |  dV  |
             !Pbl_Shear(i,k) = | -----|  + | -----|
             !                 |  DZ  |    |  DZ  |
             !                  --  --      --  --
             !
             !                  --  -- 2    --     -- 2
             !                 |   1  |    |         |
             !Pbl_Shear(i,k) = | -----|  * | DU + DV |
             !                 |  DZ  |    |         |
             !                  --  --      --     --
             !
             !                         --                  -- 2    --     -- 2
             !                 1      | g       si(k+1)      |    |         |          1.0e0_r8
             !Pbl_Shear(i,k) =----- * |--- * ----------------|  * | Du + Dv |   * ---------------------
             !                 T*T    | R     sl(k) -sl(k+1) |    |         |       SIN(colrad(i))**2
             !                         --                  --      --     --
             !                  1.0e0_r8
             ! csqiv (i) = ---------------------
             !               SIN(colrad(i))**2
             !
             Pbl_Shear(i,k)=(con1(k)*csqiv(i))*Pbl_ITemp(i,k)*((gu(i,k)-gu(i,k+1))**2+(gv(i,k)-gv(i,k+1))**2)
             Pbl_Shear(i,k)=MAX(gln(i),Pbl_Shear(i,k))
          END DO
       END DO
       !
       !     Pbl_BRich(4)        richardson number
       !     Pbl_NRich(5)   flux richardson number
       !     Pbl_NRich(8)   flux richardson number
       !
       DO k = 1,(kmax-1)
          DO i = 1, ncols
             !                g         D (Theta)
             !              ------- * -------------
             !               Theta      D (Z)
             ! Pbl_BRich = -----------------------------
             !                 --  -- 2    --  -- 2
             !                |  dU  |    |  dV  |
             !                | -----|  + | -----|
             !                |  DZ  |    |  DZ  |
             !                 --  --      --  --
             !
             Pbl_BRich(i,k)=Pbl_Stabil(i,k)/Pbl_Shear(i,k)
             !r1 = 0.5_r8*gama/alfa
             Pbl_NRich(i,k)= r1*(Pbl_BRich(i,k)+r2 &
                  -SQRT(Pbl_BRich(i,k)*(Pbl_BRich(i,k)-r3)+r4))
             Pbl_NRich(i,k)=MIN(rfc,Pbl_NRich(i,k))
             Pbl_NRich(i,k)=Pbl_NRich(i,k)
             !
             !    Pbl_SmBar and Pbl_ShBar are momentum flux and heat flux
             !    stability parameters, respectively
             !
             !     Pbl_ShBar(3)   shbar
             !     Pbl_SmBar(4)   smbar
             !
             !     eliminate negative value for s1-s2*gwrk(i,1,5):
             !     gwrk(i,1,5) is s1/s2 under some circumstances
             !     which makes this expression zero.  machine roundoff
             !     can produce an unphysical negative value in this case.
             !     it is used as sqrt argument in later loop.
             !     s1  =3.0_r8*a2* gam1
             !     s2  =3.0_r8*a2*(gam1+gam2)
             !
             ! s1-s2 = 3.0*a2* gam1 - 3.0*a2*(gam1+gam2)
             ! s1-s2 = 3.0*a2* (gam1 - (gam1+gam2))
             !
             s1ms2g=s1-s2*Pbl_NRich(i,k)
             IF (ABS(s1ms2g) < 1.0e-10_r8) s1ms2g=0.0_r8
             !
             !                     s1ms2g
             !Pbl_ShBar(i,k)=---------------------------
             !                 (1.0_r8-Pbl_NRich(i,k))
             !
             ! a1    =   0.92_r8
             ! a2    =   0.74_r8
             ! b1    =  16.6_r8
             ! b2    =  10.1_r8
             !
             !         1.0               a1
             !gam1 = -------  - 2.0  * ------
             !         3.0               b1
             !
             !       b2          a1
             !gam2=(----) + (6*------)
             !       b1          b1
             !
             !gam2=(b2  + 6.0*a1)
             !     --------------
             !          b1
             !                 --                   --
             !                | 1.0               a1  |
             !s1 = 3.0 * a2 * |------  - 2.0  * ------|
             !                | 3.0               b1  |
             !                 --                   --
             !s2  =3.0_r8*a2*(gam1+gam2)
             !
             !                   s1-s2*Pbl_NRich(i,k)
             !Pbl_ShBar(i,k)=---------------------------
             !                 (1.0_r8-Pbl_NRich(i,k))
             !
             !                        ((gam1 - (gam1+gam2)))*Pbl_NRich(i,k)
             !Pbl_ShBar(i,k)=3.0*a2* ---------------------------------------- =Sm
             !                           (1.0_r8-Pbl_NRich(i,k))

             Pbl_ShBar(i,k)=s1ms2g/(1.0_r8-Pbl_NRich(i,k))
             !
             !     gwrk(i,1,3)=(s1-s2*gwrk(i,1,5))/(1.0_r8-gwrk(i,1,5))
             !     end of  negative sqrt argument trap
             ! c1    =   0.08_r8
             ! alfa=b1*(gam1-c1)+3.0_r8*(a2+2.0_r8*a1)
             ! beta=b1*(gam1-c1)
             !        --                              --
             !       | a2                               |
             ! gama=-|---- *(b1*(gam1+gam2)-3.0_r8*a1)  |
             !       | a1                               |
             !        --                              --
             !       --          --
             !      | a2           |
             ! dela=|---- b1* gam1 |
             !      | a1           |
             !       --          --
             !                                     ((b1*(gam1-c1))-(b1*(gam1-c1)+3.0*(a2+2.0*a1))*Pbl_NRich(i,k))
             ! Pbl_SmBar(i,k)=Pbl_ShBar(i,k) * ------------------------------------------------------------------
             !                                     --          --     --                           --
             !                                    | a2           |   | a2                            |
             !                                    |---- b1* gam1 | - |---- *(b1*(gam1+gam2)-3.0*a1)  |*Pbl_NRich(i,k))
             !                                    | a1           |   | a1                            |
             !                                     --          --     --                           --
             !
             !                                     ((b1*(gam1-c1)) - (b1*(gam1-c1) + 3.0*a2 + 6.0*a1))*Pbl_NRich(i,k))
             ! Pbl_SmBar(i,k)=Pbl_ShBar(i,k) * --------------------------------------------------------------
             !                                     --  --     --                             --
             !                                    | a2   |   |                                 |
             !                                    |----  | * |b1* gam1 -(b1*(gam1+gam2)-3.0*a1)|*Pbl_NRich(i,k))
             !                                    | a1   |   |                                 |
             !                                     --  --     --                              --

             !
             Pbl_SmBar(i,k)=Pbl_ShBar(i,k)*(beta-alfa*Pbl_NRich(i,k))/ &
                  (dela-gama*Pbl_NRich(i,k))
             !
             !
             !     Pbl_Sqrtw(5)   sqrt(w) or b/l
             !     Pbl_KmMixl(4)   km/l**2
             !     Pbl_KhMixl(3)   kh/l**2
             !
             !     The ratio of SH to SM is equal to the ratio of the turbulent
             !     flux Richardson number to the bulk (large scale) Richardson
             !     number.
             !
             !     u^2 =  (1-2*gam1)q^2
             !
             !     SQRT(B1*SM*(1 - Ri)*Shear)
             !             GH    SM
             !     Ri = - ---- =-----Rf
             !             GM    SH
             !             GH
             !     GM = - ----
             !             Ri
             !                --                  --
             !               | --  -- 2    --  -- 2 |
             !          l^2  ||  dU  |    |  dV  |  |
             !     GM =-----*|| -----|  + | -----|  |
             !          q^2  ||  DZ  |    |  DZ  |  |
             !               | --  --               |
             !                --                  --
             !
             !                          --      -- 2
             !             l^2         |  dTHETA  |
             !     GH = - -----*beta*g*| ---------|
             !             q^2         |  DZ      |
             !                          --      --

             !
             !          --                       --  1/2
             !         |      --  -- 2    --  -- 2 |
             !     q   | 1   |  dU  |    |  dV  |  |
             !    ----=|----*| -----|  + | -----|  |
             !     l   | GM  |  DZ  |    |  DZ  |  |
             !         |      --  --               |
             !          --                       --
             !
             !  1
             ! ---- = B1*Sm*(1 - Rf)
             !  GM
             !
             Pbl_Sqrtw (i,k)=SQRT(b1*Pbl_SmBar(i,k)*(1.0_r8-Pbl_NRich(i,k))*Pbl_Shear(i,k))
             !
             ! Km = l*q*Sm
             !
             ! Km     q
             !---- = ---*Sm
             ! l^2    l
             !
             ! Kh = l*q*Sh
             !
             !
             ! Kh     q
             !---- = ---*Sh
             ! l^2    l
             !
             Pbl_KmMixl(i,k)=Pbl_Sqrtw(i,k)*Pbl_SmBar(i,k)
             Pbl_KhMixl(i,k)=Pbl_Sqrtw(i,k)*Pbl_ShBar(i,k)
          END DO
       END DO
       !
       !     Pbl_HgtLyI(1)   height at the layer interface
       !
       !        R*T
       ! DZ = ------ * DP
       !        g*P
       !
       !        R*T      DP
       ! DZ = ------ * -----
       !         g       P
       !
       !         R      DP
       ! DZ = ------ * ----- * T
       !         g       P
       !
       !
       ! DZ = con0(k)  * T
       !
       !                                              kg*m*m
       !                                             --------
       !              R      DP       (j/kg/k)        kg*K*s*s
       ! con0(k) = ------ * ----- =  --------   =   ------------    = m/K
       !              g       P        m/s*s             m
       !                                               -----
       !                                                s*s
       !            gasr        si(k) - si(k+1)
       ! con0(k)= -------- * ------------------------
       !            grav             sl(k)
       !
       ! Pbl_HgtLyI = con0(k)  * T
       !
       k=1
       DO i = 1, ncols
          Pbl_HgtLyI(i,k)=con0(k)*gt(i,k)
       END DO

       DO k = 2, kmax
          DO i = 1, ncols
             Pbl_HgtLyI(i,k)=Pbl_HgtLyI(i,k-1)+con0(k)*gt(i,k)
          END DO
       END DO
       DO itr = 1, nitr
          !
          !     Pbl_EddEner(2)   mixing length
          !     Pbl_EddEner(2)   b     :b**2 is eddy enegy
          !
          !..gl0    maximum mixing length l0 in blackerdar's formula
          !         this is retained as a first guess for next time step
          !                                      k0*z
          !                                l = --------
          !                                    (1 + k0*z/l0)

          gln = 0.0_r8
          gld = 0.0_r8
          Pbl_EddEner(:,1) = 0.0_r8
          DO k = 1, kmax-1
             DO i = 1, ncols
                !
                !                 vk0*gl0(i)*Z(i,k)
                ! Pbl_EddEner = ------------------------------
                !                (gl0(i) + vk0*Z(i,k))
                !
                Pbl_EddEner(i,k+1)=vk0*gl0(i)*Pbl_HgtLyI(i,k) / (gl0(i)+vk0*Pbl_HgtLyI(i,k))
                !
                !                 vk0*gl0(i)*Z(i,k)           q          q
                ! Pbl_EddEner = ------------------------ * --------- = ---------
                !                (gl0(i) + vk0*Z(i,k))        l^2        l
                !
                Pbl_EddEner(i,k+1)=Pbl_EddEner(i,k+1)*Pbl_Sqrtw(i,k)
             END DO
          END DO
          k=1
          DO i = 1, ncols
             Pbl_EddEner(i,k)= 1.0e-3_r8
          END DO
          k=1
          DO i = 1, ncols
             x=0.5_r8*delsig(k)*(Pbl_EddEner(i,k)+Pbl_EddEner(i,k+1))
             y=x*0.5_r8*Pbl_HgtLyI(i,k)
             gld(i)=gld(i)+x
             gln(i)=gln(i)+y
          END DO
          k=kmax
          DO i = 1, ncols
             x=0.5_r8*delsig(k)*Pbl_EddEner(i,k)
             y=x*0.5_r8*(Pbl_HgtLyI(i,k)+Pbl_HgtLyI(i,k-1))
             gln(i)=gln(i)+y
             gld(i)=gld(i)+x
          END DO
          IF (kmax > 2) THEN
             DO k = 2, kmax-1
                DO i = 1, ncols
                   x=0.5_r8*delsig(k)*(Pbl_EddEner(i,k)+Pbl_EddEner(i,k+1))
                   y=x*0.5_r8*(Pbl_HgtLyI(i,k)+Pbl_HgtLyI(i,k-1))
                   gln(i)=gln(i)+y
                   gld(i)=gld(i)+x
                END DO
             END DO
          END IF
          DO i = 1, ncols
             !                0.5 * del(k) * (q(i,k)+q(i,k+1)) * 0.5*(Z(i,k)+Z(i,k-1))
             !gl0(i)=facl * -----------------------------------------------------------
             !                        0.5 * del(k) * (q(i,k)+q(i,k+1))
             gl0(i)=facl*gln(i)/gld(i)
          END DO
          !
          !     iteration that determines mixing length
          !
       END DO
       !
       !     Pbl_MixLgh(5)   mixing length
       !
       DO k = 1, kmax-1
          DO i=1,ncols
             !        vk0*gl0(i)*Z(i,k)         m^2
             ! l  = -------------------------------- = ------
             !        gl0(i) + vk0*Z(i,k)       m
             Pbl_MixLgh(i,k)=vk0*gl0(i)*Pbl_HgtLyI(i,k)/(gl0(i)+vk0*Pbl_HgtLyI(i,k))
          END DO
       END DO
       !
       !     Pbl_CoefKm(1)   km = l*q*Sm
       !     Pbl_CoefKh(2)   kh = l*q*Sh
       !
       !     where KM and KH are the diffusion coefficients for momentum
       !     and heat, respectively, l is the master turbulence length scale,
       !     q2 is the turbulent kinetic energy (so q is the magnitude of
       !     the turbulent wind velocity), and SM and SH are momentum
       !     flux and heat flux stability parameters, respectively
       !
       IF (kmean == 0) THEN
          DO k = 1, kmax-1
             DO i = 1, ncols
                !
                !             Km
                !Km = l^2 * -----
                !            l^2
                !
                Pbl_CoefKm(i,k)=MIN(gkm1,MAX(gkm0,Pbl_MixLgh(i,k)**2*Pbl_KmMixl(i,k)))
                !
                !             Kh
                !Kh = l^2 * -----
                !            l^2
                !
                Pbl_CoefKh(i,k)=MIN(gkh1,MAX(gkh0,Pbl_MixLgh(i,k)**2*Pbl_KhMixl(i,k)))
             END DO
          END DO
       ELSE
          DO k = 1, kmax-1
             DO i = 1, ncols
                !
                !             Km
                !Km = l^2 * -----
                !            l^2
                !
                Pbl_KM(i,k)=Pbl_MixLgh(i,k)**2*Pbl_KmMixl(i,k)
                !
                !             Kh
                !Kh = l^2 * -----
                !            l^2
                !
                Pbl_KH(i,k)=Pbl_MixLgh(i,k)**2*Pbl_KhMixl(i,k)
             END DO
          END DO
          fac=0.25_r8
          IF (kmax >= 4) THEN
             DO k = 2, kmax-2
                DO i = 1, ncols
                   !
                   !             k=2  ****Km(k),sl*** } -----------
                   !             k=3/2----si,ric,rf,km,kh,b,l -----------
                   !             k=1  ****Km(k),sl*** } -----------
                   !             k=1/2----si ----------------------------
                   !
                   !       Km(k-1) + 2*Km(k) + Km(k+1)
                   ! Km = -------------------------------
                   !                  4
                   !
                   Pbl_CoefKm(i,k)=fac*(Pbl_KM(i,k-1)+2.0_r8*Pbl_KM(i,k)+Pbl_KM(i,k+1))
                   !
                   !       Kh(k-1) + 2*Kh(k) + Kh(k+1)
                   ! Kh = -------------------------------
                   !                  4
                   !
                   Pbl_CoefKh(i,k)=fac*(Pbl_KH(i,k-1)+2.0_r8*Pbl_KH(i,k)+Pbl_KH(i,k+1))
                END DO
             END DO
          END IF
          DO i = 1, ncols
             !
             !       Km(1) + Km(2)
             ! Km = ---------------
             !            2
             !
             !
             !       Kh(1) + Kh(2)
             ! Kh = ---------------
             !            2
             !
             Pbl_CoefKm(i,     1)=0.5_r8*(Pbl_KM(i,     1)+Pbl_KM(i,     2))
             Pbl_CoefKh(i,     1)=0.5_r8*(Pbl_KH(i,     1)+Pbl_KH(i,     2))
             Pbl_CoefKm(i,kmax-1)=0.5_r8*(Pbl_KM(i,kmax-1)+Pbl_KM(i,kmax-2))
             Pbl_CoefKh(i,kmax-1)=0.5_r8*(Pbl_KH(i,kmax-1)+Pbl_KH(i,kmax-2))
          END DO
          DO k = 1, kmax-1
             DO i = 1, ncols
                Pbl_CoefKm(i,k)=MIN(gkm1,MAX(gkm0,Pbl_CoefKm(i,k))) !(m/sec**2)
                Pbl_CoefKh(i,k)=MIN(gkh1,MAX(gkh0,Pbl_CoefKh(i,k))) !(m/sec**2)
             END DO
          END DO
          rfx=rfc-0.001_r8
          IF (kmax >= 3) THEN

             icnt=0
             DO k = kmax-1, 2, -1
                DO i = 1, ncols
                   IF (Pbl_NRich(i,k) > rfx .AND. Pbl_NRich(i,k-1) <= rfx) THEN
                      icnt(i)=icnt(i)+1
                      ichk(i,icnt(i))=k
                   END IF
                END DO
             END DO

             DO i = 1, ncols
                IF (icnt(i) /= 0) THEN
                   Pbl_CoefKm(i,ichk(i,1))=gkm0  !(m/sec**2)
                   Pbl_CoefKh(i,ichk(i,1))=gkh0  !(m/sec**2)
                END IF
             END DO
          END IF
       END IF
       !                            --           --
       !      d -(U'W')       d    |        d U    |
       !   ------------- = --------|KM *  -------- |
       !      dt              dt   |        d z    |
       !                            --           --
       !     momentum diffusion
       !
       CALL VDIFV(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKm,a,b,gu,gv,gmu)
       !
       !                            --           --
       !      d -(Q'W')       d    |        d Q    |
       !   ------------- = --------|KH *  -------- |
       !      dt              dt   |        d z    |
       !                            --           --
       !
       !     water vapour diffusion
       !
       CALL VDIFH(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKh,a,b,gq,gmq)
       !
       !                            --           --
       !      d -(T'W')       d    |        d T    |
       !   ------------- = --------|KH *  -------- |
       !      dt              dt   |        d z    |
       !                            --           --
       !
       !     sensible heat diffusion
       !
       CALL VDIFT(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKh,a,b,gt,gmt)

    ELSE
       !
       !
       ! ympbl1 :does second half part of gauss elimination
       !         and obtains time tendency for t,q,u,v
       !
       !-----------------------------------------------------------------------
       !           input values
       !-----------------------------------------------------------------------
       !..ncols   number of grid points on a gaussian latitude circle
       !..kpbl   number of layers pbl process is included( for u v,t )
       !..kqpbl  number of layers pbl process is included( for q     )
       !..gmt    temperature related matrix
       !         for k.ge.2
       !         gmt(i,k,1)*d(gt(i,k-1))/dt+gmt(i,k,2)*d(gt(i,k))/dt=gmt(i,k,3)
       !         for k.eq.1,the solution is already obtained in sib.
       !         gmt(i,1,3)=d(gt(i,1))/dt
       !..gmq    specific humidity related matrix
       !         for k.ge.2
       !         gmq(i,k,1)*d(gq(i,k-1))/dt+gmq(i,k,2)*d(gq(i,k))/dt=gmq(i,k,3)
       !         for k.eq.1,the solution is already obtained in sib.
       !         gmq(i,1,3)=d(gq(i,1))/dt
       !..gmu    wind related matrix
       !         for k.ge.2
       !         gmu(i,k,1)*d(gu(i,k-1))/dt+gmu(i,k,2)*d(gu(i,k))/dt=gmu(i,k,3)
       !         gmu(i,k,1)*d(gv(i,k-1))/dt+gmu(i,k,2)*d(gv(i,k))/dt=gmu(i,k,3)
       !         for k.eq.1, the solution is already obtained in sib.
       !         gmu(i,1,3)=d(gu(i,1))/dt
       !         gmu(i,1,4)=d(gv(i,1))/dt
       !-----------------------------------------------------------------------
       !           output values
       !-----------------------------------------------------------------------
       !         gmt(i,k,3)=d(gt(i,k))/dt
       !         gmq(i,k,3)=d(gq(i,k))/dt
       !         gmu(i,k,3)=d(gu(i,k))/dt
       !         gmu(i,k,4)=d(gv(i,k))/dt
       !         where  da/dt=(a(t+dt)-a(t-dt))/(2*dt)
       !         where  da/dt=(a(t+dt)-a(t-dt))/(2*dt)

       !

       kpbl =kmax
       kqpbl=kmax
       CALL gauss1(gmt,ncols,kpbl ,3)
       CALL gauss1(gmq,ncols,kqpbl,3)
       CALL gauss1(gmu,ncols,kpbl ,4)
    END IF
  END SUBROUTINE ympbl0
  !---------------------------------------------------------------------
  !XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  !---------------------------------------------------------------------
  SUBROUTINE VDIFV(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKm,a,b,gu,gv,gmu)
    !     ***************************************************************
    !     *                                                             *
    !     *        VERTICAL DIFFUSION OF VELOCITY COMPONENTS            *
    !     *                                                             *
    !     ***************************************************************
    !---------------------------------------------------------------------
    INTEGER      ,    INTENT(in   ) :: nCols
    INTEGER      ,    INTENT(in   ) :: kMax
    REAL(KIND=r8),    INTENT(in   ) :: twodti
    REAL(KIND=r8),    INTENT(in   ) :: a         (kmax)      !s * K**2/m**2
    REAL(KIND=r8),    INTENT(in   ) :: b         (kmax)      !s * K**2/m**2
    REAL(KIND=r8),    INTENT(in   ) :: Pbl_ITemp (nCols,kMax)!1/K**2
    REAL(KIND=r8),    INTENT(inout) :: Pbl_CoefKm(nCols,kMax)!(m/sec**2)
    REAL(KIND=r8),    INTENT(in   ) :: gu        (nCols,kMax)
    REAL(KIND=r8),    INTENT(in   ) :: gv        (nCols,kMax)
    REAL(KIND=r8),    INTENT(inout) :: gmu       (nCols,kMax,4)

    REAL(KIND=r8) :: Pbl_DifVzn(nCols,kMax)
    REAL(KIND=r8) :: Pbl_DifVmd(nCols,kMax)
    REAL(KIND=r8) :: Pbl_KHbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ2(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ1(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KHbyDZ2(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_TendU(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_TendV(nCols,kMax) !1/(sec * K)

    INTEGER       :: i
    INTEGER       :: k

    !
    !     momentum diffusion
    !
    DO k = 1, kMax-1
       DO i = 1, nCols
          Pbl_CoefKm(i,k  )=Pbl_CoefKm(i,k)*Pbl_ITemp(i,k)!(m/sec**2) * (1/K**2) = m/(sec**2 * K**2)
          !
          !                   --   --      -- -- 2
          !                  |       |    |  1  |         K**2 * s
          !a(k)=             |  2*Dt |  * | --- |     ==>-----------
          !                  |       |    |  dZ |           m**2
          !                   --   --      -- --
          !                                         K**2 * s         m              1
          Pbl_KHbyDZ(i,k  )=a(k  )*Pbl_CoefKm(i,k)!----------- * -------------  = --------
          !                                           m**2          s**2*K**2     m * s
          !
          !                                         K**2 * s        m**2             1
          Pbl_KMbyDZ(i,k+1)=b(k+1)*Pbl_CoefKm(i,k)!----------- * -------------  = --------
          !                                           m**2          s**2*K**2         s
          !
          !     gwrk(1)   difference of pseudo v wind ( km is destroyed )
          !     gwrk(5)   difference of pseudo u wind ( b  is destroyed )
          !
          Pbl_DifVzn(i,k)=gu(i,k)-gu(i,k+1)
          Pbl_DifVmd(i,k)=gv(i,k)-gv(i,k+1)
       END DO
    END DO
    DO i = 1, nCols
       Pbl_KMbyDZ2   (i,1)=0.0_r8
       Pbl_KMbyDZ1   (i,1)=1.0_r8 + Pbl_KHbyDZ(i,1)
       Pbl_KHbyDZ2   (i,1)=        -Pbl_KHbyDZ(i,1)
       !                          --             --
       ! DU       d(w'u')      d |          d U    |       m
       !------ = ------- =    ---| - Km *  ------  |  = --------
       ! Dt       dz           dz|          dz     |     s * s
       !                          --             --

       Pbl_TendU(i,1)=-twodti*Pbl_KHbyDZ(i,1)*Pbl_DifVzn(i,1)!(1/m)*(m/s)
       !
       !                     1          1           m           m
       !Pbl_TendU(i,1) = - ------ * -------- *  -------- =   --------
       !                     s          s           s         s * s
       !
       Pbl_TendV(i,1)=-twodti*Pbl_KHbyDZ(i,1)*Pbl_DifVmd(i,1)!m/s**2

       Pbl_KMbyDZ2   (i,kMax)=       - Pbl_KMbyDZ(i,kMax)
       Pbl_KMbyDZ1   (i,kMax)=1.0_r8 + Pbl_KMbyDZ(i,kMax)
       Pbl_KHbyDZ2   (i,kMax)=0.0_r8
       Pbl_TendU(i,kMax)=twodti*Pbl_KMbyDZ(i,kMax)*Pbl_DifVzn(i,kMax-1)
       Pbl_TendV(i,kMax)=twodti*Pbl_KMbyDZ(i,kMax)*Pbl_DifVmd(i,kMax-1)
    END DO
    DO k = 2, kMax-1
       DO i = 1, nCols
          Pbl_KMbyDZ2   (i,k)=      -Pbl_KMbyDZ(i,k)                   !1/(sec * K)
          Pbl_KMbyDZ1   (i,k)=1.0_r8+Pbl_KHbyDZ(i,k)+Pbl_KMbyDZ(i,k)   !1/(sec * K)
          Pbl_KHbyDZ2   (i,k)=      -Pbl_KHbyDZ(i,k)                   !1/(sec * K)
          Pbl_TendU(i,k)=(Pbl_KMbyDZ(i,k)*Pbl_DifVzn(i,k-1)  - &
               Pbl_KHbyDZ(i,k)*Pbl_DifVzn(i,k  )) * twodti
          Pbl_TendV(i,k)=(Pbl_KMbyDZ(i,k)*Pbl_DifVmd(i,k-1)  - &
               Pbl_KHbyDZ(i,k)*Pbl_DifVmd(i,k  )) * twodti
       END DO
    END DO
    DO k = kmax-1, 1, -1
       DO i = 1, ncols
          Pbl_KHbyDZ2   (i,k)=Pbl_KHbyDZ2 (i,k)/Pbl_KMbyDZ1(i,k+1)
          !
          !                                - Pbl_KMbyDZ_1(i,k)
          !Pbl_KHbyDZ2   (i,k)=-------------------------------------------------
          !                     1.0 + Pbl_KMbyDZ_1(i,k+1) + Pbl_KMbyDZ_2(i,k+1)
          !
          Pbl_KMbyDZ1   (i,k)=Pbl_KMbyDZ1 (i,k)-Pbl_KHbyDZ2(i,k)*Pbl_KMbyDZ2(i,k+1)
          !                                                                         Pbl_KMbyDZ_1(i,k)*Pbl_KMbyDZ_2(i,k+1)
          !Pbl_KMbyDZ1   (i,k)=1.0_r8 + Pbl_KMbyDZ_1(i,k) + Pbl_KMbyDZ_2(i,k) - -------------------------------------------------
          !                                                                      1.0 + Pbl_KMbyDZ_1(i,k+1) + Pbl_KMbyDZ_2(i,k+1)
          Pbl_TendU(i,k)=Pbl_TendU(i,k)-Pbl_KHbyDZ2(i,k)*Pbl_TendU(i,k+1)
          Pbl_TendV(i,k)=Pbl_TendV(i,k)-Pbl_KHbyDZ2(i,k)*Pbl_TendV(i,k+1)
       END DO
    END DO
    DO k = 1, kmax
       DO i = 1, ncols
          gmu(i,k,1)=Pbl_KMbyDZ2 (i,k)
          gmu(i,k,2)=Pbl_KMbyDZ1 (i,k)
          gmu(i,k,3)=Pbl_TendU   (i,k)
          gmu(i,k,4)=Pbl_TendV   (i,k)
       END DO
    END DO
  END SUBROUTINE VDIFV
  !---------------------------------------------------------------------
  !XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  !---------------------------------------------------------------------
  SUBROUTINE VDIFH(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKh,a,b,gq,gmq)
    !     ***************************************************************
    !     *                                                             *
    !     *         VERTICAL DIFFUSION OF MASS VARIABLES                *
    !     *                                                             *
    !     ***************************************************************
    INTEGER      ,    INTENT(in   ) :: nCols
    INTEGER      ,    INTENT(in   ) :: kMax
    REAL(KIND=r8),    INTENT(in   ) :: twodti
    REAL(KIND=r8),    INTENT(in   ) :: a         (kmax)
    REAL(KIND=r8),    INTENT(in   ) :: b         (kmax)
    REAL(KIND=r8),    INTENT(in   ) :: Pbl_ITemp (nCols,kMax)
    REAL(KIND=r8),    INTENT(in   ) :: Pbl_CoefKh(nCols,kMax)
    REAL(KIND=r8),    INTENT(in   ) :: gq        (nCols,kMax)
    REAL(KIND=r8),    INTENT(inout) :: gmq       (nCols,kMax,3)

    REAL(KIND=r8) :: Pbl_DifQms(nCols,kMax)
    REAL(KIND=r8) :: Pbl_CoefKh2(nCols,kMax)

    REAL(KIND=r8) :: Pbl_KHbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ2(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ1(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KHbyDZ2(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_TendQ(nCols,kMax) !1/(sec * K)

    INTEGER       :: i
    INTEGER       :: k

    DO k = 1, kMax-1
       DO i = 1, nCols
          Pbl_CoefKh2(i,k  )=Pbl_CoefKh(i,k)*Pbl_ITemp(i,k)
          Pbl_KHbyDZ(i,k  )=a(k  )*Pbl_CoefKh2(i,k)
          Pbl_KMbyDZ(i,k+1)=b(k+1)*Pbl_CoefKh2(i,k)
          !
          !     Pbl_DifQms(1)   difference of specific humidity
          !
          Pbl_DifQms(i,k)=gq(i,k)-gq(i,k+1)
       END DO
    END DO
    DO i = 1, ncols
       Pbl_KMbyDZ2(i,1)=0.0_r8
       Pbl_KMbyDZ1(i,1)=1.0_r8  + Pbl_KHbyDZ(i,1)
       Pbl_KHbyDZ2(i,1)=        - Pbl_KHbyDZ(i,1)
       Pbl_TendQ  (i,1)=-twodti * Pbl_KHbyDZ(i,1) * Pbl_DifQms(i,1)

       Pbl_KMbyDZ2(i,kMax)=        - Pbl_KMbyDZ(i,kMax)
       Pbl_KMbyDZ1(i,kMax)=1.0_r8  + Pbl_KMbyDZ(i,kMax)
       Pbl_KHbyDZ2(i,kMax)=0.0_r8
       Pbl_TendQ  (i,kMax)= twodti * Pbl_KMbyDZ(i,kMax) * Pbl_DifQms(i,kMax-1)
    END DO
    DO k = 2, kmax-1
       DO i = 1, ncols
          Pbl_KMbyDZ2(i,k)=       - Pbl_KMbyDZ(i,k)
          Pbl_KMbyDZ1(i,k)=1.0_r8 + Pbl_KHbyDZ(i,k)+Pbl_KMbyDZ(i,k)
          Pbl_KHbyDZ2(i,k)=       - Pbl_KHbyDZ(i,k)
          Pbl_TendQ(i,k)=(Pbl_KMbyDZ(i,k) * Pbl_DifQms(i,k-1)- &
               Pbl_KHbyDZ(i,k) * Pbl_DifQms(i,k  ))*twodti
       END DO
    END DO
    DO k = kmax-1, 1, -1
       DO i = 1, ncols
          Pbl_KHbyDZ2(i,k)=Pbl_KHbyDZ2(i,k) / Pbl_KMbyDZ1(i,k+1)
          Pbl_KMbyDZ1(i,k)=Pbl_KMbyDZ1(i,k) - Pbl_KHbyDZ2(i,k)*Pbl_KMbyDZ2(i,k+1)
          Pbl_TendQ  (i,k)=Pbl_TendQ  (i,k) - Pbl_KHbyDZ2(i,k)*Pbl_TendQ  (i,k+1)
       END DO
    END DO
    DO k = 1, kmax
       DO i = 1, ncols
          gmq(i,k,1)=Pbl_KMbyDZ2(i,k)
          gmq(i,k,2)=Pbl_KMbyDZ1(i,k)
          gmq(i,k,3)=Pbl_TendQ  (i,k)
       END DO
    END DO

  END SUBROUTINE VDIFH
  !----------------------------------------------------------------------
  !XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  !----------------------------------------------------------------------
  SUBROUTINE VDIFT(kMax,nCols,twodti,Pbl_ITemp,Pbl_CoefKh,a,b,gt,gmt)
    !     ***************************************************************
    !     *                                                             *
    !     *         VERTICAL DIFFUSION OF MASS VARIABLES                *
    !     *                                                             *
    !     ***************************************************************
    INTEGER      ,    INTENT(in   ) :: nCols
    INTEGER      ,    INTENT(in   ) :: kMax
    REAL(KIND=r8),    INTENT(in   ) :: twodti
    REAL(KIND=r8),    INTENT(in   ) :: a         (kmax)
    REAL(KIND=r8),    INTENT(in   ) :: b         (kmax)
    REAL(KIND=r8),    INTENT(in   ) :: Pbl_ITemp (nCols,kMax)
    REAL(KIND=r8),    INTENT(in   ) :: Pbl_CoefKh(nCols,kMax)
    REAL(KIND=r8),    INTENT(in   ) :: gt        (nCols,kMax)
    REAL(KIND=r8),    INTENT(inout) :: gmt       (nCols,kMax,3)

    REAL(KIND=r8) :: Pbl_CoefKh2(nCols,kMax)
    REAL(KIND=r8) :: Pbl_KHbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ(nCols,kMax) !1/(sec * K)
    REAL(KIND=r8) :: Pbl_KMbyDZ2(nCols,kMax)
    REAL(KIND=r8) :: Pbl_KMbyDZ1(nCols,kMax)
    REAL(KIND=r8) :: Pbl_KHbyDZ2(nCols,kMax)
    REAL(KIND=r8) :: Pbl_TendT(nCols,kMax)
    INTEGER       :: i
    INTEGER       :: k
    !
    !     sensible heat diffusion
    !
    !   sigk  (   k)=       sl(k)**akappa
    !   sigkiv(   k)=1.0_r8/sl(k)**akappa
    !   sigr  (   k)=sigk(k  )*sigkiv(k+1) =(sl(k  )**akappa)*(1.0_r8/sl(k+1)**akappa)
    !   sigriv( k+1)=sigk(k+1)*sigkiv(k  ) =(sl(k+1)**akappa)*(1.0_r8/sl(k  )**akappa)
    !
    DO k = 1, kMax-1
       DO i = 1, nCols
          Pbl_CoefKh2(i,k  )=Pbl_CoefKh(i,k)*Pbl_ITemp(i,k)
          Pbl_KHbyDZ(i,k  )=a(k  )*Pbl_CoefKh2(i,k)
          Pbl_KMbyDZ(i,k+1)=b(k+1)*Pbl_CoefKh2(i,k)
       END DO
    END DO
    DO i = 1, nCols
       Pbl_KMbyDZ2(i,1)=  0.0_r8
       Pbl_KMbyDZ1(i,1)=  1.0_r8+Pbl_KHbyDZ(i,1)
       Pbl_KHbyDZ2(i,1)=-sigr(1)*Pbl_KHbyDZ(i,1)
       Pbl_TendT  (i,1)=-Pbl_KHbyDZ(i,1)*(gt(i,1)-sigr(1)*gt(i,1+1))*twodti

       Pbl_KMbyDZ2(i,kMax)=-sigriv(kMax)*Pbl_KMbyDZ(i,kMax)
       Pbl_KMbyDZ1(i,kMax)=    1.0_r8+Pbl_KMbyDZ(i,kMax)
       Pbl_KHbyDZ2(i,kMax)=0.0_r8
       Pbl_TendT  (i,kMax)=twodti*Pbl_KMbyDZ(i,kMax)*(sigriv(kMax)*gt(i,kMax-1)-gt(i,kMax))
    END DO
    DO k = 2, kMax-1
       DO i = 1, nCols
          Pbl_KMbyDZ2(i,k)=-sigriv(k)*Pbl_KMbyDZ(i,k)
          Pbl_KMbyDZ1(i,k)=1.0_r8+Pbl_KHbyDZ(i,k)+Pbl_KMbyDZ(i,k)
          Pbl_KHbyDZ2(i,k)=-sigr  (k)*Pbl_KHbyDZ(i,k)
          Pbl_TendT  (i,k)=( Pbl_KMbyDZ(i,k)*(sigriv(k)*gt(i,k-1) - gt(i,k))&
               -Pbl_KHbyDZ(i,k)*(gt(i,k)- sigr(k)*gt(i,k+1))  )*twodti
       END DO
    END DO

    DO k = kmax-1, 1, -1
       DO i = 1, ncols
          Pbl_KHbyDZ2(i,k)=Pbl_KHbyDZ2(i,k)/Pbl_KMbyDZ1(i,k+1)
          Pbl_KMbyDZ1(i,k)=Pbl_KMbyDZ1(i,k)-Pbl_KHbyDZ2(i,k  )*Pbl_KMbyDZ2(i,k+1)
          Pbl_TendT  (i,k)=Pbl_TendT  (i,k)-Pbl_KHbyDZ2(i,k  )*Pbl_TendT  (i,k+1)
       END DO
    END DO

    DO k = 1, kmax
       DO i = 1, ncols
          gmt(i,k,1)=Pbl_KMbyDZ2(i,k)
          gmt(i,k,2)=Pbl_KMbyDZ1(i,k)
          gmt(i,k,3)=Pbl_TendT  (i,k)
       END DO
    END DO
  END SUBROUTINE VDIFT
END MODULE PlanBoundLayer