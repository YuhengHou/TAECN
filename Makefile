#
# OMNeT++/OMNEST Makefile for taecn
#
# This file was generated with the command:
#  opp_makemake -f --deep -o taecn -I../inet-4.5.4/src -L../inet-4.5.4/out/clang-release/src -lINET
#

# Name of target to be created (-o option)
TARGET_DIR = .
TARGET_NAME = taecn$(D)
TARGET = $(TARGET_NAME)$(EXE_SUFFIX)
TARGET_FILES = $(TARGET_DIR)/$(TARGET)

# User interface (-u option)
USERIF_LIBS = $(ALL_ENV_LIBS)

# C++ include paths (-I)
INCLUDE_PATH = -I../inet-4.5.4/src -I$(OMNETPP_INCL_DIR)

# Libraries (-L, -l)
LIBS = $(LDFLAG_LIBPATH)../inet-4.5.4/out/clang-release/src -lINET

# Output directories
PROJECT_OUTPUT_DIR = out
PROJECTRELATIVE_PATH =
O = $(PROJECT_OUTPUT_DIR)/$(CONFIGNAME)/$(PROJECTRELATIVE_PATH)

# 🔧 FIXED: object list now points to the correct flattened src/
OBJS = $O/src/TAECNQueue.o

# Message and state machine files
MSGFILES =
SMFILES =

# -------------------------------------------------------------------------
# Pull in OMNeT++ configuration
# -------------------------------------------------------------------------
ifneq ("$(OMNETPP_CONFIGFILE)","")
CONFIGFILE = $(OMNETPP_CONFIGFILE)
else
CONFIGFILE = $(shell opp_configfilepath)
endif

ifeq ("$(wildcard $(CONFIGFILE))","")
$(error Config file '$(CONFIGFILE)' does not exist -- add the OMNeT++ bin directory to PATH or set OMNETPP_CONFIGFILE)
endif

include $(CONFIGFILE)

OMNETPP_LIBS = $(OPPMAIN_LIB) $(USERIF_LIBS) $(KERNEL_LIBS) $(SYS_LIBS)
ifneq ($(PLATFORM),win32)
LIBS += -Wl,-rpath,$(abspath ../inet-4.5.4/out/clang-release/src)
endif

COPTS = $(CFLAGS) $(IMPORT_DEFINES) $(INCLUDE_PATH) -I$(OMNETPP_INCL_DIR)
MSGCOPTS = $(INCLUDE_PATH)
SMCOPTS =

COPTS_FILE = $O/.last-copts
ifneq ("$(COPTS)","$(shell cat $(COPTS_FILE) 2>/dev/null || echo '')")
  $(shell $(MKPATH) "$O")
  $(file >$(COPTS_FILE),$(COPTS))
endif

# -------------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------------
all: $(TARGET_FILES)

$(TARGET_DIR)/% :: $O/%
	@mkdir -p $(TARGET_DIR)
	$(Q)$(LN) $< $@
ifeq ($(TOOLCHAIN_NAME),clang-msabi)
	-$(Q)-$(LN) $(<:%.dll=%.lib) $(@:%.dll=%.lib) 2>/dev/null

$O/$(TARGET_NAME).pdb: $O/$(TARGET)
endif

$O/$(TARGET): $(OBJS) Makefile $(CONFIGFILE)
	@$(MKPATH) $O
	@echo "Creating executable: $@"
	$(Q)$(CXX) $(LDFLAGS) -o $O/$(TARGET) $(OBJS) $(AS_NEEDED_OFF) $(WHOLE_ARCHIVE_ON) $(LIBS) $(WHOLE_ARCHIVE_OFF) $(OMNETPP_LIBS)

.PHONY: all clean cleanall depend msgheaders smheaders

.SUFFIXES :
.PRECIOUS : %_m.h %_m.cc

$O/%.o: %.cc $(COPTS_FILE)
	@$(MKPATH) $(dir $@)
	$(qecho) "$<"
	$(Q)$(CXX) -c $(CXXFLAGS) $(COPTS) -o $@ $<

clean:
	$(qecho) Cleaning $(TARGET)
	$(Q)-rm -rf $O
	$(Q)-rm -f $(TARGET_FILES)
	$(Q)-rm -f $(call opp_rwildcard, . , *_m.cc *_m.h *_sm.cc *_sm.h)

cleanall:
	$(Q)$(CLEANALL_COMMAND)
	$(Q)-rm -rf $(PROJECT_OUTPUT_DIR)
