//File: gensData.cpp
//Author: Adam Blenk
//Created On: 1/18/18

#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <cstdlib>
using namespace std;

int main ()
{
    vector<string> uselessText;
    vector<string> geneticData;
    vector<string> geneticFitness;
    vector<double> geneticFitnessDouble;
    string uselessTextElement;
    string geneticDataElement;
    string geneticFitnessElement;
    double geneticFitnessDoubleElement;
    double maxFitnessScores;

    //Creates files if not already created
    ifstream testFile("gensData.csv");

    if(!testFile.is_open())
    {
        ofstream makeFile("gensData.csv");

        if(makeFile.is_open())
        {
            makeFile.close();
        }
        else
        {
            cout << "Error: Failed to create file gensData.csv" << endl;
        }
    }
    else
    {
        testFile.close();
    }


    ifstream testFile2("maxFitnessScores.csv");

    if(!testFile2.is_open())
    {
        ofstream makeFile2("maxFitnessScores.csv");

        if(makeFile2.is_open())
        {
            makeFile2.close();
        }
        else
        {
            cout << "Error: Failed to create file maxFitnessScores.csv" << endl;
        }
    }
    else
    {
        testFile2.close();
    }


    //opens generationDNA.csv and reads data in
    ifstream file("generationDNA.csv");

    if(!file.is_open())
    {
        cout << "Error: generationDNA.csv did not open" << endl;
    }

    for(int i = 0; i < 8; i++)
    {
        getline(file, uselessTextElement);
        uselessText.push_back(uselessTextElement);
    }

    for(int i = 0; i < 5; i++)
    {
        getline(file, geneticDataElement);
        geneticData.push_back(geneticDataElement);
    }

    file.close();


    //opens fitnessScores, reads data in, and finds maximum
    ifstream file2("fitnessScores.csv");

    if(!file2.is_open())
    {
        cout << "Error: fitnessScores.csv did not open" << endl;
    }

    for(int i = 0; i < 2; i++)
    {
        getline(file2, uselessTextElement);
        uselessText.push_back(uselessTextElement);
    }

    for(int i = 0; i < 5; i++)
    {
        getline(file2, geneticFitnessElement);
        geneticFitness.push_back(geneticFitnessElement);
    }

    for(int i = 0; i < 5; i++)
    {
        geneticFitnessDoubleElement = atof(geneticFitness[i].c_str());
        geneticFitnessDouble.push_back(geneticFitnessDoubleElement);
    }

    maxFitnessScores = geneticFitnessDouble[0];
    for(int i = 1; i < 5; i++)
    {
        if(geneticFitnessDouble[i] > maxFitnessScores)
        {
            maxFitnessScores = geneticFitnessDouble[i];
        }
    }

    file2.close();


    //opens gensData and writes data from fitnessScores and generationDNA to it
    ofstream file3 ("gensData.csv", ios_base::app | ios_base::out);

    if (file3.is_open())
    {
        for(int i = 0; i < 5; i++)
        {
            file3 << geneticData[i] << "\n";
        }

        file3.close();
    }
    else
    {
        cout << "Error: Unable to open file gensData.csv";
    }

    ofstream file4 ("maxFitnessScores.csv", ios_base::app | ios_base::out);

    if (file4.is_open())
    {
        file4 << maxFitnessScores << "\n";

        file4.close();
    }
    else
    {
        cout << "Error: Unable to open file maxFitnessScores.csv";
    }

    return(0);
}
