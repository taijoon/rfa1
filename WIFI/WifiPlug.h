enum {
	WEP1 = 1,
	WEP2 = 2,

	// it has some issue, 
	// after replacing CR to 0x0d in the code
	// the code started run, by jh.kang 20120809
	CR = 0x0d
};

//#define SSID "OKCOM"
//#define PASSWORD ""
#define SSID "tos_office"
#define PASSWORD "0123456789"
//#define TYPE "OPEN" "WEP" "WPA" "WPAAES" "WPA2AES" "WPA2TKIP" "WPA2"
#define TYPE "WEP"
#define IP "222.239.78.8"
#define PORT "1114"
