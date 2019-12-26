#-*- coding: utf-8 -*-
"""
Created on Thu Aug 15 14:54:22 2019

@author: Evelyn
"""

# Written by: Suren Gourapura
# Written on: April 12 2019
# Purpose: Plot the fitness scores from each generation and the ones before. Give a 3D and 2D plot to the users and save the 2D plot to g.destinations

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
Plot2D = "FScorePlot2D"
Plot3D = "FScorePlot3D"

#----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE----------DEFINITIONS HERE

def AverageData(genVec, fVec):
     avgGenVec = np.arange(g.numGens)
     fMat = fVec.reshape((g.numGens, int(len(fVec)/g.numGens)))
     return avgGenVec, fMat.mean(1)


def plot3D(x1, x2, y):
     # Plot the result using matplotlib
     fig = plt.figure()
     ax = fig.add_subplot(111, projection='3d')
     ax.scatter(x1, x2, y, color='g', marker='o')
     ax.set_xlabel('Generation')
     ax.set_ylabel('Individuals')
     ax.set_zlabel('Fitness Score')
     ax.set_title('Fitness Scores over the Generations')
     plt.savefig(g.destination+'/'+Plot3D)
     plt.show()

def plot2D(genVec, fVec):
    # Split data for each generation
    avgGenVec, avgFVec = AverageData(genVec, fVec)

    # Plot the result using matplotlib
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.scatter(genVec, fVec, color='green', marker='o')
    ax.scatter(avgGenVec, avgFVec, color='red', marker='o')
    ax.plot(avgGenVec, avgFVec, 'r-')
    ax.set_xlabel('Generation')
    ax.set_ylabel('Fitness Score')
    ax.set_title('Fitness Scores over the Generations 2D')
    plt.savefig(g.destination+'/'+Plot2D)
    plt.show()



#----------STARTS HERE----------STARTS HERE----------STARTS HERE----------STARTS HERE

# This array will store for each generation the fitness scores
fScores = []

for gen in range(g.numGens):
    # Read in each generation individually
    fScorei= np.genfromtxt(g.source + '/'+str(gen)+'_fitnessScores.csv', delimiter=',')

    # Trim the first two elements, since those are words
    # Then insert this into the fScores array
    np.append(fScores, fScorei[2:])
    # Convert fScores to a numpy array (The best way to store data in python)
    fScores = np.array(fScores)
    
    # We need to format this into the three things that plot3D needs
    # Add 1 to get the list to start at 1, not zero
    Gen = np.zeros(fScores.shape[0]*fScores.shape[1])
    Indiv = np.zeros(fScores.shape[0]*fScores.shape[1])
    fScorePlot = np.zeros(fScores.shape[0]*fScores.shape[1])

    # This data needs to be put in scatter form, so 3 arrays with numGen*numIndiv number of elements
    for i in range(fScores.shape[0]):
        for j in range(fScores.shape[1]):
            Gen[j+i*fScores.shape[1]]=i
            Indiv[j+i*fScores.shape[1]]=j
            fScorePlot[j+i*fScores.shape[1]] = fScores[i,j]

plot3D(Gen, Indiv, fScorePlot)

plot2D(Gen, fScorePlot)
