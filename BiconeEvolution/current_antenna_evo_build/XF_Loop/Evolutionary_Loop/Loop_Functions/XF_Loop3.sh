#!/bin/bash
#Evolutionary loop for antennas.
#Last update: 6 Jan 2019 by Suren Gourapura
#OSU GENETIS Team
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loops/Evolutionary_Loop/scriptEOFiles
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

RunName='ALEXM5'                ## Replace when needed
TotalGens=2   			## number of generations (after initial) to run through
NPOP=2 				## number of individuals per generation; please keep this value below 99
FREQ=60 			## frequencies being iterated over in XF (Currectly only affects the output.xmacro loop)

#########################################################################################################################






########  Initialization of variables  ###################################################################################

WorkingDir=`pwd` #this is /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop
echo $WorkingDir
XmacrosDir=$WorkingDir/../Xmacros
XFProj=$WorkingDir/Run_Outputs/${RunName}/${RunName}.xf  ## Provide path to the project directory in the 'single quotes'
echo $XFProj
AraSimExec="/fs/project/PAS0654/BiconeEvolutionOSC/AraSim/"  ##Location of AraSim.exe


## Lines for output.xmacro files ##
line1='var query = new ResultQuery();'
line2='///////////////////////Get Theta and Phi Gain///////////////'
line3='query.projectId = App.getActiveProject().getProjectDirectory();'
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
#when do that, we end up making the files only readable; we should just overwrite them
#alternatively, we can just set them as rwe when the script makes them
cd $XmacrosDir

#I'm commenting out the next two lines. They are written to below (around lines 154-170)
#If we keep them this way then the files have restricted permissions
 
rm output.xmacro
rm simulation_PEC.xmacro


: 'Cat the relevant information onto output.xmacro for each antenna in a generation. 
The zeroStr will be used to paste the appropriate number of zeros into the simulation ID'
zeroStr=('00000' '0000' '000' '00' '0')


# NEW WAY
#(using the single > over >> overwrites instead of appending)
echo "$line1" > output.xmacro
echo "$line2" >> output.xmacro
echo "$line3" >> output.xmacro
echo "var NPOP = $NPOP;" >> output.xmacro
cat outputmacroskeleton.txt >> output.xmacro

# Building the simulation_PEC.xmacro is a bit simpler. Cat the first skeleton, add the gridsize from datasize.txt, and cat the second skeleton



echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
echo "App.saveCurrentProjectAs(\"/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro

cat simulationPECmacroskeleton.txt >> simulation_PEC.xmacro 
cd "$WorkingDir"


cd $XmacrosDir 


#The above line needs to be fixed

cat simulationPECmacroskeleton2.txt >> simulation_PEC.xmacro


echo
echo
echo 'Opening XF user interface...'
echo '*** Please remember to save the project with the same name as RunName! ***'
echo
echo '1. Import and run simulation_PEC.xmacro'
echo '2. Import and run output.xmacro'
echo '3. Close XF'
#read -p "Press any key to continue... " -n1 -s

module load xfdtd
xfdtd --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/simulation_PEC.xmacro || true


for i in `seq 1 $NPOP`
do
	cd $XFProj/Simulations/00000$i/Run0001/
	xfsolver -t=35 -v
done

cd $WorkingDir
	
xfdtd $XFProj --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/output.xmacro || true

chmod -R 777 $WorkingDir #We're just gonna put this after at the end of every block


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

