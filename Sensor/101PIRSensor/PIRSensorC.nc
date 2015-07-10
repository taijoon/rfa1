/*
 */

configuration PIRSensorC {
  provides interface SensorControl;
}
implementation {
  components PIRSensorP, LedsC, new TimerMilliC(); 

  SensorControl = PIRSensorP;
  PIRSensorP.Timer -> TimerMilliC;
  PIRSensorP.IntSleepTimer -> TimerMilliC;
  PIRSensorP.Leds -> LedsC;

  components BusyWaitMicroC;
  PIRSensorP.BusyWait -> BusyWaitMicroC;

  // For RF 
  components CollectionC_sonno as Collector,  // Collection layer
	     ActiveMessageC,                         // AM layer
	     new CollectionSenderC_sonno(PIR_OSCILLOSCOPE); // Sends multihop RF

  PIRSensorP.RadioControl -> ActiveMessageC;
  PIRSensorP.RoutingControl -> Collector;
  PIRSensorP.Send -> CollectionSenderC_sonno.Send;

	components PlatformIOC;
	components PlatformINTC;
  // For PIR Sensor Power On
  PIRSensorP.PowGio -> PlatformIOC.PIR_Power;						// Power On/Off
#if PIR2
  // For PIR Seosor Interrupt Wiring
  PIRSensorP.GpioInterrupt -> PlatformINTC.PIR2_INT;
  PIRSensorP.GeneralIO -> PlatformIOC.PIR2_IO;
#else
  PIRSensorP.GpioInterrupt -> PlatformINTC.PIR_INT;
  PIRSensorP.GeneralIO -> PlatformIOC.PIR_IO;
#endif

  // Low Power Listening Wiring //
  components fxP;
  fxP.LowSignal -> PIRSensorP.LowSignal;

  // Battery Read Wiring //
  components BatteryC;
  PIRSensorP.Battery -> BatteryC;

#if KEEPER
#warning ########## Keeper enable ##########
  components KeeperC;
  SensorControl = KeeperC.SensorControl;
  PIRSensorP.Send -> KeeperC.Send;
  KeeperC.Packet -> CollectionSenderC_sonno.Send;
#endif

}
