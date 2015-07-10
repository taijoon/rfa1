/*
 * Authors:		Dongik Kim, Sonnonet
 * Date : 02.08.2011
 */

#include "WifiPlug.h"

module WifiPlugP {
  provides {
		interface BaseControl as Start;
    interface WifiPlug;
  }
  uses {
    interface Timer<TMilli>;
    interface Timer<TMilli> as count;
    interface Timer<TMilli> as resetT;
    interface UartStream;
    interface Leds;
    interface StdControl as UartControl;
    interface BaseControl as Control;
		interface SensorControl as PlugControl;
    interface GeneralIO as WifiState;
    interface GeneralIO as WifiReset;

    interface BusyWait<TMicro,uint16_t> as BusyWait;
    interface GpioInterrupt as BTN20I;
    interface GeneralIO as BTN20G;
    interface GeneralIO as Power;
		interface ATCMD;
  }
}
implementation {
  int rCnt = 0;
  //uint8_t apid[] = SSID;
  //uint8_t _type[] = "WEP";
  //uint8_t password[] = "0123456789";
  //uint8_t _ip[] = "222.239.78.8";
  //uint8_t _port[] = "20000";
  norace uint8_t ackbuf[13];
	norace uint8_t STATE = 1;
  norace bool ata = FALSE;
	oscilloscope_t local;
  base_info_t *info;
	uint8_t mode_state = 0;
	uint16_t tCount = 0;
	norace uint8_t EdgeState = 0;

  command error_t Start.start(base_info_t *nodeInfo){
		call PlugControl.start(info);
		//call PlugControl.repeatTimer(0);
		call Leds.set(7);
		call UartControl.start();
#ifndef WPS
		call Timer.startOneShot(1024);
#endif
		memcpy(&local.info, nodeInfo, sizeof(base_info_t));
    info = nodeInfo;
    call WifiState.makeInput();
		call WifiReset.makeOutput();
		call WifiReset.set();
    call Power.makeOutput();
		call Power.clr();	// Off
		call BusyWait.wait(10);
		EdgeState = 0;
		call Leds.set(0);
		//call PlugControl.stop();
    return SUCCESS;
  }

  command error_t Start.stop() {return SUCCESS;}
  command error_t Start.repeatTimer(uint32_t interval) {return SUCCESS;}
  command error_t Start.oneShotTimer(uint32_t interval) {return SUCCESS;}

	uint8_t WI_RESET= 0;
	norace uint16_t wps_cnt=0;
  event void count.fired() {
		call Leds.led1Toggle();
		wps_cnt++;
		if(wps_cnt > 240){
			call resetT.startPeriodic(512);
			call count.stop();
		}	
	}

  event void resetT.fired() {
		if(WI_RESET == 1){
			WI_RESET = 2;
			call WifiReset.set();
			call Leds.set(3);
		}
		else if(WI_RESET == 2){
			call Leds.set(7);
			WDTCTL = 0;
		}
		else{
			WI_RESET = 1;
			call Leds.set(1);
			call WifiReset.clr();
		}
	}

	event void ATCMD.wps(){
		call count.stop();
		call count.startPeriodic(256);
		call Leds.set(0);
  	call WifiPlug.setWPS();
		call Control.stop();
		call PlugControl.stop();
		//call Timer.stop();
		wps_cnt = 0;
	}

  async event void BTN20I.fired() {
	}

	uint16_t deley = 10240;
	norace uint8_t o_state =0, reCnt=1;
	task void Timer_Process(){
		if(STATE == 1){
			call WifiPlug.setStart();
			deley = 5120;
		}
		else if(STATE == 2){
			uint8_t* apid = SSID;
			call WifiPlug.setAP(apid, strlen(apid));
			deley = 5120;
		}
		else if(STATE == 3){
			uint8_t* type = TYPE;
			uint8_t* password = PASSWORD;
			call WifiPlug.setPassword(type, password);
			deley = 5120;
		}
		else if(STATE == 4){
  		call WifiPlug.setFSOCK();
			deley = 5120;
		}
		else if(STATE == 5){
			call WifiPlug.setDHCP(1);
			deley = 5120;
		}
		else if(STATE == 6){
			call WifiPlug.setJoin();
			deley = 10240;
		}
		else if(STATE == 7){
			uint8_t* ip = IP;
			uint8_t* port = PORT;
			deley = 10240;
			call WifiPlug.setCon(ip, port);
		}
		else if(STATE == 8){
			deley = 1024;
#ifndef WPS
			call Control.start(info);
			call Control.repeatTimer(0);
#endif
			call PlugControl.start(info);
			call PlugControl.repeatTimer(0);
			call Leds.set(0);
			STATE++;
		}

		if(STATE < 8){
			call Leds.set(STATE);
			if(o_state == STATE){
				reCnt++;
				if(reCnt%4 == 0){
#ifdef WPS
			STATE = 4;
#else
			STATE = 1;
#endif
					call Control.stop();
					call PlugControl.stop();
					call resetT.startPeriodic(512);
					call Leds.set(0);
					WI_RESET = 0;
				}
			}
			else{
				o_state = STATE;
			}
		}
		else{
			if(call WifiState.get()){
#ifdef WPS
			STATE = 4;
#else
			STATE = 1;
#endif
				call Control.stop();
				call PlugControl.stop();
				call resetT.startPeriodic(512);
				WI_RESET = 0;
			}
		}
		call Timer.startOneShot(deley);
	}

  event void Timer.fired() {
		post Timer_Process();
	}

  async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t error) {

  }

	uint8_t repeat = 0;
	uint8_t Sending = 0;
	task void Uart_packet();
  async event void UartStream.receivedByte(uint8_t byte) {
		if(rCnt > 0)
			ackbuf[rCnt++] = byte;
    if (byte == '[') {
      rCnt = 0;
      ackbuf[rCnt++] = byte;
    }
    else if (byte == ']') {
			post Uart_packet();
		}
	}

	task void Uart_packet(){
		{
      if ('O' == ackbuf[1])
      	if ('K' == ackbuf[2]){
						call count.stop();
						call resetT.stop();
						call Timer.stop();
						call Timer.startOneShot(2048);
						repeat = 0;
						reCnt = 1;
						if(wps_cnt>1){
							post Timer_Process();
							STATE = 4;
							wps_cnt=0;
						}
						else
							STATE++;
					}
      if ('E' == ackbuf[1])
      	if ('R' == ackbuf[2])
      		if ('R' == ackbuf[3])
      			if ('O' == ackbuf[4])
      				if ('R' == ackbuf[5]){
									call Timer.stop();
									call Timer.startOneShot(2048);
									if(repeat>3)
										if(STATE > 1)
											STATE--;
							}
      if ('D' == ackbuf[1])
      	if ('I' == ackbuf[2])
      		if ('S' == ackbuf[3])
      			if ('C' == ackbuf[4])
      				if ('O' == ackbuf[5])
      					if ('N' == ackbuf[6])
				      		if ('N' == ackbuf[7])
      							if ('E' == ackbuf[8])
				      				if ('C' == ackbuf[9])
				      					if ('T' == ackbuf[10]){
													STATE=7;
													reCnt=1;
													//WDTCTL = 0;
												}

      memset(ackbuf, 0, sizeof(ackbuf));
    }
  }

  default async event void WifiPlug.complete(error_t result){ }

  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t error) {

  }

  uint8_t buf[50];

  async command error_t WifiPlug.setStart(){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = 0x0D;//0x0d;		// ENTER KEY

      ata = FALSE;
      if (call UartStream.send(buf, 3) != SUCCESS) {
				return FAIL;
      }
    }

    return SUCCESS;
  }

  async command error_t WifiPlug.setWPS(){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'W';
      buf[5] = 'P';
      buf[6] = 'S';
      buf[7] = '=';
      buf[8] = '0';
      buf[9] = 0x0d;		// ENTER KEY

    }

    ata = FALSE;
    if (call UartStream.send(buf, 10) != SUCCESS) {
      return FAIL;
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setFSOCK(){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'F';
      buf[4] = 'S';
      buf[5] = 'O';
      buf[6] = 'C';
      buf[7] = 'K';
      buf[8] = '=';
      buf[9] = '1';
      buf[10] = ',';
      buf[11] = '0';
      buf[12] = 0x0d;		// ENTER KEY

    }

    ata = FALSE;
    if (call UartStream.send(buf, 13) != SUCCESS) {
      return FAIL;
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setAP(char* ssid, uint8_t len){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'S';
      buf[5] = 'E';
      buf[6] = 'T';
      buf[7] = '=';
      buf[8] = '0';
      buf[9] = ',';
      memcpy(&buf[10], ssid, len); 
      buf[10+len] = 0x0d;		// ENTER KEY

    }

    ata = FALSE;
    if (call UartStream.send(buf, 12+len) != SUCCESS) {
      return FAIL;
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setSTATIC(uint8_t * ipaddr, uint8_t len){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'N';
      buf[4] = 'S';
      buf[5] = 'E';
      buf[6] = 'T';
      buf[7] = '=';

      memcpy(&buf[8], ipaddr, len); 
      buf[8+len] = 0x0d;		// ENTER KEY

      ata = FALSE;
      if (call UartStream.send(buf, 9+len) != SUCCESS) {
				return FAIL;
      }
    }

  }

  async command error_t WifiPlug.setJoin(){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'J';
      buf[5] = 'O';
      buf[6] = 'I';
      buf[7] = 'N';
      buf[8] = 0x0d;		// ENTER KEY
      ata = FALSE;
      if (call UartStream.send(buf, 9) != SUCCESS) {
				return FAIL;
      }
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setDHCP(bool dhcp){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'N';
      buf[5] = 'E';
      buf[6] = 'T';
      buf[7] = '=';
      if (dhcp)
				buf[8] = '1';
      else 
				buf[8] = '0';
      buf[9] = 0x0d;		// ENTER KEY
      ata = FALSE;
      if (call UartStream.send(buf, 10) != SUCCESS) {
				return FAIL;
      }
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setCon(char* ip, char* port){
		uint8_t total =0, len = 0;
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'S';
      buf[4] = 'C';
      buf[5] = 'O';
      buf[6] = 'N';
			buf[7] = '=';
			buf[8] = 'O';
			buf[9] = ',';
			buf[10] = 'T';
			buf[11] = 'C';
			buf[12] = 'N';
			buf[13] = ',';
			len = strlen(ip);
      memcpy(&buf[14], ip, len); 
			buf[14+len] = ',';
			total = 15+len;
			len = strlen(port);
      memcpy(&buf[total], port, len); 
			total = total+len;
			buf[total] = ',';
      memcpy(&buf[total+1], port, len); 
			total = total+len;
			buf[total+1] = ',';
			buf[total+2] = '1';
			buf[total+3] = 0x0d;

      ata = FALSE;
      if (call UartStream.send(buf, total+4) != SUCCESS) {
				return FAIL;
      }
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setPassword(char* type, char* pass){
		uint8_t total =0, len = 0;
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'S';
      buf[5] = 'E';
      buf[6] = 'C';
			buf[7] = '=';
			buf[8] = '0';
			buf[9] = ',';
			len = strlen(type);
      memcpy(&buf[10], type, len); 
			buf[10+len] = ',';
			total = 11+len;
			len = strlen(pass);
      memcpy(&buf[total], pass, len); 
			buf[total+len] = 0x0d;

      ata = FALSE;
      if (call UartStream.send(buf, total+len+1) != SUCCESS) {
				return FAIL;
      }
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setSSID(char* ssid, uint8_t len){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'W';
      buf[4] = 'A';
      buf[5] = 'U';
      buf[6] = 'T';
      buf[7] = 'O';
      buf[8] = '=';
      buf[9] = '0';
      buf[10] = ',';
      memcpy(&buf[11], ssid, len); 
      buf[11+len] = 0x0d;		// ENTER KEY

    }

    ata = FALSE;
    if (call UartStream.send(buf, 12+len) != SUCCESS) {
      return FAIL;
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setServerInfo(char* ip, uint8_t ip_len) {
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 'A';		
      buf[1] = 'T';
      buf[2] = '+';
      buf[3] = 'N';
      buf[4] = 'A';
      buf[5] = 'U';
      buf[6] = 'T';
      buf[7] = 'O';
      buf[8] = '=';
      buf[9] = '0';
      buf[10] = ',';
      buf[11] = '1';
      buf[12] = ',';
      memcpy(&buf[13], ip, ip_len); 
      buf[13+ip_len] = 0x0d;		// ENTER KEY

    }

    ata = FALSE;
    if (call UartStream.send(buf, 14+ip_len) != SUCCESS) {
      return FAIL;
    }
    return SUCCESS;
  }

  async command error_t WifiPlug.setEnd(){
    atomic {
      memset(buf, 0, sizeof(buf));
      buf[0] = 0x0d;		// ENTER KEY
      buf[1] = 'A';		
      buf[2] = 'T';
      buf[3] = 'A';
      buf[4] = 0x0d;		// ENTER KEY
      ata = TRUE;	
      if (call UartStream.send(buf, 5) != SUCCESS) {
				return FAIL;
      }
    }
    return SUCCESS;
  }
}
