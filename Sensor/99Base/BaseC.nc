/*
 */

configuration BaseC {
	provides interface BaseControl;
}
implementation {
//#if SPLUGBASE
//  components SPlugBaseP as BaseP;
//  components PlatformSerialC as UART;
//  BaseP.UartControl -> UART.StdControl;
//  BaseP.UartStream -> UART.UartStream;	
//#else
  components BaseP as BaseP;
//#endif
	components new TimerMilliC();
  BaseControl = BaseP;
  BaseP.Timer -> TimerMilliC;


#if WIFIPLUG
  components NoLedsC as LedsC;
#else
  components LedsC;
#endif
  BaseP.Leds -> LedsC;

  // Communication components.  These are documented in TEP 113:
  // Serial Communication, and TEP 119: Collection.
  //
  components CollectionC_sonno as Collector,  // Collection layer
    ActiveMessageC,                         // AM layer
    new CollectionSenderC_sonno(BASE_OSCILLOSCOPE), // Sends multihop RF
    SerialActiveMessageC,                   // Serial messaging
    new SerialAMSenderC(BASE_OSCILLOSCOPE);   // Sends to the serial port

  BaseP.RadioControl -> ActiveMessageC;
  BaseP.AMPacket -> ActiveMessageC;
  BaseP.SerialControl -> SerialActiveMessageC;
  BaseP.RoutingControl -> Collector;

  BaseP.Send -> CollectionSenderC_sonno.Send;
  BaseP.SerialSend -> SerialAMSenderC.AMSend;
  BaseP.Snoop -> Collector.Snoop[AM_OSCILLOSCOPE];
  BaseP.AckRev -> Collector.Receive[ACK_OSCILLOSCOPE];
  BaseP.BaseRev -> Collector.Receive[BASE_OSCILLOSCOPE];
  BaseP.THRev -> Collector.Receive[TH_OSCILLOSCOPE];
  BaseP.TH20Rev -> Collector.Receive[TH20_OSCILLOSCOPE];
  BaseP.PIRRev -> Collector.Receive[PIR_OSCILLOSCOPE];
  BaseP.POWRev -> Collector.Receive[POW_OSCILLOSCOPE];
  BaseP.MAXCO2Rev -> Collector.Receive[MAXCO2_OSCILLOSCOPE];
  BaseP.CO2Rev -> Collector.Receive[CO2_OSCILLOSCOPE];
  BaseP.CO2S100Rev -> Collector.Receive[CO2S100_OSCILLOSCOPE];
  BaseP.VOCSRev -> Collector.Receive[VOCS_OSCILLOSCOPE];
  BaseP.ThermoLoggerRev -> Collector.Receive[THERMO_LOGGER_OSCILLOSCOPE];
  BaseP.USRev -> Collector.Receive[US_OSCILLOSCOPE];
  BaseP.SPlugRev -> Collector.Receive[SPLUG_OSCILLOSCOPE];
  BaseP.SPlug2Rev -> Collector.Receive[SPLUG2_OSCILLOSCOPE];
  BaseP.SOLARRev -> Collector.Receive[SOLAR_OSCILLOSCOPE];
  BaseP.ETYPERev -> Collector.Receive[ETYPE_OSCILLOSCOPE];
  BaseP.MARKERRev -> Collector.Receive[MARKER_OSCILLOSCOPE];
  BaseP.DUMMYRev -> Collector.Receive[DUMMY_OSCILLOSCOPE];
  BaseP.RootControl -> Collector;

  components new AMReceiverC(BASE_OSCILLOSCOPE);
  BaseP.AMReceive -> AMReceiverC;

  components ActiveMessageAddressC;
  BaseP.setAmAddress-> ActiveMessageAddressC;

  components new PoolC(message_t, 10) as UARTMessagePoolP,
    new QueueC(message_t*, 10) as UARTQueueP;

  BaseP.UARTMessagePool -> UARTMessagePoolP;
  BaseP.UARTQueue -> UARTQueueP;
}
