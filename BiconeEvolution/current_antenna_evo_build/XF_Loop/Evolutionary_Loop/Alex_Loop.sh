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

RunName='biconeTest'                ## Replace when needed
TotalGens=15   			## number of generations (after initial) to run through
NPOP=7     			## number of individuals per generation; please keep this value below 99
FREQ=60 			## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)

#########################################################################################################################






########  Initialization of variables  ###################################################################################

WorkingDir=`pwd`
echo $WorkingDir
XmacrosDir=$WorkingDir/../Xmacros
XFexec='/usr/local/remcom/bin/' ##Location of XFUI executable
XFProj="/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/${RunName}/${RunName}.xf"  ## Provide path to the project directory in the 'single quotes'
AraSimExec="/datapool/projects/ara/AraSim/trunk/"  ##Location of AraSim.exe


## Lines for output.xmacro files ##
line1='var query = new ResultQuery();'
line2='///////////////////////Get Theta and Phi Gain///////////////'
line3='query.projectId = App.getActiveProject().getProjectDirectory();'
#line4='query.simulationId = '  ## append 6-digit simulation ID number; for example "000001";
## cat skeleton here
#lastline='FarZoneUtils.exportToUANFile(thdata,thphase,phdata,phphase,inputpower,"/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/' ##append simulation ID number followed by .uan");


############################################################################################################################
# Make the run name directory
mkdir $WorkingDir/Run_Outputs/$RunName
# Create the run's date and save it in the run's directory
python dateMaker.py
mv "runDate.txt" "$WorkingDir/Run_Outputs/$RunName/"



#start editing here (why not above?) -- I think we just wanted to comment below out
#we want to export text from here to the text file Alex.txt
#doing the following should work: echo '(all the text)' > /datapool/projects/ara/AraSim/trunk
#for now, this isn't quite working - at a certain point it sort of let's go of 
#the text it's supposed to be block commenting

#potential idea- head and tail copying; see next line
#https://askubuntu.com/questions/950432/how-can-i-copy-the-content-of-a-text-file-and-paste-it-to-another-starting-at-a
#I can use head -n (int) (this file) > (destination file) to send the first (int) lines
#similarly, I can use tail instead of head to send the last (int) lines

#so we'd want something like below:
# head -n 500 Alex_Loop.sh > /datapool/projects/ara/AraSim/trunk/Alex.txt
#to only copy the stuff above, change 500 to 78
#we might want to copy what we have in that file to here and change it here to send back

#I can select a range using head -n (H) file.name | tail -(T) > destination.file
#this takes the last T lines of the first H lines from the file
#looks like lines 89 to 161 (maybe add an extra on each end); run the next line
head -n 162 Alex_Loop.sh | tail -72 > /users/PAS0654/machtay1/AraSim/test_setup.txt 


:<<'EOF'

##############################Stuff we want for the Alex.txt file#################

