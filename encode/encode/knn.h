#include "aaindexencoding.h"

using namespace std;

// encoding functions
// KNN feature encoding scheme
void KNNEncode(struct prot *data, char *TrainFile, char *sbjFile, int outFormat, int fragLen, int encodeWindow, char *KValuesFile);
// KNN feature encoding scheme (encode training file)
void KNNEncode_train(struct prot *data, char *TrainFile, char *sbjFile, int outFormat, int fragLen, int encodeWindow, char *KValuesFile);

// function bodys
// KNN feature encoding scheme
void KNNEncode(struct prot *data, char *TrainFile, char *sbjFile, int outFormat, int fragLen, int encodeWindow, char *KValuesFile){
    char AA[]={'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', '-'};
    int BLOSUM62[21][21]={
       //A   R   N   D   C   Q   E   G   H   I   L   K   M   F   P   S   T   W   Y   V   -
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

    map<char, int> index;
    for(int i=0; i<21; i++){
        index.insert(pair<char, int>(AA[i], i));
    }

    float maxBlosum=11.0;
    float minBlosum=-4.0;

    //read the K values
    int numberOfK=0;
    int trainNumber=0;
    int *kValues=NULL;

    ifstream ifssub(KValuesFile);
    if(!ifssub){
        printMessage("Cannot open the K value setting file.");
    }
    string iStr;
    while(!ifssub.eof()){
        getline(ifssub, iStr);
        if(iStr.empty()) { continue; }
        numberOfK++;
    }
    ifssub.close();
    ifssub.clear();

    kValues=new int[numberOfK];


    ifssub.open(KValuesFile);
    if(!ifssub){
        printMessage("Cannot open the K value setting file.");
    }
    int k=0;
    while(!ifssub.eof() && k<numberOfK){
        getline(ifssub, iStr);
        if(iStr.empty()) { continue; }
        istringstream iStream(iStr);
        iStream>>kValues[k++];
    }
    ifssub.close();
    ifssub.clear();

    // read the train file into memory
    struct prot *trainHead=NULL, *trainTail=NULL;

    ifssub.open(TrainFile);
    if(!ifssub){
        printMessage("Cannot open the KNN train file.");
    }
    string tmpStr;
    while(!ifssub.eof()){
        getline(ifssub, tmpStr);
        if(tmpStr.empty()){ continue; }
        string str1, str2, str3;
        int tmpTag=0;
        istringstream iStream(tmpStr);
        iStream>>str1>>str2>>str3>>tmpTag;
        str3.replace(0, 1, "");
        struct prot *p=new prot;
        p->next=NULL;
        p->protSeq=str1;
        p->protName=str2;
        p->position=atoi(str3.c_str());
        p->tag=tmpTag;
        if(trainHead==NULL && trainTail==NULL){
            trainHead=trainTail=p;
        }
        else{
            trainTail->next=p;
            trainTail=p;
        }
        trainNumber++;
    }

    ifssub.close();
    ifssub.clear();

    // Calculate KNN feature

    struct prot *head=data;
    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 0){
        while(head != NULL){
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

            struct knnScore *knnHead=new knnScore[trainNumber];
            int scorePos=0;
            struct prot *tmpHead=trainHead;
            while(tmpHead != NULL){
                string tmpSeq=tmpHead->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                float tmpScore=0;
                for(int i=0; i<seq.length(); i++){
                    tmpScore+=((BLOSUM62[index[seq.at(i)]][index[tmpSeq.at(i)]]-minBlosum)/(maxBlosum - minBlosum));
                }
                tmpScore/=encodeWindow;

                knnHead[scorePos].score=1-tmpScore;
                knnHead[scorePos].tag=tmpHead->tag;
                scorePos++;

                tmpHead=tmpHead->next;
            }

            // sort
            for(int i=0; i<trainNumber; i++){
                for(int j=trainNumber-1; j>i; j--){
                    struct knnScore tmpKNNScore;
                    if(knnHead[j].score < knnHead[j-1].score){
                        tmpKNNScore.score=knnHead[j].score;
                        tmpKNNScore.tag=knnHead[j].tag;
                        knnHead[j].score=knnHead[j-1].score;
                        knnHead[j].tag=knnHead[j-1].tag;
                        knnHead[j-1].score=tmpKNNScore.score;
                        knnHead[j-1].tag=tmpKNNScore.tag;
                    }
                }
            }

            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int m=1;
            for(int i=0; i<numberOfK; i++){
                float poNumber=0;
                for(int j=0; j<kValues[i]; j++){
                    if(knnHead[j].tag == 1){
                        poNumber++;
                    }
                }
                ofssub<<m<<":"<<poNumber/kValues[i]<<"  ";
                m++;
            }
            ofssub<<endl;

            // free memory
            delete [] knnHead;

            head=head->next;
        }
    }
    else if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=numberOfK; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
        while(head != NULL){
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

            struct knnScore *knnHead=new knnScore[trainNumber];
            int scorePos=0;
            struct prot *tmpHead=trainHead;
            while(tmpHead != NULL){
                string tmpSeq=tmpHead->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                float tmpScore=0;
                for(int i=0; i<seq.length(); i++){
                    tmpScore+=((BLOSUM62[index[seq.at(i)]][index[tmpSeq.at(i)]]-minBlosum)/(maxBlosum - minBlosum));
                }
                tmpScore/=encodeWindow;

                knnHead[scorePos].score=1-tmpScore;
                knnHead[scorePos].tag=tmpHead->tag;
                scorePos++;

                tmpHead=tmpHead->next;
            }

            // sort
            for(int i=0; i<trainNumber; i++){
                for(int j=trainNumber-1; j>i; j--){
                    struct knnScore tmpKNNScore;
                    if(knnHead[j].score < knnHead[j-1].score){
                        tmpKNNScore.score=knnHead[j].score;
                        tmpKNNScore.tag=knnHead[j].tag;
                        knnHead[j].score=knnHead[j-1].score;
                        knnHead[j].tag=knnHead[j-1].tag;
                        knnHead[j-1].score=tmpKNNScore.score;
                        knnHead[j-1].tag=tmpKNNScore.tag;
                    }
                }
            }

            for(int i=0; i<numberOfK; i++){
                float poNumber=0;
                for(int j=0; j<kValues[i]; j++){
                    if(knnHead[j].tag == 1){
                        poNumber++;
                    }
                }
                ofssub<<poNumber/kValues[i]<<",";

            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }

            // free memory
            delete [] knnHead;

            head=head->next;
        }

    }
    else{
        printMessage("Unknown output format.");
    }

    ofssub.close();
    ofssub.clear();

    // free the memory
    while(trainHead != NULL){
        struct prot *p=trainHead;
        trainHead=trainHead->next;
        delete p;
    }
    trainHead=trainTail=NULL;

    delete kValues;
}

