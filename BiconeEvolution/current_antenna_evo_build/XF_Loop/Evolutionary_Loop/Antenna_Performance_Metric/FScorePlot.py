import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import argparse
 
#---------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES----------GLOBAL VARIABLES

# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations]
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory (no end dash)", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for (no end dash)", type=int)
g = parser.parse_args()

# The name of the plot that will be put into the destination folder, g.destination
Plot2DName = "/FScorePlot2D.png"
Plot3DName = "/FScorePlot3D.png"

#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE
fileReadTemp = []
fScoresGen = []
fScoresInd = []

for gen in range(g.numGens+1):
    filename = "/{}_fitnessScores.csv".format(gen)
    fileReadTemp = np.genfromtxt(g.source + filename, delimiter=',')
    fScoresGen.append(fileReadTemp[2:])

fScoresInd = np.transpose(fScoresGen)
NPOP = len(fScoresInd)

genAxis = np.linspace(0,g.numGens,g.numGens+1)

plt.figure()
for ind in range(NPOP):
    LabelName = "Individual {}".format(ind+1)
    plt.plot(genAxis, fScoresInd[ind], label = LabelName)
  
plt.xlabel('Generation')
plt.ylabel('Fitness Score')
plt.title("Fitness Score over Generations (0 - {})".format(int(g.numGens-1)))
plt.legend()
plt.savefig(g.destination + Plot2DName)
#plt.show()
# was commented out to prevent graph from popping up and block=False replaced it along with plt.pause
# the pause functions for how many seconds to wait until it closes graph
plt.show(block=False)
plt.pause(2)

plt.figure()
indAxis = np.linspace(1,NPOP,NPOP)
genAxis, indAxis = np.meshgrid(genAxis, indAxis)
ax = plt.axes(projection='3d')
ax.plot_surface(genAxis, indAxis, fScoresInd, rstride=1, cstride=1, cmap='viridis', edgecolor='none')
ax.set_title('3D Fitness Score over Generations');
ax.set_xlabel('Generation')
ax.set_ylabel('Individual')
ax.set_zlabel('Fitness Score')
plt.savefig(g.destination + Plot3DName)
#plt.show()
# was commented out to prevent graph from popping up and block=False replaced it along with plt.pause
# the pause functions for how many seconds to wait until it closes graph
plt.show(block=False)
plt.pause(2)
