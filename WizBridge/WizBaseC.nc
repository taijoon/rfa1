configuration WizBaseC {
	provides {
		interface BaseControl as Start;
	}
}
implementation {
	components WizBaseP;
	Start = WizBaseP;
#if WIZBRIDGE
	components BaseC;
	WizBaseP.Control -> BaseC;
#elif WIZBASESTATION
	components BaseStationC as BaseC;
	WizBaseP.Control -> BaseC;
#endif
    //components NoLedsC as LedsC;
  components LedsC;
	WizBaseP.Leds -> LedsC;

	components WizBridgeC;
	WizBaseP.WizBridge ->	WizBridgeC;
}
