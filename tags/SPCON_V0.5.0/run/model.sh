#!/usr/bin/ksh
#PBS -q multi                    # queue: dq for <=8 CPUs
#PBS -T mpisx                    # Job type: mpisx for MPI
#PBS -l cpunum_prc=4 # cpus per Node
#PBS -l tasknum_prc=1
#PBS -b 1                  # number of nodes
#PBS -l cputim_job=7200    # max accumulated cputime
#PBS -l memsz_job=5gb  # memory per node
#PBS -o turi:/gfs/home3/modoper/tempo/global/oens/run/setout/run6PNT-EN201202140433.out
#PBS -e turi:/gfs/home3/modoper/tempo/global/oens/run/setout/run6PNT-EN201202140433.out
#PBS -j o                        # join stdout/stderr
#PBS -N OECTR126              # job name

echo "RODANDO MPI"

cd /gfs/home3/modoper/tempo/global/oens/model/exec
export OMP_NUM_THREADS=1
export F_RSVTASK=1
export MPIPROGINF=DETAIL
export F_FILEINF=DETAIL
export F_PROGINF=DETAIL
export F_ERRCNT=1
export F_SETBUF=20480
export MPIMULTITASKMIX=YES
#MPIEXPORT="OMP_NUM_THREADS F_FILEINF"
#export MPIEXPORT
if [[ 1 -eq  4 ]] ; then
mpirun  -v -host 0 -np 2 -host 1 -np 4 -host 2 -np 0 -host 3 -np 0 /gfs/home3/modoper/tempo/global/oens/run/mpisep.sh
fi
if [[ 1 -eq  3 ]] ; then
mpirun  -v -host 0 -np 2 -host 1 -np 4 -host 2 -np 0  /gfs/home3/modoper/tempo/global/oens/run/mpisep.sh
fi
if [[ 1 -eq  2 ]] ; then
mpirun  -v -host 0 -np 2 -host 1 -np 4  /gfs/home3/modoper/tempo/global/oens/run/mpisep.sh
fi
if [[ 1 -eq  1 ]] ; then
mpirun  -v -host 0 -np 2  /gfs/home3/modoper/tempo/global/oens/run/mpisep.sh
fi