#include "encodingFunctions_1.h"

using namespace std;

// encoding functions
// AAindex encoding scheme
void AAindexEncode(struct prot *data, char *aaindexFeature, char *featureSelection, char *selectedFeature, char *sbjFile, int outFormat, int fragLen, int encodeWindow);
// charge/hydrophobicity ratio encoding scheme
void chargeHydRatioEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow);


// function bodys
// AAindex encoding scheme
void AAindexEncode(struct prot *data, char *aaindexFeature, char *featureSelection, char *selectedFeature, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V'};
    map<char, int> order;
    map<int, float*> AAindex;
    int featureNumber=0;
    int AAType=20;

    // Initialize the order
    for(int i=0; i<AAType; i++){
        order.insert(pair<char, int>(AA[i], i));
    }

    string iStr;
    int m=0;

    // read the AAindex
    ifstream ifssub(aaindexFeature);
    if(!ifssub){
        printMessage("Cannot open the AAindex file.");
    }
    while(!ifssub.eof()){
        getline(ifssub, iStr);
        if(iStr.empty()){ continue; }
        float *tmp=new float[20];
        istringstream iStream(iStr);
        string tmpSeq;
        iStream>>tmpSeq;

        int i=0;
        while(iStream>>tmp[i] && i<20){ i++; }
        AAindex.insert(pair<int, float*>(m, tmp));

        featureNumber++;
        m++;
    }
    ifssub.close();
    ifssub.clear();

    struct prot *head=data;
    int centralSite=encodeWindow/2;

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    if(strcmp(featureSelection, "N") == 0){
        if(outFormat==0){
            while(head != NULL){
                if(head->tag ==1){
                    ofssub<<"+1  ";
                }
                else{
                    ofssub<<"-1  ";
                }

                int posIndex=1;
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                for(int i=0; i<seq.length(); i++){
//                    if(i == centralSite){ continue; }
                    if(seq.at(i)=='0'){
                        for(int j=0; j<featureNumber; j++){
                            ofssub<<posIndex<<":0  ";
                            posIndex++;
                        }
                    }
                    else{
                        for(int j=0; j<featureNumber; j++){
                            ofssub<<posIndex<<":"<<AAindex[j][order[seq.at(i)]]<<"  ";
                            posIndex++;
                        }
                    }
                }
                ofssub<<endl;
                head=head->next;
            }
        }
        else if(outFormat == 1){
            ofssub<<"@relation features\n\n";
            for(int i=1; i<=encodeWindow * featureNumber; i++){
                ofssub<<"@attribute f"<<i<<" real\n";
            }
            ofssub<<"@attribute play {yes, no}\n\n";
            ofssub<<"@data\n";

            while(head != NULL){
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                for(int i=0; i<seq.length(); i++){
//                    if(i == centralSite){ continue; }
                    if(seq.at(i)=='-'){
                        for(int j=0; j<featureNumber; j++){
                            ofssub<<"0,";
                        }
                    }
                    else{
                        for(int j=0; j<featureNumber; j++){
                            ofssub<<AAindex[j][order[seq.at(i)]]<<",";
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
            printMessage("Unknown output format parameter.");
        }
    }
    else if(strcmp(featureSelection, "Y") == 0){
        map<int, int> phyChemFea;
        string iStr;
        int FeaNum=0;
        ifstream ifssub(selectedFeature);
        if(!ifssub){
            printMessage("Cannot open the selected phyChem feature file.");
        }
        while(!ifssub.eof()){
            getline(ifssub, iStr);
            if(iStr.empty()){ continue; }
            istringstream iStream(iStr);
            int tmpFeature;
            iStream>>tmpFeature;
            phyChemFea.insert(pair<int, int>(tmpFeature, 1));
            FeaNum++;
        }
        ifssub.close();
        ifssub.clear();

        if(outFormat==0){
            while(head != NULL){
                if(head->tag ==1){
                    ofssub<<"+1  ";
                }
                else{
                    ofssub<<"-1  ";
                }

                int posIndex=1;
                int posIndex_1=1;
                string seq=head->protSeq.substr((int)((fragLen/2)-int(encodeWindow/2)), encodeWindow);
                for(int i=0; i<seq.length(); i++){
//                    if(i == centralSite){ continue; }
                    if(seq.at(i)=='-'){
                        for(int j=0; j<featureNumber; j++){
                            if(phyChemFea.find(posIndex) != phyChemFea.end()){
                                ofssub<<posIndex_1<<":0  ";
                                posIndex_1++;
                            }
                            posIndex++;
                        }
                    }
                    else{
                        for(int j=0; j<featureNumber; j++){
                            if(phyChemFea.find(posIndex) != phyChemFea.end()){
                                ofssub<<posIndex_1<<":"<<AAindex[j][order[seq.at(i)]]<<"  ";
                                posIndex_1++;
                            }
                            posIndex++;
                        }
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
                for(int i=0; i<seq.length(); i++){
//                    if(i == centralSite){ continue; }
                    if(seq.at(i)=='-'){
                        for(int j=0; j<featureNumber; j++){
                            if(phyChemFea.find(posIndex) != phyChemFea.end()){
                                ofssub<<"0,";
                            }
                            posIndex++;
                        }
                    }
                    else{
                        for(int j=0; j<featureNumber; j++){
                            if(phyChemFea.find(posIndex) != phyChemFea.end()){
                                ofssub<<AAindex[j][order[seq.at(i)]]<<",";
                            }
                            posIndex++;
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
            printMessage("Unknown output format parameter.");
        }
    }
    else{
        printMessage("Unknown parameter for AAindex encoding scheme.");
    }

    ofssub.close();
    ofssub.clear();

    // free the memory
    for (map<int, float*>::iterator it=AAindex.begin(); it!=AAindex.end(); ++it){
        float *p=it->second;
        AAindex[it->first]=NULL;
        delete p;
    }
}


// charge/hydrophobicity ratio encoding scheme
void chargeHydRatioEncode(struct prot *data, char *sbjFile, int outFormat, int fragLen, int encodeWindow){
    char AA[]={'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V'};
    int netCharge[]={0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0};
    // normalized hydrophobicity for each amino acids
    float hydrophobicity[]={0.7, 0, 0.111111, 0.111111, 0.777778, 0.111111, 0.111111, 0.455556, 0.144444, 1, 0.922222, 0.066667, 0.711111, 0.811111, 0.322222, 0.411111, 0.422222, 0.4, 0.355556, 0.966667};
    int slideWindow[7]={3, 7, 11, 21, 27, 31, 41};
    int windowNumber=0;
    for(int i=0; i<6; i++){
        if(slideWindow[i] <= encodeWindow) { windowNumber++; }
    }

    map<char, int> order;
    int AAType=20;

    // Initialize the order
    for(int i=0; i<AAType; i++){
        order.insert(pair<char, int>(AA[i], i));
    }

    ofstream ofssub(sbjFile);
    if(!ofssub){
        printMessage("Cannot open the output file.");
    }

    struct prot *head=data;
    if(outFormat == 0){
        while(head != NULL){
            float *meanHyd=new float[fragLen];
            for(int i=0; i< head->protSeq.length(); i++){
                float meanHydScore=0;
                for(int j=i-2; j<=i+2; j++){
                    if(j<0 || j>=fragLen){
                        meanHydScore+=0;
                    }
                    else{
                        meanHydScore+=hydrophobicity[order[head->protSeq.at(j)]];
                    }
                }
                meanHydScore/=5;
                meanHyd[i]=meanHydScore;
            }

            if(head->tag == 1){
                ofssub<<"+1  ";
            }
            else{
                ofssub<<"-1  ";
            }

            int centralPos=fragLen/2;
            int m=1;
            // mean net charge
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float meanNetChargeScore=0;
                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    meanNetChargeScore+=netCharge[order[head->protSeq.at(tmpPos)]];
                }
                meanNetChargeScore/=slideWindow[i];
                ofssub<<m<<":"<<meanNetChargeScore<<"  ";
                m++;
            }

            // aromatic content
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float aromaticContent=0;
                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    if(head->protSeq.at(tmpPos) == 'F' || head->protSeq.at(tmpPos) == 'Y' || head->protSeq.at(tmpPos) == 'W'){
                        aromaticContent++;
                    }
                }
                aromaticContent/=slideWindow[i];
                ofssub<<m<<":"<<aromaticContent<<"  ";
                m++;
            }

            // charge/hydrophobicity ratio
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float chargeScore=0;
                float hydScore=0;

                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    chargeScore+=netCharge[order[head->protSeq.at(tmpPos)]];
                    hydScore+=hydrophobicity[order[head->protSeq.at(tmpPos)]];
                }
                if(hydScore != 0)
				{
					ofssub<<m<<":"<<chargeScore/hydScore<<"  ";
                }
				else
				{
					ofssub<<m<<":"<<"0"<<"  ";
				}
				m++;
            }
            ofssub<<endl;
            delete [] meanHyd;
            head=head->next;
        }
    }
    else if(outFormat == 1){
        ofssub<<"@relation features\n\n";
        for(int i=1; i<=3 * windowNumber; i++){
            ofssub<<"@attribute f"<<i<<" real\n";
        }
        ofssub<<"@attribute play {yes, no}\n\n";
        ofssub<<"@data\n";

        while(head != NULL){
            float *meanHyd=new float[fragLen];
            for(int i=0; i< head->protSeq.length(); i++){
                float meanHydScore=0;
                for(int j=i-2; j<=i+2; j++){
                    if(j<0 || j>=fragLen){
                        meanHydScore+=0;
                    }
                    else{
                        meanHydScore+=hydrophobicity[order[head->protSeq.at(j)]];
                    }
                }
                meanHydScore/=5;
                meanHyd[i]=meanHydScore;
            }

            int centralPos=fragLen/2;
            // mean net charge
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float meanNetChargeScore=0;
                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    meanNetChargeScore+=netCharge[order[head->protSeq.at(tmpPos)]];
                }
                meanNetChargeScore/=slideWindow[i];
                ofssub<<meanNetChargeScore<<",";

            }

            // aromatic content
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float aromaticContent=0;
                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    if(head->protSeq.at(tmpPos) == 'F' || head->protSeq.at(tmpPos) == 'Y' || head->protSeq.at(tmpPos) == 'W'){
                        aromaticContent++;
                    }
                }
                aromaticContent/=slideWindow[i];
                ofssub<<aromaticContent<<",";
            }

            // charge/hydrophobicity ratio
            for(int i=0; i<windowNumber; i++){
                int halfWindow=slideWindow[i]/2;
                float chargeScore=0;
                float hydScore=0;

                for(int tmpPos=centralPos-halfWindow; tmpPos<=centralPos+halfWindow; tmpPos++){
                    chargeScore+=netCharge[order[head->protSeq.at(tmpPos)]];
                    hydScore+=hydrophobicity[order[head->protSeq.at(tmpPos)]];
                }
                ofssub<<chargeScore/hydScore<<",";

            }
            if(head->tag == 1){
                ofssub<<"yes"<<endl;
            }
            else{
                ofssub<<"no"<<endl;
            }
            delete [] meanHyd;
            head=head->next;
        }
    }
    else{
        printMessage("Unknown output format.");
    }

    ofssub.close();
    ofssub.clear();
}
