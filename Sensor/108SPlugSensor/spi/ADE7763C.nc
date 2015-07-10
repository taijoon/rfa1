
configuration ADE7763C {
  provides interface ADE7763;
}

implementation {
  components ADE7763P;
  components HplMsp430GeneralIOC as IOC; 
  components BusyWaitMicroC;

  ADE7763 = ADE7763P;
  
	components LedsC;
  ADE7763P.Leds -> LedsC;

  ADE7763P.SCK  -> IOC.Port40;	//PSCLK
#if CROSS
	#warning ###### PLUG PIN CROSS ###### 
  ADE7763P.MISO -> IOC.Port34;	//PDOUT
  ADE7763P.MOSI -> IOC.Port35;	//PDIN
#else
  ADE7763P.MISO -> IOC.Port35;	//PDOUT
  ADE7763P.MOSI -> IOC.Port34;	//PDIN
#endif
  ADE7763P.CSB  -> IOC.Port30;	//PCS

  ADE7763P.BusyWait -> BusyWaitMicroC;
}