chmod -R 777 $WorkingDir

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



	#We will want to call a job here to do what this AraSim call is doing so it can run in parallel
	cd $WorkingDir
	qsub -v number=$i -v dir=$WorkingDir AraSimCall.sh

	rm outputs/*.root
	
done

chmod -R 777 $WorkingDir

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
#InputFiles=
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

#The line above is where I think something is going wrong; a couple lines below there's also a relevant line and I'm not seeing where the files above are input to be changed to i_generation.csv, but 0_generation.csv is definitely being made

chmod -R 777 $WorkingDir

########  Plotting (F)  ################################################################################################
#
#
#      1. Plots in 3D and 2D of current and all previous generation's scores. Saves the 2D plots. Extracts data from $RunName folder in all of the i_generationDNA.csv files. Plots to same directory.
#
#
########################################################################################################################


# Current Plotting Software

cd Antenna_Performance_Metric
# Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
python FScorePlot.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $NPOP
cd "$WorkingDir"


chmod -R 777 $WorkingDir










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
#should the line below be double indented?

	read -p "Starting generation ${gen}. Press any key to continue... " -n1 -s

#Part A
    cd $XmacrosDir
    rm simulation_PEC.xmacro
    cd "$WorkingDir"
    ./roulette_algorithm.exe cont $NPOP

    cp generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv

    chmod -R 777 $WorkingDir

#we can make a function that does this with the flag $gen
#doing this in part A would mean setting $gen=0

#Part B
    cd $XmacrosDir
    #The part below is not in the above part A (at least not here)
    echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
    cat simulationPECmacroskeleton.txt >> simulation_PEC.xmacro
    cd "$WorkingDir"
    cd $XmacrosDir
    cat simulationPECmacroskeleton2.txt >> simulation_PEC.xmacro
    
 
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
	./xfdtd $XFProj --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/simulation_PEC.xmacro || true
	./xfdtd $XFProj --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/output.xmacro || true #|| true
	#curious as to what the double || true in the above line is for
	#it isn't present in the equivalent part above

    chmod -R 777 $WorkingDir

#Part C
    #read -p "Press any key to continue... " -n1 -s
    echo "Resuming..."
    echo


    ## Run AraSim -- feeds the plots into AraSim 
	## First we convert the plots from XF into AraSim readable files, then we move them to AraSim directory and execute AraSim

	cd "$WorkingDir"
	cd Antenna_Performance_Metric

	python XFintoARA.py $NPOP

     chmod -R 777 $WorkingDir
#Part D
	for i in `seq 1 $NPOP`
	do
		mv evol_antenna_model_$i.dat "$AraSimExec"
	done

	cd "$AraSimExec"

	for i in `seq 1 $NPOP`
	do	
        	#Why is this called ARA_bicone6in_output.txt. Rename this.
	        
		cp evol_antenna_model_$i.dat ARA_bicone6in_output.txt
		#Replaced the orignal command with a job call for the same command
	    
		#./AraSim setup.txt $i outputs/ > $WorkingDir/Antenna_Performance_Metric/AraOut_$i.txt &
		#rm outputs/*.root
		cd $WorkingDir
		qsub -v number=$i -v dir=$WorkingDir AraSimCall.sh
	done
	
	chmod -R 777 $WorkingDir

	wait

#Part E
	#InputFiles=
	#commented out in Part E with the comment that it can be taken out
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
#does the above line work? For $[gen+1] ?
    cd ..
    

    for i in `seq 1 $NPOP`
    do
    # Gens data used to create a .csv file for the uan file for gain plotting
    # cp Antenna_Performance_Metric/$i.uan ${i}uan.csv
	cp Antenna_Performance_Metric/$i.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${i}.uan
    done

    mv fitnessScores.csv Run_Outputs/$RunName/${gen}_fitnessScores.csv

    chmod -R 777 $WorkingDir

#Part F
    # Current Plotting Software
    cd Antenna_Performance_Metric
   

    # Format is source directory (where is generationDNA.csv), destination directory (where to put plots), npop
    python FScorePlot.py "$WorkingDir"/Run_Outputs/$RunName "$WorkingDir"/Run_Outputs/$RunName $NPOP
    cd "$WorkingDir"

    chmod -R 777 $WorkingDir

done




#cd "$WorkingDir"
#./roulette_algorithm.exe --cont
cp generationDNA.csv "$WorkingDir"/Run_Outputs/$RunName/FinalGenerationParameters.csv
mv runData.csv Antenna_Performance_Metric

chmod -R 777 $WorkingDir

echo
echo 'Done!'





