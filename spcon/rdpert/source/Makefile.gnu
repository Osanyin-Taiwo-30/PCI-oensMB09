include ../../config/Makefile.conf.$(comp)

SOPERMOD = $(WORKDIR)
INC = $(SOPERMOD)/rdpert/include

EXT = $(TRUNC)$(LEV)
DIR = $(SOPERMOD)/rdpert/bin/$(EXT)

FTNFLAG = -g -fconvert=big-endian -fdefault-real-8
CPP = -I\$(INC)
F_UFMTIEEE = 10,20

OBJ = rdpert.$(EXT) \
fread.$(EXT)  fwrite.$(EXT) gasdev.$(EXT) glatd.$(EXT)  gsctij.$(EXT) \
pertur.$(EXT) pln0.$(EXT)   ran1.$(EXT)   varave.$(EXT)

PROG = $(DIR)/rdpert.$(EXT)

all:     $(PROG)

$(PROG): $(OBJ)
	 ar rcv $(DIR)/rdpert.a $(DIR)/*.o
	 ar x $(DIR)/rdpert.a $(DIR)/rdpert.o
	 $(F77) $(FTNFLAG) -o $(PROG) $(DIR)/rdpert.o $(DIR)/rdpert.a
	 -rm $(DIR)/*.o

.SUFFIXES : .f .$(EXT)
.f.$(EXT):
	$(F77) $(CPP) $(FTNFLAG) -c -o $(DIR)/$*.o $<

clean:
	-rm $(DIR)/rdpert.a
	-rm $(DIR)/*.o *.$(EXT) #i.*.f
	-rm $(PROG)
	-rm *.o

rdpert.$(EXT): $(INC)/rdpert.h 
fread.$(EXT):  $(INC)/rdpert.h
fwrite.$(EXT): $(INC)/rdpert.h
