/* fitnessFunction.cpp
 * David Liu 18 May 2018
 * This program reads data from XF and ouputs fitness scores to a file named handshook.csv.
 * It reads 1.uan, 2.uan, 3.uan, 4.uan, 5.uan from the Data file, and outputs handshook.csv.
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

const int NPOP = 10; // Number of individuals per generation
const int NVALS = 6; // Number of values associated with each (θ,φ) coordinate in the .uan files outputted by XF.
const int THETA_STEP = 15; // Number of degrees each θ increments by.
const int PHI_STEP = 15; // Number of degrees each φ increments by. 
const int HEADER = 17; // Number of header lines in the .uan files outputted by XF.
const int NLINES = ((360/PHI_STEP)+1)*((180/THETA_STEP)+1)+HEADER; // Total number of lines in each .uan file.
const int NPHIS = (360/PHI_STEP)+1; // Number of phis per theta.
const int THETA = 90; // Angle (in degrees) at which we are interested in the θ gain value.
const float TARGETGAIN = 5.14f; // Target gain value. (DEPRECIATED)
const double EPSILON = 0.000001; // Catches errors. If the first individual's fitness score is less than this value, we rerun the program.

/* Here we declare our function headers. */

// Function Read pulls the data from the .uan files into an array we can use.
void Read(char* filename, ifstream& uanFile, string* uanLineArray);

// Function ExtractThetaGain pulls the data from the data array we got from Read into a vector thetaGain.
void ExtractThetaGain(string* uanLineArray, int individualCounter, vector<vector<double>> &thetaGain);

// Function Fitness is the actual fitness function that takes the inputs and outputs a fitness score.
double Fitness(int individualNumber, vector<vector<double>> thetaGain);

// Function WriteHandshook writes the fitness scores in sequence to handshook.csv.
void WriteFitnessScores(vector<double> fitnessScores);

/** MAIN FUNCTION **/

int main(int argc, char** argv)
{
	// Quick variable declarations:
	vector<vector<double>> thetaGain (NPOP, vector <double>(NPHIS,0.0f) ); // Stores our theta gain for each individual.
	vector<double> fitnessScores (NPOP, 0.0); // Stores our fitness scores for each individual.
	string *uanLineArray = NULL; // Stores the actual lines read in from the .uan files.
	ifstream inputFile; // Opens the .uan files.
	
	cout << "Fitness function initialized." << endl;
	
	if(argc != NPOP + 1)
		cout << "Error! Specify all XF output data files, preserving individual order." << endl << endl;
	
	else
	{
		double score = 0.0;
		
		while(abs(fitnessScores[0]) < EPSILON)
		{
			for(int individualCounter = 1; individualCounter <= NPOP; individualCounter++)
			{
				uanLineArray = new string[NLINES];
				Read(argv[individualCounter], inputFile, uanLineArray);
				cout << "Data successfully read." << endl;
				ExtractThetaGain(uanLineArray, individualCounter, thetaGain);
				cout << "Theta gains successfully extracted." << endl;
				delete [] uanLineArray;
				uanLineArray = NULL;
			}
			
			for(int individualNumber=0; individualNumber < NPOP; individualNumber++)
			{
				fitnessScores[individualNumber] = Fitness(individualNumber,thetaGain);
				cout << "Fitness scores successfully assigned." << endl;
			}
		}
	WriteFitnessScores(fitnessScores);
	cout << "Fitness scores successfully written." << endl << "Fitness function concluded." << endl;
	}
	
	return (0);
}

// Function Read pulls the data from the .uan files into an array we can use.
void Read(char* filename, ifstream& uanFile, string* uanLineArray)
{
	string uan = filename;
	uanFile.open(uan.c_str());
	
	// Error message if we can't open the .uan files from XF.
	if(!uanFile.is_open())
	{
		cout << endl << "Error! " << filename << ".uan could not be opened!" << endl;
	}
	
	// Read the data.
	else
	{
		for(int lineNumber=0; lineNumber<NLINES; lineNumber++)
		{
			getline(uanFile,uanLineArray[lineNumber]);
		}
		uanFile.close();
		uanFile.clear();
	}
}
	

// Function ExtractThetaGain pulls the data from the data array we got from Read into a vector thetaGain.
void ExtractThetaGain(string* uanLineArray, int individualCounter, vector<vector<double>> &thetaGain)
{
	string currentLine="Empty"; // Stores the current line we're reading.
	int currentTheta=0; // Stores the current angle θ we are looking at.
	string gain="0"; // Stores the actual gain values in string form (extracted from the .uan).
	double gainValue=0.0; // Stores the actual gain values in double form (converted from gain).
	int thetaCounter = 0; // Counts how many thetas we've read so far.
	string initialToken="Empty"; // Stores the initial token that indicates we've gotten to data.
	int firstSpace=0; // Stores the first space separating the gains.
	int secondSpace=0; // Stores the second space separating the gains.
	int thirdSpace=0; // Stores the third space separating the gains.
	
	for(int i=0; i<NLINES; i++)
	{
		currentLine = uanLineArray[i];
		initialToken = currentLine.substr(0, currentLine.find(' '));
		currentTheta = atoi(initialToken.c_str());
		
		if(currentTheta == THETA)
		{
			firstSpace = currentLine.find(" ");
			secondSpace = currentLine.find(" ",firstSpace+1);
			thirdSpace = currentLine.find(" ", secondSpace+1);
			
			gain = currentLine.substr(secondSpace + 1, thirdSpace - secondSpace);
			thetaGain[individualCounter - 1][thetaCounter] = stod(gain);
			thetaCounter++;
		}
	}
}

// Function Fitness is the actual fitness function that takes the inputs and outputs a fitness score.
// In this case it just gets the average gain value for each indiviudual.
double Fitness(int individualNumber, vector<vector<double>> thetaGain)
{
	double totalGain = 0.0;
	double averageGain = 0.0;
	for(int i=0; i<NPHIS; i++)
	{
		totalGain += thetaGain[individualNumber][i];
	}
	
	averageGain = totalGain / NPHIS;

	return averageGain;
}

// Function WriteHandshook writes the fitness scores in sequence to handshook.csv.
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