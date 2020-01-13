#!/bin/bash
#Evolutionary loop for antennas.
#Last update: December 23, 2019 by Julie Rolla
#OSU GENETIS Team
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles

################################################################################################################################################
#
#
# The way this loop is written now is so it does steps A-F for the first generation before looping through the rest of the generations and doing the the same steps for each generation. 
# One thing that we should think about improving is putting the first generation into the same loop barring any initialization steps that may need to be adjusted.
#
# The code is optimised for a dynamic choice of NPOP UP TO fitnessFunction.exe. From there on, it has not been checked.
#
#
################################################################################################################################################





####### LINES TO CHECK OVER WHEN STARTING A NEW RUN ###############################################################################################

RunName='Patton_1_10_20(2)'           ## Replace when needed
TotalGens=2   			## number of generations (after initial) to run through
NPOP=10 				## number of individuals per generation; please keep this value below 99
FREQ=60 			## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
NNT=1000                          ##Number of Neutrinos Thrown in AraSim   
exp=21				#exponent of the energy for the neutrinos in AraSim
ScaleFactor=1.0                   ##ScaleFactor used when punishing fitness scores of antennae larger than holes used in fitnessFunctoin_ARA.cpp
#####################################################################################################################################################

########  Initialization of variables  ###############################################################################################################
BEOSC=/fs/project/PAS0654/BiconeEvolutionOSC
WorkingDir=`pwd` #this is /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop
echo $WorkingDir
XmacrosDir=$WorkingDir/../Xmacros
XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf  ## Provide path to the project directory in the 'single quotes'
echo $XFProj
AraSimExec="/fs/project/PAS0654/BiconeEvolutionOSC/AraSim"  ##Location of AraSim.exe
AntennaRadii=$WorkingDir
##Source araenv.sh for AraSim libraries##
source /fs/project/PAS0654/BiconeEvolutionOSC/araenv.sh
#####################################################################################################################################################

## Read current state of loop ##
InitialGen = 
state = 1

## THE LOOP ##

for gen in `seq $InitialGen $TotalGens`
do
	read -p "Starting generation ${gen} at location ${state}. Press any key to continue... " -n1 -s
	
	## This only runs if starting new run ##
	if [$gen -eq 0 && $state -eq 0]
	then
		# Make the run name directory
		mkdir -m 777 $WorkingDir/Run_Outputs/$RunName
		# Create the run's date and save it in the run's directory
		python dateMaker.py
		mv "runDate.txt" "$WorkingDir/Run_Outputs/$RunName/" -f
	fi

	$state = 1

	if [$state -eq 1]
	then
		./Part_A.sh $gen $NPOP $WorkingDir $RunName
		$state = 2
	fi

	## Part B ##
	if [$state -eq 2]
	then
		./Part_A.sh $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj
		$state = 3
	fi

	## Part C ##
	if [$state -eq 3]
	then
		./Part_C.sh $NPOP $WorkingDir
		$state = 4
	fi

	## Part D1 ##
	if [$state -eq 4]
	then
		./Part_D1.sh $gen $NPOP $WorkingDir $RunName $AraSimExec $exp
		$state = 5
	fi

	## Part D2 ##
	if [$state -eq 5]
	then
		./Part_D2.sh $gen $NPOP $WorkingDir $RunName
		$state = 6
	fi

	## Part E ##
	if [$state -eq 6]
	then
		./Part_E.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $AntennaRadii
		$state = 7
	fi

	## Part F ##
	if [$state -eq 7]
	then
		./Part_F.sh $NPOP $WorkingDir $RunName
		$state = 1
	fi
done

cp generationDNA.csv "$WorkingDir"/Run_Outputs/$RunName/FinalGenerationParameters.csv
mv runData.csv Antenna_Performance_Metric

#########################################################################################################################
###Moving the Veff AraSim output for the actual ARA bicone into the $RunName directory so this data isn't lost in     ###
###the next time we start a run. Note that we don't move it earlier since (1) our plotting software and fitness score ###
###calculator expect it where it is created in "$WorkingDir"/Antenna_Performance_Metric, and (2) we are only creating ###
###it once on gen 0 so it's not written over in the looping process.                                                  ###
########################################################################################################################
cd "$WorkingDir"
mv AraOut_ActualBicone.txt "$WorkingDir"/Run_Outputs/$RunName/AraOut_ActualBicone.txt
 
echo
echo 'Done!'





	












	
