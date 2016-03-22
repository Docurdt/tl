#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <string>
#include <sstream>
#include <map>
#include "data.h"
#include "messageFunctions.h"

using namespace std;

// encoding functions

// CKSAAP encoding
void CKSAAPEncode(char *ogigFile, char *sbjFile, int outFormat, int fragLen, int encodeWindow);
// CKSAAP encoding-1
void CKSAAPEncode_1(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);
//CKSAAP encoding-2 feature selection
void CKSAAPEncode_2(struct prot *data, char *sbjFile, char *featureSelection, char *selectedFeature, int outFormat, int fragLen, int encodeWindow, int cks_kv);
// binary encoding
void binaryEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);
// PSSM encoding
void PSSMEncode(struct prot *data, char *PSSMFileDir, char *sbjFile, int outFormat, int encodeWindow);
// PSSM encoding ( Radivojac P, Vacic V, Haynes C, Cocklin RR, Mohan A, et al. (2010) Identification, analysis, and prediction of protein ubiquitination sites. Proteins 78: 365-380.)
void PSSMEncodeSlideWindow(struct prot *data, char *PSSMFileDir, char *sbjFile, int outFormat, int encodeWindow);
// Amino acids content encoding
void AAContentEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);
// Amino acids content encoding (sliding window)
void AAContentEncodeSlideWindow(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);

// function bodys

