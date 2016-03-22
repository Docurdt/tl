#include "encodingFunctions.h"
#include <iomanip>

using namespace std;

// encoding functions

// disorder encoding
void DisorderEncode(struct prot *data, char *disorderFileDir, char *sbjFile, int outFormat, int encodeWindow);
// disorder encoding (sliding window)
void DisorderEncodeSlideWindow(struct prot *data, char *disorderFileDir, char *sbjFile, int outFormat, int encodeWindow);
// aggregation encoding
void AggEncode(struct prot *data, char *aggFileDir, char *sbjFile, int outFormat, int encodeWindow);
// BLOSUM62 encoding
void blosum62Encode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);

// function bodys

// Disorder encoding
void DisorderEncode(struct prot *data, char *disorderFileDir, char *sbjFile, int outFormat, int encodeWindow){
    float *disScore=NULL;
    struct prot *head=data;
    int tmpSeqLen=0;
    char lastName[buffer]="NULL";

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=encodeWindow; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    while(head != NULL){
        char name[buffer];
        strcpy(name, disorderFileDir);
        strcat(name, "/");
        strcat(name, head->protName.c_str());
        strcat(name, ".diso");

        if(strcmp(name, lastName) != 0){ // read the disorder into memory
            // clear the content
            float *p=disScore;
            disScore=NULL;
            if(p != NULL){
                delete p;
            }
            tmpSeqLen=0;

            // read disorder values
            string iStr;
            int tag=0;
            ifstream ifssub(name);
            if(!ifssub){
                printMessage("Cannot open the disorder file.");
            }
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '#'){  continue; }
                tmpSeqLen++;
            }
            ifssub.close();
            ifssub.clear();

            disScore=new float[tmpSeqLen+1];
            disScore[0]=0;

            ifssub.open(name);
            if(!ifssub){
                printMessage("Cannot open the disorder file.");
            }

            tag=0;
            int m=1;
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '#'){  continue; }
              //  tmpSeqLen++;
                tag=1;
                if(tag == 1){
                    int serialNum=0;
                    char tmpChar;
                    char tmpChar2;
                    float tmpScore;
				//	cout<<"The original string is: "<<iStr<<endl;
				    istringstream iStream(iStr);
                    iStream>>serialNum>>tmpChar>>tmpChar2>>tmpScore;
                    disScore[m] = tmpScore;
				    m++;
                }
            }

            ifssub.close();
            ifssub.clear();

            strcpy(lastName, name);
        }

        // SVM output format
        if(outFormat == 0){
            if(head->tag ==1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int tmpWindow=encodeWindow/2;
            int m=1;
            for(int tmpPos=head->position - tmpWindow + 1; tmpPos<=head->position + tmpWindow; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen){
                    ofssub<<m<<":0  ";
                    m++;
                }
                else{
                    ofssub<<m<<":"<<disScore[tmpPos]<<"  ";
                    m++;
                }
            }
            ofssub<<endl;
        }

        // weka output format
        if(outputFormat == 1){
            int tmpWindow=encodeWindow/2;
            for(int tmpPos=head->position - tmpWindow + 1; tmpPos<=head->position + tmpWindow; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen){
                    ofssub<<"0,";

                }
                else{
                    ofssub<<disScore[tmpPos]<<",";
                }
            }

            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
        }

        head=head->next;
    }

    ofssub.close();
    ofssub.clear();
}

