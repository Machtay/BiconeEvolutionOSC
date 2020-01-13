#This is going to be a cleaned up version of XF_Loop.sh 
#The goal is to make the loop shorter by using functions

#Note: DO NOT RUN THIS YET

#!/bin/bash
#Evolutionary loop for antennas.
#Last update: 6 Jan 2019 by Suren Gourapura
#OSU GENETIS Team

####################################################################################################################
#
#
# The way this loop is written now is so it does steps A-F for the first generation before looping through the rest of the generations and doing the the same steps for each generation. One thing that we should think about improving is putting the first generation into the same loop barring any initialization steps that may need to be adjusted.
#
# The code is optimised for a dynamic choice of NPOP UP TO fitnessFunction.exe. From there on, it has not been checked.
#
#
####################################################################################################################





####### LINES TO CHECK OVER WHEN STARTING A NEW RUN ###################################################################

RunName='Machtay_Runs/ALEXM4'                ## Replace when needed
TotalGens=2   			## number of generations (after initial) to run through
NPOP=2 				## number of individuals per generation; please keep this value below 99
FREQ=60 			## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)

#########################################################################################################################



########  Initialization of variables  ###################################################################################
BEOSC=/fs/project/PAS0654/BiconeEvolutionOSC
WorkingDir=`pwd` #this is /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop
echo $WorkingDir
XmacrosDir=$WorkingDir/../Xmacros
XFexec='/usr/local/remcom/bin/' ##Location of XFUI executable
XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf  ## Provide path to the project directory in the 'single quotes'
AraSimExec="/fs/project/PAS0654/AraSim/AraSim/"  ##Location of AraSim.exe
#we have to export the above variables
export BEOSC WorkingDir XmacrosDir XFexec XFProj AraSimExec

## Lines for output.xmacro files ##
line1='var query = new ResultQuery();'
line2='///////////////////////Get Theta and Phi Gain///////////////'
line3='query.projectId = App.getActiveProject().getProjectDirectory();'
#we have to export the above variables
export line1 line2 line3
#line4='query.simulationId = '  ## append 6-digit simulation ID number; for example "000001";
## cat skeleton here
#lastline='FarZoneUtils.exportToUANFile(thdata,thphase,phdata,phphase,inputpower,"/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/' ##append simulation ID number followed by .uan");


############################################################################################################################
# Make the run name directory
mkdir -m 777 $WorkingDir/Run_Outputs/$RunName
#chmod 777 $WorkingDir/Run_Outputs
# Create the run's date and save it in the run's directory
python dateMaker.py
mv "runDate.txt" "$WorkingDir/Run_Outputs/$RunName/" -f



#If I put the following command here, it should initialize the AraSim input file without needing user input
#head -n 162 Alex_Loop.sh | tail -72 > /fs/project/PAS0654/AraSim/test_setup.txt



########    Execute our initial genetic algorithm (A)     #################################################
#
#
#   This part of the loop  ::
#
#      1. Runs genetic algorithm
#
#
#      2. Moves GA outputs and renames the .csv file so it isn't overwritten 
#
#
#
#
###########################################################################################################

#we have to set gen = 0 so that our if statements work
gen=0

export gen


./Part_A.sh



########    XF Simulation Software (B)     ##############################################################
#
#
#     1. Prepares output.xmacro with generic parameters such as :: 
#             I. Antenna type
#             II. Population number
#             III. Grid size
#
#
#     2. Prepares simulation_PEC.xmacro with information such as:
#             I. Each generation antenna parameters
#
#
#     3. Runs XF and loads XF with both xmacros. 
#
#
##########################################################################################################


./Part_B.sh


########  XF output conversion code (C)  ###############################################################
#
#
#         1. Converts .uan file from XF into a readable .dat file that Arasim can take in.
#
#
########################################################################################################



./Part_C.sh

########  AraSim Execution (D)  ######################################################################################
#
#
#       1. Moves each .dat file individually into a folder that AraSim can access
#
#       2. For each individual ::
#           I. Move its .dat file into one .txt file that arasim can use    (Possibly combine this step with step 1)
#           II. Run Arasim for that text file
#           III. Moves the AraSim output into the Antenna_Performance_Metric folder
#
#
######################################################################################################################

./Part_D.sh


########  Fitness Score Generation (E)  #############################################################################
#
#
#      1. Takes AraSim data and cocatenates each file name into one string that is then used to generate fitness scores 
#
#      2. Then gensData.py extracts useful information from generationDNA.csv and fitnessScores.csv, and writes to maxFitnessScores.csv and runData.csv
#
#      3. Copies each .uan file from the Antenna_Performance_Metric folder and moves to Run_Outputs/$RunName folder
#
#
########################################################################################################################

./Part_E.sh


########  Plotting (F)  ################################################################################################
#
#
#      1. Plots in 3D and 2D of current and all previous generation's scores. Saves the 2D plots. Extracts data from $RunName folder in all of the i_generationDNA.csv files. Plots to same directory.
#
#
########################################################################################################################

./Part_F.sh 


########  Loop (G)  ######################################################################################
#
#
#     1. Does steps A-F for each generation
#     2. This is accomplished here by looping over each of the above parts with gen > 0
#
#
#
###########################################################################################################


for gen in `seq 1 $TotalGens`
export gen
do
	./Part_A.sh
	./Part_B.sh
	./Part_C.sh
	./Part_D.sh
	./Part_E.sh
	./Part_F.sh
done


