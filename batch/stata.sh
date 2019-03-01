#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=END
#SBATCH --mail-user=alanzchen@nyu.edu


module load stata/15


PROJDIR=/gpfs/home/$USER/ny_mergers


# Command line  arguments
export STATA_DO="stata -b do \"$PROJDIR/$1\""
shift
export ARGS=$@


# Run program
echo "$STATA_DO $ARGS"
$STATA_DO $ARGS