///////////////////
NFOUR=1024
EXPONENT=21
NNU=10000 // number of neutrino events
NNU_PASSED=5 // number of neutrino events that are allowed to pass the trigger
ONLY_PASSED_EVENTS=0 // 0 (default): AraSim throws NNU events whether or not they pass; 1: AraSim throws events until the number of events that pass the trigger is equal to NNU_PASSED (WARNING: may cause long run times if reasonable values are not chosen)
NOISE_WAVEFORM_GENERATE_MODE=0 // generate new noise waveforms for each events
NOISE_EVENTS=16 // number of pure noise waveforms
TRIG_ANALYSIS_MODE=1 // 0 = signal + noise, 1 = signal only, 2 = noise only
DETECTOR=1 // ARA stations 1 to 7
ANTENNA_MODE=0
NOFZ=1
core_x=10000
core_y=10000
TIMESTEP=5.E-10 // value for 2GHz actual station value
TRIG_WINDOW=1.E-7 // 100ns which is actual testbed trig window
POWERTHRESHOLD=-6.06 // 100Hz global trig rate for 3 out of 16 ARA stations
//DATA_BIN_SIZE=8192
POSNU_RADIUS=3000
V_MIMIC_MODE=0 // 0 : global trig is located center of readout windows
DATA_SAVE_MODE=0 // 2 : don't save any waveform informations at all
DATA_LIKE_OUTPUT=0 // 0 : don't save any waveform information to eventTree
BORE_HOLE_ANTENNA_LAYOUT=0
SECONDARIES=0
// below settings are available for only TestBed mode (DETECTOR=3 case)
TRIG_ONLY_BH_ON=0
CALPULSER_ON=0
USE_MANUAL_GAINOFFSET=0
USE_TESTBED_RFCM_ON=0
NOISE_TEMP_MODE=0
TRIG_THRES_MODE=0
READGEOM=0 // reads geometry information from the sqlite file or not (0 : don't read)
// new variables
//INTERACTION_MODE=0 // pickunbiased mode!
//taumodes=1
//BH_ANT_SEP_DIST_ON=0 // default 0 : use constant borehole antenna distance. 1 : use separate antenna distance. use z_btw01, z_btw12, ... in ARA_N_info.txt or ARA37_info.txt
TRIG_MODE=0 // use vpol, hpol separated trigger mode. by default N_TRIG_V=3, N_TRIG_H=3. You can change this values
//N_TRIG_V=4
//N_TRIG_H=4
number_of_stations=1
core_x=10000
core_y=10000
///////////////////
//DATA_SAVE_MODE=2
// Settings for Arbitrary event generation
//EVENT_TYPE=10 // arbitrary event type
//INTERACTION_MODE=2 // pick exact location using settings below
//POSNU_THETA=1.7 // interaction location elevation angle in radians
//POSNU_THETA=-0.5 // interaction location elevation angle in radians
//POSNU_PHI=0 // interaction location azimuthal angle in radians
//POSNU_R=1000 // interaction location radius in meters
//INTERACTION_MODE=4 // pick interaction location within cylindrical volume above the ice
//PICK_ABOVE_HEIGHT=3000.
// Settings for Station A2-like simulation
//DETECTOR=4
//DETECTOR_STATION=2
//DATA_LIKE_OUTPUT=1
///////////////////////// Other Alternate Settings //////////////////
//POSNU_RADIUS=5000
//RAYSOL_RANGE=7000
//SELECT_FLAVOR=1
//NU_NUBAR_SELECT_MODE=1
//SELECT_CURRENT=1 //default 2: get from ratios in Ghandi etal paper, 0: nc, 1: cc
//NNU_THIS_THETA=1
//NNU_THETA=0.785
//NNU_D_THETA=0.0873
//NNU_D_THETA=0.0
//NOISE_EVENTS=16
//NOISE_EVENTS=1
//NOISE=0
//NOISE_TEMP_MODE=1
//APPLY_NOISE_FIGURE=1
//ALL_ANT_V_ON=1

##############################End stuff we want for the Alex.txt file#############


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


./roulette_algorithm.exe start $NPOP


cp generationDNA.csv Run_Outputs/$RunName/0_generationDNA.csv





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




# First, remove the old .xmacro files
cd $XmacrosDir
rm output.xmacro
rm simulation_PEC.xmacro


: 'Cat the relevant information onto output.xmacro for each antenna in a generation. 
The zeroStr will be used to paste the appropriate number of zeros into the simulation ID'
zeroStr=('00000' '0000' '000' '00' '0')
# OLD WAY
#for freq in `seq 1 $FREQ`
#do
#	for indiv in `seq 1 $NPOP`
#	do
		# Print the first 3 lines onto the .xmacro file
#	    	echo "$line1" >> output.xmacro
#	    	echo "$line2" >> output.xmacro
#	    	echo "$line3" >> output.xmacro
#
#		: 'To print the fourth line, we need to calculate the individual
#		simulation ID. Remember that each antenna has $FREQ simulations/'
#		indivFreqSimID=$(($indiv + $NPOP * ($freq - 1)))
#		: 'We want the ID to be 6 digits, with zeros in front. 
#		So, we choose the zero array element that, when pasted next 
#		to the simulation ID, adds up to 6 digits'
#		zeroInd=$((${#indivFreqSimID} - 1))
#		
#		echo "$line4\"${zeroStr[$zeroInd]}${indivFreqSimID}\""';'>> output.xmacro	    	
#	    	cat outputmacroskeleton.txt >> output.xmacro
#		cat $lastline >> output.xmacro
#	done
#done

# NEW WAY
echo "$line1" >> output.xmacro
echo "$line2" >> output.xmacro
echo "$line3" >> output.xmacro
echo "var NPOP = $NPOP;" >> output.xmacro
cat outputmacroskeleton.txt >> output.xmacro

