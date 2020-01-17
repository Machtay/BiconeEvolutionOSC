
########  XF output conversion code (C)  ###########################################################################################
#
#
#         1. Converts .uan file from XF into a readable .dat file that Arasim can take in.
#
#
####################################################################################################################################
#variables
NPOP=$1
WorkingDir=$2

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

cd "$WorkingDir"
cd Antenna_Performance_Metric

## Run AraSim -- feeds the plots into AraSim 
## First we convert the plots from XF into AraSim readable files, then we move them to AraSim directory and execute AraSim


python XFintoARA.py $NPOP 

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/
