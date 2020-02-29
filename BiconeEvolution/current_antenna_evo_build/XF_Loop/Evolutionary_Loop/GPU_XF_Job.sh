## We want to submit XF as a job to a GPU
#PBS -A PAS0654
#PBS -l walltime=2:00:00
#PBS -l nodes=1:ppn=28:gpus=default
#PBS -o /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/
#PBS -e /fs/project/PAS0654/BiconeEvolutionOSC/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/scriptEOFiles/

# varaibles
WorkingDir=$3
RunName=$4
XmacrosDir=$5
XFProj=$6
m=$7


## make sure we're in the right directory
cd $WorkingDir


if [ $m -lt 10 ]
then
	cd $XFProj/Simulations/00000$m/Run0001/
	#xfsolver -t=35 -v #--use-xstream #xstream
	xfsolver --use-xstream=true --xstream-use-number=1 --num-threads=1 -v
elif [ $m -ge 10 ] && [ $m -lt 100]
then
	cd $XFProj/Simulations/0000$m/Run0001/
	#xfsolver -t=35 -v #--use-xstream #xstream
	xfsolver --use-xstream=true --xstream-use-number=1 --num-threads=1 -v
elif [ $m -ge 100 ]
	cd $XFProj/Simulations/000$m/Run0001/
	#xfsolver -t=35 -v #--use-xstream #xstream
	xfsolver --use-xstream=true --xstream-use-number=1 --num-threads=1 -v

fi

