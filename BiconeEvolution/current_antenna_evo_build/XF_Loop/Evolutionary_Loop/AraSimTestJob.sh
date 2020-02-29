#In order to run AraSim in Parallel we will have to call a job for it by calling a script
#PBS -A PAS0654
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=1
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/

#cd into the AraSim directory
cd /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/

#this is the command in the XF script although I don't know if we can pass in variables from that script
#into this one like i and WorkingDir
#if in the job call we have 
#qsub -v number=$i -v dir=$WorkingDir
./AraSim setup.txt $number outputs/ a_$number > $dir/Antenna_Preformance_Metric/AraOut_$number.txt & rm outputs/*.root
