#import "RomFileReader.h"

@interface GBAReader : RomFileReader{}

struct{
	unsigned char entryPoint[4];		// 0x04: ROM Entry Point (32bit ARM branch opcode, eg. "B rom_start")
	unsigned char nintendoLogo[156];	// 0x9c: Nintendo Logo (Compressed Bitmap)
	unsigned char gameTitle[12];		// 0x0C: Game Title (Uppercase ASCII)
	unsigned char gameCode[0x04];		// 0x04: Game Code (Uppercase ASCII), last byte is Country
	unsigned char makerCode[2];			// 0x04: Maker Code (Uppercase ASCII)
	unsigned char fixedValue;			// 0x01: Fixed Value of 0x96
	unsigned char unitCode;				// 0x01: Main Unit Code (0x00 Current GBA)
	unsigned char deviceType;			// 0x01: Device Type
	unsigned char reserved[7];			// 0x07: Reserved, all 0x00s
	unsigned char version;				// 0x01: Version
	unsigned char headerChecksum;		// 0x01: Complement Check (Header Checksum)
	unsigned char reserved2[2];			// 0x02: Reserved, all 0x00s
} GBAHeader;

/* EEPROM Types:

EEPROM_V120 (4k EEP) Super Mario Advance Save working, no problems noticed
EEPROM_V122 (4k EEP) Rock'n Roll Racing Save working, failed to boot one time
EEPROM_V124 (64K EEP) Legend of Zelda - The Minish Cap Save working, game hang once
EEPROM_V124 (64K EEP) Mario & Luigi - Superstar Saga Save working, no problems noticed
EEPROM_V124 (64K EEP) Legend of Zelda II - Adv. of Link Doesn't boot (save problem)
EEPROM_V124 (64K EEP) Teenage Mutant Ninja Turtles 2 - Battle Nexus Failed to boot
FLASH512_V131 (Flash) Urbz, Sims in the City Save working, no problems noticed
FLASH512_V131 (Flash) Sonic Advance 3 Save working, no problems noticed
FLASH1M_V102 (1M Flash) Super Mario Advance 4 - Super Mario Bros 3 Hangs after "Gameboy Player" logo
FLASH1M_V103 (1M Flash) Pokémon - Fire Red Version Save working, no problems noticed
SRAM_V112 (Sram) (256kbit (32kByte)) Kirby - Nightmare in Dreamland Save working, no problems noticed
SRAM_V113 (Sram) (256kbit (32kByte)) F-Zero GP Legend Save working, no problems noticed
FeRAM ???
*/

@end
