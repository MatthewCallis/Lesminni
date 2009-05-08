#import "RomFileReader.h"

@interface NDSReader : RomFileReader{}

// This is the same info as from ndstool
struct{
	char title[0xC];
	char gamecode[0x4];
	char makercode[2];
	unsigned char unitcode;							// product code. 0 = Nintendo DS
	unsigned char devicetype;						// device code. 0 = normal
	unsigned char devicecap;						// device size. (1<<n Mbit)
	unsigned char reserved1[0x9];					// 0x015..0x01D
	unsigned char romversion;
	unsigned char reserved2;						// 0x01F
	unsigned int arm9_rom_offset;					// points to libsyscall and rest of ARM9 binary
	unsigned int arm9_entry_address;
	unsigned int arm9_ram_address;
	unsigned int arm9_size;
	unsigned int arm7_rom_offset;
	unsigned int arm7_entry_address;
	unsigned int arm7_ram_address;
	unsigned int arm7_size;
	unsigned int fnt_offset;
	unsigned int fnt_size;
	unsigned int fat_offset;
	unsigned int fat_size;
	unsigned int arm9_overlay_offset;
	unsigned int arm9_overlay_size;
	unsigned int arm7_overlay_offset;
	unsigned int arm7_overlay_size;
	unsigned int rom_control_info1;					// 0x00416657 for OneTimePROM
	unsigned int rom_control_info2;					// 0x081808F8 for OneTimePROM
	unsigned int banner_offset;
	unsigned short secure_area_crc;
	unsigned short rom_control_info3;				// 0x0D7E for OneTimePROM
	unsigned int offset_0x70;						// magic1 (64 bit encrypted magic code to disable LFSR)
	unsigned int offset_0x74;						// magic2
	unsigned int offset_0x78;						// unique ID for homebrew
	unsigned int offset_0x7C;						// unique ID for homebrew
	unsigned int application_end_offset;			// rom size
	unsigned int rom_header_size;
	unsigned int offset_0x88;						// reserved... ?
	unsigned int offset_0x8C;

	// reserved
	unsigned int offset_0x90;
	unsigned int offset_0x94;
	unsigned int offset_0x98;
	unsigned int offset_0x9C;
	unsigned int offset_0xA0;
	unsigned int offset_0xA4;
	unsigned int offset_0xA8;
	unsigned int offset_0xAC;
	unsigned int offset_0xB0;
	unsigned int offset_0xB4;
	unsigned int offset_0xB8;
	unsigned int offset_0xBC;

	unsigned char logo[156];						// character data
	unsigned short logo_crc;
	unsigned short header_crc;

	// 0x160..0x17F reserved
	unsigned int offset_0x160;
	unsigned int offset_0x164;
	unsigned int offset_0x168;
	unsigned int offset_0x16C;
	unsigned char zero[0x90];
} NDSHeader;

@end
