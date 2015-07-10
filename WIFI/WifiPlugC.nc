/*
 * Authors:		Dongik Kim, Sonnonet
 * Date : 02.08.2011
 */

configuration WifiPlugC
{
  provides {
		interface BaseControl;
    interface WifiPlug;
  }
}
implementation
{
  components WifiPlugP; 
  components new TimerMilliC(); 
  components new TimerMilliC() as Count; 
  components new TimerMilliC() as Reset; 
  components LedsC;
	//components NoLedsC as LedsC;

  //WizControl = WifiPlugP;
	BaseControl = WifiPlugP.Start;
  WifiPlug = WifiPlugP;
  WifiPlugP.Leds -> LedsC;
  WifiPlugP.Timer -> TimerMilliC;
  WifiPlugP.count -> Count;
  WifiPlugP.resetT -> Reset;

	components PlatformSerialC as UART;
  WifiPlugP.UartControl -> UART;
  WifiPlugP.UartStream -> UART;

	components BaseC as PlugBaseC;
	WifiPlugP.Control -> PlugBaseC;

  components HplMsp430GeneralIOC
				,new Msp430GpioC() as port21g
				,new Msp430GpioC() as port26g;
  port21g.HplGeneralIO -> HplMsp430GeneralIOC.Port21;		// WIFI_STATE
  WifiPlugP.WifiState -> port21g;				// 
  port26g.HplGeneralIO -> HplMsp430GeneralIOC.Port26;		// WIFI_RESET
  WifiPlugP.WifiReset -> port26g;				// 

  components Plug2C as Sensor7C;
  WifiPlugP.PlugControl -> Sensor7C;
  WifiPlugP.ATCMD -> Sensor7C;

  components BusyWaitMicroC;
  WifiPlugP.BusyWait -> BusyWaitMicroC;

  components HplMsp430InterruptC, new Msp430InterruptC() as port20i;
  port20i.HplInterrupt -> HplMsp430InterruptC.Port20;
  WifiPlugP.BTN20I -> port20i;

  components new Msp430GpioC() as port20g;
  port20g.HplGeneralIO -> HplMsp430GeneralIOC.Port20;
  WifiPlugP.BTN20G -> port20g;

  components new Msp430GpioC() as port51g;
  port51g.HplGeneralIO -> HplMsp430GeneralIOC.Port51;		// Power On/Off
  WifiPlugP.Power -> port51g;				// Power On/Off

}
