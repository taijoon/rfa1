/**
 * Command message disseminate other deployed nodes from serial command message.
 *
 *
 * @author Dongik Kim <sprit21c@gmail.com>
 * @version $Revision: 0.1 $ $Date: 2011/06/26 
 */
#include "Serial.h"
#include "SerialToDissemination.h"

module SerialToDisseminationP
{
  provides
  {
    interface StdControl;
//    interface AutoOn;
  }
  uses
  {
  	interface DisseminationValue<cmd_msg_t> as CommandValue;
  	interface DisseminationUpdate<cmd_msg_t> as CommandUpdate;
		interface StdControl as DisseminationControl;

    interface Receive as SerialReceive;
    interface SplitControl as SerialControl;
		
		//RunCommand
		interface RunCommand;
		interface StdControl as RunCommandControl;

		interface Leds;

    interface Send;
    interface SplitControl as RadioControl;
    interface StdControl as RoutingControl;

    interface Timer<TMilli>;
	}
}
implementation {
  uint8_t uartlen, scnt;
	
  message_t sendbuf;
  message_t uartbuf;
  bool sendbusy=FALSE, uartbusy=FALSE;

	uint8_t ack_req_cnt = 0;
	norace uint16_t newValCnt, sensorType, commandType;
	norace uint32_t action;
	cmd_msg_t cmd_msg;
	ack_oscilloscope_t local;

	task void sendTask()
	{
		local.type = ACK_OSCILLOSCOPE;
		local.scnt = scnt++;
		local.dest = TOS_NODE_ID;
		local.sensorType = sensorType;
		local.commandType = commandType;
		local.action = action;

		if (!sendbusy) {
			ack_oscilloscope_t *o = (ack_oscilloscope_t *)call Send.getPayload(&sendbuf, sizeof(ack_oscilloscope_t));
			if (o == NULL) {
			  return;
			}
			memcpy(o, &local, sizeof(ack_oscilloscope_t));
		
			if (call Send.send(&sendbuf, sizeof(ack_oscilloscope_t)) == SUCCESS) {
//				call Leds.led0Toggle();
				sendbusy = TRUE;
			}
		}
		ack_req_cnt++;
		if(ack_req_cnt > 2){
			ack_req_cnt = 0;
			call Timer.stop();
		}
	}

	command error_t StdControl.start() {
    if (call SerialControl.start() != SUCCESS)
   		; 
		call CommandValue.set( &cmd_msg ); 

		call RunCommandControl.start();

		if (call RadioControl.start() != SUCCESS) {
			call Leds.led1On();
			return FAIL;
		}

    if (call RoutingControl.start() != SUCCESS) {
			call Leds.led1On();
			return FAIL;
		}

    return SUCCESS;
  }

  command error_t StdControl.stop() {
		//call DisseminationControl.stop();
    return SUCCESS;
  }

  event void Timer.fired() {
			post sendTask();
	}

  event void RadioControl.startDone(error_t error) {
  }

  event void RadioControl.stopDone(error_t error) {
	}
	
  event void Send.sendDone(message_t* msg, error_t error) {
    sendbusy = FALSE;
  }

	event void SerialControl.startDone(error_t error) {
    if (error != SUCCESS)
			;
    call DisseminationControl.start();
 	}

  event void SerialControl.stopDone(error_t error) { }
  
	event message_t *SerialReceive.receive(message_t *msg, void *payload, uint8_t len) {
		if(len == sizeof(cmd_msg_t)) {
			cmd_msg_t *pRcm = (cmd_msg_t*)(payload);
			call CommandUpdate.change( pRcm );
		}
		return msg;
	}
  
	uint8_t change = 0;
	event void CommandValue.changed() {
    const cmd_msg_t* pCommand = call CommandValue.get();
		if ( (pCommand->dest == TOS_NODE_ID) || (pCommand->dest == AM_BROADCAST_ADDR) ) {
			sensorType = pCommand->sensorType;
			commandType = pCommand->commandType;
			action = pCommand->action;
			call RunCommand.exec(pCommand->commandType, pCommand->action);
    	call Timer.startPeriodic(100);
			//call Timer.startOneShot(20);
			//call Leds.led0Toggle();
			#if SPLUG2
//           signal AutoOn.AutoOnControl();
      #endif
			scnt = 0;
		}
  }

}
 

