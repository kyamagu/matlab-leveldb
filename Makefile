# Makefile for matlab-leveldb
LEVELDB_VERSION ?= 1.18
LEVELDB_DIR := leveldb-$(LEVELDB_VERSION)
LEVELDB_URL := "https://github.com/google/leveldb/archive/v$(LEVELDB_VERSION).zip"
MAKE := make
RM := rm
WGET := wget
UNZIP := unzip
ECHO := echo
MATLABDIR ?= /usr/local/matlab
MATLAB := $(MATLABDIR)/bin/matlab
MEX := $(MATLABDIR)/bin/mex
MEXEXT := $(shell $(MATLABDIR)/bin/mexext)
MEXFLAGS := -Iinclude -I$(LEVELDB_DIR)/include
TARGET := +leveldb/private/LevelDB_.$(MEXEXT)

.PHONY: all test clean clean_all

all: $(TARGET)

$(TARGET): src/LevelDB_.cc $(LEVELDB_DIR)/libleveldb.a
	$(MEX) -output $@ $< $(MEXFLAGS) $(LEVELDB_DIR)/libleveldb.a

$(LEVELDB_DIR)/libleveldb.a: $(LEVELDB_DIR)
	make -C $(LEVELDB_DIR)

$(LEVELDB_DIR):
	$(WGET) $(LEVELDB_URL)
	$(UNZIP) v$(LEVELDB_VERSION).zip

test: $(TARGET)
	$(ECHO) "run test/testLevelDB" | $(MATLAB) -nodisplay

clean:
	$(MAKE) -C $(LEVELDB_DIR) clean
	$(RM) $(TARGET)

clean_all:
	$(RM) -rf v$(LEVELDB_VERSION).zip $(TARGET) $(LEVELDB_DIR)
