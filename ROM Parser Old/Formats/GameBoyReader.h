#import "RomFileReader.h"

@interface GameBoyReader : RomFileReader{}

struct{
	unsigned char GameTitle[15], Color, Manufacture[2], SuperGameBoy, CartType, Sizefh, SRAMSize, Country, License, Version, HChecksum, checksumByte[2];
} GBROMHeader;

@end
