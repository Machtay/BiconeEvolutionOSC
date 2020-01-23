#In order to run AraSim in Parallel we will have to call a job for it by calling a script
#PBS -A PAS0654
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=4
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/

#variables
#num=$1
#WorkingDir=$2
#RunName=$3

#cd into the AraSim directory
cd /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/

#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have 
#qsub -v num=$i
echo a_$num.txt
chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/outputs/
./AraSim setup.txt $num outputs/ a_$num.txt > /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/AraOut_$num.txt

cd $WorkingDir/Run_Outputs/$RunName/AraSimFlags
echo $num > $num.txt
