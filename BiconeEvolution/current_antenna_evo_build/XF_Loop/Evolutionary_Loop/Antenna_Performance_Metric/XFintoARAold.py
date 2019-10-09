#!/bin/python

#Translate XF output into readable AraSim input. Jorge Torres, Nov 2017.
#You need to have all your XF output files in the same foler, with the standard name dipole_freq_MHz.uan
# Written by: David Liu
# Converted to atbitrary NPOP by: Suren Gourapura

import math
import itertools
import sys
import shutil
import numpy
import glob
import argparse # This allows the reading of arguments from the terminal or from the bash script

# NPOP is taken by argparse from the user or bash script; we set this up first.
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
g = parser.parse_args()

first_file = 1 #Should always be 1 for antenna stuff
NPOP = g.NPOP #Just call g.NPOP, NPOP for convenience
frequency_number = 60 #This should just be the number of frequencies we simulated
freq_counter = 0 # Keeps track of which frequency we're on
# frequency list in MHz - hardcoded to match the AraSim frequencies, AraSim will core dump if frequencies or their spacing are changed
frequency_values = [83.33, 100.00, 116.67, 133.33, 150.00, 167.67, 183.34, 200.00, 216.67, 233.34, 250.00, 266.67, 283.34, 300.00, 316.67, 333.33, 350.00, 367.67, 383.34, 400.01, 416.67, 433.33, 450.01, 467.67, 483.34, 500.01, 516.68, 533.34, 550.01, 567.68, 583.34, 600.01, 616.68, 633.34, 650.01, 667.68, 683.34, 700.01, 716.67, 733.34, 750.01, 767.68, 783.34, 800.01, 816.68, 833.35, 850.02, 866.68, 883.35, 900.02, 916.68, 933.35, 950.02, 966.68, 983.35, 1000.00, 1016.70, 1033.40, 1050.00, 1066.70]
loop_number = 1 #How many times have we gone through this loop?
file_number = first_file #which file are we on?
individual_counter = 1 #which individual's frequencies are being recorded?
input_file = "pattern.uan"#+str(n) #Name of the input file
output_file ="evol_antenna_model_1.dat"
patt = open(output_file, "w+")

# I just wanna say that the way I did this was really ghetto, but it was the best way I could think of
# without rewriting basically everything.
# - David

for loop_number in range(NPOP*frequency_number):
	indivNum = int(file_number/(frequency_number+0.0))+1 # This is the individual antenna we are on
	input_file = "/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/"+"("+str(indivNum)+")"+str(file_number-(indivNum-1) * frequency_num)+".uan" #+str(n) #Name of the input file. Need to modify with your directory path
	print(input_file) #Prints the name of the input file
	patt.write("freq : "+str(frequency_values[freq_counter])+" MHz"+'\n'+"SWR : 1.965000"+'\n')#Header for each iteration
	freq_counter+=1
	if(file_number==first_file):
		patt.write(" Theta "+'\t'+" Phi "+'\t'+" Gain(dB)     "+'\t'+"   Gain     "+'\t'+"    Phase(deg)"+'\n')#Header
	with open(input_file, 'r') as f:
		for _ in xrange(17): 
			next(f) #Skips the first 17 lines of the XF file, which are useless for us.
		for line in f:
			line = line.strip() #Identify lines.
			columns = line.split() #Identify columns.
#Here I identify the veriables with their respective columns in the XF file
			theta = int(columns[0])
			phi = int(columns[1]) 
			dB_t_gain = float(columns[2])
			t_gain = math.pow(10,dB_t_gain/10)
			dB_p_gain = float(columns[3])
			p_gain = math.pow(10,dB_p_gain/10)
			t_phase = float(columns[4])
			p_phase = float(columns[5])
			#  gain_tot = float(t_gain+p_gain)
			patt.write(str(theta)+' \t '+str(phi)+' \t '+str(dB_t_gain)+'     \t   '+str(t_gain)+'     \t    '+str(t_phase)+'\n') #Write data on the new file
	file_number+=1
	if(file_number>(NPOP*frequency_number) and individual_counter<NPOP):
		file_number=individual_counter + 1
		individual_counter+=1
		freq_counter = 0
		patt.close()
		output_file ="evol_antenna_model_"+str(individual_counter)+".dat"
		patt = open(output_file, "w+")

#Close everything
f.close()
patt.close()
        
 
