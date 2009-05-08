#import "RomFileReader.h"

@interface VirtualBoyReader : RomFileReader{}

struct{
	unsigned char gameTitle[20];
	unsigned char reserved[5];
	unsigned char manufacture[2];
	unsigned char gameCode[4];
	unsigned char version;
} VBHeader;

@end
