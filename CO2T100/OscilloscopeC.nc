
/**
 */
#include "Timer.h"
#include "Oscilloscope.h"

module OscilloscopeC @safe()
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface AMSend;
    interface Receive;
    interface Timer<TMilli>;
    interface Timer<TMilli> as Timer2;
    interface Leds;
    // Interface for Serial
		interface StdControl as SerialControl;
		interface UartStream;
  }
}
implementation
{
  message_t sendBuf;
  bool sendBusy;
  oscilloscope_t local;
  uint8_t reading;
  bool suppressCountChange;
	char sendbyte[7] = {0x02, 'A', 'C', 'D', 'L', 'S', 0x03};
	char recvrf[20];
	norace char revbyte[15];
	int recvLen = 16;
	uint16_t warringCnt = 0;

  void report_problem() { call Leds.set(7); }

  event void Boot.booted() {
    local.interval = 5120;
    local.id = TOS_NODE_ID;
    if (call RadioControl.start() != SUCCESS)
      report_problem();
		call SerialControl.start();
  }

  void startTimer() {
//    call Timer.startPeriodic(local.interval);
    call Timer2.startPeriodic(local.interval);
    reading = 0;
  }

	task void SendSerialTask(){
		call UartStream.send(recvrf, recvLen);
	}

	uint8_t i=0;
	uint16_t co2 = 0;
	uint8_t ud = 0;
	task void SendTask(){
			co2=0;
			if(revbyte[2] >= 0x30){
				co2 = (revbyte[2]-0x30)*10000;
			}
			if(revbyte[3] >= 0x30){
				co2 += (revbyte[3]-0x30)*1000;
			}
			if(revbyte[4] >= 0x30){
				co2 += (revbyte[4]-0x30)*100;
			}
			if(revbyte[5] >= 0x30){
				co2 += (revbyte[5]-0x30)*10;
			}
			if(revbyte[6] >= 0x30){
				co2 += (revbyte[6]-0x30);
			}
		
		ud ^= 1;
		if(co2 < 600){
			if(ud)
				call Leds.glow(4, 0);
			else
				call Leds.glow(0, 4);
			warringCnt = 0;
		}
		else if(co2 < 800){
			if(ud)
				call Leds.glow(6, 0);
			else
				call Leds.glow(0, 6);
			warringCnt = 0;
		}
		else if(co2 < 1000){
			if(ud)
				call Leds.glow(2, 0);
			else
				call Leds.glow(0, 2);
			warringCnt = 0;
		}
		else if(co2 < 1200){
			if(ud)
				call Leds.glow(3, 0);
			else
				call Leds.glow(0, 3);
			warringCnt = 0;
		}
		else{
			warringCnt++;

			if(warringCnt > 60)
				call Leds.led0Toggle();
			else
				if(ud)
					call Leds.glow(1, 0);
				else
					call Leds.glow(0, 1);
		}
		revbyte[14] = co2/256;
		revbyte[15] = co2%256;

		memcpy(call AMSend.getPayload(&sendBuf, recvLen), revbyte, recvLen);
		if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, recvLen) == SUCCESS)
			sendBusy = TRUE;
	}

  event void RadioControl.startDone(error_t error) {
    startTimer();
  }

  event void RadioControl.stopDone(error_t error) {
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if(TOS_NODE_ID == 0){
			memcpy(recvrf, msg->data, recvLen);
			post SendSerialTask();
		}
    return msg;
  }

  event void Timer2.fired() {
		//call UartStream.send(sendbyte, 7);
	}

  event void Timer.fired() {
//    if (reading == NREADINGS)
    {
			if (!sendBusy && sizeof local <= call AMSend.maxPayloadLength())
			{
				memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)), &local, sizeof local);
				if (call AMSend.send(AM_BROADCAST_ADDR, &sendBuf, sizeof local) == SUCCESS)
					sendBusy = TRUE;
			}
			if (!sendBusy)
				report_problem();

			reading = 0;
			if (!suppressCountChange)
				local.count++;
			suppressCountChange = FALSE;
		}
	}

  event void AMSend.sendDone(message_t* msg, error_t error) {
    sendBusy = FALSE;
  }

	int cur = 0;
	int start_op = 0;
  async event void UartStream.receivedByte( uint8_t byte ) {
		if(cur == 0){
			if(byte == 0x20){
				cur = 1;
				revbyte[cur] = byte;
			}
		}
		else{
			cur++;
			revbyte[cur] = byte;
		}

			if(byte == 0x0A ){
				if(cur == 12){
					post SendTask();
				}
				cur = 0;
			}
  }

	
  async event void UartStream.sendDone( uint8_t* buf, uint16_t len, error_t error ) {      
  }

  async event void UartStream.receiveDone( uint8_t* buf, uint16_t len, error_t error ) {
  }
}
