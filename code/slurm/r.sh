#!/bin/bash
#SBATCH --partition=cpu_dev
#SBATCH --time=4:00:00
#SBATCH --mem=32GB
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --output=logs/slurm/slurm_%j.out

# Load modules
module purge
module load r/3.5.1

# cd to repo directory
REPO=/gpfs/home/$USER/ny_mergers
cd $REPO

# Command line arguments
export R_SOURCE="Rscript \"$REPO/$1\""
shift
export ARGS=$@

# Run program
echo "$R_SOURCE $ARGS"
$R_SOURCE $ARGS
