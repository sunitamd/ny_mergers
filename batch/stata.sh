#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=END
#SBATCH --mail-user=alanzchen@nyu.edu
#SBATCH --output=$scratch/slurm/slurm_%j.out


module load stata/15

RUNDIR=$scratch/slurm/run-${SLURM_JOB_ID/.*}
mkdir -p $RUNDIR


# Command line  arguments
export STATA_DO="stata -b do \"$1\""
shift
export $ARGS=$@


# Run job
$STATA_DO $ARGS
echo "$STATA_DO $ARGS"
