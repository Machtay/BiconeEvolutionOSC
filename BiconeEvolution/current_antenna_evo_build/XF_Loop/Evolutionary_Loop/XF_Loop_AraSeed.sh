!/bin/bash
#This is a functionized version of the loop using savestates that also has seeded versions of AraSim
#Evolutionary loop for antennas.
#Last update: January 15, 2020 by Cade Sbrocco
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

RunName='Patton_1_24_20'           ## Replace when needed
TotalGens=2  			## number of generations (after initial) to run through
NPOP=1			## number of individuals per generation; please keep this value below 99
Seeds=2                         ## This is how many versions of AraSim will run for each individual
FREQ=60 			## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)
NNT=100                        ##Number of Neutrinos Thrown in AraSim   
exp=18				#exponent of the energy for the neutrinos in AraSim
ScaleFactor=1.0                   ##ScaleFactor used when punishing fitness scores of antennae larger than holes used in fitnessFunction_ARA.cpp
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

##Check if saveState exists and if not then create one at 0,0
saveStateFile="${RunName}.savestate.txt"

echo "${saveStateFile}"
cd saveStates
if ! [ -f "${saveStateFile}" ]; then
    echo "saveState does not exist. Making one and starting new run"
	
    echo 0 > $RunName.savestate.txt
    echo 0 >> $RunName.savestate.txt
    echo 1 >> $RunName.savestate.txt
fi
cd ..

## Read current state of loop ##
line=1
while read p; do
	if [ $line -eq 1 ]
	then
		InitialGen=$p
		echo "${p}"

	fi
	
	if [ $line -eq 2 ]
	then
		state=$p
		echo "${p}"
		line=2
	fi
	
	if [ $line -eq 3 ]
	then
	        indiv=$p
		echo "${p}"
		line=3
	fi

	if [ $line -eq 1 ]
	then
		line=2

	fi

	if [ $line -eq 2 ]
	then
		line=3

	fi
	
	
done <saveStates/$saveStateFile
## THE LOOP ##
echo "${state}"
#InitialGen=${gen}

for gen in `seq $InitialGen $TotalGens`
do
	read -p "Starting generation ${gen} at location ${state}. Press any key to continue... " -n1 -s
	

	## This only runs if starting new run ##
	if [[ $gen -eq 0 && $state -eq 0 ]]
	then
		# Make the run name directory
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName
		mkdir -m777 $WorkingDir/Run_Outputs/$RunName/AraSimFlags
		# Create the run's date and save it in the run's directory
		python dateMaker.py
		mv "runDate.txt" "$WorkingDir/Run_Outputs/$RunName/" -f
		state=1
	fi




	## Part A ##
	if [ $state -eq 1 ]
	then
	        ./Part_A.sh $gen $NPOP $WorkingDir $RunName
		state=2
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		#./Part_A.sh $gen $NPOP $WorkingDir $RunName


	fi

#########Commenting the below out--we shouldn't be looping this way######################
	## Part B ##
	#We need to change this so that instead of having the loop inside of Part B we loop over Part B
	if [ $state -eq 2 ]
	then
		for i in `seq $indiv $NPOP`
		do

	        	./Part_B_Prototype.sh $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj $i
			if [ $i -ne $NPOP ]
			then
				state=2
			else
				state=3
			       
			fi
			./SaveState_Prototype.sh $gen $state $RunName $i
			#./Part_B.sh $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj
		done
	fi
###############################End commenting out##########################################
	

#####################Substituting this in for the above commented out stuff################
#	if [ $state -eq 2 ]
#	then
#		./Part_B_Prototype.sh $gen $NPOP $WorkingDir $RunName $XmacrosDir $XFProj 1
#		state=3
#		./SaveState_Prototype.sh $gen $state $RunName $indiv
#	fi


#######################################End substitution###############################

	## Part C ##
	if [ $state -eq 3 ]
	then
	        #$indiv=1
	        ./Part_C.sh $NPOP $WorkingDir
		state=4

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		#./Part_C.sh $NPOP $WorkingDir


	fi

	## Part D1 ##
	if [ $state -eq 4 ]
	then
	        #The reason here why Part_D1.sh is run after teh save state is changed is because all Part_D1 does is submit AraSim jobs which are their own jobs and run on their own time
		#We need to make a new AraSim job script which takes the runname as a flag 
		state=5

		./SaveState_Prototype.sh $gen $state $RunName $indiv
		./Part_D1_AraSeed.sh $gen $NPOP $WorkingDir $AraSimExec $exp $NNT $RunName $Seeds

	fi

	## Part D2 ##
	if [ $state -eq 5 ]
	then
	        ./Part_D2_AraSeed.sh $gen $NPOP $WorkingDir $RunName $Seeds
		state=6
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		#./Part_D2.sh $gen $NPOP $WorkingDir $RunName


	fi

	## Part E ##
	if [ $state -eq 6 ]
	then
	        ./Part_E.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $AntennaRadii $indiv
		state=7
		./SaveState_Prototype.sh $gen $state $RunName $indiv
		#./Part_E.sh $gen $NPOP $WorkingDir $RunName $ScaleFactor $AntennaRadii

	fi

	## Part F ##
	if [ $state -eq 7 ]
	then
	        ./Part_F.sh $NPOP $WorkingDir $RunName
		state=1
		./SaveState_Prototype.sh $gen $state $RunName $indiv

		#./Part_F.sh $NPOP $WorkingDir $RunName


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


