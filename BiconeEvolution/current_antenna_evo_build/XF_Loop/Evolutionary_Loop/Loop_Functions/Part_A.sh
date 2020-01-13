
########    Execute our initial genetic algorithm (A)    #############################################################################
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
#######################################################################################################################################
#variables
gen = $1
NPOP = $2
WorkingDir = $3
RunName = $4

cd "$WorkingDir"
if [ $gen -eq 0]
then

	./roulette_algorithm.exe start $NPOP

else
	./roulette_algorithm.exe cont $NPOP
fi

cp generationDNA.csv Run_Outputs/$RunName/${gen}_generationDNA.csv


