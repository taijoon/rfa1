/*
 */
configuration OscilloscopeAppC { }
implementation
{
  components OscilloscopeC, MainC, ActiveMessageC, LedsC,
    new TimerMilliC(), new TimerMilliC() as Timer2,
    new AMSenderC(AM_OSCILLOSCOPE), new AMReceiverC(AM_OSCILLOSCOPE);

  OscilloscopeC.Boot -> MainC;
  OscilloscopeC.RadioControl -> ActiveMessageC;
  OscilloscopeC.AMSend -> AMSenderC;
  OscilloscopeC.Receive -> AMReceiverC;
  OscilloscopeC.Timer -> TimerMilliC;
  OscilloscopeC.Timer2 -> Timer2;
  OscilloscopeC.Leds -> LedsC;

  components PlatformSerialC as UART;
  OscilloscopeC.SerialControl -> UART.StdControl;
  OscilloscopeC.UartStream -> UART.UartStream;	
  
}
