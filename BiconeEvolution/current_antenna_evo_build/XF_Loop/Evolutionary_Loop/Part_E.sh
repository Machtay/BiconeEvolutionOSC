
########  Fitness Score Generation (E)  ######################################################################################################### 
#
#
#      1. Takes AraSim data and cocatenates each file name into one string that is then used to generate fitness scores 
#
#      2. Then gensData.py extracts useful information from generationDNA.csv and fitnessScores.csv, and writes to maxFitnessScores.csv and runData.csv
#
#      3. Copies each .uan file from the Antenna_Performance_Metric folder and moves to Run_Outputs/$RunName folder
#
#
#################################################################################################################################################### 

#variables
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
ScaleFactor=$5
AntennaRadii=$6

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

cd Antenna_Performance_Metric

echo 'Starting fitness function calculating portion...'

mv *.root "$WorkingDir/Run_Outputs/$RunName/RootFilesGen${gen}/"

#Check what this first line does. It can probably be taken out.
#InputFiles="FitnessFunction.exe $NPOP"
for i in `seq 1 $NPOP`
do
    InputFiles="${InputFiles}AraOut_${i}.txt "
done

./fitnessFunction.exe $NPOP $ScaleFactor $AntennaRadii/generationDNA.csv $InputFiles #Here's where we add the flags for the generation
cp fitnessScores.csv "$WorkingDir"/Run_Outputs/$RunName/${gen}_fitnessScores.csv
mv fitnessScores.csv "$WorkingDir"

cd "$WorkingDir"
rm runData.csv
python gensData.py $gen
cd Antenna_Performance_Metric
next_gen=$((gen+1))
#python LRPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName $[gen+1] $NPOP
python LRTPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName $next_gen $NPOP
cd ..
# Note: gensData.py floats around in the main dir until it is moved to 
# Antenna_Performance_Metric

for i in `seq 1 $NPOP`
do
    for freq in `seq 1 60`
    do
    #Remove if plotting software doesnt need
    #cp data/$i.uan ${i}uan.csv
	cp Antenna_Performance_Metric/${i}_${freq}.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${i}_${freq}.uan
    done
done

echo 'Congrats on getting a fitness score!'

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/
