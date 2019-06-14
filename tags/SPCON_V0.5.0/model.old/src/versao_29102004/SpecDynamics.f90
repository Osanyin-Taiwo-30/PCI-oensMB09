!
!  $Author: alexalm $
!  $Date: 2005/10/17 14:25:38 $
!  $Revision: 1.1.1.1 $
!
MODULE SpecDynamics
  USE Utils, ONLY : &
       Iminv, &
       Epslon                ! intent(in)

  USE Constants,    ONLY : &
       eriv,               & ! intent(in)
       er,           & ! intent(in)
       ersqiv,       & ! intent(in) 
       cp,           & ! intent(in)
       gasr,         & ! intent(in)
       raa,          & ! intent(in)
       tov,          & ! intent(in)
       rk              ! intent(in)

  USE FieldsDynamics, ONLY : &
       qqp,          & ! intent(inout)
       qdivp,        & ! intent(inout)
       qrotp,        & ! intent(inout)
       qtmpp,        & ! intent(inout)
       qlnpp,        & ! intent(in)
       qdivt,        & ! intent(in)
       qtmpt,        & ! intent(in)
       qlnpt           ! intent(in)

  USE Options,    ONLY : &
       vcrit,            & ! intent(in)
       alpha,            & ! intent(in)
       ndord,            & ! intent(in)
       iqdif,            & ! intent(in)
       nfprt,            & ! intent(in)
       ifprt               ! intent(in)

  USE Sizes,  ONLY : &
       mMax,         & ! intent(in)
       nMax,         & ! intent(in)
       nExtMax,      & ! intent(in)
       mnMax,        & ! intent(in)
       mnExtMax,     & ! intent(in)
       mnExtMap,     & ! intent(in)
       mnMap,        & ! intent(in)
       nMap,         & ! intent(in)
       mMap,         & ! intent(in)
       kMax,         & ! intent(in)
       snnp1,        & ! intent(in)
       ThreadDecomp, &
       rpi,          & ! intent(in)
       del,          & ! intent(in)
       ci              ! intent(in) 

  IMPLICIT NONE
  PRIVATE
  PUBLIC :: InitDztouv
  PUBLIC :: dztouv
  PUBLIC :: InitFiltDiss
  PUBLIC :: FiltDiss
  PUBLIC :: InitGozrim
  PUBLIC :: Gozrim
  PUBLIC :: InitImplDifu
  PUBLIC :: ImplDifu
  PUBLIC :: InitSemiImpl
  PUBLIC :: bmcm
  PUBLIC :: SemiImpl
  PUBLIC :: InitUvtodz
  PUBLIC :: uvtodz

  PUBLIC :: dk
  PUBLIC :: tk
  PUBLIC :: hm
  PUBLIC :: tm
  PUBLIC :: sv
  PUBLIC :: am
  PUBLIC :: bm
  PUBLIC :: cm
  PUBLIC :: p1
  PUBLIC :: p2
  PUBLIC :: h1
  PUBLIC :: h2
  PUBLIC :: hmt

  INTERFACE Gozrim
     MODULE PROCEDURE Gozrim1D, Gozrim2D
  END INTERFACE


  !  Module exports two routines:
  !     InitDZtoUV:        Should be invoked once, before any other module 
  !                        routine; sets up local constants and mappings;
  !     DZtoUV:            Velocity fields from Divergence and Vorticity; 
  !                        use values computed by InitDZtoUV

  !  Module require values from modules Sizes, AssocLegFunc and Constants

  REAL, ALLOCATABLE :: alfa_dz(:)        ! er*Epslon(m,n)/n  for m<n<=nExtMax; 0 otherwise
  REAL, ALLOCATABLE :: alfa_dzNp1(:)     ! alfa_dz(m,n+1) 
  REAL, ALLOCATABLE :: beta_dz(:)        ! m*er/(n*(n+1)) for m/=0 and m<=n<=nMax;
  !                                          er/(n+1)     for m=0;
  REAL, ALLOCATABLE :: alfa_gz(:)        ! -eriv*(n-1)*Epslon(m,n)  for m<n<=nExtMax;
  !                                         0 otherwise
  REAL, ALLOCATABLE :: beta_gz(:)        ! eriv*(n+2)*Epslon(m,n+1) for m<=n<nMax;
  !                                         0 otherwise



  ! Observe, in the relation to be computed, that u and v are defined for 
  ! 1<=mn<=mnExtMax, while Div and Vor for 1<=mn<=mnMax. Consequently, a 
  ! mapping from 1:mnExtMax to 1:mnMax
  ! has to be computed.

  ! This mapping will have faults, since there is no Div or Vor at (m,nExtMax).

  ! Furthermore, the relation requires mappings from (m,nExt) to (m,n), 
  ! (m,n+1) and (m,n-1)

  ! Mapping function mnp1_dz(1:2*mnExtMax) gives index of (m,nExt) on (m,n+1). 
  ! It is faulty on (*,nMax:nExtMax). Since it is only used by the last term,
  ! faulty values have to be multipied by 0 (on alfa_dzNp1)

  ! Mapping function mnm1_dz(1:2*mnExtMax) gives index of (m,nExt) on (m,n-1). 
  ! It is faulty on (m,m) for all m. Since it is only used by the second term,
  ! faulty values have to be multipied by 0 (on alfa_dz)

  ! Mapping function mnir_dz(1:2*mnExtMax) gives index of (m,nExt) on (m,n-1) and
  ! multiplies by i (trading imaginary by real and correcting sign). It is
  ! faulty on (m,nExtMax). To correct the fault, beta_dz(m,nExtMax) is set to 0.

  INTEGER, ALLOCATABLE :: mnir_dz(:)
  INTEGER, ALLOCATABLE :: mnm1_dz(:)
  INTEGER, ALLOCATABLE :: mnp1_dz(:)
  INTEGER, ALLOCATABLE :: mnm1_gz(:)
  INTEGER, ALLOCATABLE :: mnp1_gz(:)


  INTEGER :: ndho
  REAL :: dk
  REAL :: tk
  LOGICAL :: diffuseQ
  REAL, ALLOCATABLE :: ct(:)
  REAL, ALLOCATABLE :: cq(:)

  REAL, ALLOCATABLE :: sv(:)
  REAL, ALLOCATABLE :: p1(:)
  REAL, ALLOCATABLE :: p2(:)
  REAL, ALLOCATABLE :: h1(:)
  REAL, ALLOCATABLE :: h2(:)
  REAL, ALLOCATABLE :: am(:,:)
  REAL, ALLOCATABLE :: bm(:,:)
  REAL, ALLOCATABLE :: cm(:,:)
  REAL, ALLOCATABLE :: dm(:,:,:)
  REAL, ALLOCATABLE :: hm(:,:)
  REAL, ALLOCATABLE :: hmt(:,:)
  REAL, ALLOCATABLE :: tm(:,:)
  REAL, ALLOCATABLE :: workImplDifu(:)

  ! DIVERGENCE AND VORTICITY FROM VELOCITY FIELDS
  !
  ! Implements the following relations:
  !
  !    m              m        m       m        m         m   m       m   m
  ! Div   =CMPLX(-Alfa * Imag(U ), Alfa * Real(U )) + Beta * V  - Gama * V
  !    n              n        n       n        n        n+1 n+1      n  n-1
  !
  !    m              m        m       m        m         m   m       m   m
  ! Vor   =CMPLX(-Alfa * Imag(V ), Alfa * Real(V )) + Beta * U  - Gama * U
  !    n              n        n       n        n        n+1 n+1      n  n-1
  !
  ! for 0<=m<=mMax, m<=n<=nMax, where
  !
  !  m   m
  ! U = V = 0 for n < m
  !  n   n

  !  Module exports two routines:
  !     InitUvtodz:        Should be invoked once, before any other module 
  !                        routine; sets up local constants and mappings;
  !     Uvtodz:            Divergence and Vorticity from Velocity fields; 
  !                        use values computed by InitUvtodz

  !  Module require values from modules Sizes, AssocLegFunc and Constants

  REAL,    ALLOCATABLE :: alfa_uv(:)        ! eriv*m 
  !                                           for m<=n<=nMax
  REAL,    ALLOCATABLE :: beta_uv(:)        ! eriv*n*Epslon(m,n+1) 
  !                                           for m<=n<=nMax;
  REAL,    ALLOCATABLE :: gama_uv(:)        ! eriv*(n+1)*Epslon(m,n) 
  !                                           for m<=n<=nMax;

  ! Observe, in the relation to be computed, that u and v are defined for 
  ! 1<=mn<=mnExtMax, while Div and Vor for 1<=mn<=mnMax. Consequently, a 
  ! mapping from 1:mnMax to 1:mnExtMax has to be computed.

  ! In fact, the relation requires 3 mappings:
  !    1) (m,n) to (m,nExt)    implemented by index array mnir(mn);
  !    2) (m,n) to (m,nExt+1)  implemented by index array mnp1(mn);
  !    3) (m,n) to (m,nExt-1)  implemented by index array mnm1(mn);
  ! for m<=n<=nMax

  ! Mapping functions (1) and (2) are easily computed; mapping function (3)
  ! will be faulty for n=m; since it is used only at the last term,
  ! faulty values have to be multipied by 0 (on gama_uv(m,m))

  ! Mapping function mnir(1:2*mnMax) gives index of (m,n) on (m,nExt) and
  ! multiplies by i (trading immaginary by real). Other mappings keep in
  ! place the real and immaginary components.

  INTEGER, ALLOCATABLE :: mnir_uv(:)
  INTEGER, ALLOCATABLE :: mnm1_uv(:)
  INTEGER, ALLOCATABLE :: mnp1_uv(:)

  INTEGER :: kGlob
  REAL    :: alphaGlob
  REAL    :: betaGlob
  INTEGER, ALLOCATABLE :: ncrit(:)

