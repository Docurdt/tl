#include <string>
using namespace std;

const int buffer=256;

// encode type
char encodeTypeInit[buffer]="cksaap";
char *encodeType=encodeTypeInit;

// input file name
char *inputFile;

// output file name
char outputFileInit[buffer]="output.txt";
char *outputFile=outputFileInit;
int outputFormat=0;

// pssm file directory
char pssmFileDirectoryInit[buffer]="PSSM";
char *pssmFileDirectory=pssmFileDirectoryInit;

// disorder file directory
char disorderFileDirectoryInit[buffer]="DisorderVSL2";
char *disorderFileDirectory=disorderFileDirectoryInit;

// aggregation file directory
char aggFileDirectoryInit[buffer]="Aggregation";
char *aggFileDirectory=aggFileDirectoryInit;

// AAindex parameter file
char aaindexFileInit[buffer]="AAindex.txt";
char *aaindexFile=aaindexFileInit;
char ifFeatureSelectionInit[buffer]="N";
char *ifFeatureSelection=ifFeatureSelectionInit;
char selectedFeatureFileInit[buffer]="SelectedAAindexFeature.txt";
char *selectedFeatureFile=selectedFeatureFileInit;

// KNN
char knnTrainFileInit[buffer]="train.txt";
char *knnTrainFile=knnTrainFileInit;
char topKFileInit[buffer]="topKValues.txt";
char *topKFile=topKFileInit;


int cksaap_kv = 5;
int seqLen=16;
int window=16;

struct prot
{
    string protSeq;
    string protName;
    int position;
    int tag;
    struct prot *next;
};

struct knnScore
{
    float score;
    int tag;
};
