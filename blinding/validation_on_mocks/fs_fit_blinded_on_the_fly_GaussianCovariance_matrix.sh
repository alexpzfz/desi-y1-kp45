#!/bin/bash

#SBATCH -A desi
#SBATCH -C cpu
#SBATCH --qos=regular
#SBATCH --time=12:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=256
#SBATCH --output=JOB_OUT_%x_%j.txt
#SBATCH --error=JOB_ERR_%x_%j.txt


# Example script

#first steps, get environment

source /global/cfs/cdirs/desi/users/adematti/cosmodesi_environment.sh main

# # The following two lines may not be needed
# export CXI_FORK_SAFE=1
# export CXI_FORK_SAFE_HP=1


#cd /global/cfs/cdirs/desi/users/uendert/bao-fit/

tracer='QSO'
survey='main'
region='NGC'

basedir_in=/pscratch/sd/u/uendert/blinding_mocks/
basedir_out=${PWD}/unblinded/on_the_fly_GaussianCovariance_matrix/fs/
# This takes some time, run in parallel with 64 processes
# srun -N 1 -n 64 python py/bao_fs_fit.py --type $tracer --survey $survey --basedir_in $basedir_in --basedir_out $basedir_out --verspec mocks/FirstGenMocks/AbacusSummit/Y1/mock1 --version '' --region $region --todo emulator fs sampling


for i in 0 1 2 3 4 5 6 7
do

    w0=$(python py/w0waf_edges_maker.py --number $i --parameter 0 --type $tracer)
    wa=$(python py/w0waf_edges_maker.py --number $i --parameter 1 --type $tracer)
    a=1
    blinded_index=$(($i+$a))

    echo $w0
    echo $wa
    echo $blinded_index

    echo $tracer
    basedir_out=${PWD}/blinded/test_w0${w0}_wa${wa}/on_the_fly_GaussianCovariance_matrix/fs/

    echo 'Running the RSD fitting pipeline'

    srun -N 1 -n 64 python py/bao_fs_fit.py --type $tracer --survey $survey --basedir_in $basedir_in --basedir_out $basedir_out --verspec mocks/FirstGenMocks/AbacusSummit/Y1/mock1 --version '' --region $region --blind_cosmology test_w0${w0}_wa${wa} --todo fs sampling

done
