#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=4:00:00
#SBATCH --mem=100GB
#SBATCH --job-name=ny_sid
#SBATCH --mail-type=NONE
#SBATCH --mail-user=alanzchen@nyu.edu
#SBATCH --output=slurm/slurm_%j.out
  
module purge
module load stata/15
RUNDIR=$SCRATCH/ny_sid/run-${SLURM_JOB_ID/.*}
mkdir -p $RUNDIR

# Command line  arguments
SCRATCH_DIR=$1
PROJ_DIR=$2
YEAR=$3
SAMPLE=$4

# Run job
stata -b do $REPO/code/split_sample_ny_sid_helper.do $SCRATCH_DIR $PROJ_DIR $YEAR $SAMPLE