// disorder encoding (sliding window)
void DisorderEncodeSlideWindow(struct prot *data, char *disorderFileDir, char *sbjFile, int outFormat, int encodeWindow){
    int slideWindow[7]={1, 7, 11, 21, 27, 31, 41};

    int windowNumber=0;
    for(int i=0; i<7; i++){
        if(slideWindow[i] <= encodeWindow) { windowNumber++; }
    }

    float *disScore=NULL;
    struct prot *head=data;
    int tmpSeqLen=0;
    char lastName[buffer]="NULL";

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=windowNumber; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    while(head != NULL){
        char name[buffer];
        strcpy(name, disorderFileDir);
        strcat(name, "/");
        strcat(name, head->protName.c_str());
        strcat(name, ".disorder");

        if(strcmp(name, lastName) != 0){ // read the disorder into memory
            // clear the content
            float *p=disScore;
            disScore=NULL;
            if(p != NULL){
                delete p;
            }
            tmpSeqLen=0;

            // read disorder values
            string iStr;
            int tag=0;
            ifstream ifssub(name);
            if(!ifssub){
                printMessage("Cannot open the disorder file.");
            }
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '='){  continue; }
                if(iStr.at(0) == '-'){ tag=1; continue; }
                if(tag ==1){
                    tmpSeqLen++;
                }
            }
            ifssub.close();
            ifssub.clear();

            disScore=new float[tmpSeqLen+1];
            disScore[0]=0;

            ifssub.open(name);
            if(!ifssub){
                printMessage("Cannot open the disorder file.");
            }

            tag=0;
            int m=1;
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '='){ continue; }
                if(iStr.at(0) == '-'){ tag=1; continue; }
                if(tag == 1){
                    int serialNum=0;
                    char tmpChar;
                    float tmpScore=0;
                    istringstream iStream(iStr);
                    iStream>>serialNum>>tmpChar>>disScore[m];
                    m++;
                }
            }

            ifssub.close();
            ifssub.clear();

            strcpy(lastName, name);
        }

        // SVM output format
        if(outFormat == 0){
            if(head->tag ==1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int m=1;
            for(int i=0; i<windowNumber; i++){
                int tmpWindow=slideWindow[i]/2;
                float aveDisorderValue=0;
                for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                    if(tmpPos<=0 || tmpPos>tmpSeqLen){
                       aveDisorderValue+=0;
                    }
                    else{
                        aveDisorderValue+=disScore[tmpPos];
                    }
                }
                aveDisorderValue/=slideWindow[i];
                ofssub<<m<<":"<<aveDisorderValue<<"  ";
                m++;
            }
            ofssub<<endl;
        }

        // weka output format
        if(outputFormat == 1){
            for(int i=0; i<windowNumber; i++){
                int tmpWindow=slideWindow[i]/2;
                float aveDisorderValue=0;
                for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                    if(tmpPos<=0 || tmpPos>tmpSeqLen){
                       aveDisorderValue+=0;
                    }
                    else{
                        aveDisorderValue+=disScore[tmpPos];
                    }
                }
                aveDisorderValue/=slideWindow[i];
                ofssub<<aveDisorderValue<<",";
            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
        }
        head=head->next;
    }

    ofssub.close();
    ofssub.clear();
}

// Agg encoding scheme
void AggEncode(struct prot *data, char *aggFileDir, char *sbjFile, int outFormat, int encodeWindow){
    float *aggScore=NULL;
    struct prot *head=data;
    int tmpSeqLen=0;
    char lastName[buffer]="NULL";

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=encodeWindow; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    while(head != NULL){
        char name[buffer];
        strcpy(name, aggFileDir);
        strcat(name, "/");
        strcat(name, head->protName.c_str());
        strcat(name, ".agg");

        if(strcmp(name, lastName) != 0){ // read the agg into memory
            // clear the content
            float *p=aggScore;
            aggScore=NULL;
            if(p != NULL){
                delete p;
            }
            tmpSeqLen=0;

            // read disorder values
            string iStr;

            ifstream ifssub(name);
            if(!ifssub){
                printMessage("Cannot open the Agg file.");
            }
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '#'){  continue; }
                tmpSeqLen++;
            }
            ifssub.close();
            ifssub.clear();

            aggScore=new float[tmpSeqLen+1];
            aggScore[0]=0;

            ifssub.open(name);
            if(!ifssub){
                printMessage("Cannot open the disorder file.");
            }

            int m=1;
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
                if(iStr.at(0) == '#'){ continue; }
                int col_1=0;
                char col_2, col_3;
                istringstream iStream(iStr);
                iStream>>col_1>>col_2>>col_3>>aggScore[m];
                m++;
            }

            ifssub.close();
            ifssub.clear();

            strcpy(lastName, name);
        }

        // SVM output format
        if(outFormat == 0){
            if(head->tag ==1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int tmpWindow=encodeWindow/2;
            int m=1;
            for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen){
                    ofssub<<m<<":0  ";
                    m++;
                }
                else{
                    ofssub<<m<<":"<<aggScore[tmpPos]<<"  ";
                    m++;
                }
            }
            ofssub<<endl;
        }

        // weka output format
        if(outputFormat == 1){
            int tmpWindow=encodeWindow/2;
            for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen){
                    ofssub<<"0,";

                }
                else{
                    ofssub<<aggScore[tmpPos]<<",";
                }
            }

            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
        }

        head=head->next;
    }

    ofssub.close();
    ofssub.clear();
}

