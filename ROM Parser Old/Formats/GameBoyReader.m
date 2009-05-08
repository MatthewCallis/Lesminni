#import "GameBoyReader.h"
#import "NSData_CRC.h"

@implementation GameBoyReader

- (id) initWithFile:(NSString *)fullPath{
	if((self = [super initWithFile:fullPath])){
		[self readMetadata];
		return self;
	}
	return nil;
}

- (void)readMetadata{
	NSMutableDictionary *metadataDictionary = [NSMutableDictionary dictionary];
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:_fullPath];
	NSData *romBuffer;

//-----------------------------------------
//		Variables
//-----------------------------------------

	NSString *romCartType;				// returns: cartType
	NSString *romColorType;				// returns: colorType
	NSString *romCountry;				// returns: country
	NSString *romDeterminedChecksum;	// returns: determinedChecksum
	NSString *romInternalTitle;			// returns: internalTitle
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle
	NSString *romHeaderChecksum;		// returns: headerChecksum
	NSString *romLicense;				// returns: license
	NSString *romManufacture;			// returns: manufacture
	NSString *romSize;					// returns: romSize
	NSString *romSaveSize;				// returns: saveSize
	NSString *romSuperGB;				// returns: superGameboy
	NSString *romVersion;				// returns: version

	NSString *romFileCRC32;				// returns: fileCRC32
	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5

	unsigned long fileCRC;
	unsigned long checksumByte1;
//	unsigned int wholeFileSize;			// returns: fileSize

//-----------------------------------------
//		File CRC32, MD5, SHA1
//-----------------------------------------

	romBuffer = [fileHandle readDataToEndOfFile];
	romFileCRC32 = [NSString stringWithFormat:@"%08x", [romBuffer crc32]];
	fileCRC = [romBuffer crc32];

	NSString *tempMD5 = [NSString stringWithFormat:@"%@ ", [romBuffer md5]];
	romFileMD5 = [NSMutableString stringWithString:tempMD5];
	[romFileMD5 replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileMD5 length])];
	[romFileMD5 replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileMD5 length])];
	[romFileMD5 replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileMD5 length])];

	NSString *tempSHA1 = [NSString stringWithFormat:@"%@ ", [romBuffer sha1]];
	romFileSHA1 = [NSMutableString stringWithString:tempSHA1];
	[romFileSHA1 replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileSHA1 length])];
	[romFileSHA1 replaceOccurrencesOfString:@"<" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileSHA1 length])];
	[romFileSHA1 replaceOccurrencesOfString:@">" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [romFileSHA1 length])];

	[metadataDictionary setValue:romFileCRC32 forKey:@"fileCRC32"];
	[metadataDictionary setValue:romFileMD5 forKey:@"fileMD5"];
	[metadataDictionary setValue:romFileSHA1 forKey:@"fileSHA1"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"gbDatLocation"];
	if([datLocation isEqualToString:nil] || [datLocation isEqualToString:@""]){
		romPreferredTitle = [NSString stringWithString:@"No DAT"];
	}
	else{
		Preferences *preferences = [[Preferences alloc] init];
		NSMutableArray *datEntries = [NSMutableArray arrayWithArray:[preferences ParseCMdat: datLocation] ];
//		Initialize it to be something now so if it isn't found it won't be nil
		NSEnumerator *objectsEnumerator = [datEntries objectEnumerator];
		DatEntry *anObject;// = [[DatEntry alloc] init];
		while(anObject = [objectsEnumerator nextObject]){
			if([[anObject crc] isEqualToString: romFileCRC32]){
				romPreferredTitle = [NSString stringWithString:[anObject name]];
			}
		}
		[anObject release];
		[preferences release];
	}
	[metadataDictionary setValue:romPreferredTitle forKey:@"preferredTitle"];
*/
//-----------------------------------------
//		Initialize 'GBROMHeader'
//-----------------------------------------

//	This is to load all of the data into our struct, GBROMHeader, so we don't have so many variables
//	GameBoy Header Offset is 0x134 hex / 308 integer
	[fileHandle seekToFileOffset: 308];
	romBuffer = [fileHandle readDataOfLength:sizeof(GBROMHeader)];
	[romBuffer getBytes:&GBROMHeader];