# Building the simulation_PEC.xmacro is a bit simpler. Cat the first skeleton, add the gridsize from datasize.txt, and cat the second skeleton

echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
cat simulationPECmacroskeleton.txt >> simulation_PEC.xmacro 
cd "$WorkingDir"

cd $XmacrosDir 
cat simulationPECmacroskeleton2.txt >> simulation_PEC.xmacro
#echo 'for(var i = 0;i < '"$NPOP"';i++){' >> $XmacrosDir/dipole_PEC.xmacro
#cat dipolePECmacroskeleton3.txt >> $XmacrosDir/dipole_PEC.xmacro


echo
echo
echo 'Opening XF user interface...'
echo '*** Please remember to save the project with the same name as RunName! ***'
echo
echo '1. Import and run simulation_PEC.xmacro'
echo '2. Import and run output.xmacro'
echo '3. Close XF'
#read -p "Press any key to continue... " -n1 -s

cd $XFexec
./xfui $XFProj --execute-macro-script=/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/simulation_PEC.xmacro || true
./xfui $XFProj --execute-macro-script=/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/output.xmacro || true




########  XF output conversion code (C)  ###############################################################
#
#
#         1. Converts .uan file from XF into a readable .dat file that Arasim can take in.
#
#
########################################################################################################




echo
#read -p "Press any key to continue... " -n1 -s
echo
echo "Resuming..."
echo

cd "$WorkingDir"
cd Antenna_Performance_Metric

## Run AraSim -- feeds the plots into AraSim 
## First we convert the plots from XF into AraSim readable files, then we move them to AraSim directory and execute AraSim

python XFintoARA.py $NPOP




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



for i in `seq 1 $NPOP`
do
	mv evol_antenna_model_$i.dat "$AraSimExec"
done



#read -p "Press any key to continue... " -n1 -s
echo "Resuming..."
echo

cd "$AraSimExec"