CONTAINS


  ! InitDZtoUV: Mapping Functions and Local Constants


  SUBROUTINE InitDZtoUV()
    INTEGER :: m, n, mn, mn2, indir, indnp1, indnm1
    REAL :: aux

    ! mapping mnir_dz

    ALLOCATE(mnir_dz(2*mnExtMax))
    DO m = 1, mMax
       DO n = m, nMax
          mn = mnExtMap(m,n)
          indir = mnMap(m,n)
          mnir_dz(2*mn-1) = 2*indir
          mnir_dz(2*mn  ) = 2*indir-1
       END DO
       mn = mnExtMap(m,nExtMax)
       mnir_dz(2*mn-1) = 2*indir       ! faulty mapping # 1
       mnir_dz(2*mn  ) = 2*indir-1     ! faulty mapping # 1
    END DO

    ! mapping mnm1_dz

    ALLOCATE(mnm1_dz  (2*mnExtMax))
    DO m = 1, mMax
       mn = mnExtMap(m,m)
       indnm1 = mnMap(m,m  )       
       mnm1_dz(2*mn-1) = 2*indnm1-1    ! faulty mapping # 2
       mnm1_dz(2*mn  ) = 2*indnm1      ! faulty mapping # 2
       DO n = m+1, nExtMax
          mn = mnExtMap(m,n)
          indnm1 = mnMap(m,n-1)
          mnm1_dz(2*mn-1) = 2*indnm1-1
          mnm1_dz(2*mn  ) = 2*indnm1  
       END DO
    END DO
    
    ! mapping mnp1_dz

    ALLOCATE(mnp1_dz  (2*mnExtMax))
    DO m = 1, mMax
       DO n = m, nMax-1
          mn = mnExtMap(m,n)
          indnp1 = mnMap(m,n+1)
          mnp1_dz(2*mn-1) = 2*indnp1-1
          mnp1_dz(2*mn  ) = 2*indnp1  
       END DO
       DO n = nMax, nExtMax
          mn = mnExtMap(m,n)
          mnp1_dz(2*mn-1) = 2*indnp1-1 ! faulty mapping # 3
          mnp1_dz(2*mn  ) = 2*indnp1   ! faulty mapping # 3
       END DO
    END DO
    
    ! constant beta_dz

    ALLOCATE(beta_dz(2*mnExtMax))
    DO m = 1, mMax
       aux = er/REAL(m)
       mn = mnExtMap(m,m)
       beta_dz(2*mn-1) = aux
       beta_dz(2*mn  ) = -aux
       DO n = m+1, nMax
          aux = REAL(m-1)*er/REAL((n-1)*n)
          mn = mnExtMap(m,n)
          beta_dz(2*mn-1) = aux
          beta_dz(2*mn  ) = -aux
       END DO
       mn = mnExtMap(m,nExtMax)
       beta_dz(2*mn-1) = 0.0           ! corrects faulty mapping # 1
       beta_dz(2*mn  ) = 0.0           ! corrects faulty mapping # 1
    END DO
    
    ! constant alfa_dz

    ALLOCATE(alfa_dz    (2*mnExtMax))
    DO m = 1, mMax
       mn = mnExtMap(m,m)
       alfa_dz(2*mn-1) = 0.0           ! corrects faulty mapping # 2
       alfa_dz(2*mn  ) = 0.0           ! corrects faulty mapping # 2
       DO n = m+1, nExtMax
          mn = mnExtMap(m,n)
          aux = er * Epslon(mn) / REAL(n-1)
          alfa_dz(2*mn-1) = aux
          alfa_dz(2*mn  ) = aux
       END DO
    END DO
    
    ! constant alfa_dz mapped to n-1

    ALLOCATE(alfa_dzNp1 (2*mnExtMax))
    DO m = 1, mMax
       DO n = m, nMax - 1
          mn  = mnExtMap(m,n)
          mn2 = mnExtMap(m,n+1)
          aux  = er * Epslon(mn2) / REAL(n)
          alfa_dzNp1(2*mn-1) = aux
          alfa_dzNp1(2*mn  ) = aux
       END DO
       DO n = nMax, nExtMax
          mn = mnExtMap(m,n)
          alfa_dzNp1(2*mn-1) = 0.0     ! corrects faulty mapping # 3
          alfa_dzNp1(2*mn  ) = 0.0     ! corrects faulty mapping # 3
       END DO
    END DO

  END SUBROUTINE InitDZtoUV
  

  ! DZtoUV: Velocity fields from divergence and vorticity
  !
  ! Implements the following relations:
  !
  !  m            m          m       m         m         m     m       m     m
  ! U  =CMPLX(Beta * Imag(Div), -Beta *Real(Div))  - alfa * Vor  + alfa * Vor
  !  n            n          n       n         n         n    n-1     n+1   n+1
  !
  !  m            m          m       m         m         m     m       m     m
  ! V  =CMPLX(Beta * Imag(Vor), -Beta *Real(Vor))  + alfa * Div  - alfa * Div
  !  n            n          n       n         n         n    n-1     n+1   n+1
  !
  ! for 0<=m<=mMax, m<=n<=nExtMax, where
  !
  !    m     m
  ! Div = Vor = 0 for n > nMax or n < m
  !    n     n



  SUBROUTINE DZtoUV(qdivp, qrotp, qup, qvp, mnRIExtFirst, mnRIExtLast)
    REAL,    INTENT(IN ) :: qdivp(2*mnMax,kMax)
    REAL,    INTENT(IN ) :: qrotp(2*mnMax,kMax)
    REAL,    INTENT(OUT) :: qup(2*mnExtMax,kMax)
    REAL,    INTENT(OUT) :: qvp(2*mnExtMax,kMax)
    INTEGER, INTENT(IN ) :: mnRIExtFirst
    INTEGER, INTENT(IN ) :: mnRIExtLast
    INTEGER :: mn, k

    DO k = 1, kMax
       DO mn = mnRIExtFirst, mnRIExtLast
          qup(mn,k) =                          - &
               alfa_dz   (mn) * qrotp(mnm1_dz(mn),k) + &
               alfa_dzNp1(mn) * qrotp(mnp1_dz(mn),k) + &
               beta_dz   (mn) * qdivp(mnir_dz(mn),k) 
          qvp(mn,k) =                          + &
               alfa_dz   (mn) * qdivp(mnm1_dz(mn),k) - &
               alfa_dzNp1(mn) * qdivp(mnp1_dz(mn),k) + &
               beta_dz   (mn) * qrotp(mnir_dz(mn),k) 
       END DO
    END DO
  END SUBROUTINE DZtoUV


  ! InitFiltDiss


  SUBROUTINE InitFiltDiss()

    ALLOCATE(ncrit(kMax))
    alphaGlob = (alpha / 6.37) * 1.e-06
    betaGlob  = 1034.6 * 62.0 * vcrit
  END SUBROUTINE InitFiltDiss

  !
  !     ftrdis : this routine applies an extra dissipation to spectral
  !              fields, depending on maximum velocity at a given level
  !              and on wave-number .

  SUBROUTINE FiltDiss(dt, vmax, kFirst, kLast, mnRIFirst, mnRILast)
    REAL,    INTENT(IN) :: dt
    REAL,    INTENT(IN) :: vmax(kMax)
    INTEGER, INTENT(IN) :: kFirst
    INTEGER, INTENT(IN) :: kLast
    INTEGER, INTENT(IN) :: mnRIFirst
    INTEGER, INTENT(IN) :: mnRILast
    !
    REAL    :: cdump
    REAL    :: alpha0
    REAL    :: beta
    REAL    :: DumpFactor
    INTEGER :: k
    INTEGER :: n
    INTEGER :: m
    INTEGER :: mn

    alpha0 = alphaGlob * dt
    beta   = betaGlob / dt

    DO k = kFirst, kLast
       IF (vmax(k) == 0.0) THEN
          ncrit(k) = nMax
       ELSE
          ncrit(k) = beta / vmax(k)
       ENDIF
    END DO
    !$OMP BARRIER


    DO k = 1, kMax
