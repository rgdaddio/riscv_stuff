# riscv_stuff
RISC-V assembly code examples. Files with hifive in the name are runnable on the RISC-V HiFive 1 board,
those without the HiFive are runnable in the RISC-V Spike simulator.

If you don't have a toolchain or simulator you can pull them from github (see below) 
And follow the easy instructions

RISC-V is pretty much a one stop shop to get up and running. Very easy Very well done.

RISC-V assembly coder's delight: 

https://github.com/rv8-io

https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md

https://www.imperialviolet.org/2016/12/31/riscv.html

https://cdn2.hubspot.net/hubfs/3020607/SiFive%20-%20RISCV%20101%20(1).pdf?t=1508537822079

https://content.riscv.org/wp-content/uploads/2016/11/riscv-privileged-v1.9.1.pdf#page=46

Nice synopsis:
https://pdos.csail.mit.edu/6.828/2019/lec/l-riscv.txt


<b>QUICK 'hello world' test using tool chain and the spike simulator:</b>

Build a valid Risc5 GNU linux toolchain following these instructions:

https://github.com/riscv/riscv-gnu-toolchain

Build the tools using the toolchain (e.g. export PATH=/opt/riscv/bin:$PATH)

https://github.com/riscv/riscv-tools

You should now have a version of Spike the target directory of the risc5 tools (don't forget to build spike-pk).

Assemble and Link the helloriscv code:

```
riscv64-unknown-linux-gnu-as hello_riscv.s -o hello_riscv.o

risc64-unknown-linux-gnu-ld -o hello_riscv hello_riscv.o
```

Now run the ttest `hello world` in the simulator (note: be sure you ran the `build-spike-pk.sh` when building the riscv-tools):

```
spike pk hello_riscv
```

The result should be:

bbl loader

<b>hello riscv new world!!</b>


//using real HW? Remember this:

Connecting to HiFive:  `sudo screen /dev/ttyUSB1 115200`

The example flashem_riscv_hifive.s will run on the HiFive 1 Try It!!