for i in `seq 1 $NPOP`
do
        #Why is this called ARA_bicone6in_output.txt. Rename this.
	cp evol_antenna_model_$i.dat a_$i.txt
	./AraSim setup.txt $i outputs/ a_$i> $WorkingDir/Antenna_Performance_Metric/AraOut_$i.txt &
	rm outputs/*.root
done

wait


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


cd "$WorkingDir"/Antenna_Performance_Metric
mv *.root "$WorkingDir/Run_Outputs/$RunName/RootFilesGen0/"

#Check what this first line does. It can probably be taken out.
InputFiles=
for i in `seq 1 $NPOP`
do
    InputFiles="${InputFiles}AraOut_${i}.txt "
done

./fitnessFunction.exe $NPOP $InputFiles
cp fitnessScores.csv "$WorkingDir"/Run_Outputs/$RunName/0_fitnessScores.csv
mv fitnessScores.csv "$WorkingDir"

cd "$WorkingDir"
rm runData.csv
python gensData.py 0
cd Antenna_Performance_Metric
python LRPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName 1 $NPOP
cd ..
# Note: gensData.py floats around in the main dir until it is moved to 
# Antenna_Performance_Metric

for i in `seq 1 $NPOP`
do
    #Remove if plotting software doesnt need
    #cp data/$i.uan ${i}uan.csv
    cp Antenna_Performance_Metric/$i.uan "$WorkingDir"/Run_Outputs/$RunName/0_${i}.uan
done



########  Plotting (F)  ################################################################################################
#
#
#      1. Plots in 3D and 2D of current and all previous generation's scores. Saves the 2D plots. Extracts data from $RunName folder in all of the i_generationDNA.csv files. Plots to same directory.
#
#
########################################################################################################################




# Old plotting softwares:


#./uanCleaner.exe
#python plotLR.py
#python PlotGainPat.py
#python gainPlot.py

#mv Length.png "$WorkingDir"/Run_Outputs/$RunName/plots
#mv Radius.png "$WorkingDir"/Run_Outputs/$RunName/plots

#for ((i=1; i<=NPOP; i++))
#do
#    mv ${i}gainPlot.png Run_Outputs/$RunName/plots/0_${i}gainPlot.png
#    mv ${i}uan.csv "$WorkingDir"/Run_Outputs/$RunName/plots/0_${i}uan.csv
#done


# Current Plotting Software

cd Antenna_Performance_Metric
# Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
python FScorePlot.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $NPOP
cd "$WorkingDir"















########  Loop (G)  ######################################################################################
#
#
#     1. Does steps A-F for each generation
#
#
#
#
###########################################################################################################



for gen in `seq 1 $TotalGens`
do                                 
# used for fixed number of generations
#gen=0; while [ `cat highfive.txt` -eq 0 ]; do (( gen++ ))                 
# use for runs until convergence
	read -p "Starting generation ${gen}. Press any key to continue... " -n1 -s
    cd $XmacrosDir
    rm simulation_PEC.xmacro
    cd "$WorkingDir"
    ./roulette_algorithm.exe cont $NPOP

    cp generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv

    cd $XmacrosDir
    echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
    cat simulationPECmacroskeleton.txt >> simulation_PEC.xmacro
    cd "$WorkingDir"
    cd $XmacrosDir
    cat simulationPECmacroskeleton2.txt >> simulation_PEC.xmacro
    #echo 'for(var i = 0;i < '"$NPOP"';i++){' >> $XmacrosDir/dipole_PEC.xmacro
    #cat dipolePECmacroskeleton3.txt >> $XmacrosDir/dipole_PEC.xmacro
    
    cd $XFexec
    cd $XFProj
    rm -rf Simulations
    echo
    echo
    echo 'Opening XF user interface...'
    echo 
    echo '1. Run simulation_PEC.xmacro (no new modifications needed)'
    echo "2. Run output.xmacro (no new modifications needed)"
    echo '3. Close XF'
    #read -p "Press any key to continue... " -n1 -s
    echo
    ## Run XF -- opens graphical interface. From there, dipole_PEC.xmacro needs to be run, then all output(...).xmacro scripts (1-5) shsould be run.
    cd $XFexec
    ./xfui $XFProj --execute-macro-script=/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/simulation_PEC.xmacro || true
./xfui $XFProj --execute-macro-script=/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/output.xmacro || true
    
    #read -p "Press any key to continue... " -n1 -s
    echo "Resuming..."
    echo


    ## Run AraSim -- feeds the plots into AraSim 
	## First we convert the plots from XF into AraSim readable files, then we move them to AraSim directory and execute AraSim

	cd "$WorkingDir"
	cd Antenna_Performance_Metric

	python XFintoARA.py $NPOP
	for i in `seq 1 $NPOP`
	do
		mv evol_antenna_model_$i.dat "$AraSimExec"
	done

	cd "$AraSimExec"

	for i in `seq 1 $NPOP`
	do
		mv evol_antenna_model_$i.dat a_$i.txt
		./AraSim setup.txt $i outputs/ a_$i > $WorkingDir/Antenna_Performance_Metric/AraOut_$i.txt &
		rm outputs/*.root
	done

	wait

	InputFiles=
	for ((i=1; i<=NPOP; i++))
	do
		InputFiles="${InputFiles}AraOut_${i}.txt "
	done

	cd "$WorkingDir"/Antenna_Performance_Metric
	mv *.root "$WorkingDir/Run_Outputs/$RunName/RootFilesGen${gen}/"
	
    ./fitnessFunction.exe $NPOP $InputFiles
    mv fitnessScores.csv "$WorkingDir"
    cd "$WorkingDir"


    # Reorganize and extract useful data
    cd "$WorkingDir"
    python gensData.py $gen
    cd Antenna_Performance_Metric
    python LRPlot.py "$WorkingDir" "$WorkingDir"/Run_Outputs/$RunName $[gen+1] $NPOP
    cd ..
    

    for i in `seq 1 $NPOP`
    do
    # Gens data used to create a .csv file for the uan file for gain plotting
    # cp Antenna_Performance_Metric/$i.uan ${i}uan.csv
	cp Antenna_Performance_Metric/$i.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${i}.uan
    done

    mv fitnessScores.csv Run_Outputs/$RunName/${gen}_fitnessScores.csv

    # Current Plotting Software
    cd Antenna_Performance_Metric
   

    # Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
    python FScorePlot.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $NPOP
    cd "$WorkingDir"


done




#cd "$WorkingDir"
#./roulette_algorithm.exe --cont
cp generationDNA.csv "$WorkingDir"/Run_Outputs/$RunName/FinalGenerationParameters.csv
mv runData.csv Antenna_Performance_Metric

echo
echo 'Done!'



EOF
