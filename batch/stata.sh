#!/bin/bash
#SBATCH --partition=cpu_dev
#SBATCH --time=4:00:00
#SBATCH --mem=32GB
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mail-type=END
#SBATCH --mail-user=alanzchen@nyu.edu
#SBATCH --output=/gpfs/scratch/$USER/slurm/slurm_%j.out

module purge
module load stata/15


PROJDIR=/gpfs/home/$USER/ny_mergers


# Command line  arguments
export STATA_DO="stata -b do \"$PROJDIR/$1\""
shift
export ARGS=$@


# Run program
echo "$STATA_DO $ARGS"
$STATA_DO $ARGS
