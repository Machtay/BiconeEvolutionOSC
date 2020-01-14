import numpy as np		
import matplotlib.pyplot as plt	
import os			
import argparse

# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations] and the NPOP
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
g = parser.parse_args()

Veff = []
Err_plus = []
Err_minus = []
VeffArray = []
Err_plusArray = []
Err_minusArray = []

tempVeff = []
tempErr_plus = []
tempErr_minus = []

Veff_ARA = []
Err_plus_ARA = []
Err_minus_ARA = []
Veff_ARA_Ref = []

for ind in range(1,g.NPOP+1):
    for gen in range(g.numGens):
        filename = "/AraOut_{}_{}.txt".format(gen, ind)
#        print(filename)
 #       print(g.source)
        #fp = open(g.source + "/" + filename, "rw+")
        fp = open(g.source + filename)
        #line = fp.readlines()
        #print(line)
        for line in fp:
            if "test Veff(ice) : " in line:
                Veff = float(line.split()[3])
            elif "And Veff(water eq.) error plus :" in line:
                    Err_plus = float(line.split()[6])
                    Err_minus = float(line.split()[11])
#            line = fp.readline()
        tempVeff.append(Veff)
        tempErr_plus.append(Err_plus)
        tempErr_minus.append(Err_minus)
    VeffArray.append(tempVeff)
    Err_plusArray.append(tempErr_plus)
    Err_minusArray.append(tempErr_minus)
    tempVeff = []
    tempErr_plus = []
    tempErr_minus = []
fp.close()

filenameActual = "/AraOut_ActualBicone.txt"
fpActual = open(g.source + filenameActual)
for line in fpActual:
 #   print(line)
    if "test Veff(ice) : " in line:
        Veff_ARA = float(line.split()[3])
    elif "And Veff(water eq.) error plus :" in line:
        Err_plus_ARA = float(line.split()[6])
        Err_minus_ARA = float(line.split()[11])
#    line = fpActual.readline()
fpActual.close()

genAxis = np.linspace(0,g.numGens-1,g.numGens)
#print(genAxis)
#print(Veff_ARA)

Veff_ARA_Ref = Veff_ARA * np.ones(len(genAxis))
plt.plot(genAxis, Veff_ARA_Ref, label = "ARA Reference", linestyle= '--', color = 'k')

for ind in range(g.NPOP):
    LabelName = "Individual {}".format(ind+1)
    plt.errorbar(genAxis, VeffArray[ind], yerr = [Err_minusArray[ind],Err_plusArray[ind]], label = LabelName)
  
plt.xlabel('Generation')
plt.ylabel('Length [cm]')
plt.title("Veff over Generations (0 - {})".format(int(g.numGens-1)))
plt.legend()
plt.savefig(g.destination + "/Veff_plot.png")
#plt.show()
# was commented out to prevent graph from popping up and block=False replaced it along with plt.pause
# the pause functions for how many seconds to wait until it closes graph
plt.show(block=False)
plt.pause(15)
