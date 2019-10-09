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
uanLoc = "/home/radio/Documents/BiconeEvolution/current_antenna_evo_build/XF_Loop/Evolutionary_Loop/Antenna_Performance_Metric/"

# .dat file saving location
#datLoc = '/home/suren/Desktop/OSU Research/XFintoARAmod/'
datLoc = uanLoc # currently, we are saving files in the same directory

### DEFINITIONS ###

# Reads the (indivNum)freqNum.uan file
def readFile(indivNum, freqNum):
	uanName = uanLoc+str(indivNum)+"_"+str(freqNum)+".uan"
	uanData = np.loadtxt(uanName, delimiter=' ', skiprows=17)
	"""
	Now, we have all of the data in the file. However, we don't need to give AraSim
	the fourth column, for some reason (ask Jorge or David, they might know). So we
	trim this extra column now to save on used computer memory.
	"""
	trimmedData = np.zeros((uanData.shape[0], 5))
	ind = 0 # keeps track of which index the trimmedData is on
	for i in range(6):
		'''
		if i != 3: # If we are not on the fourth column (counting 1, 2, 3, 4)
			trimmedData[:,ind] = uanData[:,i]
			ind += 1
		'''
		# Move the first three columns over without doing anything to them
		trimmedData[:,0:3] = uanData[:, 0:3]
		# Move over the linear gain column
		trimmedData[:,3] = 10**(uanData[:, 3]/10)
		# Finally move over the last column
		trimmedData[:,4] = uanData[:,4]
	return trimmedData


### START ###

# NPOP is taken by argparse from the user or bash script; we set this up first.
parser = argparse.ArgumentParser()
parser.add_argument("NPOP", help="How many antennas are being simulated each generation?", type=int)
g = parser.parse_args()
# Now, the variable g.NPOP holds the int value of the number of antennas in each generation

# We process each antenna individually, to reduce computer memory stress
for antenna in range(g.NPOP):

	# Read the .uan files and save them into an array of size 
	# (freq size x angle size x elements)
	uanDat = np.zeros((60, 2701, 5))
	for freq in range(numFreq):
		# Read the antenna+1'th antenna for the freq+1'th frequency
		uanDat[freq] = readFile(antenna+1, freq+1) 

	with open("evol_antenna_model_"+str(antenna+1)+".dat", "w+") as datFile:
		for freq in range(numFreq):
			datFile.write(head1_a + str(freqVals[freq])+ head1_b+ '\n')
			datFile.write(head2+ '\n')
			datFile.write(head3+ '\n')
			
			"""
			To add the data into the .dat file, I would just use np.savetxt:
			np.savetxt(datFile, uanDat[freq], delimiter=" ")
			However, this does not format the numbers with the right rounding,
			so we do it "by hand". This involves writing each row manually.
			"""
			for r in range(2701): # for each row (r for rows)
				# Format and add the theta and phi as whole numbers
				writeStr = str(int(round(uanDat[freq, r, 0], 0)))+ "  "
				writeStr+= str(int(round(uanDat[freq, r, 1], 0)))+ "  "
				# tfw you convert a float to a worse float to an int to a string :D
				# There was probably a better way to do that...
				# Add the remaining 3 columns with 2 digits past decimal pt.
				writeStr+= '%.2f' % uanDat[freq, r, 2] +"        "
				writeStr+= '%.2f' % 10**((uanDat[freq, r, 2])/10) + "           "
				writeStr+= '%.2f' % uanDat[freq, r, 4]+" "				
				# Add the row into the datFile
				datFile.write(writeStr + '\n')


# Done!







