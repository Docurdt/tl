#include "knn.h"


using namespace std;

int main(int argc, char *argv[])
{
    if(argc < 3){
        printHelp(argv[0]);
    }

    //read the parameters
    for(int i=1; i<argc; i++){
        // input
        if(strcmp(argv[i], "-i")==0){
            inputFile=argv[i+1];
        }

        // output
        if(strcmp(argv[i], "-o")==0){
            outputFile=argv[i+1];
        }

        // output format
        if(strcmp(argv[i], "-m")==0){
            outputFormat=atoi(argv[i+1]);
        }

        // encode type
        if(strcmp(argv[i], "-t")==0){
            encodeType=argv[i+1];
        }

        // PSSM file directory
        if(strcmp(argv[i], "-p")==0){
            pssmFileDirectory=argv[i+1];
        }

        // disorder file directory
        if(strcmp(argv[i], "-d")==0){
            disorderFileDirectory=argv[i+1];
        }


        // cksaap k value
        if(strcmp(argv[i], "-ck")==0){
            cksaap_kv=atoi(argv[i+1]);
        }



        // agg file directory
        if(strcmp(argv[i], "-a")==0){
            aggFileDirectory=argv[i+1];
        }

        // AAindex
        if(strcmp(argv[i], "-f")==0){
            ifFeatureSelection=argv[i+1];
        }
        if(strcmp(argv[i], "-F")==0){
            selectedFeatureFile=argv[i+1];
        }

        // KNN
        if(strcmp(argv[i], "-Train") == 0){
            knnTrainFile=argv[i+1];
        }
        if(strcmp(argv[i], "-K") == 0){
            topKFile=argv[i+1];
        }

        // Fragment and encode window
        if(strcmp(argv[i], "-L") == 0){
            seqLen=atoi(argv[i+1]);
        }
        if(strcmp(argv[i], "-W") == 0){
            window=atoi(argv[i+1]);
        }
    }

    // read the file input memory

    struct prot *head=NULL, *tail=NULL;

    ifstream icin(inputFile);
    if(!icin){
        printMessage("Can not open the input file!");
    }
    string tmpStr;
    while(!icin.eof()){
        getline(icin, tmpStr);
        if(!tmpStr.empty()){
            string str1, str2, str3;
            int tmpTag=0;
            istringstream iStream(tmpStr);
            iStream>>str1>>str2>>str3>>tmpTag;
        //    str3.replace(0, 1, "");
            struct prot *p=new prot;
            p->next=NULL;
            p->protSeq=str1;
            p->protName=str2;
            p->position=(atoi(str3.c_str())+8);
            p->tag=tmpTag;
            if(head==NULL && tail==NULL){
                head=tail=p;
            }
            else{
                tail->next=p;
                tail=p;
            }
        }
    }
    icin.close();
    icin.clear();


    if(strcmp(encodeType, "cksaap") == 0){
        CKSAAPEncode_2(head, outputFile, ifFeatureSelection, selectedFeatureFile, outputFormat, seqLen, window, cksaap_kv);
    }
    else if(strcmp(encodeType, "binary") == 0){
        binaryEncode(head, outputFile, outputFormat, seqLen, window);
    }
    else if(strcmp(encodeType, "pssm") == 0){
        PSSMEncode(head, pssmFileDirectory, outputFile, outputFormat, window);
    }
    else if(strcmp(encodeType, "pssm-S") == 0){
        PSSMEncodeSlideWindow(head, pssmFileDirectory, outputFile, outputFormat, window);
    }
    else if(strcmp(encodeType, "AAC") == 0){
        AAContentEncode(head, outputFile, outputFormat, seqLen, window);
    }
    else if(strcmp(encodeType, "AAC-S") == 0){
        AAContentEncodeSlideWindow(head, outputFile, outputFormat, seqLen, window);
    }
    else if(strcmp(encodeType, "disorder") == 0){
        DisorderEncode(head, disorderFileDirectory, outputFile, outputFormat, window);
    }
    else if(strcmp(encodeType, "disorder-S") == 0){
        DisorderEncodeSlideWindow(head, disorderFileDirectory, outputFile, outputFormat, window);
    }
    else if(strcmp(encodeType, "agg") == 0){
        AggEncode(head, aggFileDirectory, outputFile, outputFormat, window);
    }
    else if(strcmp(encodeType, "blosum62") == 0){
        blosum62Encode(head, outputFile, outputFormat, seqLen, window);
    }
    else if(strcmp(encodeType, "aaindex") == 0){
        char AAindexFile[buffer];
        char AAindexDir[buffer];
        readlink ("/proc/self/exe", AAindexFile, buffer);
        for(int i=strlen(AAindexFile)-1; i>=0; i--){
            if(AAindexFile[i] == '/'){
                AAindexFile[i]='\0';
                break;
            }
        }
        strcpy(aaindexFile, AAindexFile);
        strcat(aaindexFile, "/AAindex/AAindex.txt");
        AAindexEncode(head, aaindexFile, ifFeatureSelection, selectedFeatureFile, outputFile,outputFormat, seqLen, window);
    }
    else if(strcmp(encodeType, "knn") == 0){
        KNNEncode(head, knnTrainFile, outputFile, outputFormat, seqLen, window, topKFile);
    }
    else if(strcmp(encodeType, "knn-train") == 0){
        KNNEncode_train(head, knnTrainFile, outputFile, outputFormat, seqLen, window, topKFile);
    }
    else if(strcmp(encodeType, "charge-hyd") == 0){
        chargeHydRatioEncode(head, outputFile, outputFormat, seqLen, window);
    }
    else{
        cout<<"Unknown encoding scheme.\n";
        printHelp(argv[0]);
    }

    // free the memory
    while(head != NULL){
        struct prot *p=head;
        head=head->next;
        delete p;
    }
    head=tail=NULL;

    return 0;
}


