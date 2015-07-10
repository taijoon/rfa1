/* -*- mode:c++; indent-tabs-mode: nil -*- */
/**
 * Go around standard tinyos pin implementation, speed optimization
 */
/*
 * @author Andreas Koepke
*/
//#include <msp430/iostructures.h>
#include "iostructures.h"

module PlatformOneWireLowLevelP {
    provides {
        interface GeneralIO as OneWirePin;
    }
    uses interface GeneralIO;
}
implementation{
#warning "Please ignore the non-atomic access warnings for shared variables port2"
    // OneWire: port 2.4
    async command void OneWirePin.set() {
				call GeneralIO.set();
        //port2.out.pin4 = 1;
    }
    
    async command void OneWirePin.clr() {
				call GeneralIO.clr();
        //port2.out.pin4 = 0;
    }
    
    async command void OneWirePin.toggle() {
				if(call GeneralIO.get())
					call GeneralIO.clr();
				else
					call GeneralIO.set();
/*
        if(port2.out.pin4) {
            port2.out.pin4 = 0;
        }
        else {
            port2.out.pin4 = 1;
        }
*/
    }
    
    async command bool OneWirePin.get() {
				return call GeneralIO.get();
        //return port2.in.pin4;
    }
    
    async command void OneWirePin.makeInput() {
				call GeneralIO.makeInput();
        //port2.dir.pin4 = 0;
    }
    
    async command bool OneWirePin.isInput() {
        return !(call GeneralIO.isInput());
        //return !(port2.dir.pin4);
    }
    
    async command void OneWirePin.makeOutput() {
				call GeneralIO.makeOutput();
        //port2.dir.pin4 = 1;
    }
    
    async command bool OneWirePin.isOutput() {
				return call GeneralIO.isOutput();
//        return port2.dir.pin4;
    }
}
