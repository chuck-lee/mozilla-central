# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := libjingle_app
DEFS_Debug := '-DFEATURE_ENABLE_SSL' \
	'-DFEATURE_ENABLE_VOICEMAIL' \
	'-D_USE_32BIT_TIME_T' \
	'-DSAFE_TO_DEFINE_TALK_BASE_LOGGING_MACROS' \
	'-DEXPAT_RELATIVE_PATH' \
	'-DJSONCPP_RELATIVE_PATH' \
	'-DWEBRTC_RELATIVE_PATH' \
	'-DHAVE_WEBRTC' \
	'-DHAVE_WEBRTC_VIDEO' \
	'-DHAVE_WEBRTC_VOICE' \
	'-DNO_HEAPCHECKER' \
	'-DLINUX' \
	'-DPOSIX' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=1' \
	'-DWTF_USE_DYNAMIC_ANNOTATIONS=1' \
	'-D_DEBUG'

# Flags passed to all source files.
CFLAGS_Debug := -pthread \
	-fno-exceptions \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-fno-strict-aliasing \
	-Wno-deprecated \
	-Wno-format \
	-Wno-unused-result \
	-O0 \
	-g

# Flags passed to only C files.
CFLAGS_C_Debug := 

# Flags passed to only C++ files.
CFLAGS_CC_Debug := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden

INCS_Debug := -Isrc \
	-Ithird_party_mods/libjingle/source \
	-Ithird_party/libjingle/source \
	-Ithird_party/expat/files \
	-Ithird_party/jsoncpp/include \
	-Isrc/modules/video_capture/main/interface \
	-Isrc/modules/interface \
	-Isrc/common_video/vplib/main/interface \
	-Isrc/modules/video_render/main/interface \
	-Isrc/video_engine/main/interface \
	-Isrc/voice_engine/main/interface \
	-Isrc/system_wrappers/interface

DEFS_Release := '-DFEATURE_ENABLE_SSL' \
	'-DFEATURE_ENABLE_VOICEMAIL' \
	'-D_USE_32BIT_TIME_T' \
	'-DSAFE_TO_DEFINE_TALK_BASE_LOGGING_MACROS' \
	'-DEXPAT_RELATIVE_PATH' \
	'-DJSONCPP_RELATIVE_PATH' \
	'-DWEBRTC_RELATIVE_PATH' \
	'-DHAVE_WEBRTC' \
	'-DHAVE_WEBRTC_VIDEO' \
	'-DHAVE_WEBRTC_VOICE' \
	'-DNO_HEAPCHECKER' \
	'-DLINUX' \
	'-DPOSIX' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DNDEBUG' \
	'-DNVALGRIND' \
	'-DDYNAMIC_ANNOTATIONS_ENABLED=0'

# Flags passed to all source files.
CFLAGS_Release := -pthread \
	-fno-exceptions \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-D_FILE_OFFSET_BITS=64 \
	-fvisibility=hidden \
	-pipe \
	-fPIC \
	-fno-strict-aliasing \
	-Wno-deprecated \
	-Wno-format \
	-Wno-unused-result \
	-O2 \
	-fno-ident \
	-fdata-sections \
	-ffunction-sections

# Flags passed to only C files.
CFLAGS_C_Release := 

# Flags passed to only C++ files.
CFLAGS_CC_Release := -fno-rtti \
	-fno-threadsafe-statics \
	-fvisibility-inlines-hidden

INCS_Release := -Isrc \
	-Ithird_party_mods/libjingle/source \
	-Ithird_party/libjingle/source \
	-Ithird_party/expat/files \
	-Ithird_party/jsoncpp/include \
	-Isrc/modules/video_capture/main/interface \
	-Isrc/modules/interface \
	-Isrc/common_video/vplib/main/interface \
	-Isrc/modules/video_render/main/interface \
	-Isrc/video_engine/main/interface \
	-Isrc/voice_engine/main/interface \
	-Isrc/system_wrappers/interface

OBJS := $(obj).target/$(TARGET)/third_party/libjingle/source/talk/app/webrtc/peerconnectionfactory.o \
	$(obj).target/$(TARGET)/third_party/libjingle/source/talk/app/webrtc/peerconnectionimpl.o \
	$(obj).target/$(TARGET)/third_party/libjingle/source/talk/app/webrtc/peerconnectionproxy.o \
	$(obj).target/$(TARGET)/third_party/libjingle/source/talk/app/webrtc/webrtcsession.o \
	$(obj).target/$(TARGET)/third_party/libjingle/source/talk/app/webrtc/webrtcjson.o

# Add to the list of files we specially track dependencies for.
all_deps += $(OBJS)

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

$(obj).target/third_party_mods/libjingle/libjingle_app.a: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(obj).target/third_party_mods/libjingle/libjingle_app.a: LIBS := $(LIBS)
$(obj).target/third_party_mods/libjingle/libjingle_app.a: TOOLSET := $(TOOLSET)
$(obj).target/third_party_mods/libjingle/libjingle_app.a: $(OBJS) FORCE_DO_CMD
	$(call do_cmd,alink)

all_deps += $(obj).target/third_party_mods/libjingle/libjingle_app.a
# Add target alias
.PHONY: libjingle_app
libjingle_app: $(obj).target/third_party_mods/libjingle/libjingle_app.a

# Add target alias to "all" target.
.PHONY: all
all: libjingle_app

