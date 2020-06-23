MODULE config
  IMPLICIT NONE
  
  INTEGER           :: nmemb
  CHARACTER(LEN=5)  :: trunc
  INTEGER           :: levels
  CHARACTER(LEN=10) :: labeli
  CHARACTER(LEN=10) :: labelf
  INTEGER           :: npmx
  INTEGER           :: nfsf
  INTEGER           :: nfkm
  INTEGER           :: imax
  INTEGER           :: jmax
  CHARACTER(LEN=95) :: dataindir 
  CHARACTER(LEN=95) :: dataoutdir 
  CHARACTER(LEN=95) :: datadirunt 
  CHARACTER(LEN=10) :: namef_pre
  CHARACTER(LEN=10) :: nameh_pre
  CHARACTER(LEN=10) :: namem_pre
  CHARACTER(LEN=10) :: extp
  CHARACTER(LEN=10) :: exth
  CHARACTER(LEN=10) :: exdh
  CHARACTER(LEN=10) :: extm
  CHARACTER(LEN=10) :: extc
  CHARACTER(LEN=95) :: unitfile
  INTEGER           :: delt
  INTEGER           :: dofprev
  INTEGER           :: divbyvar
  INTEGER           :: deltout
  INTEGER           :: nthreads
  CHARACTER(LEN=12) :: guia
  CHARACTER(LEN=200) :: filen(27:100)
  INTEGER :: nfiles
  
  CONTAINS 
  
  SUBROUTINE le_config()
    USE geral
  
    OPEN(UNIT=1,FILE='config',STATUS='old')
  
    READ(1,FMT='(A12,I3)',ERR=100)  guia,nmemb
    READ(1,FMT='(A12,A5)',ERR=100)  guia,trunc
    READ(1,FMT='(A12,I2)',ERR=100)  guia,levels
    READ(1,FMT='(A12,A10)',ERR=100) guia,labeli
    READ(1,FMT='(A12,A10)',ERR=100) guia,labelf
    READ(1,FMT='(A12,I4)',ERR=100)  guia,npmx
    READ(1,FMT='(A12,I4)',ERR=100)  guia,nfsf
    READ(1,FMT='(A12,I4)',ERR=100)  guia,nfkm
    READ(1,FMT='(A12,I4)',ERR=100)  guia,imax
    READ(1,FMT='(A12,I4)',ERR=100)  guia,jmax 
    READ(1,FMT='(A12,A90)',ERR=100) guia,dataindir
    READ(1,FMT='(A12,A90)',ERR=100) guia,dataoutdir
    READ(1,FMT='(A12,A90)',ERR=100) guia,datadirunt
    READ(1,FMT='(A12,A10)',ERR=100) guia,namef_pre
    READ(1,FMT='(A12,A10)',ERR=100) guia,nameh_pre
    READ(1,FMT='(A12,A10)',ERR=100) guia,namem_pre
    READ(1,FMT='(A12,A10)',ERR=100) guia,extp
    READ(1,FMT='(A12,A10)',ERR=100) guia,exth
    READ(1,FMT='(A12,A10)',ERR=100) guia,exdh
    READ(1,FMT='(A12,A10)',ERR=100) guia,extm
    READ(1,FMT='(A12,A10)',ERR=100) guia,extc
    READ(1,FMT='(A12,A90)',ERR=100) guia,unitfile
    READ(1,FMT='(A12,I4)' ,ERR=100) guia,delt
    READ(1,FMT='(A12,I4)' ,ERR=100) guia,dofprev
    READ(1,FMT='(A12,I4)' ,ERR=100) guia,divbyvar
    READ(1,FMT='(A12,I4)' ,ERR=100) guia,deltout
    READ(1,FMT='(A12,I4)' ,ERR=100) guia,nthreads
  
    CLOSE(UNIT=1)
    
    RETURN
    
100 PRINT *,Error('Erro na leitura do config',61,'config',2)
    
  END SUBROUTINE le_config
  
  SUBROUTINE filename(bvar,nvar)
    IMPLICIT NONE
    
    INTEGER,INTENT(IN) :: nvar
    CHARACTER(LEN=*) :: bvar(nvar)
    INTEGER :: i,nf
    CHARACTER(LEN=2) :: na,lv
    
    WRITE(lv,FMT='(I2.2)') levels
        
    filen(27)=TRIM(datadirunt)//'/'//TRIM(unitfile) !aunits
    filen(28)=TRIM(dataindir)//'/'//TRIM(nameh_pre)//'AVN'//labeli//labelf// &
               TRIM(exdh)//'.'//TRIM(trunc)//'L'//TRIM(lv)
    filen(29)=TRIM(dataindir)//'/'//TRIM(namef_pre)//'AVN'//labeli//labeli// &
               TRIM(extp)//'.'//TRIM(trunc)//'L'//TRIM(lv)
    nf=29
    DO i=1,(nmemb-1)/2
       WRITE(na,FMT='(i2.2)') i
       nf=nf+1
       filen(nf)=TRIM(dataindir)//'/'//TRIM(nameh_pre)//na//'P'//labeli// &
                   labelf//TRIM(exth)//'.'//TRIM(trunc)//'L'//TRIM(lv) 
    END DO
    DO i=1,(nmemb-1)/2
       WRITE(na,FMT='(i2.2)') i
       nf=nf+1
       filen(nf)=TRIM(dataindir)//'/'//TRIM(nameh_pre)//na//'N'//labeli// &
                   labelf//TRIM(exth)//'.'//TRIM(trunc)//'L'//TRIM(lv) 
    END DO
    nf =nf+1
    filen(nf)=TRIM(dataindir)//'/'//TRIM(nameh_pre)//'AVN'//labeli// &
                   labelf//TRIM(exth)//'.'//TRIM(trunc)//'L'//TRIM(lv)

    DO i=1,nvar
      nf=nf+1
      filen(nf)=TRIM(dataoutdir)//'/'//bvar(i)//labeli// &
                   labelf//'.'//TRIM(trunc)//'L'//TRIM(lv)// &
		   '.bin'
    END DO
    nf=nf+1
    filen(nf)=TRIM(dataoutdir)//'/'//'CONT'//labeli// &
                   labelf//'.'//TRIM(trunc)//'L'//TRIM(lv)// &
		   '.bin'

    filen(95)=TRIM(dataoutdir)//'/'//'LOCMM'//labeli// &
                   labelf//'.'//TRIM(trunc)//'L'//TRIM(lv)
    
    nfiles=nf		   
		    
  END SUBROUTINE filename
  
    
    
  
END MODULE config