!CDIR NODEP
       DO mn = mnRIFirst, mnRILast
          n = nMap((mn+1)/2)
          m = mMap((mn+1)/2)
          IF (n >= ncrit(k) + 2 .AND. m <= n) THEN
             DumpFactor = 1.0 / (1.0+alpha0*vmax(k)*(n-1-ncrit(k)))
             qdivp(mn,k) = DumpFactor * qdivp(mn,k)
             qtmpp(mn,k) = DumpFactor * qtmpp(mn,k)
             qrotp(mn,k) = DumpFactor * qrotp(mn,k)
             qqp  (mn,k) = DumpFactor * qqp(mn,k)
          END IF
       END DO
    END DO
    !$OMP BARRIER
  END SUBROUTINE FiltDiss



  ! InitGozrim: Mapping Functions and Local Constants


  SUBROUTINE InitGozrim()
    INTEGER :: m, n, mn, mn2, indnp1, indnm1

    ! mapping mnm1_gz

    ALLOCATE(mnm1_gz  (2*mnExtMax))
    DO m = 1, mMax
       mn = mnExtMap(m,m)
       indnm1 = mnMap(m,m  )       
       mnm1_gz(2*mn-1) = 2*indnm1-1    ! faulty mapping # 1
       mnm1_gz(2*mn  ) = 2*indnm1      ! faulty mapping # 1
       DO n = m+1, nExtMax
          mn = mnExtMap(m,n)
          indnm1 = mnMap(m,n-1)
          mnm1_gz(2*mn-1) = 2*indnm1-1
          mnm1_gz(2*mn  ) = 2*indnm1  
       END DO
    END DO
    
    ! mapping mnp1_gz

    ALLOCATE(mnp1_gz  (2*mnExtMax))
    DO m = 1, mMax
       DO n = m, nMax-1
          mn = mnExtMap(m,n)
          indnp1 = mnMap(m,n+1)
          mnp1_gz(2*mn-1) = 2*indnp1-1
          mnp1_gz(2*mn  ) = 2*indnp1  
       END DO
       DO n = nMax, nExtMax
          mn = mnExtMap(m,n)
          mnp1_gz(2*mn-1) = 2*indnp1-1 ! faulty mapping # 2
          mnp1_gz(2*mn  ) = 2*indnp1   ! faulty mapping # 2
       END DO
    END DO
    
    ! constant alfa_gz

    ALLOCATE(alfa_gz    (2*mnExtMax))
    DO m = 1, mMax
       mn = mnExtMap(m,m)
       alfa_gz(2*mn-1) = 0.0           ! corrects faulty mapping # 1
       alfa_gz(2*mn  ) = 0.0           ! corrects faulty mapping # 1
       DO n = m+1, nExtMax
          mn = mnExtMap(m,n)
          alfa_gz(2*mn-1) = -REAL(n-2)*Epslon(mn)
          alfa_gz(2*mn  ) = -REAL(n-2)*Epslon(mn)
       END DO
    END DO
    
    ! constant beta_gz

    ALLOCATE(beta_gz(2*mnExtMax))
    DO m = 1, mMax
       DO n = m, nMax-1
          mn = mnExtMap(m,n)
          mn2 = mnExtMap(m,n+1)
          beta_gz(2*mn-1) = REAL(n+1)*Epslon(mn2)
          beta_gz(2*mn  ) = REAL(n+1)*Epslon(mn2)
       END DO
       DO n = nMax, nExtMax
          mn = mnExtMap(m,n)
          beta_gz(2*mn-1) = 0.0        ! corrects faulty mapping # 2
          beta_gz(2*mn  ) = 0.0        ! corrects faulty mapping # 2
       END DO
    END DO
  END SUBROUTINE InitGozrim
  

  ! Gozrim: Meridional derivative of spectral field
  ! MERIDIONAL DERIVATIVE OF SPECTRAL FIELD
  !
  ! Derivative (with respect to phi) of a spectral field, computed
  ! by the following relation:
  !
  !  m       m   m       m   m
  ! G  = alfa * F  + beta * F
  !  n       n  n-1      n  n+1
  !
  ! for 0<=m<=mMax, m<=n<=nExtMax, 
  ! where F is the spectral field, G its derivative, alfa and beta are
  ! constants and
  !
  !  m     
  ! F  = 0 for n<m or n>nMax
  !  n     


  SUBROUTINE Gozrim1D(q, qder, mnRIExtFirst, mnRIExtLast)
    REAL,    INTENT(IN ) :: q(2*mnMax)
    REAL,    INTENT(OUT) :: qder(2*mnExtMax)
    INTEGER, INTENT(IN ) :: mnRIExtFirst 
    INTEGER, INTENT(IN ) :: mnRIExtLast
    INTEGER :: mn

    DO mn = mnRIExtFirst, mnRIExtLast
       qder(mn) = &
            beta_gz(mn) * q(mnp1_gz(mn)) + &
            alfa_gz(mn) * q(mnm1_gz(mn)) 
       qder(mn) = eriv*qder(mn)
    END DO
  END SUBROUTINE Gozrim1D





  SUBROUTINE Gozrim2D(q, qder, mnRIExtFirst, mnRIExtLast)
    REAL,    INTENT(IN)  :: q(2*mnMax,kMax)
    REAL,    INTENT(OUT) :: qder(2*mnExtMax,kMax)
    INTEGER, INTENT(IN ) :: mnRIExtFirst 
    INTEGER, INTENT(IN ) :: mnRIExtLast
    INTEGER :: mn, k

    DO k = 1, kMax
       DO mn = mnRIExtFirst, mnRIExtLast
          qder(mn,k) = &
               beta_gz(mn) * q(mnp1_gz(mn),k) + &
               alfa_gz(mn) * q(mnm1_gz(mn),k) 
          qder(mn,k) = eriv*qder(mn,k)
       END DO
    END DO
  END SUBROUTINE Gozrim2D


  SUBROUTINE InitImplDifu(ct_in, cq_in, dk_in, tk_in)
    REAL,    INTENT(IN) :: ct_in(:)
    REAL,    INTENT(IN) :: cq_in(:)
    REAL,    INTENT(IN) :: dk_in
    REAL,    INTENT(IN) :: tk_in
    REAL :: mn
    !
    !     horizontal diffusion coefficients
    !     revised arbitrary even order horizontal diffusion
    !     earth's radius removed algebraically to avoid exponent limit
    !     problems
    !
    IF(iqdif == 'YES ') THEN
      diffuseQ = .TRUE.
    ELSE
      diffuseQ = .FALSE.
    END IF      
    ndho = ndord/2
    ! fnn1=(nMax-1)*nMax
    ! dk=(1.0/fnn1)**ndho/(rhdifd*3600.0)
    ! tk=(1.0/fnn1)**ndho/(rhdift*3600.0)
    dk = dk_in/(er**2)**ndho
    tk = tk_in/(er**2)**ndho
    IF (ifprt(2) >= 1) THEN
       WRITE (nfprt, '(/,1P,2(A,1PG12.5),A,I2)') &
                     ' dk_in = ', dk_in, ' tk_in = ', tk_in, ' ndord = ', ndord
       WRITE (nfprt, '(1P,2(A,1PG12.5),/)') ' dk = ', dk, ' tk = ', tk
    ENDIF

    ALLOCATE (ct(kMax))
    ct = ct_in
    ALLOCATE (cq(kMax))
    cq = cq_in
    !
    ! dependence on earth's radius removed
    !
    ALLOCATE(workImplDifu(2*mnMax))
    DO mn = 1, 2*mnMax
       workImplDifu(mn) = 2.0*(snnp1(mn)**ndho)
    END DO
  END SUBROUTINE InitImplDifu

  ! impdif :  the diffusion operator (a power of the laplacian) is integrated
  ! in a fully implicit scheme (backward euler)
  ! The effect is a selective dumping of the actualized variables 
  ! in spectral space.

  SUBROUTINE ImplDifu(dt, mnRIFirst, mnRILast)
    REAL,    INTENT(IN) :: dt
    INTEGER, INTENT(IN) :: mnRIFirst
    INTEGER, INTENT(IN) :: mnRILast
    INTEGER :: mn, k
    REAL :: work(2*mnMax)
    !
    ! diffusion coefficient for divergence
    !
    DO k = 1, kMax
       DO mn = mnRIFirst, mnRILast
          qdivp(mn,k) = qdivp(mn,k)/(1.+dt*dk*workImplDifu(mn))
       END DO
    END DO
    !
    ! diffusion coefficient for remaining fields
    !
    DO mn = mnRIFirst, mnRILast
       work(mn) = dt*tk*workImplDifu(mn)
    END DO
    !
    ! damp temp and vorticity 
    !
    IF (diffuseQ) THEN
       DO k = 1, kMax
          DO mn = mnRIFirst, mnRILast
             qtmpp(mn,k) = (qtmpp(mn,k)+work(mn)*ct(k)*qlnpp(mn))/(1.+work(mn))
             qrotp(mn,k) = qrotp(mn,k)/(1.+work(mn))
             qqp(mn,k)=(qqp(mn,k)+work(mn)*cq(k)*qlnpp(mn))/(1.+work(mn))
          END DO
       END DO
    ELSE
       DO k = 1, kMax
          DO mn = mnRIFirst, mnRILast
             qtmpp(mn,k) = (qtmpp(mn,k)+work(mn)*ct(k)*qlnpp(mn))/(1.+work(mn))
             qrotp(mn,k) = qrotp(mn,k)/(1.+work(mn))
          END DO
       END DO
    ENDIF