// BLOSUM62 encoding
void blosum62Encode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', '0'};
    int BLOSUM62[21][21]={
       //A   R   N   D   C   Q   E   G   H   I   L   K   M   F   P   S   T   W   Y   V   0
        {4, -1, -2, -2,  0, -1, -1,  0, -2, -1, -1, -1, -1, -2, -1,  1,  0, -3, -2,  0,  0},  //A
        {-1, 5,  0, -2, -3,  1,  0, -2,  0, -3, -2,  2, -1, -3, -2, -1, -1, -3, -2, -3,  0},  //R
        {-2, 0,  6,  1, -3,  0,  0,  0,  1, -3, -3,  0, -2, -3, -2,  1,  0, -4, -2, -3,  0},  //N
        {-2,-2,  1,  6, -3,  0,  2, -1, -1, -3, -4, -1, -3, -3, -1,  0, -1, -4, -3, -3,  0},  //D
        {0, -3, -3, -3,  9, -3, -4, -3, -3, -1, -1, -3, -1, -2, -3, -1, -1, -2, -2, -1,  0},  //C
        {-1, 1,  0,  0, -3,  5,  2, -2,  0, -3, -2,  1,  0, -3, -1,  0, -1, -2, -1, -2,  0},  //Q
        {-1, 0,  0,  2, -4,  2,  5, -2,  0, -3, -3,  1, -2, -3, -1,  0, -1, -3, -2, -2,  0},  //E
        {0, -2,  0, -1, -3, -2, -2,  6, -2, -4, -4, -2, -3, -3, -2,  0, -2, -2, -3, -3,  0},  //G
        {-2, 0,  1, -1, -3,  0,  0, -2,  8, -3, -3, -1, -2, -1, -2, -1, -2, -2,  2, -3,  0},  //H
        {-1,-3, -3, -3, -1, -3, -3, -4, -3,  4,  2, -3,  1,  0, -3, -2, -1, -3, -1,  3,  0},  //I
        {-1,-2, -3, -4, -1, -2, -3, -4, -3,  2,  4, -2,  2,  0, -3, -2, -1, -2, -1,  1,  0},  //L
        {-1, 2,  0, -1, -3,  1,  1, -2, -1, -3, -2,  5, -1, -3, -1,  0, -1, -3, -2, -2,  0},  //K
        {-1,-1, -2, -3, -1,  0, -2, -3, -2,  1,  2, -1,  5,  0, -2, -1, -1, -1, -1,  1,  0},  //M
        {-2,-3, -3, -3, -2, -3, -3, -3, -1,  0,  0, -3,  0,  6, -4, -2, -2,  1,  3, -1,  0},  //F
        {-1,-2, -2, -1, -3, -1, -1, -2, -2, -3, -3, -1, -2, -4,  7, -1, -1, -4, -3, -2,  0},  //P
        {1, -1,  1,  0, -1,  0,  0,  0, -1, -2, -2,  0, -1, -2, -1,  4,  1, -3, -2, -2,  0},  //S
        {0, -1,  0, -1, -1, -1, -1, -2, -2, -1, -1, -1, -1, -2, -1,  1,  5, -2, -2,  0,  0},  //T
        {-3,-3, -4, -4, -2, -2, -3, -2, -2, -3, -2, -3, -1,  1, -4, -3, -2, 11,  2, -3,  0},  //W
        {-2,-2, -2, -3, -2, -1, -2, -3,  2, -1, -1, -2, -1,  3, -3, -2, -2,  2,  7, -1,  0},  //Y
        {0, -3, -3, -3, -1, -2, -2, -3, -3,  3,  1, -2,  1, -1, -2, -2,  0, -3, -1,  4,  0},  //V
        {0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0}   //-
    };

    int centralSite=encodeWindow/2;

    map<char, int> index;
    for(int i=0; i<21; i++){
        index.insert(pair<char, int>(AA[i], i));
    }

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    struct prot *head=data;

    if(outFormat==0){
        while(head != NULL){
            int m=1;
            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
    //        cout<<seq<<endl;
	//		cout<<seq.length()<<endl;
            for(int i=0; i<seq.length(); i++){
            //    if(i == centralSite) { continue; }
                for(int j=0; j<21; j++){
                    ofssub<<m<<":"<<BLOSUM62[index[seq.at(i)]][j]<<"  ";
                    m++;
                }
            }
            ofssub<<endl;
            head=head->next;
        }
    }
    else if(outputFormat==1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=21 * (encodeWindow-1); i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
        while(head != NULL){
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

            for(int i=0; i<seq.length(); i++){
              //  if(i == centralSite) continue;
                for(int j=0; j<21; j++){
                    ofssub<<BLOSUM62[index[seq.at(i)]][j]<<",";
                }
            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
            head=head->next;
        }
    }
    ofssub.close();
    ofssub.clear();
}
