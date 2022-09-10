YOSYS_ICESUGAR_NANO_OPT=-DICE_SUGAR_NANO -q -p "synth_ice40 -relut -top $(PROJECTNAME) -json $(PROJECTNAME).json"
NEXTPNR_ICESUGAR_NANO_OPT=--force --json $(PROJECTNAME).json --pcf BOARDS/icesugar_nano.pcf --asc $(PROJECTNAME).asc \
                       --freq 12 --lp1k --package cm36 --opt-timing

#######################################################################################################################

icesugar_nano: icesugar_nano.firmware_config icesugar_nano.synth icesugar_nano.prog 

icesugar_nano.synth:
	yosys $(YOSYS_ICESUGAR_NANO_OPT) $(VERILOGS)
	nextpnr-ice40 $(NEXTPNR_ICESUGAR_NANO_OPT)
	icetime -p BOARDS/icesugar_nano.pcf -P cm36 -r $(PROJECTNAME).timings -d lp1k -t $(PROJECTNAME).asc
	icepack -s $(PROJECTNAME).asc $(PROJECTNAME).bin

icesugar_nano.show: 
	yosys $(YOSYS_ICESUGAR_NANO_OPT) $(VERILOGS)
	nextpnr-ice40 $(NEXTPNR_ICESUGAR_NANO_OPT) --gui

icesugar_nano.prog:
	icesprog $(PROJECTNAME).bin

icesugar_nano.firmware_config:
	BOARD=icesugar_nano TOOLS/make_config.sh -DICE_SUGAR_NANO 
	(cd FIRMWARE; make libs)