// CKSAAP encoding 2 feature selection
void CKSAAPEncode_2(struct prot *data, char *sbjFile, char *featureSelection, char *selectedFeature, int outFormat, int fragLen, int encodeWindow, int cks_kv){
    char AA[]={'A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y'};

    map<char, int> mymap;
    for(int i=0; i<20; i++){
        mymap.insert(pair<char, int>(AA[i], i));
    }

    // open the output file.
    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    struct prot *head=data;
    if(strcmp(featureSelection, "N") == 0){
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
                for(int gap=0; gap<=cks_kv; gap++){
                    float Num[400];
                    int sum=0;
                    for(int i=0; i<400; i++){ Num[i]=0; }

                    for(int i=0; i<seq.length()-gap-1; i++){
                        if(seq.at(i)=='0'  || seq.at(i+gap+1)=='0') continue;
                        Num[mymap[seq.at(i)]*20 + mymap[seq.at(i+gap+1)]]++;
                        sum++;
                    }

                    for(int i=0; i<400; i++){
                        ofssub<<m<<":"<<Num[i]/sum<<"  ";
                        m++;
                    }
                }
                ofssub<<endl;
                head=head->next;
            }
        }
        else if(outFormat == 1){
            ofssub<<"@relation features\n\n";
            for(int i=1; i<=2400; i++){
                ofssub<<"@attribute f"<<i<<" real\n";
            }
            ofssub<<"@attribute play {yes, no}\n\n";
            ofssub<<"@data\n";

            while(head != NULL){
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                for(int gap=0; gap<=5; gap++){
                    float Num[400];
                    int sum=0;
                    for(int i=0; i<400; i++){ Num[i]=0; }

                    for(int i=0; i<seq.length()-gap-1; i++){
                        if(seq.at(i)=='-' || seq.at(i+gap+1)=='-') continue;
                        Num[mymap[seq.at(i)]*20 + mymap[seq.at(i+gap+1)]]++;
                        sum++;
                    }

                    for(int i=0; i<400; i++){
                        ofssub<<Num[i]/sum<<",";
                    }
                }
                if(head->tag == 1){
                    ofssub<<"yes\n";
                }
                else{
                    ofssub<<"no\n";
                }
                head=head->next;
            }
        }
        else{
            printMessage("Incorrect output file format.");
        }
    }
    else if(strcmp(featureSelection, "Y") == 0){
        map<int, int> CKSAAPFea;
        string iStr;
        int FeaNum=0;
        ifstream ifssub(selectedFeature);
        if(!ifssub){
            printMessage("Cannot open the selected CKSAAP feature file.");
        }
        while(!ifssub.eof()){
            getline(ifssub, iStr);
            if(iStr.empty()){ continue; }
            istringstream iStream(iStr);
            int tmpFeature;
            iStream>>tmpFeature;
            CKSAAPFea.insert(pair<int, int>(tmpFeature, 1));
            FeaNum++;
        }
        ifssub.close();
        ifssub.clear();

        if(outFormat==0){
            while(head != NULL){
                if(head->tag == 1){
                    ofssub<<"+1  ";
                }
                else{
                    ofssub<<"-1  ";
                }

                int m=1;
                int posIndex=1;
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

                for(int gap=0; gap<=5; gap++){
                    float Num[400];
                    int sum=0;
                    for(int i=0; i<400; i++){ Num[i]=0; }

                    for(int i=0; i<seq.length()-gap-1; i++){
                        if(seq.at(i)=='-'  || seq.at(i+gap+1)=='-') continue;
                        Num[mymap[seq.at(i)]*20 + mymap[seq.at(i+gap+1)]]++;
                        sum++;
                    }

                    for(int i=0; i<400; i++){
                        if(CKSAAPFea.find(posIndex) != CKSAAPFea.end()){
                            ofssub<<m<<":"<<Num[i]/sum<<"  ";
                            m++;
                        }
                        posIndex++;
                    }
                }
                ofssub<<endl;
                head=head->next;
            }
        }
        else if(outFormat == 1){
            ofssub<<"@relation features\n\n";
            for(int i=1; i<=FeaNum; i++){
                ofssub<<"@attribute f"<<i<<" real\n";
            }
            ofssub<<"@attribute play {yes, no}\n\n";
            ofssub<<"@data\n";

            while(head != NULL){
                int posIndex=1;
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

                for(int gap=0; gap<=5; gap++){
                    float Num[400];
                    int sum=0;
                    for(int i=0; i<400; i++){ Num[i]=0; }

                    for(int i=0; i<seq.length()-gap-1; i++){
                        if(seq.at(i)=='-' || seq.at(i+gap+1)=='-') continue;
                        Num[mymap[seq.at(i)]*20 + mymap[seq.at(i+gap+1)]]++;
                        sum++;
                    }

                    for(int i=0; i<400; i++){
                        if(CKSAAPFea.find(posIndex) != CKSAAPFea.end()){
                            ofssub<<Num[i]/sum<<",";
                        }
                        posIndex++;
                    }
                }
                if(head->tag == 1){
                    ofssub<<"yes\n";
                }
                else{
                    ofssub<<"no\n";
                }
                head=head->next;
            }
        }
        else{
            printMessage("Incorrect output file format.");
        }



    }
    else{
        printMessage("Unknown parameter for feature selection.");
    }

    ofssub.close();
    ofssub.clear();
}
// binary endoding
void binaryEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y', '0'};

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Unable to open the file.");
    }

    int centralSite=encodeWindow/2;
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

            for(int i=0; i<seq.length(); i++){
//                if(i == centralSite) continue;
                for(int j=0; j<21; j++){
                   if(seq.at(i)==AA[j]){
                       ofssub<<m<<":"<<1<<"  ";
                   }
                   else{
                       ofssub<<m<<":"<<0<<"  ";
                   }
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
  //              if(i == centralSite) continue;
                for(int j=0; j<21; j++){
                   if(seq.at(i)==AA[j]){
                       ofssub<<1<<",";
                   }
                   else{
                       ofssub<<0<<",";
                   }
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
    else{
        printMessage("Incorrect format parameter.");
    }
    ofssub.close();
    ofssub.clear();
}

// pssm encoding
void PSSMEncode(struct prot *data, char *PSSMFileDir, char *sbjFile, int outFormat, int encodeWindow){
    int maxCol=20;
    map<int, int*> myPSSM;

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Can not to open the output file.");
    }

    char lastName[buffer]="NULL";

    struct prot *head=data;
    int tmpSeqLen=0;

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=maxCol * encodeWindow; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    while(head != NULL){
        char name[buffer];
        strcpy(name, PSSMFileDir);
        strcat(name, "/");
        strcat(name, head->protName.c_str());
        strcat(name, ".pssm");

        if(strcmp(name, lastName) != 0){ // read the PSSM profile into memory
            // clean PSSM
            //printMessage("This is PSSM encode!!!\n");

            for (map<int, int*>::iterator it=myPSSM.begin(); it!=myPSSM.end(); ++it){
                int *p=it->second;
                myPSSM[it->first]=NULL;
                delete p;
            }
            myPSSM.clear();
            tmpSeqLen=0;

            // read PSSM
            string iStr;
            ifstream ifssub(name);
            if(!ifssub){
                printMessage(name);
                //printMessage("warning!!!");
            }

            int pos=1;
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
               // if(iStr.substr(11, 1).at(0) == 'A' || iStr.substr(22, 1).at(0) == 'K'){ continue; }
                if(iStr.at(0) == ' '){
                    int *tmp = new int[20];
                    iStr.replace(0, 10, "");
                    istringstream iStream(iStr);
                    int i=0;
                    while(iStream>>tmp[i] && i<maxCol){
                        i++;
                    }
                    myPSSM.insert(pair<int, int*>(pos, tmp));
                    pos++;
                    tmpSeqLen++;
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
            for(int tmpPos=head->position - tmpWindow + 2; tmpPos<=head->position + tmpWindow + 1; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen-1){
                    for(int j=0; j<maxCol; j++){
                        ofssub<<m<<":0"<<"  ";
                        m++;
                    }
                }
                else{
                    for(int j=0; j<maxCol; j++){
                        ofssub<<m<<":"<<myPSSM[tmpPos][j]<<"  ";
                        m++;
                    }
                }
            }
            ofssub<<endl;
        }

        // weka output format
        if(outputFormat == 1){
            int tmpWindow=encodeWindow/2;
            for(int tmpPos=head->position - tmpWindow + 1; tmpPos<=head->position + tmpWindow; tmpPos++){
                if(tmpPos<=0 || tmpPos>tmpSeqLen){
                    for(int j=0; j<maxCol; j++){
                        ofssub<<"0,";
                    }
                }
                else{
                    for(int j=0; j<maxCol; j++){
                        ofssub<<myPSSM[tmpPos][j]<<",";
                    }
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

// pssm encoding (Slide Window)
void PSSMEncodeSlideWindow(struct prot *data, char *PSSMFileDir, char *sbjFile, int outFormat, int encodeWindow){
    int maxCol=42;
    map<int, float*> myPSSM;
    int slideWindow[7]={1, 7, 11, 21, 27, 31, 41};
    int windowNumber=0;
    for(int i=0; i<7; i++){
        if(slideWindow[i] <= encodeWindow) { windowNumber++; }
    }


    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Can not to open the output file.");
    }

    char lastName[buffer]="NULL";
    struct prot *head=data;
    int tmpSeqLen=0;

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=maxCol * windowNumber; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    while(head != NULL){
        char name[buffer];
        strcpy(name, PSSMFileDir);
        strcat(name, "/");
        strcat(name, head->protName.c_str());
        strcat(name, ".pssm");

        if(strcmp(name, lastName) != 0){ // read the PSSM profile into memory
            // clean PSSM
            for (map<int, float*>::iterator it=myPSSM.begin(); it!=myPSSM.end(); ++it){
                float *p=it->second;
                myPSSM[it->first]=NULL;
                delete p;
            }
            myPSSM.clear();
            tmpSeqLen=0;

            // read PSSM
            string iStr;
            ifstream ifssub(name);
            if(!ifssub){
                printMessage(name);
            }

            int pos=1;
            while(!ifssub.eof()){
                getline(ifssub, iStr);
                if(iStr.empty()){ continue; }
//                if(iStr.substr(11, 1).at(0) == 'A' || iStr.substr(22, 1).at(0) == 'K'){ continue; }
                if(iStr.at(0) == ' '){
                    float *tmp = new float[maxCol];
                    iStr.replace(0, 7, "");
                    istringstream iStream(iStr);
                    int i=0;
                    while(iStream>>tmp[i] && i<maxCol){
                        i++;
                    }

                    myPSSM.insert(pair<int, float*>(pos, tmp));
                    pos++;
                    tmpSeqLen++;
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
                int lineNum=0;
                float tmpVector[maxCol];
                for(int i=0; i<maxCol; i++){
                    tmpVector[i]=0;
                }

                for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                    if(tmpPos<=0 || tmpPos>tmpSeqLen){ continue; }
                    for(int k=0; k<maxCol; k++){
                        tmpVector[k]+=myPSSM[tmpPos][k];
                    }
                    lineNum++;
                }

                for(int k=0; k<maxCol; k++){
                    ofssub<<m<<":"<<tmpVector[k]/lineNum<<"  ";
                    m++;
                }
            }
            ofssub<<endl;
        }

        // weka output format
        if(outputFormat == 1){
            for(int i=0; i<windowNumber; i++){
                int tmpWindow=slideWindow[i]/2;
                int lineNum=0;
                float tmpVector[maxCol];
                for(int i=0; i<maxCol; i++){
                    tmpVector[i]=0;
                }

                for(int tmpPos=head->position - tmpWindow; tmpPos<=head->position + tmpWindow; tmpPos++){
                    if(tmpPos<=0 || tmpPos>tmpSeqLen){ continue; }
                    for(int k=0; k<maxCol; k++){
                        tmpVector[k]+=myPSSM[tmpPos][k];
                    }
                    lineNum++;
                }

                for(int k=0; k<maxCol; k++){
                    ofssub<<tmpVector[k]/lineNum<<",";
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

// Amino acids content encoding
void AAContentEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y'};
    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=20; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
    }

    struct prot *head=data;
    while(head != NULL){
        double Num[20];
        int sum=0;
        for(int i=0; i<20; i++){
            Num[i]=0;
        }
        string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
        for(int i=0; i<seq.length(); i++){
            for(int j=0; j<20; j++){
                if(seq.at(i)==AA[j]){
                    Num[j]++;
                    sum++;
                }
            }
        }

        if(outFormat==0){
            int m=1;
            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }
            for(int i=0; i<20; i++){
                ofssub<<m<<":"<<Num[i]/sum<<"  ";
                m++;
            }
            ofssub<<endl;
        }

        if(outFormat == 1){
            for(int i=0; i<20; i++){
                ofssub<<Num[i]/sum<<",";
            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
        }

        head = head->next;
    }
    ofssub.close();
    ofssub.clear();
}

void AAContentEncodeSlideWindow(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y'};
    int slideWindow[7]={3, 7, 11, 21, 27, 31, 41};

    int windowNumber=0;
    for(int i=0; i<7; i++){
        if(slideWindow[i] <= encodeWindow) { windowNumber++; }
    }
    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    struct prot *head=data;
    if(outFormat == 0){
        while(head != NULL){
            int m=1;

            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            for(int win=0; win<windowNumber; win++){
                double Num[20];
                int sum=0;
                for(int i=0; i<20; i++){
                    Num[i]=0;
                }

                string seq=head->protSeq.substr((int)((fragLen/2)-int(slideWindow[win]/2)), slideWindow[win]);

                for(int i=0; i<seq.length(); i++){
                    for(int j=0; j<20; j++){
                        if(seq.at(i)==AA[j]){
                            Num[j]++;
                            sum++;
                        }
                    }
                }

                for(int i=0; i<20; i++){
                    ofssub<<m<<":"<<Num[i]/sum<<"  ";
                    m++;
                }
            }
            ofssub<<endl;
            head = head->next;
        }
    }
    else if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=20 * windowNumber; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";

        while(head != NULL){
            for(int win=0; win<windowNumber; win++){
                double Num[20];
                int sum=0;
                for(int i=0; i<20; i++){
                    Num[i]=0;
                }

                string seq=head->protSeq.substr((int)((fragLen/2)-int(slideWindow[win]/2)), slideWindow[win]);

                for(int i=0; i<seq.length(); i++){
                    for(int j=0; j<20; j++){
                        if(seq.at(i)==AA[j]){
                            Num[j]++;
                            sum++;
                        }
                    }
                }

                for(int i=0; i<20; i++){
                    ofssub<<Num[i]/sum<<",";
                }
            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
            head = head->next;
        }
    }
    else{
        printMessage("Unknown output format.");
    }

    ofssub.close();
    ofssub.clear();
}
