# This Makefile should be used for building with the gnu compiler.

# If libtiff is installed in a nonstandard location you must edit 
# TIFFPATH and uncomment the following three lines.
#TIFFPATH=/fs/project/PZS0530/setsm/tiff-4.0.3
#TIFFINC=-I$(TIFFPATH)/include
#TIFFLIB=-L$(TIFFPATH)/lib

CC=gcc
CSWITCHES =-std=c99 -O3 -fopenmp -g -DLINUX -I/usr/X11R6/include -L/usr/X11R6/lib
TRILIBDEFS = -DTRILIBRARY
VDEFS = -DVLIBRARY
MPICC=mpicc
CFLAGS=-std=c99 -O3 -fopenmp -ffast-math -march=native
GFLAGS=$(CFLAGS) -g
MPICFLAGS=$(CFLAGS) -DbuildMPI

INCS=$(TIFFINC)
LDFLAGS=$(TIFFLIB)

setsm : setsm_code.o voronoi.o
	$(CC) $(GFLAGS)  -o setsm setsm_code.o voronoi.o $(LDFLAGS) -lm -ltiff

setsm_code.o : Typedefine.h setsm_code.h setsm_code.c voronoi.o
	$(CC) $(GFLAGS) $(INCS) $(VDEFS) -c setsm_code.c

voronoi.o: voronoi.c voronoi.h
	$(CC) $(CSWITCHES) $(VDEFS) -c -o voronoi.o voronoi.c

MPI : setsm_code_mpi.o
	$(MPICC) $(MPICFLAGS) -o setsm setsm_code_mpi.o $(LDFLAGS) -lm -ltiff

setsm_code_mpi.o : Typedefine.h setsm_code.h setsm_code.c
	$(MPICC) $(MPICFLAGS) $(INCS) -o setsm_code_mpi.o -c setsm_code.c

.PHONY: clean

clean :
	rm -f setsm
	rm -f *.o

