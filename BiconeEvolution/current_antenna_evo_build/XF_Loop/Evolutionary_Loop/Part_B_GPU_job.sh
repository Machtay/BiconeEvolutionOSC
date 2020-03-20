
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
indiv=$1
gen=$2
NPOP=$3
WorkingDir=$4
RunName=$5
XmacrosDir=$6
XFProj=$7
GeoFactor=$8

module load cuda


#chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

## Lines for output.xmacro files ##
line1='var query = new ResultQuery();'
line2='///////////////////////Get Theta and Phi Gain///////////////'
line3='query.projectId = App.getActiveProject().getProjectDirectory();'
freqlist="8333 10000 11667 13333 15000 16767 18334 20000 21667 23334 25000 26667 28334 30000 31667 33333 35000 36767 38334 40001 41667 43333 45001 46767 48334 50001 51668 53334 55001 56768 58334 60001 61668 63334 65001 66768 68334 70001 71667 73334 75001 76768 78334 80001 81668 83335 85002 86668 88335 90002 91668 93335 95002 96668 98335 100000 101670 103340 105000 106670"
#The list of frequencies, scaled up by 100 to avoid float operation errors in bash
#we have to wait to change the frequencies since we're going to be changing them as we append them to simulation_PEC.xmacro (which is removed below before being remade)

#get rid of the simulation_PEC.xmacro that already exists
rm simulation_PEC.xmacro

#echo "var m = $j;" >> simulation_PEC.xmacro
echo "var NPOP = $NPOP;" >> simulation_PEC.xmacro
#now we can write the frequencies to simulation_PEC.xmacro
#now let's change our frequencies by the scale factor (and then back down by 100)

#first we need to declare the variable for the frequency lists
#the below commands write the frequency scale factor and "var freq =" to simulation_PEC.xmacro
echo "//Factor of $GeoFactor frequency" >> simulation_PEC.xmacro
echo "var freq " | tr "\n" "=" >> simulation_PEC.xmacro

#here's how we change our frequencies and put them in simulation_PEC.xmacro
for i in $freqlist; #iterating through all values in our list
do
	if [ $i -eq 8333 ] #we need to start with a bracket
	then
		echo " " | tr "\n" "[" >> simulation_PEC.xmacro
		#whenever we append to a file, it adds what we append to a new line at the end
		#the tr command replaces the new line (\n) with a bracket (there's a space at the start; that will separate the = from the list by a space)
	fi

	#now we're ready to start appending our new frequencies
	#we start by changing our frequencies by the scale factor; we'll call this variable k
	k=$(($GeoFactor*$i))
	#now we'll append our frequencies
	#the frequencies we're appending are divided by 100, since the original list was scaled up by 100
	#IT'S IMPORTANT TO DO IT THIS WAY
	#we can't just set k=$((scale*$i/100)) because of how bash handles float operations
	#instead, we need to echo it with the | bc command to allow float quotients
	if [ $i -ne 106670 ] 
	then
		echo "scale=2 ; $k/100 " | bc | tr "\n" "," >> simulation_PEC.xmacro 
		echo "" | tr "\n" " " >> simulation_PEC.xmacro #gives spaces between commas and numbers
	#we have to be careful! we want commas between numbers, but not after our last number
	#hence why we replace \n with , above, but with "]" below
	else 
		echo "scale=2 ; $k/100 " | bc | tr "\n" "]" >> simulation_PEC.xmacro 
		echo " " >> simulation_PEC.xmacro
	fi
	
done

###



###

if [[ $gen -eq 0 && $i -eq 1 ]]
then
	echo "App.saveCurrentProjectAs(\"$WorkingDir/Run_Outputs/$RunName/$RunName\");" >> simulation_PEC.xmacro
fi

#we cat things into the simulation_PEC.xmacro file, so we can just echo the list to it before catting other files

cat simulationPECmacroskeleton_prototype_GPU.txt >> simulation_PEC.xmacro 
cd $WorkingDir

cat simulationPECmacroskeleton2_prototype_GPU.txt >> simulation_PEC.xmacro

#we need to change the gridsize by the same factor as the antenna size
#the gridsize in the macro skeleton is currently set to 0.1
#we want to make it scale in line with our scalefactor

initial_gridsize=0.1
new_gridsize=$(bc <<< "scale=6; $initial_gridsize/$GeoFactor")
sed -i "s/var gridSize = 0.1;/var gridSize = $new_gridsize;/" simulation_PEC.xmacro

sed -i "s+fileDirectory+${WorkingDir}+" simulation_PEC.xmacro
#the above sed command substitute for hardcoded words and don't use a dummy file
#that's ok, since we're doing this after the simulation_PEC.xmacro file has been written; it gets deleted and rewritten from the macroskeletons, so it's ok for us to make changes this way here (as opposed to the way we do it for arasim in parts D1 and D2)

if [[ $gen -ne 0 && $i -eq 1 ]]
then
	cd $XFProj
	rm -rf Simulations
fi

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

xfdtd $XFProj --execute-macro-script=$XmacrosDir/simulation_PEC.xmacro --splash=false || true &



## Here is where we need to submit the GPU job

qsub -l nodes=1:ppn=28:gpus=1:default -l walltime=1:00:00 -A PAS0654 -v $WorkingDir,$RunName,$XmacrosDir $XFProj,$NPOP,$indiv GPU_XF_Job.sh 


cd $WorkingDir/Run_Outputs/$RunName/GPUFlags/
	
#we need to check if the file at the end of the GPU job has been made before continuing the loop
rm -f $WorkingDir/Run_Outputs/$RunName/GPUFlags/*
flag_files=0
while [ "$flag_files" != "1" ]
do

	echo "Waiting for GPU jobs to finished..."
	sleep 60
	flag_files=$(ls -l --files-type | grep -v '/$' | wc -l)

done

echo "Done!"

# First, remove the old .xmacro files
#when do that, we end up making the files only readable; we should just overwrite them
#alternatively, we can just set them as rwe when the script makes them
cd $XmacrosDir
 
rm output.xmacro

# NEW WAY
#(using the single > over >> overwrites instead of appending)
echo "$line1" > output.xmacro
echo "$line2" >> output.xmacro
echo "$line3" >> output.xmacro
#echo "var m = $i;" >> output.xmacro
echo "var NPOP = $NPOP;" >> output.xmacro
cat outputmacroskeleton_prototype_GPU.txt >> output.xmacro

sed -i "s+fileDirectory+${WorkingDir}+" output.xmacro
# When we use the sed command, anything can be the delimiter between each of the arguments; usually, we use /, but since there are / in the thing we are trying to substitute in ($WorkingDir), we need to use a different delimiter that doesn't appear there

xfdtd $XFProj --execute-macro-script=$XmacrosDir/output.xmacro || true --splash=false

cd $WorkingDir/Antenna_Performance_Metric
for freq in `seq 1 60`
do
  #Remove if plotting software doesnt need
  #cp data/$i.uan ${i}uan.csv
	mv ${m}_${freq}.uan "$WorkingDir"/Run_Outputs/$RunName/${gen}_${m}_${freq}.uan
done



#chmod -R 777 /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/

