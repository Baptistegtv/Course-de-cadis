# ============================================================================
#  CART CHAOS 3D - Nintendo 3DS homebrew build (devkitARM / libctru / citro2d)
#
#  Requires devkitARM (https://devkitpro.org) with the `3ds-dev` package set:
#      (dkp-)pacman -S 3ds-dev
#
#  Build on a PC/Mac/Linux, then copy the output to your homebrewed 3DS:
#      make
#      # -> cartchaos.3dsx  cartchaos.smdh  (copy both to /3ds/CartChaos/)
#
#  Controls:
#      A = sprint / hop into cart / restart | D-Pad = lean + steer
#      CirclePad = steer | B = drink for energy | START = back / restart
# ============================================================================

TARGET      := cartchaos
BUILD       := build
SOURCES     := source/main.cpp
DATA        :=
INCLUDES    :=
LIBS        := -lctru -lcitro2d -lctrud -lndsp

# devkitARM toolchain (env vars are set by the devkitpro container;
# defaults below cover local / CI use).
DEVKITPRO  ?= /opt/devkitpro
DEVKITARM  ?= $(DEVKITPRO)/devkitARM
CTRULIB    ?= $(DEVKITPRO)/libctru
CITRO2D    ?= $(DEVKITPRO)/citro2d

export PATH := $(DEVKITARM)/bin:$(PATH)
CC          := $(DEVKITARM)/bin/arm-none-eabi-g++
OBJCOPY     := $(DEVKITARM)/bin/arm-none-eabi-objcopy
STRIP       := $(DEVKITARM)/bin/arm-none-eabi-strip

CFLAGS  := -Wall -O2 -march=armv6k -mtune=mpcore -mfloat-abi=hard \
           -mfpu=vfp -ffast-math -fno-rtti -std=gnu++17 \
           -I$(CTRULIB)/include -I$(CITRO2D)/include $(INCLUDES)
CXXFLAGS:= $(CFLAGS)
LDFLAGS := -specs=3dsx.specs -g $(LIBS) \
           -L$(CTRULIB)/lib -L$(CITRO2D)/lib

# Auto-generated dependency list
OFILES := $(SOURCES:%.cpp=$(BUILD)/%.o)

.PHONY: all clean

all: $(BUILD)/$(TARGET).3dsx

$(BUILD)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CC) -MMD -MP -MF $(BUILD)/$*.d $(CXXFLAGS) -c $< -o $@

$(BUILD)/$(TARGET).elf: $(OFILES)
	$(CC) $(OFILES) $(LDFLAGS) -o $@

$(BUILD)/$(TARGET).3dsx: $(BUILD)/$(TARGET).elf
	3dsxtool $< $@

clean:
	@rm -rf $(BUILD) $(TARGET).3dsx $(TARGET).smdh

-include $(OFILES:.o=.d)
