# Written by: 	Suren Gourapura
# Written on: 	February 25, 2019
# Purpose: 	Plot the length and radius from each generation and the ones before. Give a 2D plot to the users and save it to g.destinations

import numpy as np		# for data manipulation, storage
import matplotlib.pyplot as plt	# For plotting
import os			# exclusively for rstrip()
import argparse			# for getting the user's arguments from terminal
# May be needed: from mpl_toolkits.mplot3d import Axes3D 

#---------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES


# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations]
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder, g.destination
PlotName = "LRPlot2D"


#----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE


def plotLR(g, yL, yR, numGens, dest):
	# Plot the result using matplotlib
	fig = plt.figure(figsize=(20, 6))
	axL = fig.add_subplot(1,2,1)
	axL.scatter(g, yL, color='g', marker='o')
	axL.set_xlabel('Generation')
	axL.set_ylabel('Length')
	axL.set_title('Length over Generations (0-'+str(numGens)+')')

	axR = fig.add_subplot(1,2,2)
	axR.scatter(g, yR, color='g', marker='o')
	axR.set_xlabel('Generation')
	axR.set_ylabel('Radius')
	axR.set_title('Radius over Generations (0-'+str(numGens)+')')

	plt.savefig(dest+"/"+PlotName)
	plt.show()


#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE 


# READ DATA (runData.csv)

# runData.csv contains every antenna's DNA and fitness score for all generations. Format for each individual is radius, length, angle, fitness score (I call these characteristics).

# First, grab each line of the runData.csv as one element in a 1D list.
runDataRaw =[]
with open(g.source+"/runData.csv", "r") as runDataFile:
	runDataRaw=runDataFile.readlines()

# This list has each element terminating with '\n', so we use rstrip to remove '\n' from each string
for i in range(len(runDataRaw)):
	runDataRaw[i] = runDataRaw[i].rstrip()

# Now, we want to store this data in a 2D numpy array. As we'll see, this is a fairly complex process! First, make a new 2D list that contains only the numbers.
runDataRawOnlyNumb =[]
for i in range(len(runDataRaw)):
	# We want to skip the empty line and the 'Generation :' line
	if i%(g.NPOP+2) != 0 and i%(g.NPOP+2) != 1:
		# The split function takes '1.122650,19.905200,0.504576,32.500000' -> ['1.122650', '19.905200', '0.504576', '32.500000'] , which makes the new list 2D
		runDataRawOnlyNumb.append(runDataRaw[i].split(',')) 

# Now convert it to a numpy array and roll it up
runData = np.array(runDataRawOnlyNumb).astype(np.float)
runData = runData.reshape((g.numGens, g.NPOP,4))
# Finally, the data is in a useable shape: (generation, individual, characteristic)


# PLOT DATA

# Create the x array. Need to duplicate the generation number for each individual in pop
'''
For g.numGens=4, g.NPOP=10, generations should look like:
[ 0.  0.  0.  0.  0.  0.  0.  0.  0.  0.  1.  1.  1.  1.  1.  1.  1.  1.
  1.  1.  2.  2.  2.  2.  2.  2.  2.  2.  2.  2.  3.  3.  3.  3.  3.  3.
  3.  3.  3.  3.]
'''
generations = np.zeros((runData.shape[0]*runData.shape[1]))
for gen in range(g.numGens):
	for indiv in range(g.NPOP):
		generations[gen*g.NPOP + indiv] = gen

# Create the yL array.
lengths = runData[:,:, 1].flatten()

# Create the yR array
radii = runData[:,:, 0].flatten()

# Plot!
plotLR(generations, lengths, radii, g.numGens, g.destination)





# python3 LRPlot.py "/home/suren/Desktop/OSU Research/LRPlotWork" "/home/suren/Desktop/OSU Research/LRPlotWork" 10 4



