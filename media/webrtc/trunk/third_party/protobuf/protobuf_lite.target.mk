# This file is generated by gyp; do not edit.

TOOLSET := target
TARGET := protobuf_lite
DEFS_Debug := '-DNO_HEAPCHECKER' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DGOOGLE_PROTOBUF_NO_RTTI' \
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

INCS_Debug := -Ithird_party/protobuf \
	-Ithird_party/protobuf/src

DEFS_Release := '-DNO_HEAPCHECKER' \
	'-DCHROMIUM_BUILD' \
	'-DENABLE_REMOTING=1' \
	'-DENABLE_P2P_APIS=1' \
	'-DENABLE_CONFIGURATION_POLICY' \
	'-DENABLE_GPU=1' \
	'-DENABLE_EGLIMAGE=1' \
	'-DUSE_SKIA=1' \
	'-DENABLE_REGISTER_PROTOCOL_HANDLER=1' \
	'-DGOOGLE_PROTOBUF_NO_RTTI' \
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

INCS_Release := -Ithird_party/protobuf \
	-Ithird_party/protobuf/src

OBJS := $(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/unknown_field_set.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/stubs/common.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/stubs/once.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/extension_set.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/generated_message_util.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/message_lite.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/repeated_field.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/wire_format_lite.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/io/coded_stream.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/io/zero_copy_stream.o \
	$(obj).target/$(TARGET)/third_party/protobuf/src/google/protobuf/io/zero_copy_stream_impl_lite.o

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

$(obj).target/third_party/protobuf/libprotobuf_lite.a: GYP_LDFLAGS := $(LDFLAGS_$(BUILDTYPE))
$(obj).target/third_party/protobuf/libprotobuf_lite.a: LIBS := $(LIBS)
$(obj).target/third_party/protobuf/libprotobuf_lite.a: TOOLSET := $(TOOLSET)
$(obj).target/third_party/protobuf/libprotobuf_lite.a: $(OBJS) FORCE_DO_CMD
	$(call do_cmd,alink)

all_deps += $(obj).target/third_party/protobuf/libprotobuf_lite.a
# Add target alias
.PHONY: protobuf_lite
protobuf_lite: $(obj).target/third_party/protobuf/libprotobuf_lite.a

# Add target alias to "all" target.
.PHONY: all
all: protobuf_lite

