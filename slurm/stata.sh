#!/bin/bash
#SBATCH --partition=cpu_dev
#SBATCH --time=4:00:00
#SBATCH --mem=32GB
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --output=/gpfs/scratch/%u/slurm/slurm_%j.out

# Load modules
module purge
module load stata/15

# Setup repo directory
REPO=/gpfs/home/$USER/ny_mergers

# Command line arguments
export STATA_DO="stata -q do \"$REPO/$1\""
shift
export ARGS=$@

# Run program
echo "$STATA_DO $ARGS"
$STATA_DO $ARGS
