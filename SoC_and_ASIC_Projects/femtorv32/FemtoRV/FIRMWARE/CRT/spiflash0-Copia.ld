MEMORY {
   FLASH (RX)  : ORIGIN = 0x00820000, LENGTH = 0x100000 /* 4 MB in flash */
}
SECTIONS {
    everything : {
	. = ALIGN(4);
        *(.*)
       /* timing */
     wait_cycles.o(.text)

	/* integer mul and div */
	*/libgcc.a:muldi3.o(.text)
	*/libgcc.a:div.o(.text)    
    } >FLASH


    /* this is to define the start of the heap, and make sure we have a minimum size */
    .heap : {
        . = ALIGN(4);
        _heap_start = .;    /* define a global symbol at heap start */
	_end = .;           /* as expected by syscalls.c            */
    } >FLASH
}
