#import "RomFileReader.h"

@interface NintendoReader : RomFileReader{}

#define INES_SIGNATURE	"NES\x1a"

// Control 1 Flags
#define INES_MIRROR		0x01
#define INES_SRAM		0x02
#define INES_TRAINER	0x04
#define INES_4SCREEN	0x08
// Control 3 Flags
#define INES_TVID		0x01

struct{
	char signature[4];			// 0x4e,0x45,0x53,0x1a (NES file signature)
	unsigned char prgSize;		// Number of 16kB PRG-ROM pages
	unsigned char chrSize;		// Number of 8kB CHR-ROM pages, or 0x00 None / VRAM
	unsigned char ctrl1;		// Cartridge Type LSB
	unsigned char ctrl2;		// Cartridge Type MSB (ignore this and further bytes if Byte 0Fh nonzero)
	unsigned char ram_size;		// Number of 8kB RAM pages
	unsigned char ctrl3;
	unsigned char reserved[6];	// 0
} iNESHeader;

struct{
	unsigned char gameTitle[16];	// Internal Title
	unsigned char unknown_1[2];		// Unknown
	unsigned char reserved[2];		// Reserved: 0x00, 0x00
	unsigned char unknown_2[4];		// Unknown
	unsigned char makerCode;		// Manufacture Code
} NESTitle;

@end
