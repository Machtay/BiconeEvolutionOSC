import numpy as np		
import matplotlib.pyplot as plt	
import os			
import argparse

# We need to grab the three arguments from the bash script or user. These arguments in order are [the name of the source folder of the fitness scores], [the name of the destination folder for the plots], and [the number of generations]
parser = argparse.ArgumentParser()
parser.add_argument("source", help="Name of source folder from home directory", type=str)
parser.add_argument("destination", help="Name of destination folder from home directory", type=str)
parser.add_argument("numGens", help="Number of generations the code is running for", type=int)
parser.add_argument("NPOP", help="Number of individuals in a population", type=int)
g = parser.parse_args()

"""
code from Justin (written in c++)
filepath = "AraOut_4.txt"
with open(filepath) as fp:
    line = fp.readline()
    while line:
        if "Veff(water eq.) : " in line:
            Veff1 = float(line.split()[4])
            Veff2 = float(line.split()[6])
        elif "And Veff(water eq.) error plus :" in line:
            Err1 = float(line.split()[6])
            Err2 = float(line.split()[11])
        line = fp.readline()
"""
filename = "AraOut_4.txt"
fp = open(g.source + "/" + filename, "rw+")
line = fp.readlines()
while line:
	if "test Veff(ice) : " in line:
		Veff = float(line.split()[4])
	elif "And Veff(water eq.) error plus :" in line:
		Err_plus = float(line.split()[7])
		Err_minus = float(line.split()[12])
	line = fp.readline()

plt.figure(figsize = (10, 6))

plt.xaxis("Generation")
plt.yaxis("Veff")
plt.errorbar(numGens, Veff, yerr = [Err_plus, Err_minus])

