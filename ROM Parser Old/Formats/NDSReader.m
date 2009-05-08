#import "NDSReader.h"
#import "NSData_CRC.h"

@implementation NDSReader

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

	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle
	NSString *romFileCRC32;				// returns: fileCRC32
	NSString *romHeaderChecksum;		// returns: headerChecksum
	NSString *romCartType;				// returns: cartType
	NSString *romSize;					// returns: romSize
	NSString *romDeterminedSize;		// returns: determinedSize
	NSString *romCountry;				// returns: country
	NSString *romVersion;				// returns: version
	NSString *romInternalTitle;			// returns: internalTitle
	NSString *romGameCode;				// returns: gameCode
	NSString *romManufacture;			// returns: manufacture

	unsigned int wholeFileSize, mbit;
	unsigned long fileCRC;

	NSNumber *fileSize;

//-----------------------------------------
//		File Size
//-----------------------------------------

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:_fullPath traverseLink:YES];
	if(fileAttributes != nil){
		fileSize = [fileAttributes objectForKey:NSFileSize];
		if(fileSize) wholeFileSize = [fileSize unsignedLongLongValue];
	}
	[metadataDictionary setValue:fileSize forKey:@"fileSize"];

//-----------------------------------------
//		Calculated ROM Size
//-----------------------------------------

	mbit = wholeFileSize / 131072;

	romDeterminedSize = [NSString stringWithFormat:@"%iMBits", mbit];
	[metadataDictionary setValue:romDeterminedSize forKey:@"determinedSize"];

//-----------------------------------------
//		File CRC32, MD5, SHA1
//-----------------------------------------

	[fileHandle seekToFileOffset:0];
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
//		Initialize 'ROMHeader'
//-----------------------------------------

	[fileHandle seekToFileOffset:0];
	romBuffer = [fileHandle readDataOfLength:sizeof(NDSHeader)];
	[romBuffer getBytes:&NDSHeader];

//-----------------------------------------
//		Header Checksum
//-----------------------------------------

	romHeaderChecksum = [NSString stringWithFormat:@"%08x", NDSHeader.header_crc];
	[metadataDictionary setValue:romHeaderChecksum forKey:@"headerChecksum"];

//-----------------------------------------
//		ROM Cart Type
//-----------------------------------------

	switch(NDSHeader.devicetype){
		case 0x00: romCartType = @"ROM";									break;
		case 0x01: romCartType = @"ROM+RAM";								break;
		default:   romCartType = @"Unidentified Type";						break;
	}

	[metadataDictionary setValue:romCartType forKey:@"cartType"];

//-----------------------------------------
//		Cart Size
//-----------------------------------------

	switch(NDSHeader.devicecap){
		case 0x08: romSize = @"2M Bits";					break;
		case 0x09: romSize = @"4M Bits";					break;
		case 0x0A: romSize = @"8M Bits";					break;
		case 0x0B: romSize = @"16 MBits";					break;
		case 0x0C: romSize = @"32 MBits";					break;
		case 0x0D: romSize = @"48 MBits";					break;
		default:   romSize = @"Unidentified";				break;
	}

	[metadataDictionary setValue:romSize forKey:@"romSize"];

