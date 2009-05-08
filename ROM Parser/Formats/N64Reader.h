#import "RomFileReader.h"

@interface N64Reader : RomFileReader{}

//	Some of this code was modified from Muppen64 by Hacktarux, Orkin (OSX: Adam Green, Victor Igumnov)
//	Basically it reorders the values backwards, 0x01234567 -> 0x67452301
#define sl(value) ( \
((value & 0x000000ff) << 24) | \
((value & 0x0000ff00) <<  8) | \
((value & 0x00ff0000) >>  8) | \
((value & 0xff000000) >> 24) )

struct{
	unsigned char latRegister;
	unsigned char psgRegister;
	unsigned char pwdRegister;
	unsigned char pgsRegister2;
	unsigned long clockRate;			// long v
	unsigned long programCounter;
	unsigned long version;
	unsigned long crc1;
	unsigned long crc2;					// long ^
	unsigned long paddingTwo[2];
	unsigned char internalName[20];
	unsigned long paddingThree;
	unsigned long makerCode;
	unsigned short cartridgeID;
	unsigned short countryCode;
	unsigned long bootCode[1008];
} N64Header;

@end
