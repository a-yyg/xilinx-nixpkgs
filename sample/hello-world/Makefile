KERNEL := vadd
SRC := src
KERNEL_SRC := $(SRC)/$(KERNEL).cpp
TARGET := hw

VPP := v++
XBU := xclbinutil
BOOTGEN := bootgen
PLATFORM := kv260_ispMipiRx_vcu_DP
CONFIG := $(SRC)/zcu102.cfg
HLS_CONFIG := $(SRC)/hls_config.cfg

VPP_FLAGS_COMMON := -t $(TARGET) \
                    --platform $(PLATFORM)

VPP_FLAGS_sw_emu := $(VPP_FLAGS_COMMON) \
                    --temp_dir $(TARGET)/temp \
                    --log_dir $(TARGET)/log \
                    --report_dir $(TARGET)/report

VPP_FLAGS_hw := $(VPP_FLAGS_COMMON) \
                --config $(HLS_CONFIG) \
                --work_dir $(TARGET)


             # --config $(CONFIG) \
             # --save-temps \

VPP_CFLAGS := -k $(KERNEL) \
              -I$(SRC)

DTBO := $(TARGET)/$(KERNEL)/$(KERNEL).dtbo
DTSI_SRC := "https://raw.githubusercontent.com/Xilinx/kria-apps-firmware/xlnx_rel_v2022.1/boards/kv260/smartcam/kv260-smartcam.dtsi"
SHELL_JSON := $(TARGET)/$(KERNEL)/shell.json
BIT_BIN := $(TARGET)/$(KERNEL)/$(KERNEL).bit.bin
XCLBIN := $(TARGET)/$(KERNEL)/$(KERNEL).xclbin

CXX := g++
EXE_SRC := $(SRC)/host.cpp
EXE := app
CFLAGS := \
          -v \
          -g \
          -std=c++17 \
          -Wall \
          -O0 \
          -fmessage-length=0 \
          -I$(SRC) \
          -lstdc++ -lrt -luuid -lxrt_core -lxrt_coreutil -pthread


          # -I$(SYSROOT)/usr/include \
          # -I$(SYSROOT)/usr/include/aarch64-linux-gnu \
          # -I$(SYSROOT)/usr/include/xrt \
          # -I$(SYSROOT)/usr/include/c++/11 \
          # -I$(SYSROOT)/usr/include/aarch64-linux-gnu/c++/11 \
          # -L$(SYSROOT)/usr/lib \
          # -L$(SYSROOT)/usr/lib/aarch64-linux-gnu \

.PHONY: all
all: xrt

$(TARGET)/$(KERNEL):
	mkdir -p $@

$(DTBO): $(TARGET)/$(KERNEL)
	wget $(DTSI_SRC) -O $(TARGET)/$(KERNEL).dtsi
	dtc -I dts -O dtb -o $@ $(TARGET)/$(KERNEL).dtsi
	rm -f $(TARGET)/$(KERNEL).dtsi

$(TARGET): $(TARGET)/$(KERNEL).xclbin

$(TARGET)/$(KERNEL).xclbin: $(TARGET)/$(KERNEL).xo
	$(VPP) -l $(VPP_FLAGS_sw_emu) -o $@ $<

sw_emu/$(KERNEL).xo: $(KERNEL_SRC)
	$(VPP) -c $(VPP_FLAGS_sw_emu) $(VPP_CFLAGS) -o $@ $<

hw/$(KERNEL).xo: $(KERNEL_SRC)
	$(VPP) -c --mode hls $(VPP_FLAGS_hw)

hw/$(KERNEL)/$(KERNEL).xclbin: hw/$(KERNEL).xclbin
	cp $< $@

hw/$(KERNEL)/$(KERNEL).bit.bin: hw/$(KERNEL)/$(KERNEL).xclbin
	$(XBU) --dump-section BITSTREAM:RAW:$(TARGET)/system.bit --input $<
	echo 'all:{system.bit}' > hw/bootgen.bif
	cd hw && \
	$(BOOTGEN) -w -arch zynqmp -process_bitstream bin -image bootgen.bif
	mv hw/system.bit.bin $@
	rm -f $(TARGET)/bootgen.bif hw/system.bit hw/system.bit.bin

#hw/$(KERNEL)/shell.json: hw/$(KERNEL)/$(KERNEL).xclbin
#	$(XBU) --dump-section HW_EMU_XDEVICE:JSON:$(TARGET)/shell.json --input $<

$(SHELL_JSON): $(SRC)/shell.json $(TARGET)/$(KERNEL)
	cp $< $@

xclbin: $(DTBO) $(SHELL_JSON) $(BIT_BIN) $(XCLBIN)

host: $(EXE)

$(EXE): $(EXE_SRC)
	$(CXX) $(CFLAGS) $< -o $@

.PHONY clean:
clean:
	rm -rf hw hw_emu sw_emu
