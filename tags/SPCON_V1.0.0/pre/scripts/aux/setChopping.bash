#!/bin/bash
#PBS -o crow:/scratch/p01211/oens-1.0.0/run/Out.MPI1
#PBS -j oe
#PBS -l walltime=4:00:00
#PBS -l mppwidth=1
#PBS -l mppnppn=1
#PBS -V
#PBS -S /bin/bash
#PBS -N Chopping
#
if [[ (Linux = "Linux") || (Linux = "linux") ]]; then
  export F_UFMTENDIAN=10,15,20,25,30,35,40,45,50,55,60,65,70,75
  export GFORTRAN_CONVERT_UNIT=big_endian:10,15,20,25,30,35,40,45,50,55,60,65,70,75
  echo "F_UFMTENDIAN= " 
  echo "GFORTRAN_CONVERT_UNIT= " 
fi
#
export KMP_STACKSIZE=128m
ulimit -s unlimited

cd /scratch/p01211/oens-1.0.0/pre/scripts/aux
ulimit -s
date
time aprun -n 1 -N 1 /scratch/p01211/oens-1.0.0/pre/exec/Chopping -i /scratch/p01211/oens-1.0.0/pre/scripts/aux/Chopping.nml
date
