# riscv_stuff
RISC-V assembly code examples. Files with the _t are runnable in the RISC-V simulator Spike.

If you don't have a toolchain or simulator you can pull them from github (see below) 
And follow the easy instructions

RISC-V is pretty much a one stop shop to get up and running. Very easy Very well done.

RISC-V assembly coder's delight: 

https://rv8.io/asm.html

https://rv8.io/syscalls.html

https://www.imperialviolet.org/2016/12/31/riscv.html

https://cdn2.hubspot.net/hubfs/3020607/SiFive%20-%20RISCV%20101%20(1).pdf?t=1508537822079

https://content.riscv.org/wp-content/uploads/2016/11/riscv-privileged-v1.9.1.pdf#page=46
                                 

QUICK TEST:
Build a valid Risc5 GNU linux toolchain following these instructions:
https://github.com/riscv/riscv-gnu-toolchain

Build the tools using the toolchain (e.g. export PATH=/opt/riscv/bin:$PATH)
https://github.com/riscv/riscv-tools

You should now have a version of Spike the target directory of the risc5 tools.

Assemble and Link the _t version of the code:
riscv64-unknown-linux-gnu-as helloriscv_t.s -o helloriscv_t.riscv64
risc64-unknown-linux-gnu-ld -o ttest helloriscv_t.risc64

Now run the ttest 'hello world' in the simulator (note: be sure you ran the build-spike-pk.sh when building the riscv-tools):
spike pk ttest

The result should be:
bbl loader
hello riscv new world!!


//using real HW? Remember this:
Connecting to HiFive:  sudo screen /dev/ttyUSB1 115200
