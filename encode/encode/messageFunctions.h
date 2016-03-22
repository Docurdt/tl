#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;

void printHelp(char *s);
void printMessage(string s);

void printHelp(char *s)
{
    cout<<"encode Version 1.0\targuments:"<<endl;
    cout<<endl<<"    -i      input file name [String]"<<endl;
    cout<<endl<<"    -o      output file name [String]\n      default = output.txt"<<endl;
    cout<<endl<<"    -m      output file format options: [Integer]\n";
    cout<<"      0 = SVM format [default]"<<endl;
    cout<<"      1 = Weka format (*.arff)"<<endl;
    cout<<endl<<"    -L      fragment length [Integer]\n      default = 51"<<endl;
    cout<<endl<<"    -W      fragment window [Integer]\n      default = 27"<<endl;
    cout<<endl<<"    -t      encoding type [String]"<<endl;
    cout<<"      pssm        PSSM encoding scheme"<<endl;
    cout<<"      pssm-S      PSSM encoding scheme [4]"<<endl;
    cout<<"      binary      Binary encoding scheme [1]"<<endl;
    cout<<"      cksaap      CKSAAP encoding scheme [1]"<<endl;
    cout<<"      blosum62    BLOSUM62 encoding scheme [2]"<<endl;
    cout<<"      knn         KNN encoding scheme(encode testing file) [3]"<<endl;
    cout<<"      knn-train   KNN encoding scheme(encode training file) [3]"<<endl;
    cout<<"      disorder    Disorder encoding scheme"<<endl;
    cout<<"      disorder-S  Disorder encoding scheme(Sliding window. window={1, 7, 11, 21, 27, 31, 41}) [4]"<<endl;
    cout<<"      AAC         Amino acids content encoding scheme"<<endl;
    cout<<"      AAC-S       Amino acids content encoding scheme(Sliding window. window={3, 7, 11, 21, 27, 31, 41}) [4]"<<endl;
    cout<<"      agg         Aggregation encoding scheme [1]"<<endl;
    cout<<"      aaindex     AAindex encoding scheme [1]"<<endl;
    cout<<"      charge-hyd  AAindex encoding scheme(Sliding window. window={3, 7, 11, 21, 27, 31, 41}) [4]"<<endl;
    cout<<endl<<"    -f      wheather do feature selection for aaindex/CKSAAP encoding[String]\n      default = N (Y/N)"<<endl;
    cout<<endl<<"    -F      Selected feature file(only used for aaindex/CKSAAP encoding): [String]"<<endl;
    cout<<endl<<"    -p      PSSM profile file directory(only used for PSSM encoding): [String]"<<endl;
    cout<<endl<<"    -d      disorder file directory(only used for disorder encoding): [String]"<<endl;
    cout<<endl<<"    -a      aggregation file directory(only used for aggregation encoding): [String]"<<endl;
    cout<<endl<<"    -Train  training dataset file in the KNN encoding: [String]"<<endl;
    cout<<endl<<"    -K      Top K values(only used for knn encoding): [String]"<<endl;
    cout<<endl<<"Reference:"<<endl;
    cout<<"[1]  Chen Z, Zhou Y, Song J, Zhang Z (2013) hCKSAAP_UbSite: Improved prediction of human ubiquitination sites by exploiting amino acid pattern and properties. Biochim Biophys Acta 1834: 1461-1467."<<endl;
    cout<<"[2]  Lee TY, Chen SA, Hung HY, Ou YY (2011) Incorporating distant sequence features and radial basis function networks to identify ubiquitin conjugation sites. PLoS One 6: e17331."<<endl;
    cout<<"[3]  Chen X, Qiu JD, Shi SP, Suo SB, Huang SY, et al. (2013) Incorporating Key Position and Amino Acid Residue Features to Identify General and Species-specific Ubiquitin Conjugation Sites. Bioinformatics."<<endl;
    cout<<"[4]  Radivojac P, Vacic V, Haynes C, Cocklin RR, Mohan A, et al. (2010) Identification, analysis, and prediction of protein ubiquitination sites. Proteins 78: 365-380."<<endl;

    cout<<endl;

    exit(1);
}

void printMessage(string s)
{
    cout<<s<<endl;
    exit(1);
}
