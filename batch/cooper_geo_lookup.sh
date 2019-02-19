#!/bin/bash
#SBATCH -p cpu_dev
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --time=1:00:00
#SBATCH --mem=2GB
#SBATCH --job-name=cooper_geo_helper
#SBATCH --mail-type=NONE
#SBATCH --mail-user=alanzchen@nyu.edu
#SBATCH --output=slurm/slurm_%j.out
  
module purge
module load stata/15
RUNDIR=$SCRATCH/cooper_geo_lookup/run-${SLURM_JOB_ID/.*}
mkdir -p $RUNDIR

# Command line  arguments
SCRATCH_DIR=$1
API_KEY=$2
i=$3

# Run job
stata -b do $REPO/code/cooper_geo_lookup_helper.do $SCRATCH_DIR $API_KEY $i
