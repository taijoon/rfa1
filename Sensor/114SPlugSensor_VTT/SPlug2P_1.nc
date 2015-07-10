#include "Timer.h"
#include "../../Yggdrasil.h"
#include "Serial.h"
#include "./Command.h"

module SPlug2P {
  provides {
    interface SensorControl as SPlugControl;
  }
  uses {
    interface ADE7763 as Spi;
    interface Timer<TMilli>;
    interface Leds;
    interface GeneralIO;
    interface BusyWait<TMicro,uint16_t> as BusyWait;

    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;
    interface Send;

		interface ConfigStorage as Config;
		interface Mount as Mount;
  }
}

implementation {
  task void sendData(); 

	typedef struct config_t {
		uint32_t accumulate;
		uint32_t overcount;
	} config_t;

  message_t sendbuf;
  bool sendbusy=FALSE;
  uint32_t interval;
  splug2_oscilloscope_t local;
  norace uint8_t dataStatus=0;			//Get Data from ADE
  bool readBusy = FALSE;	
	uint32_t watt=0, accumulate = 0;
	uint16_t per=0;
	config_t conf;

  command error_t SPlugControl.start(base_info_t* nodeInfo) {
    memcpy(&local.info, nodeInfo, sizeof(base_info_t));   
    local.info.type = SPLUG2_OSCILLOSCOPE;

		if(call Mount.mount() != SUCCESS) {
		}

    call GeneralIO.makeOutput();
    call GeneralIO.set();

    if (call RadioControl.start() != SUCCESS)
			;
    if (call RoutingControl.start() != SUCCESS)
			;

    call Spi.init();

    call Spi.cs_high();
    call Spi.cs_low();
    call Spi.writeCommand(0x8f);
    call Spi.cs_high();

    return SUCCESS;	
  }

  command error_t SPlugControl.stop() {
    return SUCCESS;
  }


  void setTimer(uint32_t repeat) {
    if(repeat == 0)
      interval = DEFAULT_INTERVAL;
    else
      interval = repeat;
    if (call Timer.isRunning()) call Timer.stop();
  }

  command error_t SPlugControl.repeatTimer(uint32_t repeat) {
    setTimer(SPLUG_INTERVAL);
		per = SPLUG_INTERVAL/1024;
    call Timer.startPeriodic(interval);
    return SUCCESS;	
  }

  command error_t SPlugControl.oneShotTimer(uint32_t repeat) {
    setTimer(repeat);
    call Timer.startOneShot(interval);
    return SUCCESS;
  }

  event void RadioControl.startDone(error_t error) {
  }

  event void RadioControl.stopDone(error_t error) { }

  event void Timer.fired(){
    if(readBusy == FALSE) {
      readBusy = TRUE;
      call Spi.cs_low();
      call Spi.writeData(0x16, CURRENT_SIZE);
      dataStatus = 1;
    }
  }

	uint32_t o_watt=0;
	uint32_t o_watt_2=0;
  event void Spi.readData(nx_uint8_t* rx_buf, uint8_t len) {
    if(dataStatus == 1)	{ //
      call Spi.cs_high();
      dataStatus = 2;
      call Spi.cs_low();
      call Spi.writeData(0x03, RAENERGY_SIZE);
		}
    else if(dataStatus == 2) {	//
      call Spi.cs_high();

			if(local.info.count > 2){
				o_watt = 0;
				o_watt = (rx_buf[0]*256*256) + (rx_buf[1]*256) + (rx_buf[2]);
				local.overcount = o_watt;
//#ifndef SPLUGTEST
				if(o_watt > 60000){
					o_watt = 0;
					local.watt = o_watt;
				}
				else if(o_watt < 69){
					o_watt = 289*o_watt;
					o_watt = o_watt / 100;	 
					local.watt = o_watt;
				}
				else if(o_watt < 103){
					o_watt = 337*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 137){
					o_watt = 410*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 171){
					o_watt = 451*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 207){
					o_watt = 483*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 291){
					o_watt = 498*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 377){
					o_watt = 522*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 462){
					o_watt = 535*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 546){
					o_watt = 535*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 631){
					o_watt = 551*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 718){
					o_watt = 555*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 886){
					o_watt = 560*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 1057){
					o_watt = 567*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 1226){
					o_watt = 569*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 1396){
					o_watt = 571*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 1566){
					o_watt = 573*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 1905){
					o_watt = 575*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else if(o_watt < 2413){
					o_watt = 578*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}
				else{
				//else if(o_watt < 40000){
					o_watt = 580*o_watt;
					o_watt = o_watt / 100;	// 700 => 7.00watt
					local.watt = o_watt;
				}

					o_watt = o_watt * 10;
					o_watt = o_watt / 9;		// 70,00 => 0.007watt/hour
					o_watt_2 = local.accumulate;
					local.accumulate += o_watt;

				//if(local.accumulate < o_watt_2)
					//local.overcount++;
//#endif
//#ifdef SPLUGTEST
//#endif
			}
			else{
      	dataStatus = 0;
				return;
			}

//#ifndef SPLUGTEST
//			if((local.info.count % 10) == 0) {
//				conf.accumulate = local.accumulate;
//				conf.overcount = local.overcount;
//				call Config.write(0, &conf, sizeof(conf));
//			}
//#endif

      dataStatus = 0;
    }
/*
		else if(dataStatus == 3) {	//Accumulated Watt
      call Spi.cs_high();
      memcpy(&local.rvaEnergy, rx_buf, len);
      dataStatus = 4;
      call Spi.cs_low();
      call Spi.writeData(IPEAK, IPEAK_SIZE);
    }
		else if(dataStatus == 4) {	//Accumulated Watt
      call Spi.cs_high();
      memcpy(&local.peak, rx_buf, len);
      dataStatus = 0;
    }
*/
    if(dataStatus == 0) {
      call Spi.cs_high();
      post sendData();
      readBusy = FALSE;
    }
  }

  event void Send.sendDone(message_t* msg, error_t error) {
    sendbusy = FALSE;
  }

  task void sendData() {
    splug2_oscilloscope_t *o;
    o = (splug2_oscilloscope_t *)call Send.getPayload(&sendbuf, sizeof(splug2_oscilloscope_t));
    if (o == NULL) {
      return;
    }

    memcpy(o, &local, sizeof(local));

    if (call Send.send(&sendbuf, sizeof(local)) == SUCCESS) {
      sendbusy = TRUE;
    }

    local.info.count++;
    //memset(&local.current, 0, (sizeof(local) - sizeof(local.info)));
  }

	event void Config.readDone(storage_addr_t addr, void* buf, 
		storage_len_t len, error_t err) __attribute__((noinline)) {

		if(err == SUCCESS){
			memcpy(&conf, buf, len);

			if(conf.accumulate < 0)
				local.accumulate = 0;
			else
				local.accumulate = conf.accumulate;
			if(conf.overcount < 0 )
				conf.overcount = 0;
			else
				local.overcount = conf.overcount;
		}
	}

	event void Config.writeDone(storage_addr_t addr, void * buf, 
		storage_len_t len, error_t err) {
		if(err == SUCCESS) {
			if(call Config.commit() != SUCCESS) {
			}
		}
	}

	event void Config.commitDone(error_t err) {
	}

	event void Mount.mountDone(error_t error) {
		if(error == SUCCESS) {
			if(call Config.valid() == TRUE) {
				if(call Config.read(0, &conf, sizeof(conf)) != SUCCESS) {
				}
			}
			else {
				if(call Config.commit() == SUCCESS) {
				}
				else {
					call Leds.led0On();
				}
			}
		}
		else {
			call Leds.led0On();
		}
	}
}

