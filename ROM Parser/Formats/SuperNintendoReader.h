#import "RomFileReader.h"

@interface SuperNintendoReader : RomFileReader{}

// This is the actual structure of a SNES ROM header
struct{
	unsigned char MakerCodeA, MakerCodeB, GameID[4], padding[7], SRAMSize, paddingb[2];
	unsigned char GameTitle[21], RomSpeed, CartType, Sizefh, SRAMSizeX, Country, License, Version;
	unsigned short inverseChecksum, checksum, nmi, rvec;
} ROMHeader;

struct{
	unsigned char one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen;
} CopierHeader;

struct{
	unsigned char	one, two, three, four, five, six, seven, eight,
					nine, ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen,
					seventeen, eighteen, nineteen, twenty, twentyone, twentytwo, twentythree, twentyfour,
					twentyfive, twentysix, twentyseven;
} BSX;

BOOL verifyOffset(int offset, NSString *fullPath);

BOOL checkForBSX(NSString *fullPath, bool hiRom);

@end
