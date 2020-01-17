
########    XF Simulation Software (B)     ########################################################################################## 
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
###################################################################################################################################### 
# varaibles
gen=$1
NPOP=$2
WorkingDir=$3
RunName=$4
XmacrosDir=$5
XFProj=$6

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

## Lines for output.xmacro files ##
line1='var query = new ResultQuery();'
line2='///////////////////////Get Theta and Phi Gain///////////////'
line3='query.projectId = App.getActiveProject().getProjectDirectory();'


# First, remove the old .xmacro files
#when do that, we end up making the files only readable; we should just overwrite them
#alternatively, we can just set them as rwe when the script makes them
cd $XmacrosDir
 
rm output.xmacro
rm simulation_PEC.xmacro


# NEW WAY
#(using the single > over >> overwrites instead of appending)
echo "$line1" > output.xmacro
echo "$line2" >> output.xmacro
echo "$line3" >> output.xmacro
echo "var NPOP = $NPOP;" >> output.xmacro
cat outputmacroskeleton.txt >> output.xmacro

# Building the simulation_PEC.xmacro is a bit simpler. Cat the first skeleton, add the gridsize from datasize.txt, and cat the second skeleton

echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
if [ $gen -eq 0 ]
then
	echo "App.saveCurrentProjectAs(\"/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro
fi

cat simulationPECmacroskeleton.txt >> simulation_PEC.xmacro 
cd "$WorkingDir"

cd $XmacrosDir 

#The above line needs to be fixed(Says who? when? Julie 12/25/19)

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
xfdtd $XFProj --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/simulation_PEC.xmacro || true


for i in `seq 1 $NPOP`
do
	cd $XFProj/Simulations/00000$i/Run0001/
	xfsolver -t=35 -v
done

cd $WorkingDir
	
xfdtd $XFProj --execute-macro-script=/fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Xmacros/output.xmacro || true

chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

