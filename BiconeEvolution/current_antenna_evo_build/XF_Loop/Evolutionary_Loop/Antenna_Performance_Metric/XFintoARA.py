'''
Written by: 	Suren Gourapura
Date Written: 	2/21/19
Goal:			Translate XF output into readable AraSim input. Modified from the old 	
			XFintoARA.py from Jorge Torres, Nov 2017.
Comments:		You need to have all your XF output files in the same folder (see uanLoc), with 
			the standard name: "antennaNumber_frequencyNumber.uan". Both of these numbers 
			start counting on 1, not zero. Will output one file (see datLoc) that combines 
			all frequencies, so one dat file per antenna. The dat standard name is: 
			"evol_antenna_model_(i).dat" where (i) is the antenna number starting from 1, 
			not zero.
Code Headers:		.uan header: 	Theta, Phi, Gain Theta (dB), Gain Phi (dB), Phase Theta, Phase Phi
			.dat header:	Theta, Phi, Gain (dB, theta), Gain (theta), Phase (theta)
'''

### IMPORTS ###

# For array storage, reading and writing files, etc.
import numpy as np
# For reading arguments from the terminal or from the bash script
import argparse 

### GLOBALS ###

# Frequency list in MHz
freqVals = [83.33, 100.00, 116.67, 133.33, 150.00, 167.67, 183.34, 200.00, 216.67, 233.34, 250.00, 266.67, 283.34, 300.00, 316.67, 333.33, 350.00, 367.67, 383.34, 400.01, 416.67, 433.33, 450.01, 467.67, 483.34, 500.01, 516.68, 533.34, 550.01, 567.68, 583.34, 600.01, 616.68, 633.34, 650.01, 667.68, 683.34, 700.01, 716.67, 733.34, 750.01, 767.68, 783.34, 800.01, 816.68, 833.35, 850.02, 866.68, 883.35, 900.02, 916.68, 933.35, 950.02, 966.68, 983.35, 1000.00, 1016.70, 1033.40, 1050.00, 1066.70]
numFreq = 60
# Strings used in the .dat file
head1_a = "freq : "
head1_b = " MHz"
head2 = "SWR : 1.965000"
head3 = " Theta     Phi     Gain(dB)     Gain     Phase(deg) "
# .uan file location
#uanLoc = '/home/suren/Desktop/OSU Research/XFintoARAmod/' 
uanLoc = "/users/PAS0654/machtay1/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/"

# .dat file saving location
#datLoc = '/home/suren/Desktop/OSU Research/XFintoARAmod/'
datLoc = uanLoc # currently, we are saving files in the same directory

### DEFINITIONS ###

# Reads the (indivNum)freqNum.uan file
def readFile(indivNum, freqNum):
    n = 37
    m = 73
    uanName = uanLoc+str(indivNum)+"_"+str(freqNum)+".uan"
    f = open(uanName, "r")


    for a in range(17):
        f.readline()
        
    mat = [["0" for x in range(n)] for y in range(m)]
    for i in range(n):
        for j in range(m):
            line = f.readline()
            lineList = line.split(" ");
            lineList[0] = lineList[0] + " " + "\t" + " "
            lineList[1] = lineList[1] + " " + "\t" + " "
            linearGainNum = float(lineList[2])
            linearGainNum = "%.2f" % 10 ** (linearGainNum / 10)
            linearGain = str(linearGainNum) + "     " + "\t" + "    "
            lineList[2] = "%.2f" % float(lineList[2]) + "     " + "\t" + "   "
            lineList[4] = "%.2f" % float(lineList[5])
            lineFinal = lineList[0] + lineList[1] + lineList[2] + linearGain + lineList[4]+"\n"
        
            mat[j][i] = lineFinal
    f.close()        
    return mat

2
### START ###

#0 NPOP is taken by argparse from the user or bash script; we set this up first.
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
g = parser.parse_args()
# We process each antenna individually, to reduce computer memory stress
n = 37
m = 73
for antenna in range(g.NPOP):
    with open("evol_antenna_model_"+str(antenna+1)+".dat", "w+") as datFile:
        for freq in range(numFreq):
            datFile.write(head1_a + str(freqVals[freq])+ head1_b+ '\n')
            datFile.write(head2+ '\n')
            datFile.write(head3+ '\n')
            uanDat = readFile(antenna+1, freq+1)
            for p in range(m-1):
                for q in range(n):
                    datFile.write(uanDat[p][q])
# Done!