//-----------------------------------------
//		Country
//-----------------------------------------

	switch(NDSHeader.gamecode[3]){
		case 0x44: romCountry = @"NOE";				break; // 0x44 = 'D'
		case 0x45: romCountry = @"USA";				break; // 0x45 = 'E'
		case 0x46: romCountry = @"NOE";				break; // 0x46 = 'F'
		case 0x48: romCountry = @"Holand";			break; // 0x48 = 'H'
		case 0x49: romCountry = @"Italy";			break; // 0x49 = 'I'
		case 0x4a: romCountry = @"Japan";			break; // 0x4a = 'J'
		case 0x4b: romCountry = @"Korea";			break; // 0x4b = 'K'
		case 0x50: romCountry = @"Europe";			break; // 0x50 = 'P'
		case 0x53: romCountry = @"Spain";			break; // 0x53 = 'S'
		case 0x58: romCountry = @"EUU";				break; // 0x58 = 'X'
		default:   romCountry = @"Unidentified";	break;
	}

	[metadataDictionary setValue:romCountry forKey:@"country"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

	switch(NDSHeader.makercode[0]){
		case 0x30:
			switch(NDSHeader.makercode[1]){
				case 0x31:	romManufacture = @"Nintendo";						break;
				case 0x32:	romManufacture = @"Rocket Games, Ajinomoto";		break;
				case 0x33:	romManufacture = @"Imagineer-Zoom";					break;
				case 0x34:	romManufacture = @"Gray Matter?";					break;
				case 0x35:	romManufacture = @"Zamuse";							break;
				case 0x36:	romManufacture = @"Falcom";							break;
				case 0x37:	romManufacture = @"Enix?";							break;
				case 0x38:	romManufacture = @"Capcom";							break;
				case 0x39:	romManufacture = @"Hot B Co.";						break;
				case 0x41:	romManufacture = @"Jaleco";							break;
				case 0x42:	romManufacture = @"Coconuts Japan";					break;
				case 0x43:	romManufacture = @"Coconuts Japan / G.X.Media";		break;
				case 0x44:	romManufacture = @"Micronet?";						break;
				case 0x45:	romManufacture = @"Technos";						break;
				case 0x46:	romManufacture = @"Mebio Software";					break;
				case 0x47:	romManufacture = @"Shouei System";					break;
				case 0x48:	romManufacture = @"Starfish";						break;
				case 0x4A:	romManufacture = @"Mitsui Fudosan/Dentsu";			break;
				case 0x4C:	romManufacture = @"Warashi Inc.";					break;
				case 0x4E:	romManufacture = @"Nowpro";							break;
				case 0x50:	romManufacture = @"Game Village";					break;
				default:	romManufacture = @"Unidentified (0x30)";			break;
			}	break;
		case 0x31:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"?????????????";					break;
				case 0x32:	romManufacture = @"Infocom";						break;
				case 0x33:	romManufacture = @"Electronic Arts Japan";			break;
				case 0x35:	romManufacture = @"Cobra Team";						break;
				case 0x36:	romManufacture = @"Human/Field";					break;
				case 0x37:	romManufacture = @"KOEI";							break;
				case 0x38:	romManufacture = @"Hudson Soft";					break;
				case 0x39:	romManufacture = @"S.C.P.";							break;
				case 0x41:	romManufacture = @"Yanoman";						break;
				case 0x43:	romManufacture = @"Tecmo Products";					break;
				case 0x44:	romManufacture = @"Japan Glary Business";			break;
				case 0x45:	romManufacture = @"Forum/OpenSystem";				break;
				case 0x46:	romManufacture = @"Virgin Games";					break;
				case 0x47:	romManufacture = @"SMDE";							break;
				case 0x4A:	romManufacture = @"Daikokudenki";					break;
				case 0x50:	romManufacture = @"Creatures Inc.";					break;
				case 0x51:	romManufacture = @"TDK Deep Impresion";				break;
				default:	romManufacture = @"Unidentified (0x31)";			break;
			}	break;
		case 0x32:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Destination Software / KSS";		break;
				case 0x31:	romManufacture = @"Sunsoft/Tokai Engineering??";	break;
				case 0x32:	romManufacture = @"POW, VR 1 Japan??";				break;
				case 0x33:	romManufacture = @"Micro World";					break;
				case 0x35:	romManufacture = @"San-X";							break;
				case 0x36:	romManufacture = @"Enix";							break;
				case 0x37:	romManufacture = @"Loriciel/Electro Brain";			break;
				case 0x38:	romManufacture = @"Kemco Japan";					break;
				case 0x39:	romManufacture = @"Seta";							break;
				case 0x41:	romManufacture = @"Culture Brain";					break;
				case 0x43:	romManufacture = @"Palsoft";						break;
				case 0x44:	romManufacture = @"Visit Co.,Ltd.";					break;
				case 0x45:	romManufacture = @"Intec";							break;
				case 0x46:	romManufacture = @"System Sacom";					break;
				case 0x47:	romManufacture = @"Poppo";							break;
				case 0x48:	romManufacture = @"Ubisoft Japan";					break;
				case 0x4A:	romManufacture = @"Media Works";					break;
				case 0x4B:	romManufacture = @"NEC InterChannel";				break;
				case 0x4C:	romManufacture = @"Tam";							break;
				case 0x4D:	romManufacture = @"Gu / Gajin / Jordan";			break;
				case 0x4E:	romManufacture = @"Smilesoft ???, Rocket ???";		break;
				case 0x51:	romManufacture = @"Mediakite";						break;
				default:	romManufacture = @"Unidentified (0x32)";			break;
			}	break;
		case 0x33:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Viacom";											break;
				case 0x31:	romManufacture = @"Carrozzeria";									break;
				case 0x32:	romManufacture = @"Dynamic";										break;
				case 0x33:	romManufacture = @"Nintendo";										break; // Not a company?
				case 0x34:	romManufacture = @"Magifact";										break;
				case 0x35:	romManufacture = @"Hect";											break;
				case 0x36:	romManufacture = @"Codemasters";									break;
				case 0x37:	romManufacture = @"Taito/GAGA Communications";						break;
				case 0x38:	romManufacture = @"Laguna";											break;
				case 0x39:	romManufacture = @"Telstar Fun & Games, Event/Taito";				break;
				case 0x42:	romManufacture = @"Arcade Zone Ltd";								break;
				case 0x43:	romManufacture = @"Entertainment International/Empire Software?";	break;
				case 0x44:	romManufacture = @"Loriciel";										break;
				case 0x45:	romManufacture = @"Gremlin Graphics";								break;
				case 0x46:	romManufacture = @"K.Amusement Leasing Co.";						break;
				default:	romManufacture = @"Unidentified (0x33)";							break;
			}	break;
		case 0x34:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Seika Corp.";									break;
				case 0x31:	romManufacture = @"Ubi Soft Entertainment";							break;
				case 0x32:	romManufacture = @"Sunsoft US";										break;
				case 0x34:	romManufacture = @"Life Fitness";									break;
				case 0x36:	romManufacture = @"System 3";										break; // 70
				case 0x37:	romManufacture = @"Spectrum Holobyte";								break;
				case 0x39:	romManufacture = @"IREM";											break;
				case 0x42:	romManufacture = @"Raya Systems";									break;
				case 0x43:	romManufacture = @"Renovation Products";							break;
				case 0x44:	romManufacture = @"Malibu Games";									break;
				case 0x46:	romManufacture = @"Eidos (was U.S. Gold <=1995)";					break;
				case 0x47:	romManufacture = @"Playmates Interactive?";							break;
				case 0x4A:	romManufacture = @"Fox Interactive";								break;
				case 0x4B:	romManufacture = @"Time Warner Interactive";						break;
				case 0x51:	romManufacture = @"Disney Interactive";								break;
				case 0x53:	romManufacture = @"Black Pearl";									break;
				case 0x55:	romManufacture = @"Advanced Productions";							break;
				case 0x58:	romManufacture = @"GT Interactive";									break;
				case 0x59:	romManufacture = @"RARE?";											break;
				case 0x5A:	romManufacture = @"Crave Entertainment";							break;
				default:	romManufacture = @"Unidentified (0x34)";							break;
			}	break;
		case 0x35:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Absolute Entertainment";							break;
				case 0x31:	romManufacture = @"Acclaim";										break;
				case 0x32:	romManufacture = @"Activision";										break;
				case 0x33:	romManufacture = @"American Sammy";									break;
				case 0x34:	romManufacture = @"Take 2 Interactive (Pre-GameTek)";				break;
				case 0x35:	romManufacture = @"Hi Tech / Park Place";							break;
				case 0x36:	romManufacture = @"LJN LTD.";										break;
				case 0x38:	romManufacture = @"Mattel";											break;
				case 0x41:	romManufacture = @"Mindscape / Bitmap Brothers";					break;
				case 0x42:	romManufacture = @"Romstar";										break;
				case 0x43:	romManufacture = @"Taxan";											break;
				case 0x44:	romManufacture = @"Midway (Pre-Tradewest)";							break;
				case 0x46:	romManufacture = @"American Softworks";								break;
				case 0x47:	romManufacture = @"Majesco Sales Inc";								break;
				case 0x48:	romManufacture = @"3DO";											break;
				case 0x4B:	romManufacture = @"Hasbro";											break;
				case 0x4C:	romManufacture = @"NewKidCo";										break;
				case 0x4D:	romManufacture = @"Telegames";										break;
				case 0x4E:	romManufacture = @"Metro3D";										break;
				case 0x50:	romManufacture = @"Vatical Entertainment";							break;
				case 0x51:	romManufacture = @"LEGO Media";										break;
				case 0x53:	romManufacture = @"Xicat Interactive";								break;
				case 0x54:	romManufacture = @"Cryo Interactive";								break;
				case 0x57:	romManufacture = @"Red Storm Entertainment";						break;
				case 0x58:	romManufacture = @"Microids";										break;
				case 0x5A:	romManufacture = @"Conspiracy/Swing";								break;
				default:	romManufacture = @"Unidentified (0x35)";							break;
			}	break;
		case 0x36:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Titus";							break;
				case 0x31:	romManufacture = @"Virgin Interactive";				break;
				case 0x32:	romManufacture = @"Maxis";							break;
				case 0x34:	romManufacture = @"LucasArts Entertainment";		break;
				case 0x37:	romManufacture = @"Ocean";							break;
				case 0x39:	romManufacture = @"Electronic Arts";				break;
				case 0x42:	romManufacture = @"Laser Beam";						break;
				case 0x45:	romManufacture = @"Elite Systems";					break;
				case 0x46:	romManufacture = @"Electro Brain";					break;
				case 0x47:	romManufacture = @"The Learning Company";			break;
				case 0x48:	romManufacture = @"BBC";							break;
				case 0x4A:	romManufacture = @"Software 2000";					break;
				case 0x4C:	romManufacture = @"BAM! Entertainment";				break;
				case 0x4D:	romManufacture = @"Studio 3";						break;
				case 0x51:	romManufacture = @"Classified Games";				break;
				case 0x53:	romManufacture = @"TDK Mediactive";					break;
				case 0x55:	romManufacture = @"DreamCatcher";					break;
				case 0x56:	romManufacture = @"JoWood Produtions";				break;
				case 0x57:	romManufacture = @"SEGA (US)";						break;
				case 0x58:	romManufacture = @"Wannado Edition";				break;
				case 0x59:	romManufacture = @"LSP / Light & Shadow";			break;
				case 0x5A:	romManufacture = @"ITE Media";						break;
				default:	romManufacture = @"Unidentified (0x36)";			break;
			}	break;
		case 0x37:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Infogrames";							break;
				case 0x31:	romManufacture = @"Interplay";							break;
				case 0x32:	romManufacture = @"JVC";								break; // Broderbund
				case 0x33:	romManufacture = @"Parker Brothers";					break;
				case 0x35:	romManufacture = @"Sales Curve";						break; // Carlton International Media
				case 0x38:	romManufacture = @"THQ";								break;
				case 0x39:	romManufacture = @"Accolade";							break;
				case 0x41:	romManufacture = @"Triffix Entertainment";				break;
				case 0x43:	romManufacture = @"Microprose Software";				break;
				case 0x44:	romManufacture = @"Universal Interactive";				break; // Sierra, Simon & Schuster
				case 0x46:	romManufacture = @"Kemco (US)";							break;
				case 0x47:	romManufacture = @"Denki / Rage Software";				break;
				case 0x48:	romManufacture = @"Encore";								break;
				case 0x4A:	romManufacture = @"Zoo";								break;
				case 0x4B:	romManufacture = @"BVM";								break;
				case 0x4C:	romManufacture = @"Simon & Schuster Interactive";		break;
				case 0x4D:	romManufacture = @"Asmik Ace Entertainment Inc./AIA";	break;
				case 0x4E:	romManufacture = @"Empire Interactive?";				break;
				case 0x51:	romManufacture = @"Jester Interactive";					break;
				case 0x54:	romManufacture = @"Scholastic";							break;
				case 0x55:	romManufacture = @"Ignition Entertainment";				break;
				case 0x57:	romManufacture = @"Stadlbauer";							break;
				default:	romManufacture = @"Unidentified (0x37)";				break;
			}	break;
		case 0x38:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Misawa";							break;
				case 0x31:	romManufacture = @"Teichiku";						break;
				case 0x32:	romManufacture = @"Namco Ltd.";						break;
				case 0x33:	romManufacture = @"LOZC";							break;
				case 0x34:	romManufacture = @"KOEI";							break;
				case 0x36:	romManufacture = @"Tokuma Shoten Intermedia";		break;
				case 0x37:	romManufacture = @"Tsukuda Original";				break;
				case 0x38:	romManufacture = @"DATAM-Polystar";					break;
				case 0x42:	romManufacture = @"Bulletproof Software";			break;
				case 0x43:	romManufacture = @"Vic Tokai Inc.";					break; // Bullet-Proof Software
				case 0x45:	romManufacture = @"Character Soft";					break;
				case 0x46:	romManufacture = @"I'Max";							break;
				case 0x47:	romManufacture = @"Saurus";							break;
				case 0x4A:	romManufacture = @"General Entertainment";			break;
				case 0x4E:	romManufacture = @"Success";						break;
				case 0x50:	romManufacture = @"SEGA Japan";						break;
				default:	romManufacture = @"Unidentified (0x38)";			break;
			}	break;
		case 0x39:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Takara Amusement";				break;
				case 0x31:	romManufacture = @"Chun Soft";						break;
				case 0x32:	romManufacture = @"Video System, McO'River???";		break;
				case 0x33:	romManufacture = @"BEC / Tsuburava";				break;
				case 0x35:	romManufacture = @"Varie";							break;
				case 0x36:	romManufacture = @"Yonezawa/S'pal";					break;
				case 0x37:	romManufacture = @"Kaneko";							break;
				case 0x39:	romManufacture = @"Victor Interactive Software, Pack in Video";					break;
				case 0x41:	romManufacture = @"Nichibutsu/Nihon Bussan";		break;
				case 0x42:	romManufacture = @"Tecmo";							break;
				case 0x43:	romManufacture = @"Imagineer";						break;
				case 0x46:	romManufacture = @"Nova";							break;
				case 0x47:	romManufacture = @"Den'Z";							break;
				case 0x48:	romManufacture = @"Bottom Up";						break;
				case 0x4A:	romManufacture = @"TGL";							break;
				case 0x4C:	romManufacture = @"Hasbro Japan?";					break;
				case 0x4E:	romManufacture = @"Marvelous Entertainment";		break;
				case 0x50:	romManufacture = @"Keynet Inc.";					break;
				case 0x51:	romManufacture = @"Hands-On Entertainment";			break;
				default:	romManufacture = @"Unidentified (0x38)";			break;
			}	break;
		case 0x41:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Telenet";						break;
				case 0x31:	romManufacture = @"Hori";							break;
				case 0x34:	romManufacture = @"Konami";							break;
				case 0x35:	romManufacture = @"K.Amusement Leasing Co.";		break;
				case 0x36:	romManufacture = @"Kawada";							break;
				case 0x37:	romManufacture = @"Takara";							break;
				case 0x39:	romManufacture = @"Technos Japan Corp.";			break;
				case 0x41:	romManufacture = @"JVC, Victor Musical Indutries";	break;
				case 0x42:	romManufacture = @"Namco";							break;
				case 0x43:	romManufacture = @"Toei Animation";					break;
				case 0x44:	romManufacture = @"Toho";							break;
				case 0x46:	romManufacture = @"Namco";							break;
				case 0x47:	romManufacture = @"Media Rings Corporation";		break;
				case 0x48:	romManufacture = @"J-Wing";							break;
				case 0x4A:	romManufacture = @"Pioneer LDC";					break;
				case 0x4B:	romManufacture = @"KID";							break;
				case 0x4C:	romManufacture = @"Mediafactory";					break;
				case 0x50:	romManufacture = @"Infogrames Hudson";				break;
				case 0x51:	romManufacture = @"Kiratto. Ludic Inc";				break;
				default:	romManufacture = @"Unidentified (0x41)";			break;
			}	break;
		case 0x42:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Acclaim Japan";					break;
				case 0x31:	romManufacture = @"ASCII (Post-Nexoft)";			break;
				case 0x32:	romManufacture = @"Bandai";							break;
				case 0x34:	romManufacture = @"Enix";							break;
				case 0x36:	romManufacture = @"HAL Laboratory";					break;
				case 0x37:	romManufacture = @"SNK";							break;
				case 0x39:	romManufacture = @"Pony Canyon";					break;
				case 0x41:	romManufacture = @"Culture Brain";					break;
				case 0x42:	romManufacture = @"Sunsoft";						break;
				case 0x43:	romManufacture = @"Toshiba EMI";					break;
				case 0x44:	romManufacture = @"Sony Imagesoft";					break;
				case 0x46:	romManufacture = @"Sammy";							break;
				case 0x47:	romManufacture = @"Magical";						break;
				case 0x48:	romManufacture = @"Visco";							break;
				case 0x4A:	romManufacture = @"Compile ";						break;
				case 0x4C:	romManufacture = @"MTO Inc.";						break;
				case 0x4E:	romManufacture = @"Sunrise Interactive";			break;
				case 0x50:	romManufacture = @"Global A Entertainment";			break;
				case 0x51:	romManufacture = @"Fuuki";							break;
				default:	romManufacture = @"Unidentified (0x42)";			break;
			}	break;
		case 0x43:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Taito";								break;
				case 0x32:	romManufacture = @"Kemco";								break;
				case 0x33:	romManufacture = @"Square";								break;
				case 0x34:	romManufacture = @"Tokuma Shoten";						break;
				case 0x35:	romManufacture = @"Data East";							break;
				case 0x36:	romManufacture = @"Tonkin House	(Post-Tokyo Shoseki)";	break;
				case 0x38:	romManufacture = @"Koei";								break;
				case 0x41:	romManufacture = @"Konami / Ultra / Palcom";			break;
				case 0x42:	romManufacture = @"NTVIC / VAP";						break;
				case 0x43:	romManufacture = @"Use Co.,Ltd.";						break;
				case 0x44:	romManufacture = @"Meldac";								break;
				case 0x45:	romManufacture = @"Pony Canyon / FCI";					break;
				case 0x46:	romManufacture = @"Angel, Sotsu Agency/Sunrise";		break;
				case 0x4A:	romManufacture = @"Boss";								break;
				case 0x47:	romManufacture = @"Yumedia/Aroma Co., Ltd";				break;
				case 0x4B:	romManufacture = @"Axela/Crea-Tech?";					break;
				case 0x4C:	romManufacture = @"Sekaibunka-Sha, Sumire kobo?, Marigul Management Inc.?";		break;
				case 0x4D:	romManufacture = @"Konami Computer Entertainment Osaka";						break;
				case 0x50:	romManufacture = @"Enterbrain";													break;
				default:	romManufacture = @"Unidentified (0x43)";										break;
			}	break;
		case 0x44:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Taito/Disco";								break;
				case 0x31:	romManufacture = @"Sofel";										break;
				case 0x32:	romManufacture = @"Quest, Bothtec";								break;
				case 0x33:	romManufacture = @"Sigma, ?????";								break;
				case 0x34:	romManufacture = @"Ask Kodansha";								break;
				case 0x36:	romManufacture = @"Naxat";										break;
				case 0x37:	romManufacture = @"Copya System";								break;
				case 0x38:	romManufacture = @"Capcom Co., Ltd.";							break;
				case 0x39:	romManufacture = @"Banpresto";									break;
				case 0x41:	romManufacture = @"Tomy";										break;
				case 0x42:	romManufacture = @"LJN Japan";									break;
				case 0x44:	romManufacture = @"NCS";										break;
				case 0x45:	romManufacture = @"Human Entertainment";						break;
				case 0x46:	romManufacture = @"Altron";										break;
				case 0x47:	romManufacture = @"Jaleco???";									break;
				case 0x48:	romManufacture = @"Gaps Inc.";									break;
				case 0x4C:	romManufacture = @"????";										break;
				case 0x4E:	romManufacture = @"Elf";										break;
				default:	romManufacture = @"Unidentified (0x44)";						break;
			}	break;
		case 0x45:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"Jaleco";										break;
				case 0x31:	romManufacture = @"Towachiki";									break;
				case 0x32:	romManufacture = @"Yutaka";										break;
				case 0x33:	romManufacture = @"Varie";										break;
				case 0x34:	romManufacture = @"T&ES	oft";									break;
				case 0x35:	romManufacture = @"Epoch";										break;
				case 0x37:	romManufacture = @"Athena";										break;
				case 0x38:	romManufacture = @"Asmik";										break;
				case 0x39:	romManufacture = @"Natsume";									break;
				case 0x41:	romManufacture = @"King Records";								break;
				case 0x42:	romManufacture = @"Atlus";										break;
				case 0x43:	romManufacture = @"Epic/Sony Records";							break;
				case 0x45:	romManufacture = @"IGS";										break;
				case 0x47:	romManufacture = @"Chatnoir";									break;
				case 0x48:	romManufacture = @"Right Stuff";								break;
				case 0x4A:	romManufacture = @"????";										break;
				case 0x4C:	romManufacture = @"Spike";										break;
				case 0x4D:	romManufacture = @"Konami Computer Entertainment Tokyo";		break;
				case 0x4E:	romManufacture = @"Alphadream Corporation";						break;				
				case 0x58:	romManufacture = @"Asmik";										break;
				default:	romManufacture = @"Unidentified (0x45)";						break;
			}	break;
		case 0x46:
			switch(NDSHeader.makercode[1]){
				case 0x30:	romManufacture = @"A Wave";										break;
				case 0x31:	romManufacture = @"Motown Software";							break;
				case 0x32:	romManufacture = @"Left Field Entertainment";					break;
				case 0x33:	romManufacture = @"Extreme Ent. Grp.";							break;
				case 0x34:	romManufacture = @"TecMagik";									break;
				case 0x39:	romManufacture = @"Cybersoft";									break;
				case 0x42:	romManufacture = @"Psygnosis";									break;
				case 0x45:	romManufacture = @"Davidson/Western Tech.";						break;
				default:	romManufacture = @"Unidentified (0x46)";						break;
			}	break;
		case 0x47:
			switch(NDSHeader.makercode[1]){
				case 0x31:	romManufacture = @"PCCW Japan";									break;
				case 0x34:	romManufacture = @"KiKi Co Ltd";								break;
				case 0x35:	romManufacture = @"Open Sesame Inc???";							break;
				case 0x36:	romManufacture = @"Sims";										break;
				case 0x37:	romManufacture = @"Broccoli";									break;
				case 0x38:	romManufacture = @"Avex";										break;
				case 0x39:	romManufacture = @"D3 Publisher";								break;
				case 0x42:	romManufacture = @"Konami Computer Entertainment Japan";		break;
				case 0x44:	romManufacture = @"Square-Enix";								break;
				default:	romManufacture = @"Unidentified (0x47)";						break;
			}	break;
		case 0x49:
			switch(NDSHeader.makercode[1]){
				case 0x48:	romManufacture = @"Yojigen";									break;
				default:	romManufacture = @"Unidentified (0x49)";						break;
			}	break;

		default:	romManufacture = @"Unidentified";										break;
	}
	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Game Version
