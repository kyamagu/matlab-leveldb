# Makefile for matlab-leveldb
WGET := wget
UNZIP := unzip
ECHO := echo
MATLABDIR ?= /usr/local/matlab
MATLAB := $(MATLABDIR)/bin/matlab
MEX := $(MATLABDIR)/bin/mex
MEXEXT := $(shell $(MATLABDIR)/bin/mexext)
MEXFLAGS := -Iinclude CXXFLAGS="\$$CXXFLAGS -std=c++11"
TARGET := +leveldb/private/LevelDB_.$(MEXEXT)

.PHONY: all test clean

all: $(TARGET)

$(TARGET): src/LevelDB_.cc
	$(MEX) -output $@ $< $(MEXFLAGS) -lleveldb

test: $(TARGET)
	$(ECHO) "run test/testLevelDB" | $(MATLAB) -nodisplay

clean:
	$(RM) $(TARGET)
