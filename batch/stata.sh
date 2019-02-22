#!/bin/bash
#SBATCH --partition=gpu4_dev
#SBATCH --time=4:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=256GB
#SBATCH --mail-type=END
#SBATCH --mail-user=alanzchen@nyu.edu
#SBATCH --output=$scratch/slurm/slurm_%j.out


module load stata/15
RUNDIR=$scratch/slurm/run-${SLURM_JOB_ID/.*}
mkdir -p $RUNDIR


# Command line  arguments
ARGS=$1


# Run job
stata -b do "explore/ny_sid_supp.do" $ARGS
