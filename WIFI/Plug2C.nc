#include "StorageVolumes.h"

configuration Plug2C { 
  provides interface SensorControl;
  provides interface ATCMD;
}

implementation {
  components MainC, SPlug2P, new TimerMilliC()
		, new TimerMilliC() as enableTimer
		, new TimerMilliC() as tickTimer
    , new PowerAdcC() as Sensor
    ,HplMsp430GeneralIOC, new Msp430GpioC() as port51g; 

  SensorControl = SPlug2P.SPlugControl;
  ATCMD = SPlug2P.ATCMD;
  SPlug2P.Timer -> TimerMilliC;
  SPlug2P.eTimer -> enableTimer.Timer;
  SPlug2P.tTimer -> tickTimer.Timer;

  //components NoLedsC;
  components LedsC as NoLedsC;
  SPlug2P.Leds -> NoLedsC;

  components ADE7763C;
  SPlug2P.Spi -> ADE7763C; 

  components BusyWaitMicroC;
  SPlug2P.BusyWait -> BusyWaitMicroC;

  components CollectionC_sonno as Collector,			// Collection layer
	     //ActiveMessageC, CC2420ActiveMessageC,            // AM layer
	     //new CollectionSenderC_sonno(SPLUG2_OSCILLOSCOPE); // Sends multihop RF
       new CollectionSenderC_sonno(BASE_OSCILLOSCOPE), // Sends multihop RF
       SerialActiveMessageC,                   // Serial messaging
       new SerialAMSenderC(BASE_OSCILLOSCOPE);   // Sends to the serial port
  //SPlug2P.RadioControl -> ActiveMessageC;
  SPlug2P.RoutingControl -> Collector;
  //SPlug2P.Send -> CollectionSenderC_sonno;
  port51g.HplGeneralIO -> HplMsp430GeneralIOC.Port51;		// Power On/Off
  SPlug2P.GeneralIO -> port51g;				// Power On/Off

  SPlug2P.RadioControl -> SerialActiveMessageC;
  //SPlug2P.Send -> CollectionSenderC_sonno.Send;
  SPlug2P.AMSend -> SerialAMSenderC.AMSend;

  components new ConfigStorageC(VOLUME_CONFIGTEST);
  SPlug2P.Config -> ConfigStorageC.ConfigStorage;
  SPlug2P.Mount  -> ConfigStorageC.Mount;

  components SerialToDisseminationC;
  SPlug2P.AutoOn -> SerialToDisseminationC;

  components HplMsp430InterruptC, new Msp430InterruptC() as port20i;
  port20i.HplInterrupt -> HplMsp430InterruptC.Port20;
	SPlug2P.BTN20I -> port20i;

  components new Msp430GpioC() as port20g;
  port20g.HplGeneralIO -> HplMsp430GeneralIOC.Port20;
  SPlug2P.BTN20G -> port20g;
}
