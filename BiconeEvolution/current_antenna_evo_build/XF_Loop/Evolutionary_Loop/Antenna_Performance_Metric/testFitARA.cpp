/*	fitnessFunction - ARA.cpp
	Written by David Liu
	Revised by Max Clowdus and Julie Rolla on 5 Dec 2018
	Revised by Suren Gourapura to accept NPOP as an argument on 6 Jan 2019

	This program reads data from XF and ouputs fitness scores to a file named fitnessScores.csv.
  	It reads the data from the AraSim output files from the Antenna_Performance_Metric folder, and outputs to file named fitnessScore.csv.
 */
 
#include <iostream>
#include <cmath>
#include <cstdlib>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

using namespace std;

/* Here we declare our global variables. */

int NPOP; /* This global constant represents how many individuals there are per generation. It's value is determined by the user, in argv[1]. It cannot be cast as a constant, because the user's value of NPOP has to be defined inside int main. BE VERY CAREFUL NOT TO REDEFINE NPOP SOMEWHERE IN THE CODE! */
const int HEADER = 729; // Which line is Veff(ice) on from the AraSim output files?
const int NLINES = 737; // How many lines are there in the AraSim output files?
const double EPSILON = 0.000001; // Catches errors. If the first individual's fitness score is less than this value, we rerun the program.

/* Here we declare our function headers. */

void Read(char* filename, ifstream& inputFile, string* araLineArray, vector<double> &fitnessScores, int individualCounter);

void WriteFitnessScores(vector<double> fitnessScores);

/** MAIN FUNCTION **/

int main(int argc, char** argv)
{
	/* Define NPOP first. Due to argv[1] being length NPOP+2, we just hope the user correctly inputs NPOP first, then the list of file names */
	NPOP = atoi(argv[1]); // The atoi function converts from string to int

	// Quick variable declarations:
	vector<double> fitnessScores (NPOP, 0.0); // Stores our fitness scores for each individual.
	string *araLineArray = NULL; // Stores the actual lines read in from the .txt files.
	ifstream inputFile; // Opens the .txt files.
	
	cout << "Fitness function initialized." << endl;
	
	if(argc != NPOP + 2) // +1 for fitnessFunction.exe, +1 for NPOP.
		cout << "Error, number of elements in argument of fitnessFunction.exe is incorrect! Specify NPOP first, then specify all AraSim output data files, preserving individual order." << endl << endl;
	
	else
	{
		double score = 0.0;

			for(int individualCounter = 1; individualCounter <= NPOP; individualCounter++)
			{
				Read(argv[individualCounter+1], inputFile, araLineArray, fitnessScores, individualCounter);
				cout << "Data successfully read. Data successfully written." << endl;
				araLineArray = NULL;
			}
			

	WriteFitnessScores(fitnessScores);
	cout << "Fitness scores successfully written." << endl << "Fitness function concluded." << endl;
	}
	
	return (0);
}

// Subroutines:

void Read(char* filename, ifstream& inputFile, string* araLineArray, vector<double> &fitnessScores, int individualCounter)
{
	string txt = filename;
	inputFile.open(txt.c_str());
	
	// Error message if we can't open the .uan files from XF.
	if(!inputFile.is_open())
	{
		cout << endl << "Error! " << filename << ".txt could not be opened!" << endl;
	}
	
	// Read the data.
	else
	{
		string currentLine="Empty"; // Stores the current line we're reading
		int commaToken=0; // Stores the comma separating m^3 and km^3
		int spaceToken=0; // Stores the space separating km^3 from units
		string vEff="0"; // Stores the string form of the effective volume
		int lineNumber = 0;
		getline(inputFile,currentLine);
		while (currentLine.length() < 15 ||currentLine.substr(0, 13).compare("test Veff(ice")){
				getline(inputFile,currentLine);
			}
		
		commaToken=currentLine.find(",");
		spaceToken=currentLine.find(" ",commaToken+2);
		cout << currentLine << endl;
		vEff = currentLine.substr(commaToken + 2, (spaceToken-commaToken-1));	
		cout << vEff << endl;
		fitnessScores[individualCounter-1] = stod(vEff);
		
		inputFile.close();
		inputFile.clear();
	}
}

void WriteFitnessScores(vector<double> fitnessScores)
{
	ofstream fitnessFile;
	fitnessFile.open("fitnessScores.csv");
	fitnessFile << "The Ohio State University GENETIS Data." << endl;
	fitnessFile << "Current generation's fitness scores:" << endl;
	
	for(int i=0; i<NPOP; i++)
	{
		fitnessFile << fitnessScores[i] << endl;
	}
	fitnessFile.close();
}