//
void KNNEncode_train(struct prot *data, char *TrainFile, char *sbjFile, int outFormat, int fragLen, int encodeWindow, char *KValuesFile){
    char AA[]={'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', '-'};
    int BLOSUM62[21][21]={
       //A   R   N   D   C   Q   E   G   H   I   L   K   M   F   P   S   T   W   Y   V   -
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

    map<char, int> index;
    for(int i=0; i<21; i++){
        index.insert(pair<char, int>(AA[i], i));
    }

    float maxBlosum=11.0;
    float minBlosum=-4.0;

    //read the K values
    int numberOfK=0;
    int trainNumber=0;
    int *kValues=NULL;

    ifstream ifssub(KValuesFile);
    if(!ifssub){
        printMessage("Cannot open the K value setting file.");
    }
    string iStr;
    while(!ifssub.eof()){
        getline(ifssub, iStr);
        if(iStr.empty()) { continue; }
        numberOfK++;
    }
    ifssub.close();
    ifssub.clear();

    kValues=new int[numberOfK];


    ifssub.open(KValuesFile);
    if(!ifssub){
        printMessage("Cannot open the K value setting file.");
    }
    int k=0;
    while(!ifssub.eof() && k<numberOfK){
        getline(ifssub, iStr);
        if(iStr.empty()) { continue; }
        istringstream iStream(iStr);
        iStream>>kValues[k++];
    }
    ifssub.close();
    ifssub.clear();

    // read the train file into memory
    struct prot *trainHead=NULL, *trainTail=NULL;

    ifssub.open(TrainFile);
    if(!ifssub){
        printMessage("Cannot open the KNN train file.");
    }
    string tmpStr;
    while(!ifssub.eof()){
        getline(ifssub, tmpStr);
        if(tmpStr.empty()){ continue; }
        string str1, str2, str3;
        int tmpTag=0;
        istringstream iStream(tmpStr);
        iStream>>str1>>str2>>str3>>tmpTag;
        str3.replace(0, 1, "");
        struct prot *p=new prot;
        p->next=NULL;
        p->protSeq=str1;
        p->protName=str2;
        p->position=atoi(str3.c_str());
        p->tag=tmpTag;
        if(trainHead==NULL && trainTail==NULL){
            trainHead=trainTail=p;
        }
        else{
            trainTail->next=p;
            trainTail=p;
        }
        trainNumber++;
    }

    ifssub.close();
    ifssub.clear();

    // Calculate KNN feature

    struct prot *head=data;
    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(outFormat == 0){
        while(head != NULL){
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

            struct knnScore *knnHead=new knnScore[trainNumber];
            int scorePos=0;
            struct prot *tmpHead=trainHead;
            while(tmpHead != NULL){
                if(tmpHead->protName.compare(head->protName) == 0 && tmpHead->position == head->position){
                    knnHead[scorePos].score=1;
                    knnHead[scorePos].tag=tmpHead->tag;
                    scorePos++;
                }
                else{
                    string tmpSeq=tmpHead->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                    float tmpScore=0;
                    for(int i=0; i<seq.length(); i++){
                        tmpScore+=((BLOSUM62[index[seq.at(i)]][index[tmpSeq.at(i)]]-minBlosum)/(maxBlosum - minBlosum));
                    }
                    tmpScore/=encodeWindow;

                    knnHead[scorePos].score=1-tmpScore;
                    knnHead[scorePos].tag=tmpHead->tag;
                    scorePos++;
                }

                tmpHead=tmpHead->next;
            }

            // sort
            for(int i=0; i<trainNumber; i++){
                for(int j=trainNumber-1; j>i; j--){
                    struct knnScore tmpKNNScore;
                    if(knnHead[j].score < knnHead[j-1].score){
                        tmpKNNScore.score=knnHead[j].score;
                        tmpKNNScore.tag=knnHead[j].tag;
                        knnHead[j].score=knnHead[j-1].score;
                        knnHead[j].tag=knnHead[j-1].tag;
                        knnHead[j-1].score=tmpKNNScore.score;
                        knnHead[j-1].tag=tmpKNNScore.tag;
                    }
                }
            }

            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int m=1;
            for(int i=0; i<numberOfK; i++){
                float poNumber=0;
                for(int j=0; j<kValues[i]; j++){
                    if(knnHead[j].tag == 1){
                        poNumber++;
                    }
                }
                ofssub<<m<<":"<<poNumber/kValues[i]<<"  ";
                m++;
            }
            ofssub<<endl;

            // free memory
            delete [] knnHead;

            head=head->next;
        }
    }
    else if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=numberOfK; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";
        while(head != NULL){
            string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);

            struct knnScore *knnHead=new knnScore[trainNumber];
            int scorePos=0;
            struct prot *tmpHead=trainHead;
            while(tmpHead != NULL){
                if(tmpHead->protName.compare(head->protName) == 0 && tmpHead->position == head->position){
                    knnHead[scorePos].score=1;
                    knnHead[scorePos].tag=tmpHead->tag;
                    scorePos++;
                }
                else{
                    string tmpSeq=tmpHead->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                    float tmpScore=0;
                    for(int i=0; i<seq.length(); i++){
                        tmpScore+=((BLOSUM62[index[seq.at(i)]][index[tmpSeq.at(i)]]-minBlosum)/(maxBlosum - minBlosum));
                    }
                    tmpScore/=encodeWindow;

                    knnHead[scorePos].score=1-tmpScore;
                    knnHead[scorePos].tag=tmpHead->tag;
                    scorePos++;
                }

                tmpHead=tmpHead->next;
            }

            // sort
            for(int i=0; i<trainNumber; i++){
                for(int j=trainNumber-1; j>i; j--){
                    struct knnScore tmpKNNScore;
                    if(knnHead[j].score < knnHead[j-1].score){
                        tmpKNNScore.score=knnHead[j].score;
                        tmpKNNScore.tag=knnHead[j].tag;
                        knnHead[j].score=knnHead[j-1].score;
                        knnHead[j].tag=knnHead[j-1].tag;
                        knnHead[j-1].score=tmpKNNScore.score;
                        knnHead[j-1].tag=tmpKNNScore.tag;
                    }
                }
            }

            for(int i=0; i<numberOfK; i++){
                float poNumber=0;
                for(int j=0; j<kValues[i]; j++){
                    if(knnHead[j].tag == 1){
                        poNumber++;
                    }
                }
                ofssub<<poNumber/kValues[i]<<",";

            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }

            // free memory
            delete [] knnHead;

            head=head->next;
        }

    }
    else{
        printMessage("Unknown output format.");
    }

    ofssub.close();
    ofssub.clear();

    // free the memory
    while(trainHead != NULL){
        struct prot *p=trainHead;
        trainHead=trainHead->next;
        delete p;
    }
    trainHead=trainTail=NULL;

    delete kValues;
}

