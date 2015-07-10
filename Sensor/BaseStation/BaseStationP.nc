// $Id: BaseStationP.nc,v 1.2 2010/06/29 22:07:14 scipio Exp $

#include "AM.h"
#include "Serial.h"

module BaseStationP {
	provides {
		interface BaseControl;
	}
  uses {
//    interface Boot;
    interface SplitControl as SerialControl;
    interface SplitControl as RadioControl;

    interface Send as UartSend;
    
    interface Receive as RadioReceive[am_id_t id];
    interface Receive as RadioSnoop[am_id_t id];
    interface Packet as RadioPacket;
    interface AMPacket as RadioAMPacket;

    interface Leds;
  }
}

implementation
{
  enum {
    UART_QUEUE_LEN = 12,
    RADIO_QUEUE_LEN = 12,
  };

  message_t  uartQueueBufs[UART_QUEUE_LEN];
  message_t  * ONE_NOK uartQueue[UART_QUEUE_LEN];
  uint8_t    uartIn, uartOut;
  bool       uartBusy, uartFull;

  task void uartSendTask();

  void dropBlink() {
    call Leds.led2Toggle();
  }

  void failBlink() {
    call Leds.led2Toggle();
  }

	command error_t BaseControl.start(base_info_t *nodeInfo){
  //event void Boot.booted() {
    uint8_t i;

    for (i = 0; i < UART_QUEUE_LEN; i++)
      uartQueue[i] = &uartQueueBufs[i];
    uartIn = uartOut = 0;
    uartBusy = FALSE;
    uartFull = TRUE;

    call RadioControl.start();
    call SerialControl.start();
	  return SUCCESS;	
  }

	command error_t BaseControl.repeatTimer(uint32_t repeat) {
	  return SUCCESS;	
	}

	command error_t BaseControl.oneShotTimer(uint32_t repeat) {
	  return SUCCESS;	
	}

	command error_t BaseControl.stop(){
    call RadioControl.stop();
	  return SUCCESS;	
	}

  event void RadioControl.startDone(error_t error) {
  }

  event void SerialControl.startDone(error_t error) {
    if (error == SUCCESS) {
      uartFull = FALSE;
    }
  }

  event void SerialControl.stopDone(error_t error) {}
  event void RadioControl.stopDone(error_t error) {}

  uint8_t count = 0;

  message_t* ONE receive(message_t* ONE msg, void* payload, uint8_t len);
  
  event message_t *RadioSnoop.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }
  
  event message_t *RadioReceive.receive[am_id_t id](message_t *msg,
						    void *payload,
						    uint8_t len) {
    return receive(msg, payload, len);
  }

  message_t* receive(message_t *msg, void *payload, uint8_t len) {
    message_t *ret = msg;

    atomic {
      if (!uartFull)
	{
	  ret = uartQueue[uartIn];
	  uartQueue[uartIn] = msg;

	  uartIn = (uartIn + 1) % UART_QUEUE_LEN;
	
	  if (uartIn == uartOut)
	    uartFull = TRUE;

	  if (!uartBusy)
	    {
	      post uartSendTask();
	      uartBusy = TRUE;
	    }
	}
      else
	dropBlink();
    }
    
    return ret;
  }

  uint8_t tmpLen;
  
  task void uartSendTask() {
    uint8_t len;
    message_t* msg;

    atomic {
      if (uartIn == uartOut && !uartFull) {
	uartBusy = FALSE;
	return;
      }
    }

    msg = uartQueue[uartOut];
    tmpLen = len = call RadioPacket.payloadLength(msg);

    if (call UartSend.send(uartQueue[uartOut], len) == SUCCESS) {
      call Leds.led1Toggle();
    }
    else  {
      failBlink();
      post uartSendTask();
    }
  }

  event void UartSend.sendDone(message_t* msg, error_t error) {
    if (error != SUCCESS)
      failBlink();
    else
      atomic
	if (msg == uartQueue[uartOut])
	  {
	    if (++uartOut >= UART_QUEUE_LEN)
	      uartOut = 0;
	    if (uartFull)
	      uartFull = FALSE;
	  }
    post uartSendTask();
  }

}  
