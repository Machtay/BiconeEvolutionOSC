#File: PlotLR.py
#Author: Julie Rolla
#Created on: 2/8

import matplotlib
matplotlib.use('Agg')

import csv
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import numpy as np

individuals = 5

with open('gensData.csv') as file:
    readCSV=csv.reader(file)
    
    FirstColumn = []
    SecondColumn = []
    
    Lengths = []
    Radi = []
    
    for row in readCSV:
       
        first=row[0]
        second=row[1]
        
        FirstColumn.append(first)
        SecondColumn.append(second)
       
    TotalRows = len(FirstColumn)
    TotalGenerations = TotalRows/individuals
    print(TotalRows)
    print(TotalGenerations)
    
    xvalues = np.linspace(1, TotalRows, TotalRows)
    genarray = 5*np.linspace(1,TotalGenerations, TotalGenerations)
    
    plt.plot([1,TotalRows], [0.25, 0.25], 'k:', label="300 MHz, 1/4 wavelength goal")
    plt.plot( xvalues, SecondColumn)
    plt.xticks(xvalues)
    plt.xlabel('Individuals')
    plt.ylabel('Length (m)')
    for i in range(0,int(TotalGenerations)):
        plt.axvline(int(genarray[i]), linestyle='--', color='grey')
        i=i+1
    plt.show()
    plt.savefig('Length.png')
    
    plt.figure()
    plt.plot( xvalues, FirstColumn)
    plt.xticks(xvalues)
    plt.xlabel('Individuals')
    plt.ylabel('Radius (m)')
    for i in range(0,int(TotalGenerations)):
        plt.axvline(int(genarray[i]), linestyle='--', color='grey')
        i=i+1
    plt.show()
    plt.savefig('Radius.png')   
    
    
