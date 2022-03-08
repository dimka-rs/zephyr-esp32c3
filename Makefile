BOARD ?= esp32c3_devkitm
OPENOCD ?= $(HOME)/repos/openocd

.PHONY: all clean flash menuconfig guiconfig init mcuboot flash_mcuboot flashst reset rtt

all:
	west build -b $(BOARD)

clean:
	rm -rf ./build

flash:
	west flash

menuconfig:
	west build -t menuconfig

guiconfig:
	west build -t guiconfig

init:
	@echo "source $(HOME)/zephyrproject/zephyr/zephyr-env.sh"
	@echo "export ZEPHYR_TOOLCHAIN_VARIANT=\"espressif\""
	@echo "export ESPRESSIF_TOOLCHAIN_PATH=\"${HOME}/.espressif/tools/zephyr\""

mcuboot:
	west build -s $(HOME)/zephyrproject/bootloader/mcuboot/boot/zephyr/ -d build/mcuboot -b $(BOARD) -- -DBOARD_ROOT=$(CURDIR)

flash_mcuboot: build/mcuboot/zephyr/zephyr.hex
	@echo Flashing: $<
	$(OPENOCD)/src/openocd \
		-s $(OPENOCD)/tcl \
		-f interface/stlink.cfg \
		-f target/nrf52.cfg \
		-c init \
		-c "reset init" \
		-c halt \
		-c "nrf5 mass_erase" \
		-c "flash write_image $<" \
		-c reset \
		-c exit

flashst: build/zephyr/zephyr.hex
	@echo Flashing: $<
	$(OPENOCD)/src/openocd \
		-s $(OPENOCD)/tcl \
		-f interface/stlink.cfg \
		-f target/nrf52.cfg \
		-c init \
		-c "reset init" \
		-c halt \
		-c "nrf5 mass_erase" \
		-c "flash write_image $<" \
		-c reset \
		-c exit

reset:
	$(OPENOCD)/src/openocd \
		-s $(OPENOCD)/tcl \
		-f interface/stlink.cfg \
		-f target/nrf52.cfg \
		-c init \
		-c reset \
		-c exit

rtt:
	JLinkRTTViewer --autoconnect --speed 4000 --interface swd --connection usb --device nrf52832_xxaa
