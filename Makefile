COMPONENT=YggdrasilAppC

include CH_GROUP.txt
PFLAGS += -DCC2420_DEF_RFPOWER=31

#CFLAGS=-Wno-unused-but-set-variable
###### Pick BASESTATION SENSOR #################################
#CFLAGS += -DDEFAULT_BAUDRATE=115200		#Basic Sensor
#CFLAGS += -DBASE

###### NEW T.H. L SENSOR ########################################
#CFLAGS += -DTH20

###### OLD T. H. L SENSOR #################################
#CFLAGS += -DTH

###### PIR SENSOR #######################################
#CFLAGS += -DPIR
#CFLAGS += -DPIR2

###### ETYPE SENSOR ########################################
#CFLAGS += -DDEFAULT_BAUDRATE=9600
#CFLAGS += -DETYPE

###### SPLUG2 SENSOR ########################################
#CFLAGS += -DCROSS
#CFLAGS += -DSPLUG2

###### CO2 SENSOR ########################################
CFLAGS += -DCO2S100
CFLAGS += -DDEFAULT_BAUDRATE=38400		#CO2S100 Need

##################### MAXFOR SENSOR ####################
#CFLAGS += -DDEFAULT_BAUDRATE=9600	
#CFLAGS += -DMAXCO2

###### Talk Module #####################################
#CFLAGS += -DDUMMY





###### Talk Module #####################################
#CFLAGS += -DDUMMY






###### Talk Module #####################################
#CFLAGS += -DDUMMY

###### SPLUG BASE SENSOR ONLY TEST #################################
#CFLAGS += -DDEFAULT_BAUDRATE=115200		#Basic Sensor
#CFLAGS += -DWIZBRIDGE
#CFLAGS += -DSPLUGBASE

###### WIFIPLUG SENSOR #################################
#CFLAGS += -DWPS
#CFLAGS += -DDEFAULT_BAUDRATE=115200		#Basic Sensor
#CFLAGS += -DWIFIPLUG
#CFLAGS += -DCROSS

###### WIFIPLUG ONLY PLUG SENSOR ########################################
#CFLAGS += -DSPLUG2
#CFLAGS += -DCROSS

###### WIZ BASESTATION SENSOR #################################
#CFLAGS += -DDEFAULT_BAUDRATE=115200		#Basic Sensor
#CFLAGS += -DWIZBASESTATION
#CFLAGS += -DCC2420_NO_ACKNOWLEDGEMENTS
#CFLAGS += -DCC2420_NO_ADDRESS_RECOGNITION

####### TOTAL SENSOR #######################################
#CFLAGS += -DTH20
#CFLAGS += -DPIR2
#CFLAGS += -DCO2S100
#CFLAGS += -DDEFAULT_BAUDRATE=38400		#CO2S100 Need

###### PIR SENSOR #######################################
#CFLAGS += -DPIR

###### TH SENSOR ########################################
#CFLAGS += -DTH20

###### CO2S100 SENSOR ###################################
#CFLAGS += -DCO2S100
#CFLAGS += -DDEFAULT_BAUDRATE=38400		#CO2S100 Need

###### SPLUG2 SENSOR ########################################
#CFLAGS += -DSPLUG2

###### ETYPE SENSOR ########################################
#CFLAGS += -DDEFAULT_BAUDRATE=9600		#ETYPE, US
#CFLAGS += -DETYPE				#Etype meter

##################### MAXFOR SENSOR ####################
#CFLAGS += -DDEFAULT_BAUDRATE=9600	
#CFLAGS += -DMAXCO2

####################### OLD SENSOR #####################
#CFLAGS += -DFX					#Low Power and Led Off
#FX only for THL, lowpower battery operation  
####################### BASIC SENSOR #####################
#CFLAGS += -DDEFAULT_BAUDRATE=115200		#Basic Sensor
#CFLAGS += -DBASE
#CFLAGS += -DTH
#CFLAGS += -DCO2

