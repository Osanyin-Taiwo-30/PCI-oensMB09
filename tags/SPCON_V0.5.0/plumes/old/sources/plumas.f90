SUBROUTINE plumas(var,memb,nloc,prob,ndiv,vmax,vmin,dt,dtout)
  IMPLICIT NONE
  
  INTEGER,INTENT(IN) :: ndiv               ! Numero de divisoes entre max e min
  INTEGER,INTENT(IN) :: memb               ! Numero de membros
  INTEGER,INTENT(IN) :: nloc               ! Numero de localidades
  INTEGER,INTENT(IN) :: dt                 ! Numero de timesteps  
  INTEGER,INTENT(IN) :: dtout              ! Numero de timesteps de saida  
  REAL,INTENT(IN)    :: var(nloc,memb,dtout)  ! Variavel para avaliar
  REAL,INTENT(OUT)   :: prob(nloc,ndiv,dtout) ! array de probabilidade 
  REAL,INTENT(OUT)   :: vmax,vmin          ! Valores maximos e minimos
  REAL               :: delta
  REAL               :: faixa(ndiv+1)
  INTEGER            :: i,j,k,t,tent
  
  vmax=MAXVAL(var) !Maior valor da variavel em todas as localidades
  vmin=MINVAL(var) !Menor valor da variavel em todas as localidades
#AMM  delta=(vmax-vmin)/ndiv !delta variavel 
  delta=(vmax-vmin)/(ndiv-1) !delta variavel -modificado para resolver problema na umidade relativa
  prob=0.
  
!$OMP PARALLEL DO
  DO i=1,ndiv+1
    faixa(i)=vmin+(i-1)*delta !distribui por faixas
  END DO
  faixa(ndiv+1)=2*faixa(ndiv+1) !extrapola faixa maxima
  
!$OMP PARALLEL DO
  DO i=1,nloc            !Localizacoes
    DO j=1,memb          ! membros
      DO k=1,ndiv        !Procura nas faixas
        DO t=1,dtout
          IF(var(i,j,t)>=faixa(k) .AND. var(i,j,t)<faixa(k+1)) &
	                           prob(i,k,t)=prob(i,k,t)+1
        END DO
      END DO
    END DO
  END DO
  
  !Determina a probabilidade
!$OMP PARALLEL DO
  DO i=1,nloc !Localizacoes
    DO k=1,ndiv ! membros
      DO t=1,dtout
        prob(i,k,t)=prob(i,k,t)/memb
      END DO
    END DO
  END DO

END SUBROUTINE plumas