//-----------------------------------------
//	The version is stored as version 1.VersionByte and must be less than 128.

	romVersion = [NSString stringWithFormat:@"v1.%x", NDSHeader.romversion];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Game Code
//-----------------------------------------

	romGameCode = [NSString stringWithCString:NDSHeader.gamecode];
	[metadataDictionary setValue:romGameCode forKey:@"gameCode"];

//-----------------------------------------
//		Game Title
//-----------------------------------------

	romInternalTitle = [NSString stringWithCString:NDSHeader.title encoding:NSShiftJISStringEncoding];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"ndsDatLocation"];
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
//		Clean Up
//-----------------------------------------

	[fileHandle closeFile];

//-----------------------------------------
//		Debug Info
//-----------------------------------------
/*
	NSLog(@"Calculated ROM Size: %i", (wholeFileSize / 131072) );
	NSLog(@"File CRC32: %@", romFileCRC32);
	NSLog(@"File MD5: %@", romFileMD5);
	NSLog(@"File SHA1: %@", romFileSHA1);
//	NSLog(@"File Size: %d", [fileSize unsignedLongLongValue]);
	NSLog(@"Header Checksum: %04x", NDSHeader.header_crc);
	NSLog(@"Cart Type: %@", romCartType);
	NSLog(@"Size: %04x / %@", NDSHeader.devicecap, romSize);
//	NSLog(@"Size (1<<n): %04x", (1<<NDSHeader.devicecap) );
	NSLog(@"Country: %02x / %@", NDSHeader.gamecode[3], romCountry);
	NSLog(@"License: %s%s (%@)", NDSHeader.makercode[0], NDSHeader.makercode[1], romManufacture);
	NSLog(@"Version: v1.%x", NDSHeader.romversion);
	NSLog(@"Game Title: %@", romInternalTitle);
*/
//-----------------------------------------
//		Nintendo DS End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
