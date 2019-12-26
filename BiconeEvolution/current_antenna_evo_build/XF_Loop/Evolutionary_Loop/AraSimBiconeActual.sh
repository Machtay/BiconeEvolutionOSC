#In order to run AraSim in Parallel we will have to call a job for it by calling a script
#PBS -A PAS0654
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=4
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#cd into the AraSim directory
cd /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/
#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have
#qsub -v num=$i

echo /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/ARA_bicone6in_output.txt
./AraSim setup.txt outputs/ 1 /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/ARA_bicone6in_output.txt > /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/AraOut_ActualBicone.txt

cd /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/AraSimFlags/
echo ARABicone > ARABicone.txt
