RunName='Julie_12_2'           ## Replace when needed                                                                 
TotalGens=6                     ## number of generations (after initial) to run through                                
WorkingDir=`pwd` 
NPOP=2                          ## number of individuals per generation; please keep this value below 99                
FREQ=60                         ## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop\
                                                                                                                       
NNT=10000                          ##Number of Neutrinos Thrown in AraSim                                               
ScaleFactor=1.0                   ##ScaleFactor used when punishing fitness scores of antennae larger than holes used i\

AntennaRadii=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Lo\
op/Run_Outputs/${RunName}



#cd "$WorkingDir"/Antenna_Performance_Metric
       
        
 #       for i in `seq 1 $NPOP`
  #      do
   #         InputFiles="${InputFiles}AraOut_${i}.txt "
    #    done


     #   ./fitnessFunction.exe $NPOP $ScaleFactor $WorkingDir/generationDNA.csv $InputFiles
#cd "$WorkingDir"
# rm runData.csv
#python gensData.py 1
cd Antenna_Performance_Metric
#python LRPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName 1 $NPOP
python LRTPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName 2 $NPOP  
