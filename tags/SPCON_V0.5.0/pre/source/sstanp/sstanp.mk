#!/bin/sh -x

SHELL=/bin/sh
EXT=$(TRUNC)
DIR=$(SOPERMOD)/pre/bin/sstanp/$(EXT)

OBJ = \
sstanp.$(EXT) epslon.$(EXT) fax.$(EXT)    fft991.$(EXT) fft99a.$(EXT) \
fft99b.$(EXT) fftpln.$(EXT) fftrig.$(EXT) gl.$(EXT)     glats.$(EXT)  \
nterp.$(EXT)  pln2.$(EXT)   ply.$(EXT)    poly.$(EXT)   rectrg.$(EXT) \
reset.$(EXT)  sumpln.$(EXT) transp.$(EXT) vpassm.$(EXT) wterp.$(EXT)

PROG=$(DIR)/sstanp.$(EXT)

all:	 $(PROG)

$(PROG): $(OBJ)
	 ar rcv $(DIR)/objects.a $(DIR)/*.o
	 rm $(DIR)/*.o
	 ar x $(DIR)/objects.a $(DIR)/sstanp.o
	 $(F77) $(FTNFLAG) -o $(PROG) $(DIR)/sstanp.o $(DIR)/objects.a

.SUFFIXES : .f .$(EXT)
.f.$(EXT):
	 $(F77) -I$(INC) $(FTNFLAG) -c -o $(DIR)/$*.o $<
	 touch $*.$(EXT)

clean:
	 -rm $(DIR)/objects.a
	 -rm $(DIR)/*.o *.$(EXT)
	 -rm $(PROG)
#
sstanp.$(EXT): $(INC)/reshsst.h
fftpln.$(EXT): $(INC)/reshsst.h
rectrg.$(EXT): $(INC)/reshsst.h
sumpln.$(EXT): $(INC)/reshsst.h
