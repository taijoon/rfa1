// $Id: BaseStationC.nc,v 1.2 2010/06/29 22:07:14 scipio Exp $

configuration BaseStationC {
	provides interface BaseControl;
}
implementation {
  components MainC, BaseStationP, LedsC;
  components ActiveMessageC as Radio;
  components Serial802_15_4C as Serial;
  
  //MainC.Boot <- BaseStationP;
  BaseControl = BaseStationP;

  BaseStationP.RadioControl -> Radio;
  BaseStationP.SerialControl -> Serial;
  
  BaseStationP.UartSend -> Serial;
  
  BaseStationP.RadioReceive -> Radio.Receive;
  BaseStationP.RadioSnoop -> Radio.Snoop;
  BaseStationP.RadioPacket -> Radio;
  BaseStationP.RadioAMPacket -> Radio;
  
  BaseStationP.Leds -> LedsC;
}
