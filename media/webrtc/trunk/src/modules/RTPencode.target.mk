# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := RTPencode
DEFS_Debug := '-DNO_HEAPCHECKER' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DWEBRTC_TARGET_PC' \
	'-DWEBRTC_LINUX' \
	'-DWEBRTC_THREAD_RR' \
	'-DCODEC_ILBC' \
	'-DCODEC_PCM16B' \
	'-DCODEC_G711' \
	'-DCODEC_G722' \
	'-DCODEC_ISAC' \
	'-DCODEC_PCM16B_WB' \
	'-DCODEC_ISAC_SWB' \
	'-DCODEC_PCM16B_32KHZ' \
	'-DCODEC_CNGCODEC8' \
	'-DCODEC_CNGCODEC16' \
	'-DCODEC_CNGCODEC32' \
	'-DCODEC_ATEVENT_DECODE' \
	'-DCODEC_RED' \
	'-D__STDC_FORMAT_MACROS' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=1' \
	'-DWTF_USE_DYNAMIC_ANNOTATIONS=1' \
	'-D_DEBUG'

# Flags passed to all source files.
CFLAGS_Debug := -Werror \
	-pthread \
	-fno-exceptions \
	-Wall \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-fno-strict-aliasing \
	-O0 \
	-g

# Flags passed to only C files.
CFLAGS_C_Debug := 

# Flags passed to only C++ files.
CFLAGS_CC_Debug := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-Wsign-compare

INCS_Debug := -Isrc \
	-I. \
	-Isrc/modules/audio_coding/NetEQ/main/interface \
	-Isrc/modules/audio_coding/NetEQ/main/test \
	-Isrc/modules/audio_coding/codecs/G711/main/interface \
	-Isrc/modules/audio_coding/codecs/G722/main/interface \
	-Isrc/modules/audio_coding/codecs/PCM16B/main/interface \
	-Isrc/modules/audio_coding/codecs/iLBC/main/interface \
	-Isrc/modules/audio_coding/codecs/iSAC/main/interface \
	-Isrc/modules/audio_coding/codecs/CNG/main/interface \
	-Isrc/common_audio/vad/main/interface

DEFS_Release := '-DNO_HEAPCHECKER' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DWEBRTC_TARGET_PC' \
	'-DWEBRTC_LINUX' \
	'-DWEBRTC_THREAD_RR' \
	'-DCODEC_ILBC' \
	'-DCODEC_PCM16B' \
	'-DCODEC_G711' \
	'-DCODEC_G722' \
	'-DCODEC_ISAC' \
	'-DCODEC_PCM16B_WB' \
	'-DCODEC_ISAC_SWB' \
	'-DCODEC_PCM16B_32KHZ' \
	'-DCODEC_CNGCODEC8' \
	'-DCODEC_CNGCODEC16' \
	'-DCODEC_CNGCODEC32' \
	'-DCODEC_ATEVENT_DECODE' \
	'-DCODEC_RED' \
	'-D__STDC_FORMAT_MACROS' \
	'-DNDEBUG' \
	'-DNVALGRIND' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=0'

# Flags passed to all source files.
CFLAGS_Release := -Werror \
	-pthread \
	-fno-exceptions \
	-Wall \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-fno-strict-aliasing \
	-O2 \
	-fno-ident \
	-fdata-sections \
	-ffunction-sections

# Flags passed to only C files.
CFLAGS_C_Release := 

# Flags passed to only C++ files.
CFLAGS_CC_Release := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden \
	-Wsign-compare

INCS_Release := -Isrc \
	-I. \
	-Isrc/modules/audio_coding/NetEQ/main/interface \
	-Isrc/modules/audio_coding/NetEQ/main/test \
	-Isrc/modules/audio_coding/codecs/G711/main/interface \
	-Isrc/modules/audio_coding/codecs/G722/main/interface \
	-Isrc/modules/audio_coding/codecs/PCM16B/main/interface \
	-Isrc/modules/audio_coding/codecs/iLBC/main/interface \
	-Isrc/modules/audio_coding/codecs/iSAC/main/interface \
	-Isrc/modules/audio_coding/codecs/CNG/main/interface \
	-Isrc/common_audio/vad/main/interface

OBJS := $(obj).target/$(TARGET)/src/modules/audio_coding/NetEQ/main/test/RTPencode.o

# Add to the list of files we specially track dependencies for.
all_deps += $(OBJS)

# Make sure our dependencies are built before any of us.
$(OBJS): | $(obj).target/src/modules/libNetEqTestTools.a $(obj).target/src/modules/libG711.a $(obj).target/src/modules/libG722.a $(obj).target/src/modules/libPCM16B.a $(obj).target/src/modules/libiLBC.a $(obj).target/src/modules/libiSAC.a $(obj).target/src/modules/libCNG.a $(obj).target/src/common_audio/libvad.a $(obj).target/src/common_audio/libspl.a

# CFLAGS et al overrides must be target-local.
# See "Target-specific Variable Values" in the GNU Make manual.
$(OBJS): TOOLSET := $(TOOLSET)
$(OBJS): GYP_CFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE)) $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_C_$(BUILDTYPE))
$(OBJS): GYP_CXXFLAGS := $(DEFS_$(BUILDTYPE)) $(INCS_$(BUILDTYPE)) $(CFLAGS_$(BUILDTYPE)) $(CFLAGS_CC_$(BUILDTYPE))

# Suffix rules, putting all outputs into $(obj).

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(srcdir)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

# Try building from generated source, too.

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj).$(TOOLSET)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

$(obj).$(TOOLSET)/$(TARGET)/%.o: $(obj)/%.cc FORCE_DO_CMD
	@$(call do_cmd,cxx,1)

# End of this set of suffix rules
### Rules for final target.
LDFLAGS_Debug := -pthread \
	-Wl,-z,noexecstack

LDFLAGS_Release := -pthread \
	-Wl,-z,noexecstack \
	-Wl,-O1 \
	-Wl,--as-needed \
	-Wl,--gc-sections

LIBS := 

$(builddir)/RTPencode: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(builddir)/RTPencode: LIBS := $(LIBS)
$(builddir)/RTPencode: LD_INPUTS := $(OBJS) $(obj).target/src/modules/libNetEqTestTools.a $(obj).target/src/modules/libG711.a $(obj).target/src/modules/libG722.a $(obj).target/src/modules/libPCM16B.a $(obj).target/src/modules/libiLBC.a $(obj).target/src/modules/libiSAC.a $(obj).target/src/modules/libCNG.a $(obj).target/src/common_audio/libvad.a $(obj).target/src/common_audio/libspl.a
$(builddir)/RTPencode: TOOLSET := $(TOOLSET)
$(builddir)/RTPencode: $(OBJS) $(obj).target/src/modules/libNetEqTestTools.a $(obj).target/src/modules/libG711.a $(obj).target/src/modules/libG722.a $(obj).target/src/modules/libPCM16B.a $(obj).target/src/modules/libiLBC.a $(obj).target/src/modules/libiSAC.a $(obj).target/src/modules/libCNG.a $(obj).target/src/common_audio/libvad.a $(obj).target/src/common_audio/libspl.a FORCE_DO_CMD
	$(call do_cmd,link)

all_deps += $(builddir)/RTPencode
# Add target alias
.PHONY: RTPencode
RTPencode: $(builddir)/RTPencode