//-----------------------------------------
//		Game Title
//-----------------------------------------

//	GameBoy Header Offset is 0x134 hex / 308 integer, 15 bytes long
	char *ROMName = (char *)GBROMHeader.GameTitle;
	romInternalTitle = [NSString stringWithCString:ROMName];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Color / Mono
//-----------------------------------------

//	Color Offset: 0x143 hex / 323 integer, 1 byte long, but also part of the title on older ROMs
	switch(GBROMHeader.Color){
		case 0x00:	romColorType = @"Mono";						break;
		case 0x20:	romColorType = @"Color";					break; // Part Of Title: Friendly Pet Jurassic Park 3 (Chinese) (Unl) [C] & Other ChinesePirates
		case 0x30:	romColorType = @"Color";					break; // Part Of Title: Pocket Monsters Yellow (Chinese) (Unl) [S][!] & Other ChinesePirates
		case 0x31:	romColorType = @"Color";					break; // Part Of Title: SD Gundam Gaiden - Lacroan Heroes (Chinese) [p1][!]
		case 0x32:	romColorType = @"Super GameBoy Color";		break; // Part Of Title: Donkey Kong Land 2 (UE) [S][!]
		case 0x33:	romColorType = @"Super GameBoy Color";		break; // Part Of Title: Donkey Kong Land 3 (U) [S][!]
		case 0x35:	romColorType = @"Super GameBoy Color";		break; // Part Of Title: Donkey Kong Land (U) [S][!]
		case 0x47:	romColorType = @"Color";					break; // Part Of Title: Fire Dragon (J) (Chinese)
		case 0x4E:	romColorType = @"Super GameBoy Color";		break; // Part Of Title: Zankurou Musouken (J) [S][!]
		case 0x80:	romColorType = @"Color";					break;
		case 0xC0:	romColorType = @"Weird Color";				break;
		default:	romColorType = @"Unidentified";				break;
	}

	[metadataDictionary setValue:romColorType forKey:@"colorType"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

//	Manufacture Offset: 0x144 hex / 324 integer, 2 bytes long
	unsigned long manufacture = ((GBROMHeader.Manufacture[0] - 0x30)*10) + (GBROMHeader.Manufacture[1] - 0x30);

	switch(manufacture){
		case 0x00: romManufacture = @"Unknown/Pre-None";						break;
		case 0x01: romManufacture = @"Nintendo";								break;
		case 0x02: romManufacture = @"Octopus Studios / Rocket";				break;
		case 0x08: romManufacture = @"Capcom";									break;
		case 0x0D: romManufacture = @"EA (Electronic Arts)";					break;
		case 0x11: romManufacture = @"Jaleco";									break;
		case 0x12: romManufacture = @"Hudson Soft";								break;
		case 0x18: romManufacture = @"StarFish Inc.";							break;
		case 0x1C: romManufacture = @"Kemco";									break;
		case 0x1E: romManufacture = @"Now Production / Media Gallop";			break;
		case 0x20: romManufacture = @"NetVillage / GameVillage";				break;
		case 0x29: romManufacture = @"Ubi Soft";								break;
		case 0x2A: romManufacture = @"Creatures";								break;
		case 0x2C: romManufacture = @"Ubi Soft (Japan)";						break;
		case 0x30: romManufacture = @"Pinocchio / Nippon Animation Co. / Tam";	break;
		case 0x31: romManufacture = @"Jorudan";									break;
		case 0x32: romManufacture = @"SmileSoft Co.";							break;
		case 0x33: romManufacture = @"Acclaim";									break;
		case 0x34: romManufacture = @"Activision";								break;
		case 0x36: romManufacture = @"Take 2 / Majesco (Europe)";				break;
		case 0x3A: romManufacture = @"Mattel";									break;
		case 0x3C: romManufacture = @"Titus";									break;
		case 0x3D: romManufacture = @"Imagineer";								break; // Multiple?
		case 0x3E: romManufacture = @"Eidos Interactive";						break;
		case 0x40: romManufacture = @"LucasArts";								break;
		case 0x43: romManufacture = @"Mindscape";								break;
		case 0x45: romManufacture = @"Electronic Arts";							break;
		case 0x46: romManufacture = @"Midway";									break;
		case 0x47: romManufacture = @"InterPlay";								break;
		case 0x49: romManufacture = @"Majesco Games";							break;
		case 0x4A: romManufacture = @"3DO";										break;
		case 0x4B: romManufacture = @"Titus";									break; // Multiple?
		case 0x4E: romManufacture = @"T*HQ";									break;
		case 0x50: romManufacture = @"Infogrames";								break;
		case 0x52: romManufacture = @"Crave";									break;
		case 0x5A: romManufacture = @"Titus / Microids";						break; // Multiple?
		case 0x5B: romManufacture = @"Chun Soft";								break;
		case 0x5C: romManufacture = @"Kemco";									break;
		case 0x58: romManufacture = @"Bam Entertainment / Altron";				break;
		case 0x63: romManufacture = @"Pack In Soft / Victor Interactive";		break;
		case 0x6D: romManufacture = @"CyberFront / Natsume / Imagineer";		break;
		case 0x6E: romManufacture = @"Success";									break;
		case 0x70: romManufacture = @"Sega / Red";								break;
		case 0x72: romManufacture = @"Bottom Up";								break;
		case 0x75: romManufacture = @"Activision";								break;
		case 0xAE: romManufacture = @"Konami";									break;
		case 0xB1: romManufacture = @"Takara";									break;
		case 0xB5: romManufacture = @"ASCII";									break;
		case 0xB6: romManufacture = @"Bandai";									break;
		case 0xB8: romManufacture = @"Enix";									break; // Enix America
		case 0xBE: romManufacture = @"Taito / Bullet Proof";					break;
		case 0xC0: romManufacture = @"Namco";									break;
		case 0xC2: romManufacture = @"J-Wing";									break;
		case 0xC5: romManufacture = @"Culture Brain";							break;
		case 0xC6: romManufacture = @"Sunsoft / Red";							break;
		case 0xC7: romManufacture = @"Irem";									break;
		case 0xCE: romManufacture = @"Compile";									break;
		case 0xD0: romManufacture = @"MTO";										break;
		case 0xD1: romManufacture = @"Banpresto";								break;
		case 0xD3: romManufacture = @"Pony Canyon";								break;
		case 0xD7: romManufacture = @"Epoch";									break;
		case 0xD9: romManufacture = @"Tomy";									break;
		case 0xDA: romManufacture = @"Asmik Ace";								break;
		case 0xDB: romManufacture = @"Natsume";									break;
		case 0xDC: romManufacture = @"NEC Interchannel";						break;
		case 0xDE: romManufacture = @"Enterbrain / Altron";						break;
		case 0xE0: romManufacture = @"Gaps";									break;
		case 0xE2: romManufacture = @"Epoch (Japan / Doraemon)";				break;
		case 0xE3: romManufacture = @"King Records";							break;
		case 0xE4: romManufacture = @"Atlus";									break;
		case 0xE6: romManufacture = @"Elf";										break;
		case 0x119: romManufacture = @"Sachen";									break;
		case 0x163: romManufacture = @"Red Storm Entertainment";				break;
		case 0x1C3: romManufacture = @"GYY";									break;
		case 0xfffffdf0: romManufacture = @"None-Pirate";						break;
		default:	romManufacture = @"Unidentified";							break;
	}
	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Super GameBoy
//-----------------------------------------

//	Super GameBoy Offset: 0x146 hex / 326 integer, 1 byte long
	switch(GBROMHeader.SuperGameBoy){
		case 0x03:  romSuperGB = @"Super Gameboy Cart";	break;
		default:	romSuperGB = @"Regular Cart";		break;
	}
	[metadataDictionary setValue:romSuperGB forKey:@"superGameboy"];

//-----------------------------------------
//		Cartridge Type
//-----------------------------------------

//	Cartridge Type Offset: 0x147 hex / 327 integer, 1 byte long
	switch(GBROMHeader.CartType){
		case 0x00: romCartType = @"ROM";							break;
		case 0x01: romCartType = @"MBC1";							break;
		case 0x02: romCartType = @"MBC1+RAM";						break;
		case 0x03: romCartType = @"MBC1+RAM+BATTERY";				break;
		case 0x05: romCartType = @"MBC2";							break;
		case 0x06: romCartType = @"MBC2+BATTERY";					break;
		case 0x08: romCartType = @"ROM+RAM";						break;
		case 0x09: romCartType = @"ROM+RAM+BATTERY";				break;
		case 0x0B: romCartType = @"MMM01";							break;
		case 0x0C: romCartType = @"MMM01+RAM";						break;
		case 0x0D: romCartType = @"MMM01+RAM+BATTERY";				break;
		case 0x0F: romCartType = @"MBC3+TIMER+BATTERY";				break;
		case 0x10: romCartType = @"MBC3+TIMER+RAM+BATTERY";			break;
		case 0x11: romCartType = @"MBC3";							break;
		case 0x12: romCartType = @"MBC3+RAM";						break;
		case 0x13: romCartType = @"MBC3+RAM+BATTERY";				break;
		case 0x15: romCartType = @"MBC4";							break;
		case 0x16: romCartType = @"MBC4+RAM";						break;
		case 0x17: romCartType = @"MBC4+RAM+BATTERY";				break;
		case 0x19: romCartType = @"MBC5";							break;
		case 0x1A: romCartType = @"MBC5+RAM";						break;
		case 0x1B: romCartType = @"MBC5+RAM+BATTERY";				break;
		case 0x1C: romCartType = @"MBC5+RUMBLE";					break;
		case 0x1D: romCartType = @"MBC5+RUMBLE+RAM";				break;
		case 0x1E: romCartType = @"MBC5+RUMBLE+RAM+BATTERY";		break;
		case 0x22: romCartType = @"MBC7: Kirby's Tilt'n'Tumble";	break;
		case 0x59: romCartType = @"MBC1: GameBoy Smart Card";		break;
		case 0xBE: romCartType = @"MBC5: Pocket Voice Recorder";	break;
		case 0xEA: romCartType = @"MBC1: SONIC5";					break;
		case 0xFC: romCartType = @"POCKET CAMERA";					break;
		case 0xFD: romCartType = @"Bandai TAMA5: Tamagotchi";		break;
		case 0xFE: romCartType = @"Hudson HuC-3";					break;
		case 0xFF: romCartType = @"Hudson HuC-1+RAM+BATTERY";		break;
		default:   romCartType = @"Unidentified";					break;
	}
	[metadataDictionary setValue:romCartType forKey:@"cartType"];

//-----------------------------------------
//		ROM Size
//-----------------------------------------

//	ROM Size Offset: 0x148 hex / 328 integer, 1 byte
	switch(GBROMHeader.Sizefh){
		case 0x00: romSize = @"32k";			break;
		case 0x01: romSize = @"64k";			break;
		case 0x02: romSize = @"128k";			break;
		case 0x03: romSize = @"256k";			break;
		case 0x04: romSize = @"512k";			break;
		case 0x05: romSize = @"1024k (1MB)";	break;
		case 0x06: romSize = @"2048k (2MB)";	break;
		case 0x07: romSize = @"4096k (4MB)";	break;
		case 0x08: romSize = @"8192k (8MB)";	break;
		default: romSize = @"Unidentified";	break;	
	}
	[metadataDictionary setValue:romSize forKey:@"romSize"];

//-----------------------------------------
//		SRAM Size
//-----------------------------------------

//	SRAM Size Offset: 0x149 hex / 329 integer, 1 byte
	switch(GBROMHeader.SRAMSize){
		case 0x00:	romSaveSize = @"0k";			break;
		case 0x01:	romSaveSize = @"2k";			break;
		case 0x02:	romSaveSize = @"8k";			break;
		case 0x03:	romSaveSize = @"32k";			break;
		case 0x04:	romSaveSize = @"64k";			break;
		case 0x05:	romSaveSize = @"128k";			break; // Does it exsist?
		default:	romSaveSize = @"Unidentified";	break;	
	}
	[metadataDictionary setValue:romSaveSize forKey:@"saveSize"];

//-----------------------------------------
//		Country Code
//-----------------------------------------

//	Country Code Offset: 0x14A hex / 330 integer, 1 byte
	switch(GBROMHeader.Country){
		case 0x00:	romCountry = @"Japan";			break;
		case 0x01:	romCountry = @"USA & Europe";	break;
		case 0x33:	romCountry = @"China (Pirate)";	break;
		default:	romCountry = @"Unidentified";	break;	
	}
	[metadataDictionary setValue:romCountry forKey:@"country"];

//-----------------------------------------
//		License
//-----------------------------------------

//	License Offset: 0x14B hex / 331 integer, 1 byte long
//	NSLog(@"license: %x", GBROMHeader.License);
	switch(GBROMHeader.License){
		case 0x00: romLicense = @"None";						break;
		case 0x01: romLicense = @"Nintendo";					break;
		case 0x08: romLicense = @"Capcom";						break;
		case 0x09: romLicense = @"Hot-B";						break;
		case 0x0A: romLicense = @"Jaleco";						break;
		case 0x0B: romLicense = @"Coconuts";					break;
		case 0x0C: romLicense = @"Elite Systems";				break;
		case 0x13: romLicense = @"Electronic Arts";				break;
		case 0x18: romLicense = @"Hudson Soft";					break;
		case 0x19: romLicense = @"Itc Entertainment";			break;
		case 0x1A: romLicense = @"Yanoman";						break;
		case 0x1D: romLicense = @"Clary";						break;
		case 0x1F: romLicense = @"Virgin";						break;
		case 0x24: romLicense = @"PCM Complete";				break;
		case 0x25: romLicense = @"San-X";						break;
		case 0x28: romLicense = @"Kotobuki Systems";			break;
		case 0x29: romLicense = @"Seta";						break;
		case 0x30: romLicense = @"Infogrames";					break;
		case 0x31: romLicense = @"Nintendo";					break;
		case 0x32: romLicense = @"Bandai";						break;
		case 0x33: romLicense = @"'See Above'";					break; // Set to manufacture, as 'see above' meaning the same as the manufacture
		case 0x34: romLicense = @"Konami";						break;
		case 0x35: romLicense = @"Hector";						break;
		case 0x38: romLicense = @"Capcom";						break;
		case 0x39: romLicense = @"Banpresto";					break;
		case 0x3C: romLicense = @"*Entertainment I";			break;
		case 0x3E: romLicense = @"Gremlin";						break;
		case 0x41: romLicense = @"Ubi Soft";					break;
		case 0x42: romLicense = @"Atlus";						break;
		case 0x44: romLicense = @"Malibu";						break;
		case 0x46: romLicense = @"Angel";						break;
		case 0x47: romLicense = @"Spectrum Holoby";				break;
		case 0x49: romLicense = @"Irem";						break;
		case 0x4A: romLicense = @"Virgin";						break;
		case 0x4D: romLicense = @"Malibu";						break;
		case 0x4F: romLicense = @"U.S. Gold";					break;
		case 0x50: romLicense = @"Absolute";					break;
		case 0x51: romLicense = @"Acclaim";						break;
		case 0x52: romLicense = @"Activision";					break;
		case 0x53: romLicense = @"American Sammy";				break;
		case 0x54: romLicense = @"Gametek";						break;
		case 0x55: romLicense = @"Park Place";					break;
		case 0x56: romLicense = @"Ljn";							break;
		case 0x57: romLicense = @"Matchbox";					break;
		case 0x59: romLicense = @"Milton Bradley";				break;
		case 0x5A: romLicense = @"Mindscape";					break;
		case 0x5B: romLicense = @"Romstar";						break;
		case 0x5C: romLicense = @"Naxat Aoft";					break;
		case 0x5D: romLicense = @"Tradewest";					break;
		case 0x60: romLicense = @"Titus";						break;
		case 0x61: romLicense = @"Virgin";						break;
		case 0x67: romLicense = @"Ocean";						break;
		case 0x69: romLicense = @"Electronic Arts";				break;
		case 0x6E: romLicense = @"Elite Systems";				break;
		case 0x6F: romLicense = @"Electro Brain";				break;
		case 0x70: romLicense = @"Infogrames";					break;
		case 0x71: romLicense = @"Interplay";					break;
		case 0x72: romLicense = @"Broderbund";					break;
		case 0x73: romLicense = @"Sculptered Soft";				break;
		case 0x75: romLicense = @"The Sales Curve";				break;
		case 0x78: romLicense = @"T*HQ";						break;
		case 0x79: romLicense = @"Accolade";					break;
		case 0x7A: romLicense = @"Triffix Entertainment";		break;
		case 0x7C: romLicense = @"Microprose";					break;
		case 0x7F: romLicense = @"Kemco";						break;
		case 0x80: romLicense = @"Misawa Entertainment";		break;
		case 0x83: romLicense = @"Lozc";						break;
		case 0x86: romLicense = @"*Tokuma Shoten I";			break;
		case 0x8B: romLicense = @"Bullet-Proof Software";		break;
		case 0x8C: romLicense = @"Vic Tokai";					break;
		case 0x8E: romLicense = @"Ape";							break;
		case 0x91: romLicense = @"Chun Soft";					break;
		case 0x92: romLicense = @"Video System";				break;
		case 0x93: romLicense = @"Tsuburava";					break;
		case 0x95: romLicense = @"Varie";						break;
		case 0x96: romLicense = @"Yonezawa, S'Pal";				break;
		case 0x97: romLicense = @"Kaneko";						break;
		case 0x99: romLicense = @"Arc";							break;
		case 0x9A: romLicense = @"Nihon Bussan";				break;
		case 0x9B: romLicense = @"Tecmo";						break;
		case 0x9C: romLicense = @"Imagineer";					break;
		case 0x9D: romLicense = @"Banpresto";					break;
		case 0x9F: romLicense = @"Nova";						break;
		case 0xA1: romLicense = @"Hori Electric";				break;
		case 0xA2: romLicense = @"Bandai";						break;
		case 0xA4: romLicense = @"Konami";						break;
		case 0xA6: romLicense = @"Kawada";						break;
		case 0xA7: romLicense = @"Takara";						break;
		case 0xA9: romLicense = @"Technos Japan";				break;
		case 0xAA: romLicense = @"Broderbund";					break;
		case 0xAC: romLicense = @"Toei Animation";				break;
		case 0xAD: romLicense = @"Toho";						break;
		case 0xAF: romLicense = @"Namco";						break;
		case 0xB0: romLicense = @"Acclaim";						break;
		case 0xB1: romLicense = @"Ascii, Nexoft";				break;
		case 0xB2: romLicense = @"Bandai";						break;
		case 0xB4: romLicense = @"Enix";						break;
		case 0xB6: romLicense = @"Hal";							break;
		case 0xB7: romLicense = @"Snk";							break;
		case 0xB9: romLicense = @"Pony Canyon";					break;
		case 0xBA: romLicense = @"*Culture Brain O";			break;
		case 0xBB: romLicense = @"Sunsoft";						break;
		case 0xBD: romLicense = @"Sony Imagesoft";				break;
		case 0xBF: romLicense = @"Sammy";						break;
		case 0xC0: romLicense = @"Taito";						break;
		case 0xC2: romLicense = @"Kemco";						break;
		case 0xC3: romLicense = @"Squaresoft";					break;
		case 0xC4: romLicense = @"*Tokuma Shoten I";			break;
		case 0xC5: romLicense = @"Data East";					break;
		case 0xC6: romLicense = @"Tonkin House";				break;
		case 0xC8: romLicense = @"Koei";						break;
		case 0xC9: romLicense = @"Ufl";							break;
		case 0xCA: romLicense = @"Ultra";						break;
		case 0xCB: romLicense = @"Vap";							break;
		case 0xCC: romLicense = @"Use";							break;
		case 0xCD: romLicense = @"Meldac";						break;
		case 0xCE: romLicense = @"*Pony Canyon OR";				break;
		case 0xCF: romLicense = @"Angel";						break;
		case 0xD0: romLicense = @"Taito";						break;
		case 0xD1: romLicense = @"Sofel";						break;
		case 0xD2: romLicense = @"Quest";						break;
		case 0xD3: romLicense = @"Sigma Enterprises";			break;
		case 0xD4: romLicense = @"Ask Kodansha";				break;
		case 0xD6: romLicense = @"Naxat Soft";					break;
		case 0xD7: romLicense = @"Copya Systems";				break;
		case 0xD9: romLicense = @"Banpresto";					break;
		case 0xDA: romLicense = @"Tomy";						break;
		case 0xDB: romLicense = @"Ljn";							break;
		case 0xDD: romLicense = @"Ncs";							break;
		case 0xDE: romLicense = @"Human";						break;
		case 0xDF: romLicense = @"Altron";						break;
		case 0xE0: romLicense = @"Jaleco";						break;
		case 0xE1: romLicense = @"Towachiki";					break;
		case 0xE2: romLicense = @"Uutaka";						break;
		case 0xE3: romLicense = @"Varie";						break;
		case 0xE5: romLicense = @"Epoch";						break;
		case 0xE7: romLicense = @"Athena";						break;
		case 0xE8: romLicense = @"Asmik";						break;
		case 0xE9: romLicense = @"Natsume";						break;
		case 0xEA: romLicense = @"King Records";				break;
		case 0xEB: romLicense = @"Atlus";						break;
		case 0xEC: romLicense = @"Epic, Sony Records";			break;
		case 0xEE: romLicense = @"Igs";							break;
		case 0xF0: romLicense = @"A Wave";						break;
		case 0xF3: romLicense = @"Extreme Entertainment";		break;
		case 0xFF: romLicense = @"Ljn";							break;
		default: romLicense = @"Unidentified";					break;
	}
	[metadataDictionary setValue:romLicense forKey:@"license"];

//-----------------------------------------
//		Header Check / Version
//-----------------------------------------

//	Version Offset: 0x14C hex / 332 integer, 1 byte long
	romVersion = [NSString stringWithFormat:@"v1.%d", GBROMHeader.Version];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Header Checksum
//-----------------------------------------

//	Header Checksum: 0x14D hex / 333 integer, 1 byte long
	romHeaderChecksum = [NSString stringWithFormat:@"%02x", GBROMHeader.HChecksum];
	[metadataDictionary setValue:romHeaderChecksum forKey:@"headerChecksum"];

//-----------------------------------------
//		ROM Checksum
//-----------------------------------------

//	ROM Checksum: 0x14E hex / 334 integer, 2 bytes long
	checksumByte1 = GBROMHeader.checksumByte[0] << 24;
	checksumByte1 = checksumByte1 >> 16;
	checksumByte1 += GBROMHeader.checksumByte[1];

	romDeterminedChecksum = [NSString stringWithFormat:@"%04x", checksumByte1];
	[metadataDictionary setValue:romDeterminedChecksum forKey:@"determinedChecksum"];

//-----------------------------------------
//		File MD5
//-----------------------------------------
//	Returns a long, long string of things we don't really need, then the MD5. Outdated version
/*
	NSString *algorithmString = @"md5"; // md2, md4, md5, mdc2, rmd160, sha, sha1 also avaliable
	NSTask *openSSLTask = [[NSTask alloc] init];
	NSPipe *outPipe = [NSPipe pipe];
	NSArray *myArguments = [NSArray arrayWithObjects:algorithmString, _fullPath, nil];
	NSFileHandle *readHandle = [outPipe fileHandleForReading];
	NSData *inData = nil;

	// Set up task
	[openSSLTask setStandardOutput:outPipe];
	[openSSLTask setLaunchPath:@"/usr/bin/openssl"];
	[openSSLTask setArguments: myArguments];

	[openSSLTask launch];
	[openSSLTask waitUntilExit];

	// Read the processed data
	inData = [readHandle availableData];
	// Process the output data
	NSMutableString *output = [[NSString alloc] initWithData:inData encoding: NSASCIIStringEncoding];
	NSRange firstSpace = [output rangeOfString:@"= "];

	if(firstSpace.location && firstSpace.length){
		romFileMD5 = [output substringFromIndex:firstSpace.location + 2];
	}
	else{
		romFileMD5 = output;
	}

	[metadataDictionary setValue:romFileMD5 forKey:@"fileMD5"];
*/
//-----------------------------------------
//		File Size
//-----------------------------------------
/*
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:_fullPath traverseLink:YES];
	if(fileAttributes != nil){
		fileSize = [fileAttributes objectForKey:NSFileSize];
		if(fileSize) wholeFileSize = [fileSize unsignedLongLongValue];
	}
	[metadataDictionary setValue:wholeFileSize forKey:@"fileSize"];
*/
//-----------------------------------------
//		XML Title
//-----------------------------------------
/*
//	This is for displaying the best avaliable name, rather than the headers name and for renaming the files
	NSURL *theURL = [NSURL fileURLWithPath:@"/Users/Shared/GB.xml"];
	XMLTree *tree = [[XMLTree alloc] initWithURL:theURL];
//	NSLog(@"1index 0: %@", [tree childAtIndex:0]);	// returns "xml"
//	NSLog(@"1index 1: %@", [tree childAtIndex:1]);	// returns all XML contents

	XMLTree *tree2 = [tree childAtIndex:1];
//	NSLog(@"2index 0: %@", [tree2 childAtIndex:0]);	// returns 3 Choume no Tama - Tama and Friends - 3 Choume Obake Panic!! (J)UNCHECKED
//	NSLog(@"2index 1: %@", [tree2 childAtIndex:1]);	// returns 3-pun Yosou Umaban Club (J)UNCHECKED
//	NSLog(@"2index 2: %@", [tree2 childAtIndex:2]);	// returns 4 in 1 Funpak (J)UNCHECKED

//	XMLTree *tree3 = [tree2 childAtIndex:0];
//	NSLog(@"3index 0: %@", [tree3 childAtIndex:0]);				// returns 3 Choume no Tama - Tama and Friends - 3 Choume Obake Panic!! (J)
//	NSLog(@"3index 1: %@", [tree3 childAtIndex:1]);				// UNCHECKED
//	NSLog(@"3index a: %@", [tree3 attributeNamed:@"crc32"]);	// returns b61cd120

//	NSLog(@"Good: %@", [[[tree2 childNamed:@"rom" withAttribute:@"crc32" equalTo:searchCRC32] descendentNamed:@"Title"] description]);
	romPreferredTitle = [[[tree2 childNamed:@"rom" withAttribute:@"crc32" equalTo:searchCRC32] descendentNamed:@"Title"] description];
	[metadataDictionary setValue:romPreferredTitle forKey:@"preferredTitle"];
	[tree release];			// Good Title
*/
//-----------------------------------------
//		Clean Up
//-----------------------------------------

	[fileHandle closeFile];

//-----------------------------------------
//		Debug Info
//-----------------------------------------

//	NSLog(@"CRC32: %@", romFileCRC32);
//	NSLog(@"Internal Title: %@", romInternalTitle);
//	NSLog(@"Color Type: %x", colorType);
//	NSLog(@"Color: %@", romColorType);
//	NSLog(@" %02x / %02x", GBROMHeader.Manufacture[0], GBROMHeader.Manufacture[1]);
//	NSLog(@"Manufacture: %x", manufacture);
//	NSLog(@"Manufacture: %@", romManufacture);
//	NSLog(@"Super Gameboy: %@", romSuperGB);
//	NSLog(@"Cart Type: %@", romCartType);
//	NSLog(@"RAM Size: %@", romSize);
//	NSLog(@"Save Size: %@", romSRAMSize);
//	NSLog(@"CountryCode: %x", GBROMHeader.checksumByte);
//	NSLog(@"Country: %@", romCountry);
//	NSLog(@"License: %@", romLicense);
//	NSLog(@"Version: %@", romVersion);
//	NSLog(@"Header Checksum: %@", romHeaderChecksum);
//	NSLog(@"Checksum: 0x%04x", checksumByte1);
//	NSLog(@"File MD5: %@", romFileMD5);
//	NSLog(@"File Size: %d", wholeFileSize);

//-----------------------------------------
//		GameBoy End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
