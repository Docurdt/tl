######################################################################
#       Makefile for cncode 1.0                                      #
######################################################################

encode: encode.o
	g++ -o encode encode.o

encode.o: encode.cc data.h messageFunctions.h encodingFunctions.h encodingFunctions_1.h aaindexencoding.h knn.h
	g++ -c encode.cc

clean:
	rm encode encode.o
