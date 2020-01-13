
########  AraSim Execution (D)  ################################################################################################################## 
#
#
#       1. Moves each .dat file individually into a folder that AraSim can access while changing to a .txt file that AraSim can use. (can we just have the .py program make this output a .txt?)
#
#       2. For each individual ::
#           I. Run Arasim for that text file
#           III. Moves the AraSim output into the Antenna_Performance_Metric folder
#
#
################################################################################################################################################## 

#variables
gen = $1
NPOP = $2
WorkingDir = $3
AraSimExec = $4
exp = $5


for i in `seq 1 $NPOP`
do
	mv evol_antenna_model_$i.dat $AraSimExec/a_$i.txt
done



#read -p "Press any key to continue... " -n1 -s
echo "Resuming..."
echo

cd "$AraSimExec"

for i in `seq 1 $NPOP`
do

##############################################################################################################################################################################                             
###This next line replaces the number of neutrinos thrown in our setup.txt AraSim file with what ever number you assigned NNT at the top of this program. setup_dummy.txt  ###                             
###is a copy of setup.txt that has NNU=num_nnu (NNU is the number of neutrinos thrown. This line finds every instance of num_nnu in setup_dummy.txt and replaces it with   ###                             
###$NNT (the number you assigned NNT above). It then pipes this information into setup.txt (and overwrites the last setup.txt file allowing the number of neutrinos thrown ###                             
###to be as variable changed at the top of this script instead of manually changing it in setup.txt each time. Command works the following way:                            ###                             
###sed "s/oldword/newwordReplacingOldword/" path/to/filewiththisword.txt > path/to/fileWeAreOverwriting.txt                                                                ###                             
##############################################################################################################################################################################     
        sed -e "s/num_nnu/$NNT/" -e "s/n_exp/$exp/" /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/setup_dummy.txt > /fs/project/PAS0654/BiconeEvolutionOSC/AraSim/setup.txt
	#We will want to call a job here to do what this AraSim call is doing so it can run in parallel
	cd $WorkingDir
	qsub -v num=$i AraSimCall.sh

	rm outputs/*.root
	
done

#This submits the job for the actual ARA bicone. Veff depends on Energy and we need this to run once per run to compare it to. 
if [$gen -eq 0]
then
	qsub AraSimBiconeActual.sh 
fi

cd $WorkingDir/AraSimFlags/
nFiles=0

totPop = $NPOP
if [$gen -eq 0]
then
	$totPop = $NPOP + 1
fi

while [ "$nFiles" != "$totPop" ]
do
	echo "Waiting for AraSim jobs to finish..."
	sleep 60
	nFiles=$(ls -1 --file-type | grep -v '/$' | wc -l)

#	echo "Waiting for AraSim jobs to finish..."
#	sleep 60
#	shopt -s nullglobs
#	numfiles=(*)
#	numfiles=${#numfiles[@]}
#	nFiles=$numfiles
#	#nFiles=$(ls -1 --file-type | grep -v '/$' | wc -l)
done

