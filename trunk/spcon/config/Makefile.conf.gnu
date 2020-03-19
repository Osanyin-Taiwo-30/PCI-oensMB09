# spectral resolution
TRUNC=TQ0126
LEV=L028

# simultaneous parallel jobs & load average limit
MAXJOBS = 1
MAXLOAD = 1

# standard
SHELL     = sh
MAKE      = make
MAKEFILE  = Makefile
MAKEFLAGS = -r -j$(MAXJOBS) -l$(MAXLOAD)

# utils
ECHO    = echo
RM      = rm
CP      = cp
MV      = mv
CD      = cd
MKDIR   = mkdir
TAR     = tar
GZIP    = gzip
INSTALL = install

# dirs
HOME=/cray_home/carlos_bastarz/oensMB09
WORKDIR=$(HOME)

CPTECDIR=$(WORKDIR)
CPTECINC=$(CPTECDIR)/include

FFTPLN=$(CPTECDIR)/fftpln/source
EOFTEMP=$(CPTECDIR)/eoftemp/source  
EOFHUMI=$(CPTECDIR)/eofhumi/source
EOFWIND=$(CPTECDIR)/eofwind/source
DECEOF=$(CPTECDIR)/deceof/source
RECANL=$(CPTECDIR)/recanl/source
RDPERT=$(CPTECDIR)/rdpert/source
DECANL=$(CPTECDIR)/decanl/source
RECFCT=$(CPTECDIR)/recfct/source
EOFPRES=$(CPTECDIR)/eofpres/source

# preprocessor, compilers, linker & archiver
FC  = ftn 
F77 = ftn 
LD  = ftn 
AR  = ar

# default flags
ARFLAGS  = -r

# add flags for debugging if requested
ifeq (dbg,$(findstring dbg,$(mode)))
	CCFLAGS += -DDEBUG -g
	FFLAGS  += -g -fconvert=big-endian -fdefault-real-8 
	LDFLAGS += -g 
endif

# add flags for optimization if requested
ifeq (opt,$(findstring opt,$(mode)))
	FFLAGS  +=  -g -fconvert=big-endian -fdefault-real-8 
	LDFLAGS += 
endif