!$OMP BARRIER
  END SUBROUTINE ImplDifu








  SUBROUTINE InitSemiImpl()
    INTEGER :: i, j, k
    REAL    :: det
    INTEGER :: lll(kMax), mmm(kMax)


    ALLOCATE(sv(kmax))
    ALLOCATE(p1(kmax))
    ALLOCATE(p2(kmax))
    ALLOCATE(h1(kmax))
    ALLOCATE(h2(kmax))
    ALLOCATE(am(kmax,kmax))
    ALLOCATE(bm(kmax,kmax))
    ALLOCATE(cm(kmax,kmax))
    ALLOCATE(hm(kmax,kmax))
    ALLOCATE(hmt(kmax,kmax))
    ALLOCATE(tm(kmax,kmax))

    hm = 0.0
    tm = 0.0
    !cdir novector
    DO k=1, kmax-1
       hm(k,k) = 1.0
       tm(k,k) = 0.5*cp*(rpi(k)-1.0)
    END DO
    DO k=1, kmax-1
       hm(k,k+1) = -1.0
       tm(k,k+1) = 0.5*cp*(1.0-1.0/rpi(k))
    END DO
    DO k=1, kmax
       hm(kmax,k) = del(k)
       tm(kmax,k) = gasr*del(k)
    END DO
    CALL iminv (hm,  kmax, det, lll, mmm)
    DO i=1, kmax
       DO j=1, kmax
          am(i,j) = 0.0
          DO k=1, kmax
             am(i,j) = am(i,j) + hm(i,k)*tm(k,j)
          END DO
       END DO
    END DO

    tm = am
    hm = am
    hmt = TRANSPOSE(hm)
    am = am *ersqiv
    CALL iminv(tm, kmax, det, lll, mmm)

    !cdir novector
    DO k=1, kmax
       sv(k) = -del(k)
    END DO
    DO k=1, kmax-1
       p1(k) = 1.0 / rpi(k)
       p2(k+1) = rpi(k)
    END DO
    p1(kmax) = 0.0
    p2( 1  ) = 0.0

    ALLOCATE (dm(kMax,kMax,nMax))
    dm =0.0
  END SUBROUTINE InitSemiImpl






  SUBROUTINE bmcm(dt, slagr)
    LOGICAL, INTENT(IN) :: slagr
    REAL,    INTENT(IN) :: dt
    !
    !  local variables
    !
    REAL, DIMENSION(kmax) ::  x1, x2
    INTEGER :: i, j, k, n, nn, lll(kMax), mmm(kMax)
    REAL :: temp, det
    REAL    :: rim(kMax,kMax)
    !
    IF (.NOT. slagr) THEN
       DO k=1,kmax-1
          h1(k) = p1(k) * tov(k+1) - tov(k)
       END DO
       h1(kmax)=0.0 
       h2(   1)=0.0 
       DO k=2, kmax
          h2(k) = tov(k) - p2(k) * tov(k-1)
       END DO
    ELSE
       DO k=1,kmax-1
          h1(k) = ( 1.0-p2(k+1) ) * tov(k)
       END DO
       h1(kmax)=0.0 
       h2(   1)=0.0 
       DO k=2, kmax
          h2(k) = ( p1(k-1) - 1.0 ) * tov(k) 
       END DO
    END IF
    DO k=1, kmax
       x1(k) = rk*tov(k)+0.5*(ci(k+1)*h1(k)+ci(k)*h2(k))/del(k)
       x2(k) = 0.5*(h1(k)+h2(k)) / del(k)
    END DO
    DO j=1, kmax
       DO k=1, kmax
          bm(k,j) = -x1(k)*del(j)
       END DO
    END DO
    DO k=1, kmax
       DO j=1, k
          bm(k,j) = bm(k,j) + x2(k)*del(j)
       END DO
    END DO
    DO k=1, kmax
       bm(k,k) = bm(k,k) - 0.5*h2(k)
    END DO
    DO i=1, kmax
       DO j=1, kmax
          cm(i,j) = 0.0 
          DO k=1, kmax
             cm(i,j) = cm(i,j) + am(i,k) * bm(k,j)
          END DO
          cm(i,j) = (cm(i,j)+raa*tov(i)*sv(j))*dt*dt
       END DO
    END DO

    rim=0.0
    DO k=1,kmax
       rim(k,k)=1.0
    END DO
    DO nn=1,nMax
       n=nn-1
       temp = n*(n+1)
       dm(:,:,nn)=rim-temp*cm
       CALL iminv (dm(1,1,nn), kmax, det, lll, mmm)
    END DO

  END SUBROUTINE bmcm






  SUBROUTINE SemiImpl(dt, mnRIFirst, mnRILast)
    REAL,    INTENT(IN) :: dt
    INTEGER, INTENT(IN) :: mnRIFirst
    INTEGER, INTENT(IN) :: mnRILast
    INTEGER :: i
    INTEGER :: j
    INTEGER :: k
    INTEGER :: n
    INTEGER :: mn
    REAL    :: tor
    REAL    :: aux(2*mnMax,kMax)

    DO k=1, kmax
       DO mn = mnRIFirst, mnRILast
          aux(mn,k)=0.0
       END DO
    END DO
    DO j=1, kmax
       DO k=1, kmax
          DO mn = mnRIFirst, mnRILast
             aux(mn,j)=aux(mn,j)+am(j,k)*qtmpt(mn,k)
          END DO
       END DO
    END DO
    DO k=1, kmax
       tor=gasr*tov(k)/(er*er)
       DO mn = mnRIFirst, mnRILast
          aux(mn,k)=aux(mn,k)+tor*qlnpt(mn)
          aux(mn,k)=aux(mn,k)*dt*snnp1(mn)
       END DO
    END DO
    DO k=1, kmax
       DO mn = mnRIFirst, mnRILast
          aux(mn,k)=aux(mn,k)+qdivt(mn,k)
       END DO
    END DO
    DO mn = mnRIFirst, mnRILast
       n = nMap((mn+1)/2)
       DO k=1,kmax
          qdivp(mn,k)=0.0
       END DO
       DO k=1, kmax
          DO i=1, kmax
             qdivp(mn,i)=qdivp(mn,i)+dm(i,k,n)*aux(mn,k)
          END DO
       END DO
    END DO

    DO k=1, kmax
       DO mn = mnRIFirst, mnRILast
          aux(mn,k)=0.0
       END DO
    END DO
    DO j=1, kmax
       DO k=1, kmax
          DO mn = mnRIFirst, mnRILast
             aux(mn,j)=aux(mn,j)+bm(j,k)*qdivp(mn,k)
          END DO
       END DO
    END DO
    DO k=1, kmax
       DO mn = mnRIFirst, mnRILast
          qtmpp(mn,k)=qtmpt(mn,k)+dt*aux(mn,k)
       END DO
    END DO
    DO mn = mnRIFirst, mnRILast
       aux(mn,1)=0.0
    END DO
    DO k=1, kmax
       DO mn = mnRIFirst, mnRILast
          aux(mn,1)=aux(mn,1)+sv(k)*qdivp(mn,k)
       END DO
    END DO
    DO mn = mnRIFirst, mnRILast
       qlnpp(mn)=qlnpt(mn)+dt*aux(mn,1)
    END DO
  END SUBROUTINE SemiImpl

  ! InitUvtodz: Mapping Functions and Local Constants


  SUBROUTINE InitUvtodz()
    INTEGER :: m, n, mn, mnExt

    ! mapping mnir_uv

    ALLOCATE(mnir_uv(2*mnMax))
    DO m = 1, mMax
       DO n = m, nMax
          mn    = mnMap(m,n)
          mnExt = mnExtMap(m,n)
          mnir_uv(2*mn-1) = 2*mnExt
          mnir_uv(2*mn  ) = 2*mnExt-1
       END DO
    END DO

    ! mapping mnm1_uv

    ALLOCATE(mnm1_uv(2*mnMax))
    DO m = 1, mMax
       mn    = mnMap(m,m)
       mnExt = mnExtMap(m,m)
       mnm1_uv(2*mn-1) = 2*mnExt-1   ! faulty mapping
       mnm1_uv(2*mn  ) = 2*mnExt     ! faulty mapping
       DO n = m+1, nMax
          mn    = mnMap(m,n)
          mnExt = mnExtMap(m,n-1)
          mnm1_uv(2*mn-1) = 2*mnExt-1
          mnm1_uv(2*mn  ) = 2*mnExt
       END DO
    END DO
    
    ! mapping mnp1_uv

    ALLOCATE(mnp1_uv(2*mnMax))
    DO m = 1, mMax
       DO n = m, nMax
          mn    = mnMap(m,n)
          mnExt = mnExtMap(m,n+1)
          mnp1_uv(2*mn-1) = 2*mnExt-1
          mnp1_uv(2*mn  ) = 2*mnExt
       END DO
    END DO

    ! constant alfa_uv

    ALLOCATE(alfa_uv(2*mnMax))
    DO m = 1, mMax
       DO n = m, nMax
          mn = mnMap(m,n)
          alfa_uv(2*mn-1) = -REAL(m-1)
          alfa_uv(2*mn  ) = REAL(m-1)
       END DO
    END DO
    
    ! constant beta_uv

    ALLOCATE(beta_uv(2*mnMax))
    DO m = 1, mMax
       DO n = m, nMax
          mn    = mnMap(m,n)
          mnExt = mnExtMap(m,n+1)
          beta_uv(2*mn-1) = REAL(n-1)*Epslon(mnExt)
          beta_uv(2*mn  ) = REAL(n-1)*Epslon(mnExt)
       END DO
    END DO
    
    ! constant gama_uv

    ALLOCATE(gama_uv(2*mnExtMax))
    DO m = 1, mMax
       mn = mnMap(m,m)
       gama_uv(2*mn-1) = 0.0     ! corrects faulty mapping
       gama_uv(2*mn  ) = 0.0     ! corrects faulty mapping
       DO n = m+1, nMax
          mn    = mnMap(m,n)
          mnExt = mnExtMap(m,n)
          gama_uv(2*mn-1) = REAL(n) * Epslon(mnExt)
          gama_uv(2*mn  ) = REAL(n) * Epslon(mnExt)
       END DO
    END DO

  END SUBROUTINE InitUvtodz
  

  ! Uvtodz: Divergence and Vorticity from Velocity fields 


  SUBROUTINE Uvtodz(qup, qvp, qdivt, qrott, mnRIFirst, mnRILast)
    REAL,    INTENT(IN ) :: qup(2*mnExtMax,kMax)
    REAL,    INTENT(IN ) :: qvp(2*mnExtMax,kMax)
    REAL,    INTENT(OUT) :: qdivt(2*mnMax,kMax)
    REAL,    INTENT(OUT) :: qrott(2*mnMax,kMax)
    INTEGER, INTENT(IN ) :: mnRIFirst
    INTEGER, INTENT(IN ) :: mnRILast
    INTEGER :: mn, k

    DO k = 1, kMax
       DO mn = mnRIFirst, mnRILast
          qdivt(mn,k) = &
               alfa_uv(mn) * qup(mnir_uv(mn),k) + &
               beta_uv(mn) * qvp(mnp1_uv(mn),k) - &
               gama_uv(mn) * qvp(mnm1_uv(mn),k)
          qdivt(mn,k) = eriv * qdivt(mn,k)
          qrott(mn,k) = &
               alfa_uv(mn) * qvp(mnir_uv(mn),k) - &
               beta_uv(mn) * qup(mnp1_uv(mn),k) + &
               gama_uv(mn) * qup(mnm1_uv(mn),k)
          qrott(mn,k) = eriv * qrott(mn,k)
       END DO
    END DO
  END SUBROUTINE Uvtodz
END MODULE SpecDynamics
