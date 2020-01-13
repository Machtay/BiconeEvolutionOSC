

#variables
gen = $1
NPOP = $2
WorkingDir = $3
RunName = $4

rm AraSimFlags/*

#file check delay goes here

wait

cd "$WorkingDir"/Antenna_Performance_Metric
#saving AraSim outputs so they are not overwritten.
for i in `seq 1 $NPOP`
do

    cp AraOut_${i}.txt /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/AraOut_${gen}_${i}.txt

done

if [$gen -eq 0]
then
	cp /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/AraOut_ActualBicone.txt /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/AraOut_ActualBicone.txt
fi

#Plotting software for Veff(for each individual) vs Generation
#python Veff_Plotting.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $TotalGens $NPOP

