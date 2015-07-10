#!/bin/bash
source /opt/env.scripts/env.opt.tinyos2.x
if (($# >= 4))
then
/opt/msp430/bin/msp430-gcc -B/usr/lib/ncc -mdisable-hwmul -mmcu=msp430x1611 -Os -O -Wall -Wshadow -v -o /tmp/ccygtfQ1.o -c -fdollars-in-identifiers build/telosb/app_com.c -D$1=1 -DCHANNEL=$2 -DGROUP=$3
/opt/msp430/bin/msp430-ld -m msp430x1611 -o build/telosb/main.exe /opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/crt430x1611.o -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib /tmp/ccygtfQ1.o -lm -lgcc -lc -lgcc
/opt/msp430/bin/msp430-objcopy --output-target=ihex build/telosb/main.exe build/telosb/main.ihex 
make telosb reinstall.$4
elif (($# >= 2))
then
/opt/msp430/bin/msp430-gcc -B/usr/lib/ncc -mdisable-hwmul -mmcu=msp430x1611 -Os -O -Wall -Wshadow -v -o /tmp/ccygtfQ1.o -c -fdollars-in-identifiers build/telosb/app_com.c -D$1=1
/opt/msp430/bin/msp430-ld -m msp430x1611 -o build/telosb/main.exe /opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/crt430x1611.o -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib /tmp/ccygtfQ1.o -lm -lgcc -lc -lgcc
/opt/msp430/bin/msp430-objcopy --output-target=ihex build/telosb/main.exe build/telosb/main.ihex 
make telosb reinstall.$2
elif (($# >= 1))
then
make telosb reinstall.$1
else 
/opt/msp430/bin/msp430-gcc -B/usr/lib/ncc -mdisable-hwmul -mmcu=msp430x1611 -Os -O -Wall -Wshadow -v -o /tmp/ccygtfQ1.o -c -fdollars-in-identifiers build/telosb/app_com.c -D$1=1
/opt/msp430/bin/msp430-ld -m msp430x1611 -o build/telosb/main.exe /opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/crt430x1611.o -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib/msp2 -L/opt/msp430/lib/gcc-lib/msp430/3.2.3/../../../../msp430/lib /tmp/ccygtfQ1.o -lm -lgcc -lc -lgcc
/opt/msp430/bin/msp430-objcopy --output-target=ihex build/telosb/main.exe build/telosb/main.ihex 
fi