#CFLAGS += -DVOCS
#CFLAGS += -DPOWER
#CFLAGS += -DTHERMO_LOGGER 
#CFLAGS += -DBASERSSI
#CFLAGS += -DSERIAL_ACK_ENABLE
#CFLAGS += -DINFO


######################## DEMAND CONTROLLER ######################
#CFLAGS += -DSIDC				#samin meter

######################## NEED UART SENSOR ######################
#CFLAGS += -DDEFAULT_BAUDRATE=9600		#ETYPE, US
#CFLAGS += -DETYPE				#Etype meter
#CFLAGS += -DMAXCO2				#MAXFOR CO2
#CFLAGS += -DUS
#CFLAGS += -DPRINTFUART_ENABLED

##################### SonnoPlug SENSOR ####################
#CFLAGS += -DDCPLUG
# if you want to use Splug, define SPLUG, KEEPER, KPID
#CFLAGS += -DSPLUG

##################### MAXFOR SENSOR ####################
#CFLAGS += -DDEFAULT_BAUDRATE=9600	
#CFLAGS += -DMAXCO2

# not implementation
##################### Extention SENSOR ####################
#CFLAGS += -DEXTENTION

######################### OPTIONS ########################
#CFLAGS += -DNOLED				#Led Off	
#CFLAGS += -DRESET_TIMER			#Reset Timer
#CFLAGS += -DFX					#Low Power and Led Off
#CFLAGS += -DAA					#Battery Type

### For Single hop LQI Routing
#CFLAGS += -DSINGLEHOP				#LQI Routing protocol enable & single hop
#CFLAGS += -I./net/lqi/
CFLAGS += -I./net/ctp/
CFLAGS += -I./net/4bitle/

CFLAGS += -DTOSH_DATA_LENGTH=100

CFLAGS += -I./Keeper # Keeper
#CFLAGS += -v 
CFLAGS += -I./fx 
CFLAGS += -I./ds2411 
#CFLAGS += -I./Battery 
CFLAGS += -I./SerialToDis
CFLAGS += -I./Command
CFLAGS += -I./Sensor 
CFLAGS += -I./WIFI
CFLAGS += -I./WIFI/spi
CFLAGS += -I./WizBridge
CFLAGS += -I./WizBridge/WizBridge
CFLAGS += -I./WizBridge/WizBridge/WizWifi
CFLAGS += -I./Sensor/BaseStation
CFLAGS += -I./Sensor/99Base
CFLAGS += -I./Sensor/BaseRssi
CFLAGS += -I./Sensor/100THSensor
CFLAGS += -I./Sensor/101PIRSensor
CFLAGS += -I./Sensor/102DoorSensor
CFLAGS += -I./Sensor/103CO2Sensor
CFLAGS += -I./Sensor/104VOCSSensor
CFLAGS += -I./Sensor/105PowerSensor
CFLAGS += -I./Sensor/106UltraSonicSensor
CFLAGS += -I./Sensor/107ThermoLoggerSensor
CFLAGS += -I./Sensor/108SPlugSensor
CFLAGS += -I./Sensor/108SPlugSensor/spi
CFLAGS += -I./Sensor/109Extention
CFLAGS += -I./Sensor/109Extention/Mode
CFLAGS += -I./Sensor/109Extention/Sensor
CFLAGS += -I./Sensor/112THSensor
CFLAGS += -I./Sensor/113CO2Sensor
CFLAGS += -I./Sensor/114SPlugSensor
CFLAGS += -I./Sensor/211EtypeSensor
CFLAGS += -I./Sensor/212maxforco2
CFLAGS += -I./Sensor/213SIDC
CFLAGS += -I./Sensor/250Dummy
CFLAGS += -I./Sensor/251Info

CFLAGS += -I./Sensor/Location/Mobile
CFLAGS += -I./Sensor/Location/Marker
CFLAGS += -I./Sensor/Location/Mango_Marker
CFLAGS += -I./Sensor/Keti_Solar_Node
CFLAGS += -I./Sensor/Keti_Solar_Base

### For Drip:
CFLAGS += -I./net -I./net/drip

include $(MAKERULES)
#WizBridge/WizBridge/WizBridge.h
