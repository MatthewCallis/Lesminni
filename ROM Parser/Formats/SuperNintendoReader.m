#import "SuperNintendoReader.h"
#import "NSData_CRC.h"

@implementation SuperNintendoReader

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

	NSString *romFileCRC32;				// returns: fileCRC32
	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5
	NSString *headerCheck;				// returns: headerCheck
	NSString *romDeterminedChecksum;	// returns: determinedChecksum
	NSString *romHeaderChecksum;		// returns: headerChecksum
	NSString *romGameCode;				// returns: gameCode

	NSString *romCartType;				// returns: cartType
	NSString *romSize;					// returns: romSize
	NSString *romDeterminedSize;		// returns: determinedSize
	NSString *romSaveSize;				// returns: saveSize
	NSString *romCountry;				// returns: country
	NSString *romVideoSystem;			// returns: videoSystem
	NSString *romLicense;				// returns: license
	NSString *romManufacture;			// returns: manufacture
	NSString *romVersion;				// returns: version
	NSString *romMap;					// returns: romMap
	NSString *romSpeed;					// returns: romSpeed

	NSString *romInternalTitle;			// returns: internalTitle
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle

	unsigned int wholeFileSize;
	unsigned long fileCRC;

	NSNumber *fileSize;

	bool loRom;
	bool hiRom;

	int offset, headerOffset, start, mbit;

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
//		Copier Header Check
//-----------------------------------------
/*	Known Copiers:
		Super Wild Card
		Super Wild Card DX
		Super Wild Card DX2
		Super Magicom
		UFO Super Drive
		Super Pro Fighter Q
		Supercom Pro
		Game Doctor SF II, III, IV, V, VI, VII
		Supercom Partner
		Dragon Boy				*/
	[fileHandle seekToFileOffset:0];
	romBuffer = [fileHandle readDataOfLength:sizeof(CopierHeader)];
	[romBuffer getBytes:&CopierHeader];

	if( (CopierHeader.nine == 0xAA) && (CopierHeader.ten == 0xBB) && (CopierHeader.eleven == 0x04) ){
		headerCheck = @"Super Wild Card (SWC)";
		headerOffset = 512;
	}
	//	Checking for 'GAME DOCTOR' of 'GAME DOCTOR SF 3' header
	else if((CopierHeader.one == 0x47) && 
			(CopierHeader.two == 0x41) && 
			(CopierHeader.three == 0x4d) && 
			(CopierHeader.four == 0x45) && 
			(CopierHeader.five == 0x20) && 
			(CopierHeader.six == 0x44) && 
			(CopierHeader.seven == 0x4f) && 
			(CopierHeader.eight == 0x43) && 
			(CopierHeader.nine == 0x54) && 
			(CopierHeader.ten == 0x4f) && 
			(CopierHeader.eleven == 0x52) ){
		headerCheck = @"Game Doctor SF 3 (GD3)";
		headerOffset = 512;
	}
	//	Checking for 'SUPERUFO' header
	else if((CopierHeader.nine == 0x53) && 
			(CopierHeader.ten == 0x55) && 
			(CopierHeader.eleven == 0x50) &&
			(CopierHeader.twelve == 0x45) && 
			(CopierHeader.thirteen == 0x52) && 
			(CopierHeader.fourteen == 0x55) && 
			(CopierHeader.fifteen == 0x46) && 
			(CopierHeader.sixteen == 0x4f) ){
		headerCheck = @"UFO Super Drive (UFO)";
		headerOffset = 512;
	}
	//	Checking for Pro Fighter header
	else if( ((CopierHeader.three == 0x40) || (CopierHeader.three == 0x00)) &&
			 ((CopierHeader.four == 0x80) || (CopierHeader.four == 0x00)) &&
			 ((CopierHeader.five == 0xFD) || (CopierHeader.five == 0x47) || (CopierHeader.five == 0x77)) &&
			 ((CopierHeader.six == 0x82) || (CopierHeader.six == 0x83)) ){
		headerCheck = @"Pro Fighter (FIG)";
		headerOffset = 512;
	}
	//	Checking for Generic (0x80) header
	else if((CopierHeader.one == 0x80) && (CopierHeader.two == 0x00) && (CopierHeader.three == 0x00) && 
			(CopierHeader.four == 0x00) && (CopierHeader.five == 0x00) && (CopierHeader.six == 0x00) && 
			(CopierHeader.seven == 0x00) && (CopierHeader.eight == 0x00) && (CopierHeader.nine == 0x00) && 
			(CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Generic (0x80)";
		headerOffset = 512;
	}
	//	Checking for Generic (0x84) header
	else if((CopierHeader.one == 0x84) && (CopierHeader.two == 0x00) && (CopierHeader.three == 0x00) && 
			(CopierHeader.four == 0x00) && (CopierHeader.five == 0x00) && (CopierHeader.six == 0x00) && 
			(CopierHeader.seven == 0x00) && (CopierHeader.eight == 0x00) && (CopierHeader.nine == 0x00) && 
			(CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Generic (0x84)";
		headerOffset = 512;
	}
	//	Checking for Generic (0x02) header
	else if((CopierHeader.one == 0x00) && (CopierHeader.two == 0x02) && /* (CopierHeader.three == 0x00) && 
			(CopierHeader.four == 0x00) && */ (CopierHeader.five == 0x00) && (CopierHeader.six == 0x00) && 
			(CopierHeader.seven == 0x00) && (CopierHeader.eight == 0x00) && (CopierHeader.nine == 0x00) && 
			(CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Generic (0x02)";
		headerOffset = 512;
	}
	//	Checking for Unknown (80, CC, 80) header
	else if((CopierHeader.four == 0x80) && (CopierHeader.five == 0xCC) && (CopierHeader.six == 0x80) && 
			(CopierHeader.seven == 0x00) && (CopierHeader.eight == 0x00) && (CopierHeader.nine == 0x00) && 
			(CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Unknown (0x80CC80)";
		headerOffset = 512;
	}
	//	Checking for Unknown (0x08) header
	else if((CopierHeader.one == 0x08) && (CopierHeader.two == 0x00) && (CopierHeader.three == 0xFC) && 
			(CopierHeader.four == 0x01) && (CopierHeader.five == 0x00) && (CopierHeader.six == 0x00) && 
			(CopierHeader.seven == 0x00) && (CopierHeader.eight == 0x00) && (CopierHeader.nine == 0x00) && 
			(CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Unknown (0x08)";
		headerOffset = 512;
	}
	//	Checking for Unknown (0x0003) header
	else if((CopierHeader.one == 0x00) && (CopierHeader.two == 0x03) && (CopierHeader.three == 0x00) && 
			(CopierHeader.four == 0x80) && (CopierHeader.five == 0x00) && (CopierHeader.six == 0x00) ){
		headerCheck = @"Unknown (0x0003)";
		headerOffset = 0;
	}
	//	Checking for Unknown (0x00) header
	else if((CopierHeader.ten == 0x00) && (CopierHeader.eleven == 0x00) && (CopierHeader.twelve == 0x00) && 
			(CopierHeader.thirteen == 0x00) && (CopierHeader.fourteen == 0x00) && (CopierHeader.fifteen == 0x00) && 
			(CopierHeader.sixteen == 0x00) ){
		headerCheck = @"Unknown / Bad Dump";
		headerOffset = 0;
	}
	else{
		headerCheck = @"No Header";
		headerOffset = 0;
	}
	[metadataDictionary setValue:headerCheck forKey:@"headerCheck"];

//-----------------------------------------
//		File CRC32, MD5, SHA1
//-----------------------------------------

	[fileHandle seekToFileOffset:headerOffset];
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
//		Detect HiROM / LoROM
//-----------------------------------------
//	There are (usually) four possible offsets for the ROMHeader:
//		LoROM Header Position (Deafult):	33216 / 0x81C0
//		LoROM Header Position (Alternate):	32704 / 0x7FC0
//		HiROM Header Position (Default):	65984 / 0x101C0
//		HiROM Header Position (Alternate):	65472 / 0xFFC0
//	If the checksum & the inverse checksum match (add to 0xFFFF) the right location is found (see verifyOffset function).
//	To skip the CopierHeader later, buffer 512 (int start)
	offset = 33216;
	start = 512;
	hiRom = FALSE;
	loRom = TRUE;
	if(!verifyOffset(offset, _fullPath)){
		offset = 65984;
		hiRom = TRUE;
		loRom = FALSE;
		if(!verifyOffset(offset, _fullPath)){
			offset = 65472;
			start = 0;
			hiRom = TRUE;
			loRom = FALSE;
			if(!verifyOffset(offset, _fullPath)){
				offset = 32704;
				hiRom = FALSE;
				loRom = TRUE;
				if(!verifyOffset(offset, _fullPath)){
				//	NSLog(@"Checking for special cases...");
					hiRom = TRUE;
					loRom = FALSE;
					if(fileCRC == 0x27E43CEE)		offset = 65984;		// Tales Of Phantasia (DeJap Translation)
					else if(fileCRC == 0x4aafa3ae)	offset = 65984;		// Tales Of Phantasia (DeJap Translation) v1.2
					else if(fileCRC == 0x9328ece9)	offset = 4260288;	// Dai Kaijuu Monogatari 2 (J) [!]
					else if(fileCRC == 0xa6c98ffe)	offset = 4259776;	// Daikaijuu Monogatari 2 (J) [!] (No Header)
					else if(fileCRC == 0xc0872e07)	offset = 64960;		// Star Fox 2 (Beta) [b1]
					else if(fileCRC == 0x23ed7a47)	offset = 65472;		// Star Fox 2 (Beta) [b2], see above
					else if(fileCRC == 0x421bbb4b)	offset = 131520;	// Donkey Kong Country 2 - Diddy's Kong Quest (U) (V1.0) [t4]
					else if(fileCRC == 0xa73f1cbe)	offset = 131520;	// Donkey Kong Country 2 - Diddy's Kong Quest (U) (V1.0) [t5]
					else if(fileCRC == 0xed0b99c0)	offset = 33216;		// Super Temco NBA Basketball [t1]
					else if(fileCRC == 0x90ccead0)	offset = 33216;		// Wild Guns [t4]
					else if(fileCRC == 0x2a4f5a5e)	offset = 33216;		// Wild Guns [t3]
					else if(fileCRC == 0x1e327bd9)	offset = 65472;		// Tengai Makyou Zero (J)
					else{
					//	NSLog(@"%@", romFileCRC32);
					//	NSLog(@"Can't find the ROM Header!");
//						[romBuffer release];
//						[fileHandle closeFile];
//						return NO;
					}
				}
			}
		}
	}

	if(hiRom == TRUE && loRom == FALSE) romMap = @"HiROM";
	else romMap = @"LoROM";
	[metadataDictionary setValue:romMap forKey:@"romMap"];

//-----------------------------------------
//		Calculated ROM Size
//-----------------------------------------

	mbit = wholeFileSize / 131072;
//	NSLog(@"mbit: %i", (wholeFileSize / 131072) );

	romDeterminedSize = [NSString stringWithFormat:@"%i MBits", mbit];
	[metadataDictionary setValue:romDeterminedSize forKey:@"determinedSize"];

//-----------------------------------------
//		Calculated ROM Header Checksum
//-----------------------------------------
/*	Calculate the checksum
	This information is generally used to calcate the checksum, however I do it
	in the NSData method, but someone or I might need this information later...
	int count, hisum = 0, lowsum = 0;
	lowchunk = pow(2, (int)(log10(mbit) / log10(2)) );		NSLog(@"lowchunk: %i", lowchunk);
	hichunk = mbit - lowchunk;								NSLog(@"hichunk: %i", hichunk);
	if(hichunk == 0) factor = 0;
	else factor = lowchunk / hichunk;						NSLog(@"factor: %i", factor);	*/

	[fileHandle seekToFileOffset: headerOffset];
	romBuffer = [fileHandle readDataToEndOfFile];

	romDeterminedChecksum = [NSString stringWithFormat:@"%04x", [romBuffer snesChecksum]];
	[metadataDictionary setValue:romDeterminedChecksum forKey:@"determinedChecksum"];

//-----------------------------------------
//		Broadcast Satellaview-X Check
//-----------------------------------------

//	if(checkForBSX(_fullPath, hiRom)) NSLog(@"Not BS-X");
//	else NSLog(@"BS-X");
/**
	if(hiRom) offset += 0x8000;

	Settings.BS = FALSE;
	Settings.BS = (-1 != is_bsx(ROM + 0x7FC0));

	if(Settings.BS){
		Memory.LoROM=TRUE;
		Memory.HiROM=FALSE;
	}
	else{
		Settings.BS = (-1 != is_bsx(ROM + 0xFFC0));
		if(Settings.BS){
			Memory.HiROM=TRUE;
			Memory.LoROM=FALSE;
		}
	}

int is_bsx(unsigned char *p){
	unsigned c;

	if(p[0x19] & 0x4f ) goto notbsx;
	c = p[0x1a];
	if((c != 0x33) && (c != 0xff)) goto notbsx;	// 0x33 = Manufacturer: Nintendo
	c = (p[0x17] << 8) | p[0x16];
	if((c != 0x0000) && (c != 0xffff)){
		if((c & 0x040f) != 0) goto notbsx;
		if((c & 0xff) > 0xc0) goto notbsx;
	}
	c = p[0x18];
	if((c & 0xce) || ((c & 0x30) == 0))	goto notbsx;
	if((p[0x15] & 0x03) != 0)			goto notbsx;
	c = p[0x13];
	if((c != 0x00) && (c != 0xff))		goto notbsx;
	if(p[0x14] != 0x00)					goto notbsx;
	if(bs_name(p) != 0)					goto notbsx;
	return 0; // It's a Satellaview ROM!
notbsx:
	return -1;
}

int bs_name(unsigned char *p){
	unsigned c;
	int lcount;
	int numv; // number of valid name characters seen so far
	numv = 0; 
	for(lcount = 16; lcount > 0; lcount--){
		if(check_char(c = *p++) != 0){
			c = *p++;
			if(c < 0x20){
				// Dr. Mario Hack
				if((numv != 0x0b) || (c != 0)) goto notBsName;
			}
			numv++;
			lcount--;
			continue;
		}
		else{
			if(c == 0){
				if(numv == 0)	goto notBsName;
				continue;
			}
			if(c < 0x20) goto notBsName;
			if(c >= 0x80){
				if((c < 0xa0) || (c >= 0xf0))	goto notBsName;
			}
			numv++;
		}
	}
	if(numv > 0) return 0;
notBsName:
	return -1;
}

int check_char(unsigned c){
	if((c & 0x80) == 0 ) return 0;
	if((c - 0x20 ) & 0x40 ) return 1;
	else return 0;
}
***/

//-----------------------------------------
//		Initialize 'ROMHeader'
//-----------------------------------------

	[fileHandle seekToFileOffset: (offset-16)];
	romBuffer = [fileHandle readDataOfLength:sizeof(ROMHeader)];
	[romBuffer getBytes:&ROMHeader];

//-----------------------------------------
//		Header Checksum
//-----------------------------------------

	romHeaderChecksum = [NSString stringWithFormat:@"%04x", ROMHeader.checksum];
	[metadataDictionary setValue:romHeaderChecksum forKey:@"headerChecksum"];

//-----------------------------------------
//		ROM Speed
//-----------------------------------------

	switch(ROMHeader.RomSpeed){
		case 0x00: romSpeed = @"SlowROM (200ns)";		break;
		case 0x02: romSpeed = @"FastROM (120ns)";		break; // ie: Arcus Spirits (Beta)
//		case 0x10: romSpeed = @"SlowROM (200ns)";		break; // ie: Asterix (E) [b1] / Blues Brothers, The (U) [hI] (FastROM)
		case 0x1c: romSpeed = @"FastROM (120ns)";		break; // ie: Romancing SaGa 3 (J) (V1.0) [h1]
		case 0x20: romSpeed = @"SlowROM (200ns)";		break;
		case 0x21: romSpeed = @"SlowROM (200ns)";		break;
		case 0x23: romSpeed = @"SlowROM (200ns)";		break;
		case 0x25: romSpeed = @"SlowROM (200ns)";		break; // ie: Super Demo World - The Legend Continues (SMW1 Hack)
		case 0x28: romSpeed = @"FastROM (120ns)";		break; // ie: Super Bomberman 4 (J) [t2]
		case 0x29: romSpeed = @"SlowROM (200ns)";		break;
		case 0x2e: romSpeed = @"FastROM (120ns)";		break; // ie: Arkanoid - Doh It Again (J) [T+Por]
		case 0x30: romSpeed = @"FastROM (120ns)";		break;
		case 0x31: romSpeed = @"FastROM (120ns)";		break;
		case 0x32: romSpeed = @"FastROM (120ns)";		break;
		case 0x35: romSpeed = @"FastROM (120ns)";		break;
		case 0x3A: romSpeed = @"FastROM (120ns)";		break;
		case 0x41: romSpeed = @"SlowROM (200ns)";		break; // ie: Super Demo World - OryNider's Retro World V1.01 (SMW1 Hack)
		case 0x42: romSpeed = @"SlowROM (200ns)";		break;
		case 0x44: romSpeed = @"SlowROM (200ns)";		break;
		case 0x52: romSpeed = @"FastROM (120ns)";		break; // ie: Street Fighter II - The World Warrior (Beta)
		case 0x53: romSpeed = @"FastROM (120ns)";		break; // ie: Rudra no Hihou (J) [T+Eng.99b2_AGTP]
		case 0x61: romSpeed = @"FastROM (120ns)";		break; // ie: Speedy Gonzales - Los Gatos Bandidos (U) (V1.0) [T+Spa]
		case 0x80: romSpeed = @"SlowROM (200ns)";		break; // ie: BS Zelda
		case 0x8d: romSpeed = @"SlowROM (200ns)";		break; // ie: Super Aleste (J) [t1]
		case 0x92: romSpeed = @"FastROM (120ns)";		break; // ie: Street Hockey '95 (Beta) [b1]
		case 0xa9: romSpeed = @"FastROM (120ns)";		break; // ie: Seiken Densetsu 3 (J) (Sample) [b1]
		case 0xbf: romSpeed = @"SlowROM (200ns)";		break; // ie: Super Drift Out (J) [b1]
		case 0xfb: romSpeed = @"SlowROM (200ns)";		break; // ie: American Tail, An - Fievel Goes West (U) [t1]
		case 0xfd: romSpeed = @"FastROM (120ns)";		break; // ie: Super Fire Pro Wrestling Special (J) [h3C]
		case 0xff: romSpeed = @"FastROM (120ns)";		break; // ie: Super Bonk (U) [t1]
		default:   romSpeed = @"Unidentified Speed";	break;
	}

	[metadataDictionary setValue:romSpeed forKey:@"romSpeed"];

//-----------------------------------------
//		ROM Cart Type
//-----------------------------------------
///	RAM+BAT = SRAM
//	0x9b4ca911 = ST Add-on Base Cassete (J)
	switch(ROMHeader.CartType){
		case 0x00: romCartType = @"ROM";									break;
		case 0x01: romCartType = @"ROM+RAM";								break;
		case 0x02: romCartType = @"ROM+RAM+BAT";							break;
		case 0x03: romCartType = @"ROM+DSP-1";
			if(ROMHeader.RomSpeed == 0x30) romCartType = @"ROM+DSP-4";				// ie: Top Gear 3000 (U) [!]
			break;
//		case 0x04: romCartType = @"ROM+RAM+DSP-1";							break;
		case 0x05: romCartType = @"ROM+RAM+BAT+DSP-1";
			if(ROMHeader.RomSpeed == 0x20) romCartType = @"ROM+RAM+BAT+DSP-2";		// ie: Dungeon Master (J) (V1.0) [!]
			if((ROMHeader.RomSpeed == 0x30) && (ROMHeader.License == 0xb2)){
				romCartType = @"ROM+RAM+BAT+DSP-3";									// ie: Top Gear 3000 (U) [!]
			}
			break;
//		case 0x11: romCartType = @"ROM+RAM";								break;	// ie: Mega Man X 2 (E)(NG-Dump Known)???
		case 0x13: romCartType = @"ROM+SuperFX (Mario Chip 1)";
			if(fileCRC == 0xb2edbf88) romCartType = @"ROM+RAM+BAT+OBC1";			// ie: Metal Combat [b1] Correction
			break;
		case 0x14: romCartType = @"ROM+RAM+SuperFX";								// ie: 
			if((ROMHeader.Sizefh == 0x0b) || (ROMHeader.Sizefh == 0x0c)){
				romCartType = @"ROM+RAM+SuperFX2";									// ie: Doom (U) [!]
			}
			break;
		case 0x15: romCartType = @"ROM+RAM+BAT+SuperFX";							// ie: Stunt Race FX (E)
			if((ROMHeader.Sizefh == 0x0b) || (ROMHeader.Sizefh == 0x0c)){
				romCartType = @"ROM+RAM+BAT+SuperFX2";								// ie: Super Mario World 2 - Yoshi's Island (U) (M3) (V1.0) [!]
			}
			break;
		case 0x1A: romCartType = @"ROM+RAM+SuperFX";						break;	// ie: Stunt Race FX (US)
		case 0x25: romCartType = @"ROM+RAM+BAT+OBC1";						break;	// ie: Metal Combat - Falcon's Revenge (U) [!]
		case 0x34: romCartType = @"ROM+RAM+SA-1";							break;	// ie: Dragon Ball Z - Hyper Dimension (J) [!]
		case 0x35: romCartType = @"ROM+RAM+BAT+SA-1";						break;	// ie: Super Mario RPG
		case 0x43: romCartType = @"ROM+S-DD1";								break;	// ie: Street Fighter Zero 2 (J)
		case 0x45: romCartType = @"ROM+RAM+BAT+S-DD1";						break;	// ie: Star Ocean (J) [!]
		case 0x55: romCartType = @"ROM+RAM+BAT+S-RTC";								// ie: Dai Kaiju Monogatari 2 (J) [Dejap Fix]
			if(fileCRC == 0xa6c98ffe) romCartType = @"ROM+RAM+BAT+S-RTC";			// ie: Daikaijuu Monogatari 2 (J) [!]
			break;
		case 0xAA: romCartType = @"ROM+RAM+CoPro#10";						break;	// ie: Wolfstein 3D
		case 0xE3: romCartType = @"ROM+RAM+GameBoy";						break;
		case 0xE5: romCartType = @"BS-X BIOS";								break;
		case 0xF3: romCartType = @"ROM+C4";									break;	// ie: Mega Man X 2/3 (U) [!]
		case 0xF5: romCartType = @"ROM+RAM+BAT+Seta-RISC";							// ie: Hayazashi Nidan Morita Shougi 2 (J), common ROMSpeed
			if(ROMHeader.RomSpeed == 0x3a) romCartType = @"ROM+RAM+BAT+SPC7110";	// ie: Momotaro Dentetsu Happy (J) [!]
			break;
		case 0xF6: romCartType = @"ROM+SetaDSP";							break;	// ie: Hayazashi Nidan Morita Shougi (J)
		case 0xF9: romCartType = @"ROM+SPC7110+RTC";						break;	// ie: Tengai Makyou Zero (J) [!]
		default:
			romCartType = [NSString stringWithFormat:@"Unidentified Type (%x)", ROMHeader.CartType];
			break;
	}	
	if(fileCRC == 0x3c89322a) romCartType = @"Tri-Star BIOS";			// Tri-Star Dos - NES-SNES (Adaptor Bios)å
	if(fileCRC == 0x9b4ca911) romCartType = @"Sufami Turbo BIOS";		// Sufami Turbo BIOS
	if(fileCRC == 0x43d47034) romCartType = @"X-Band Modem BIOS + BAT";	// X-Band Modem BIOS

	[metadataDictionary setValue:romCartType forKey:@"cartType"];

//-----------------------------------------
//		Cart Size
//-----------------------------------------

	switch(ROMHeader.Sizefh){
		case 0x08: romSize = @"2 MBits";					break;
		case 0x09: romSize = @"4 MBits";					break;
		case 0x0A: romSize = @"8 MBits";					break;
		case 0x0B: romSize = @"16 MBits";					break;
		case 0x0C: romSize = @"32 MBits";					break;
		case 0x0D: romSize = @"48 MBits";					break;
		case 0x0E: romSize = @"64 MBits";					break;
		default:   romSize = @"Unidentified";				break;
	}

	[metadataDictionary setValue:romSize forKey:@"romSize"];

//-----------------------------------------
//		SRAM / Battery Size
//-----------------------------------------
	
	unsigned char saveRAM;
	if(	ROMHeader.SRAMSize != 0x00 ||
		ROMHeader.SRAMSize != 0x01 ||
		ROMHeader.SRAMSize != 0x02 ||
		ROMHeader.SRAMSize != 0x03 ||
		ROMHeader.SRAMSize != 0x04 ||
		ROMHeader.SRAMSize != 0x05 ||
		ROMHeader.SRAMSize != 0x06 ||
		ROMHeader.SRAMSize != 0x07 )	ROMHeader.SRAMSizeX = saveRAM;
	else ROMHeader.SRAMSize = saveRAM;

	switch(ROMHeader.SRAMSize){
		case 0x00: romSaveSize = @"None";			break;
		case 0x01: romSaveSize = @"16 KBits";		break;
		case 0x02: romSaveSize = @"32 KBits";		break;
		case 0x03: romSaveSize = @"64 KBits";		break;
		case 0x04: romSaveSize = @"128 KBits";		break; // ???
		case 0x05: romSaveSize = @"256 KBits";		break; // Star Fox 2
		case 0x06: romSaveSize = @"512 KBits";		break; // Marvelous (J)
		case 0x07: romSaveSize = @"1024 KBits";		break; // Kaite Tukutte Asoberu Dezaemon (J)
		case 0x08: romSaveSize = @"64 KBits";		break; // Air Management - Oozora ni Kakeru (J) (V1.1) [!]
		case 0x12: romSaveSize = @"64 KBits";		break; // Super Power League 2 (J) (V1.1) [!]
		default:   romSaveSize = [NSString stringWithFormat:@"Unidentified (%x)", ROMHeader.SRAMSize];
			break;
	}

	[metadataDictionary setValue:romSaveSize forKey:@"saveSize"];

//-----------------------------------------
//		Country
//-----------------------------------------

	switch(ROMHeader.Country){
		case 0x00: romCountry = @"Japan";								romVideoSystem = @"NTSC";	break;
		case 0x01: romCountry = @"USA";									romVideoSystem = @"NTSC";	break;
		case 0x02: romCountry = @"Australia, Europe, Oceania & Asia";	romVideoSystem = @"PAL";	break;
		case 0x03: romCountry = @"Sweden";								romVideoSystem = @"PAL";	break;
		case 0x04: romCountry = @"Finland";								romVideoSystem = @"PAL";	break;
		case 0x05: romCountry = @"Denmark";								romVideoSystem = @"PAL";	break;
		case 0x06: romCountry = @"France";								romVideoSystem = @"PAL";	break;
		case 0x07: romCountry = @"Holland";								romVideoSystem = @"PAL";	break;
		case 0x08: romCountry = @"Spain";								romVideoSystem = @"PAL";	break;
		case 0x09: romCountry = @"Germany, Austria & Switzerland";		romVideoSystem = @"PAL";	break;
		case 0x0A: romCountry = @"Italy";								romVideoSystem = @"PAL";	break;
		case 0x0B: romCountry = @"Hong Kong & China";					romVideoSystem = @"PAL";	break;
		case 0x0C: romCountry = @"Indonesia";							romVideoSystem = @"PAL";	break;
		case 0x0D: romCountry = @"Korea";								romVideoSystem = @"NTSC";	break;
		case 0x51: romCountry = @"Europe (51)";							romVideoSystem = @"PAL";	break; // Simpsons, The - Krusty's Super Fun House (E) [!]
		case 0x11: romCountry = @"Japan (11)";							romVideoSystem = @"NTSC";	break; // Star Fox 2 (Beta) [b1]
		case 0x9B: romCountry = @"Japan (9B)";							romVideoSystem = @"NTSC";	break; // Star Fox 2 (Beta) [b2]
		default:   romCountry = @"Unidentified";						romVideoSystem = @"Unknown"; break;
	}

	[metadataDictionary setValue:romCountry forKey:@"country"];
	[metadataDictionary setValue:romVideoSystem forKey:@"videoSystem"];

//-----------------------------------------
//		License
//-----------------------------------------

	switch((unsigned char)ROMHeader.License){
		case 0x00:	romLicense = @"INVALID COMPANY";					break;
		case 0x01:	romLicense = @"Nintendo";							break;
		case 0x02:	romLicense = @"Ajinomoto";							break;
		case 0x03:	romLicense = @"Imagineer-Zoom";						break;
		case 0x04:	romLicense = @"Chris Gray Enterprises Inc.";		break;
		case 0x05:	romLicense = @"Zamuse";								break;
		case 0x06:	romLicense = @"Falcom";								break;
//		case 0x07:	romLicense = @"";									break;
		case 0x08:	romLicense = @"Capcom";								break;
		case 0x09:	romLicense = @"HOT-B";								break;
		case 0x0A:	romLicense = @"Jaleco";								break;
		case 0x0B:	romLicense = @"Coconuts";							break;
		case 0x0C:	romLicense = @"Rage Software";						break;
		case 0x0D:	romLicense = @"Micronet";							break;
		case 0x0E:	romLicense = @"Technos";							break;
		case 0x0F:	romLicense = @"Mebio Software";						break;
		case 0x10:	romLicense = @"SHOUEi System";						break;
		case 0x11:	romLicense = @"Starfish";							break;
		case 0x12:	romLicense = @"Gremlin Graphics";					break;
		case 0x13:	romLicense = @"Electronic Arts";					break;
		case 0x14:	romLicense = @"NCS / Masaya";						break;
		case 0x15:	romLicense = @"COBRA Team";							break;
		case 0x16:	romLicense = @"Human/Field";						break;
		case 0x17:	romLicense = @"KOEI";								break;
		case 0x18:	romLicense = @"Hudson";								break;
		case 0x19:	romLicense = @"Game Village";						break;
		case 0x1A:	romLicense = @"Yanoman";							break;
//		case 0x1B:	romLicense = @"";									break;
		case 0x1C:	romLicense = @"Tecmo";								break;
//		case 0x1D:	romLicense = @"";									break;
		case 0x1E:	romLicense = @"Open System";						break;
		case 0x1F:	romLicense = @"Virgin Games";						break;
		case 0x20:	romLicense = @"KSS";								break;
		case 0x21:	romLicense = @"Sunsoft";							break;
		case 0x22:	romLicense = @"POW";								break;
		case 0x23:	romLicense = @"Micro World";						break;
//		case 0x24:	romLicense = @"";									break;
//		case 0x25:	romLicense = @"";									break;
		case 0x26:	romLicense = @"Enix";								break;
		case 0x27:	romLicense = @"Loriciel/Electro Brain";				break;
		case 0x28:	romLicense = @"Kemco";								break;
		case 0x29:	romLicense = @"Seta Co.,Ltd.";						break;
		case 0x2A:	romLicense = @"Culture Brain";						break;
		case 0x2B:	romLicense = @"Irem Japan";							break;
		case 0x2C:	romLicense = @"Pal Soft";							break;
		case 0x2D:	romLicense = @"Visit Co.,Ltd.";						break;
		case 0x2E:	romLicense = @"INTEC Inc.";							break;
		case 0x2F:	romLicense = @"System Sacom Corp.";					break;
		case 0x30:	romLicense = @"Viacom New Media";					break;
		case 0x31:	romLicense = @"Carrozzeria";						break;
		case 0x32:	romLicense = @"Dynamic";							break;
		case 0x33:	romLicense = @"Nintendo";							break;
		case 0x34:	romLicense = @"Magifact";							break;
		case 0x35:	romLicense = @"Hect";								break;
//		case 0x36:	romLicense = @"";									break;
//		case 0x37:	romLicense = @"";									break;
		case 0x38:	romLicense = @"Capcom Europe";						break;
		case 0x39:	romLicense = @"Accolade Europe";					break;
//		case 0x3A:	romLicense = @"";									break;
		case 0x3B:	romLicense = @"Arcade Zone";						break;
		case 0x3C:	romLicense = @"Empire Software";					break;
		case 0x3D:	romLicense = @"Loriciel";							break;
		case 0x3E:	romLicense = @"Gremlin Graphics";					break;
//		case 0x3F:	romLicense = @"";									break;
		case 0x40:	romLicense = @"Seika Corp.";						break;
		case 0x41:	romLicense = @"UBI Soft";							break;
//		case 0x42:	romLicense = @"";									break;
//		case 0x43:	romLicense = @"";									break;
		case 0x44:	romLicense = @"LifeFitness Exertainment";			break;
//		case 0x45:	romLicense = @"";									break;
		case 0x46:	romLicense = @"System 3";							break;
		case 0x47:	romLicense = @"Spectrum Holobyte";					break;
//		case 0x48:	romLicense = @"";									break;
		case 0x49:	romLicense = @"Irem";								break;
//		case 0x4A:	romLicense = @"";									break;
		case 0x4B:	romLicense = @"Raya Systems/Sculptured Software";	break;
		case 0x4C:	romLicense = @"Renovation Products";				break;
		case 0x4D:	romLicense = @"Malibu Games/Black Pearl";			break;
//		case 0x4E:	romLicense = @"";									break;
		case 0x4F:	romLicense = @"U.S. Gold";							break;
		case 0x50:	romLicense = @"Absolute Entertainment";				break;
		case 0x51:	romLicense = @"Acclaim";							break;
		case 0x52:	romLicense = @"Activision";							break;
		case 0x53:	romLicense = @"American Sammy";						break;
		case 0x54:	romLicense = @"GameTek";							break;
		case 0x55:	romLicense = @"Hi Tech Expressions";				break;
		case 0x56:	romLicense = @"LJN Toys";							break;
//		case 0x57:	romLicense = @"";									break;
//		case 0x58:	romLicense = @"";									break;
//		case 0x59:	romLicense = @"";									break;
		case 0x5A:	romLicense = @"Mindscape";							break;
		case 0x5B:	romLicense = @"Romstar, Inc.";						break;
//		case 0x5C:	romLicense = @"";									break;
		case 0x5D:	romLicense = @"Tradewest";							break;
//		case 0x5E:	romLicense = @"";									break;
		case 0x5F:	romLicense = @"American Softworks Corp.";			break;
		case 0x60:	romLicense = @"Titus";								break;
		case 0x61:	romLicense = @"Virgin Interactive Entertainment";	break;
		case 0x62:	romLicense = @"Maxis";								break;
		case 0x63:	romLicense = @"Origin/FCI/Pony Canyon";				break;
//		case 0x64:	romLicense = @"";									break;
//		case 0x65:	romLicense = @"";									break;
//		case 0x66:	romLicense = @"";									break;
		case 0x67:	romLicense = @"Ocean";								break;
//		case 0x68:	romLicense = @"";									break;
		case 0x69:	romLicense = @"Electronic Arts";					break;
//		case 0x6A:	romLicense = @"";									break;
		case 0x6B:	romLicense = @"Laser Beam";							break;
//		case 0x6C:	romLicense = @"";									break;
//		case 0x6D:	romLicense = @"";									break;
		case 0x6E:	romLicense = @"Elite";								break;
		case 0x6F:	romLicense = @"Electro Brain";						break;
		case 0x70:	romLicense = @"Infogrames";							break;
		case 0x71:	romLicense = @"Interplay";							break;
		case 0x72:	romLicense = @"LucasArts";							break;
		case 0x73:	romLicense = @"Parker Brothers";					break;
		case 0x74:	romLicense = @"Konami";								break;
		case 0x75:	romLicense = @"STORM";								break;
//		case 0x76:	romLicense = @"";									break;
//		case 0x77:	romLicense = @"";									break;
		case 0x78:	romLicense = @"THQ Software";						break;
		case 0x79:	romLicense = @"Accolade Inc.";						break;
		case 0x7A:	romLicense = @"Triffix Entertainment";				break;
//		case 0x7B:	romLicense = @"";									break;
		case 0x7C:	romLicense = @"Microprose";							break;
//		case 0x7D:	romLicense = @"";									break;
//		case 0x7E:	romLicense = @"";									break;
		case 0x7F:	romLicense = @"Kemco";								break;
		case 0x80:	romLicense = @"Misawa";								break;
		case 0x81:	romLicense = @"Teichio";							break;
		case 0x82:	romLicense = @"Namco Ltd.";							break;
		case 0x83:	romLicense = @"Lozc";								break;
		case 0x84:	romLicense = @"Koei";								break;
//		case 0x85:	romLicense = @"";									break;
		case 0x86:	romLicense = @"Tokuma Shoten Intermedia";			break;
		case 0x87:	romLicense = @"Tsukuda Original";					break;
		case 0x88:	romLicense = @"DATAM-Polystar";						break;
//		case 0x89:	romLicense = @"";									break;
//		case 0x8A:	romLicense = @"";									break;
		case 0x8B:	romLicense = @"Bullet-Proof Software";				break;
		case 0x8C:	romLicense = @"Vic Tokai";							break;
		case 0x8D:	romLicense = @"Lozc";								break;
		case 0x8E:	romLicense = @"Character Soft";						break;
		case 0x8F:	romLicense = @"I'Max";								break;
		case 0x90:	romLicense = @"Takara";								break;
		case 0x91:	romLicense = @"CHUN Soft";							break;
		case 0x92:	romLicense = @"Video System Co., Ltd.";				break;
		case 0x93:	romLicense = @"BEC";								break;
//		case 0x94:	romLicense = @"";									break;
		case 0x95:	romLicense = @"Varie";								break;
		case 0x96:	romLicense = @"Yonezawa / S'Pal Corp.";				break;
		case 0x97:	romLicense = @"Kaneco";								break;
//		case 0x98:	romLicense = @"";									break;
		case 0x99:	romLicense = @"Pack in Video";						break;
		case 0x9A:	romLicense = @"Nichibutsu";							break;
		case 0x9B:	romLicense = @"TECMO";								break;
		case 0x9C:	romLicense = @"Imagineer Co.";						break;
//		case 0x9D:	romLicense = @"";									break;
//		case 0x9E:	romLicense = @"";									break;
//		case 0x9F:	romLicense = @"";									break;
		case 0xA0:	romLicense = @"Telenet";							break;
		case 0xA1:	romLicense = @"Hori";								break;
		case 0xA2:	romLicense = @"Sotsu Agency, Sunrise";				break; // Yokoyama Mitsuteru Sangokushi (J)
//		case 0xA3:	romLicense = @"";									break;
		case 0xA4:	romLicense = @"Konami";								break;
		case 0xA5:	romLicense = @"K.Amusement Leasing Co.";			break;
//		case 0xA6:	romLicense = @"";									break;
		case 0xA7:	romLicense = @"Takara";								break;
//		case 0xA8:	romLicense = @"";									break;
		case 0xA9:	romLicense = @"Technos Jap.";						break;
		case 0xAA:	romLicense = @"JVC";								break;
//		case 0xAB:	romLicense = @"";									break;
		case 0xAC:	romLicense = @"Toei Animation";						break;
		case 0xAD:	romLicense = @"Toho";								break;
//		case 0xAE:	romLicense = @"";									break;
		case 0xAF:	romLicense = @"Namco Ltd.";							break;
		case 0xB0:	romLicense = @"Media Rings Corp.";					break;
		case 0xB1:	romLicense = @"ASCII Co. Activison";				break;
		case 0xB2:	romLicense = @"Bandai";								break;
//		case 0xB3:	romLicense = @"";									break;
		case 0xB4:	romLicense = @"Enix America";						break;
//		case 0xB5:	romLicense = @"";									break;
		case 0xB6:	romLicense = @"Halken";								break;
//		case 0xB7:	romLicense = @"";									break;
//		case 0xB8:	romLicense = @"";									break;
//		case 0xB9:	romLicense = @"";									break;
		case 0xBA:	romLicense = @"Culture Brain";						break;
		case 0xBB:	romLicense = @"Sunsoft";							break;
		case 0xBC:	romLicense = @"Toshiba EMI";						break;
		case 0xBD:	romLicense = @"Sony Imagesoft";						break;
//		case 0xBE:	romLicense = @"";									break;
		case 0xBF:	romLicense = @"Sammy";								break;
		case 0xC0:	romLicense = @"Taito";								break;
//		case 0xC1:	romLicense = @"";									break;
		case 0xC2:	romLicense = @"Kemco";								break;
		case 0xC3:	romLicense = @"Square";								break;
		case 0xC4:	romLicense = @"Tokuma Soft";						break;
		case 0xC5:	romLicense = @"Data East";							break;
		case 0xC6:	romLicense = @"Tonkin House";						break;
//		case 0xC7:	romLicense = @"";									break;
		case 0xC8:	romLicense = @"KOEI";								break;
//		case 0xC9:	romLicense = @"";									break;
		case 0xCA:	romLicense = @"Konami USA";							break;
		case 0xCB:	romLicense = @"NTVIC";								break;
//		case 0xCC:	romLicense = @"";									break;
		case 0xCD:	romLicense = @"Meldac";								break;
		case 0xCE:	romLicense = @"Pony Canyon";						break;
		case 0xCF:	romLicense = @"Sotsu Agency/Sunrise";				break;
		case 0xD0:	romLicense = @"Disco/Taito";						break;
		case 0xD1:	romLicense = @"Sofel";								break;
		case 0xD2:	romLicense = @"Quest Corp.";						break;
		case 0xD3:	romLicense = @"Sigma";								break;
		case 0xD4:	romLicense = @"Ask Kodansha Co., Ltd.";				break;
//		case 0xD5:	romLicense = @"";									break;
		case 0xD6:	romLicense = @"Naxat";								break;
//		case 0xD7:	romLicense = @"";									break;
		case 0xD8:	romLicense = @"Capcom Co., Ltd.";					break;
		case 0xD9:	romLicense = @"Banpresto";							break;
		case 0xDA:	romLicense = @"Tomy";								break;
		case 0xDB:	romLicense = @"Acclaim";							break;
//		case 0xDC:	romLicense = @"";									break;
		case 0xDD:	romLicense = @"NCS";								break;
		case 0xDE:	romLicense = @"Human Entertainment";				break;
		case 0xDF:	romLicense = @"Altron";								break;
		case 0xE0:	romLicense = @"Jaleco";								break;
//		case 0xE1:	romLicense = @"";									break;
		case 0xE2:	romLicense = @"Yutaka";								break;
//		case 0xE3:	romLicense = @"";									break;
		case 0xE4:	romLicense = @"T&ESoft";							break;
		case 0xE5:	romLicense = @"EPOCH Co.,Ltd.";						break;
//		case 0xE6:	romLicense = @"";									break;
		case 0xE7:	romLicense = @"Athena";								break;
		case 0xE8:	romLicense = @"Asmik";								break;
		case 0xE9:	romLicense = @"Natsume";							break;
		case 0xEA:	romLicense = @"King Records";						break;
		case 0xEB:	romLicense = @"Atlus";								break;
		case 0xEC:	romLicense = @"Sony Music Entertainment";			break;
//		case 0xED:	romLicense = @"";									break;
		case 0xEE:	romLicense = @"IGS";								break;
//		case 0xEF:	romLicense = @"";									break;
//		case 0xF0:	romLicense = @"";									break;
		case 0xF1:	romLicense = @"Motown Software";					break;
		case 0xF2:	romLicense = @"Left Field Entertainment";			break;
		case 0xF3:	romLicense = @"Beam Software";						break;
		case 0xF4:	romLicense = @"Tec Magik";							break;
		case 0xF5:	romLicense = @"Enix";								break; // Tenchi Souzou (J)
//		case 0xF6:	romLicense = @"";									break;
//		case 0xF7:	romLicense = @"";									break;
//		case 0xF8:	romLicense = @"";									break;
		case 0xF9:	romLicense = @"Cybersoft";							break;
//		case 0xFA:	romLicense = @"";									break;
		case 0xFB:	romLicense = @"Psygnosis";							break;
		case 0xFC:	romLicense = @"Game Village";						break; // Sutobasu Yarou Show - 3 on 3 Basketball (J)
//		case 0xFD:	romLicense = @"";									break;
		case 0xFE:	romLicense = @"Davidson";							break;
//		case 0xFF:	romLicense = @"";									break;
		default:	romLicense = [NSString stringWithFormat:@"Unidentified (0x%x)", (unsigned char)ROMHeader.License];
			break;
	}

	[metadataDictionary setValue:romLicense forKey:@"license"];

//-----------------------------------------
//		Game Version
//-----------------------------------------
//	The version is stored as version 1.VersionByte and must be less than 128.

	romVersion = [NSString stringWithFormat:@"v1.%x", ROMHeader.Version];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

	switch(ROMHeader.MakerCodeA){
		case 0x30:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"Capcom";							break; // should be reported as bad, but SFA2 is Capcom
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x30%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x31:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"?????????????";					break;
				case 0x32:	romManufacture = @"Infocom";						break;
				case 0x33:	romManufacture = @"Electronic Arts Japan";			break;
				case 0x35:	romManufacture = @"Cobra Team";						break;
				case 0x36:	romManufacture = @"Human / Field";					break;
				case 0x37:	romManufacture = @"KOEI";							break;
				case 0x38:	romManufacture = @"Hudson";							break;
				case 0x39:	romManufacture = @"S.C.P.";							break;
				case 0x41:	romManufacture = @"Yanoman";						break;
				case 0x43:	romManufacture = @"Tecmo Products";					break;
				case 0x44:	romManufacture = @"Japan Glary Business";			break;
				case 0x45:	romManufacture = @"Forum / OpenSystem";				break;
				case 0x46:	romManufacture = @"Virgin Games";					break;
				case 0x47:	romManufacture = @"SMDE";							break;
				case 0x4A:	romManufacture = @"Daikokudenki";					break;
				case 0x50:	romManufacture = @"Creatures Inc.";					break;
				case 0x51:	romManufacture = @"TDK Deep Impresion";				break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x31%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x32:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"Destination Software / KSS";		break;
				case 0x31:	romManufacture = @"Sunsoft / Tokai Engineering";	break;
				case 0x32:	romManufacture = @"POW / VR 1 Japan";				break;
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
				case 0x4E:	romManufacture = @"Smilesoft / Rocket";				break;
				case 0x51:	romManufacture = @"Mediakite";						break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x32%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x33:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"Viacom";											break;
				case 0x31:	romManufacture = @"Carrozzeria";									break;
				case 0x32:	romManufacture = @"Dynamic";										break;
				case 0x33:	romManufacture = @"Nintendo";										break; // Not a company?
				case 0x34:	romManufacture = @"Magifact";										break;
				case 0x35:	romManufacture = @"Hect";											break;
				case 0x36:	romManufacture = @"Codemasters";									break;
				case 0x37:	romManufacture = @"Taito / GAGA Communications";					break;
				case 0x38:	romManufacture = @"Laguna";											break;
				case 0x39:	romManufacture = @"Telstar Fun & Games, Event / Taito";				break;
				case 0x42:	romManufacture = @"Arcade Zone Ltd";								break;
				case 0x43:	romManufacture = @"Entertainment International / Empire Software?";	break;
				case 0x44:	romManufacture = @"Loriciel";										break;
				case 0x45:	romManufacture = @"Gremlin Graphics";								break;
				case 0x46:	romManufacture = @"K.Amusement Leasing Co.";						break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x33%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x34:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x34%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x35:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x35%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x36:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x36%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x37:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x37%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x38:
			switch(ROMHeader.MakerCodeB){
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
				case 0x48:	romManufacture = @"TNN";							break; // ie: Shijou Saikyou League Serie A - Ace Striker (Japan)
				case 0x4A:	romManufacture = @"General Entertainment";			break;
				case 0x4E:	romManufacture = @"Success";						break;
				case 0x50:	romManufacture = @"SEGA Japan";						break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x38%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x39:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x39%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x41:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x41%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x42:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x42%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x43:
			switch(ROMHeader.MakerCodeB){
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
				case 0x48:	romManufacture = @"Outrigger / Be-On Works";			break;	// ie: Shiki Eiyuuden (Japan)
				case 0x4B:	romManufacture = @"Axela/Crea-Tech?";					break;
				case 0x4C:	romManufacture = @"Sekaibunka-Sha, Sumire kobo, Marigul Management Inc.";		break;
				case 0x4D:	romManufacture = @"Konami Computer Entertainment Osaka";						break;
				case 0x50:	romManufacture = @"Enterbrain";													break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x43%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x44:
			switch(ROMHeader.MakerCodeB){
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x44%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x45:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"Jaleco";										break;
				case 0x31:	romManufacture = @"Towachiki";									break;
				case 0x32:	romManufacture = @"Yutaka";										break;
				case 0x33:	romManufacture = @"Varie";										break;
				case 0x34:	romManufacture = @"T&E Soft";									break;
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
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x45%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x46:
			switch(ROMHeader.MakerCodeB){
				case 0x30:	romManufacture = @"A Wave";										break;
				case 0x31:	romManufacture = @"Motown Software";							break;
				case 0x32:	romManufacture = @"Left Field Entertainment";					break;
				case 0x33:	romManufacture = @"Extreme Ent. Grp.";							break;
				case 0x34:	romManufacture = @"TecMagik";									break;
				case 0x39:	romManufacture = @"Cybersoft";									break;
				case 0x42:	romManufacture = @"Psygnosis";									break;
				case 0x45:	romManufacture = @"Davidson/Western Tech.";						break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x46%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x47:
			switch(ROMHeader.MakerCodeB){
				case 0x31:	romManufacture = @"PCCW Japan";									break;
				case 0x34:	romManufacture = @"KiKi Co Ltd";								break;
				case 0x35:	romManufacture = @"Open Sesame Inc???";							break;
				case 0x36:	romManufacture = @"Sims";										break;
				case 0x37:	romManufacture = @"Broccoli";									break;
				case 0x38:	romManufacture = @"Avex";										break;
				case 0x39:	romManufacture = @"D3 Publisher";								break;
				case 0x42:	romManufacture = @"Konami Computer Entertainment Japan";		break;
				case 0x44:	romManufacture = @"Square-Enix";								break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x47%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		case 0x49:
			switch(ROMHeader.MakerCodeB){
				case 0x48:	romManufacture = @"Yojigen";									break;
				default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x49%x)", ROMHeader.MakerCodeB];
					break;
			}	break;
		default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x%02x%02x)", ROMHeader.MakerCodeA, ROMHeader.MakerCodeB];
			break;
	}
	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Game Code
//-----------------------------------------

	romGameCode = [NSString stringWithCString:(char *)ROMHeader.GameID encoding:NSUTF8StringEncoding];
	[metadataDictionary setValue:romGameCode forKey:@"gameCode"];

//-----------------------------------------
//		Game Title
//-----------------------------------------
//	Clean up the title so it doesn't contain trash or spaces after the first series of spaces.
//	This is the code from Snes9X to get the full name and/or to clean the rom name of whitespace.

	char *ROMName = (char *)ROMHeader.GameTitle;
	ROMName[23 - 1] = 0;
	if(strlen(ROMName)){
		char *p = ROMName + strlen(ROMName) - 1;
		while(p > ROMName && *(p - 1) == ' ') p--;
		*p = 0;
	}

	romInternalTitle = [NSString stringWithCString:ROMName encoding:NSShiftJISStringEncoding];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"snesDatLocation"];
	if([datLocation isEqualToString:nil] || [datLocation isEqualToString:@""]){
		romPreferredTitle = [NSString stringWithString:@"No DAT"];
	}
	else{
		Preferences *preferences = [[Preferences alloc] init];
		NSMutableArray *datEntries = [NSMutableArray arrayWithArray:[preferences ParseCMdat: datLocation]];
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
//	NSLog(@"DAT Location: %@", datLocation);
//	NSLog(@"Pref Title: %@", romPreferredTitle);
	NSLog(@"Game Title:\t\t\t %@", romInternalTitle);
	NSLog(@"Header:\t\t\t\t %@", headerCheck);
	NSLog(@"Cart Type:\t\t\t %x / %@", ROMHeader.CartType, romCartType);
	NSLog(@"Country:\t\t\t\t %x / %@", ROMHeader.Country, romCountry);
	NSLog(@"ROM Speed:\t\t\t %02x / %@", ROMHeader.RomSpeed, romSpeed);
	NSLog(@"Header Checksum:\t %04x", ROMHeader.checksum);
	NSLog(@"Real Checksum:\t\t %@", romDeterminedChecksum);

	NSLog(@"Manufacture:\t\t\t %02x%02x / %@", ROMHeader.MakerCodeA, ROMHeader.MakerCodeB, romManufacture);
	NSLog(@"License:\t\t\t\t %02x / %@", ROMHeader.License, romLicense);
	NSLog(@"SRAM Size:\t\t\t %x / %@", ROMHeader.SRAMSize, romSaveSize);
	NSLog(@"Real Size:\t\t\t %iMBits", mbit);
	NSLog(@"Size:\t\t\t\t\t %x / %@", ROMHeader.Sizefh, romSize);
	NSLog(@"Video:\t\t\t\t %@", romVideoSystem);
	NSLog(@"Version:\t\t\t\t v1.%x", ROMHeader.Version);
	NSLog(@"File CRC32:\t\t\t %@", romFileCRC32);
	NSLog(@"File MD5:\t\t\t %@", romFileMD5);
//	NSLog(@"File SHA1: %@", romFileSHA1);
//	NSLog(@"File Size: %d", [fileSize unsignedLongLongValue]);
*/
//-----------------------------------------
//		Super Nintendo End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

//-----------------------------------------
//		Functions
//-----------------------------------------

BOOL verifyOffset(int offset, NSString *fullPath){
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
	NSData *HiLoBuffer;

	[fileHandle seekToFileOffset: (offset-16)];
	HiLoBuffer = [fileHandle readDataOfLength:sizeof(ROMHeader)];
	[HiLoBuffer getBytes:&ROMHeader];

	[fileHandle closeFile];

//	If the return value is true, the right offset is found
//	NSLog(@"Header: %04x + %04x = %04x", ROMHeader.inverseChecksum, ROMHeader.checksum, (ROMHeader.inverseChecksum + ROMHeader.checksum));
	return((ROMHeader.inverseChecksum + ROMHeader.checksum) == 0xFFFF);
}

BOOL checkForBSX(NSString *fullPath, bool hiRom){
	int offset;
	unsigned tempByte;
//		LoROM Header Position (Deafult):	33216 / 0x81C0
//		LoROM Header Position (Alternate):	32704 / 0x7FC0
//		HiROM Header Position (Default):	65984 / 0x101C0
//		HiROM Header Position (Alternate):	65472 / 0xFFC0
	if(hiRom == TRUE) offset = 33216;
	else offset = 65984;

	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:fullPath];
	NSData *bsxBuffer;

	[fileHandle seekToFileOffset:offset];
	bsxBuffer = [fileHandle readDataOfLength:32];
	[bsxBuffer getBytes:&BSX];

	if(BSX.twentyfive & 0x4f) return -1;
//	NSLog(@"Passed BS-X Test 1");

//	Check for 0x33, to indicate the manufacturer as Nintendo
	if((BSX.twentysix != 0x33) && (BSX.twentysix != 0x00)) return -1;
//	NSLog(@"Passed BS-X Test 2");

	tempByte = (BSX.twentythree << 8) | BSX.twentytwo;
	if((tempByte != 0x0000) && (tempByte != 0xffff)){
		if((tempByte & 0x040f) != 0) return -1;
		if((tempByte & 0xff) > 0xc0) return -1;
	}
//	NSLog(@"Passed BS-X Test 3");

//	NSLog(@"Test 3: %x", BSX.twentyfour);

	if(BSX.twentyfive != 0x30)	return -1;
//	NSLog(@"Passed BS-X Test 4");

	if((BSX.twentyone & 0x03) != 0)							return -1;
//	NSLog(@"Passed BS-X Test 5");

	if((BSX.nineteen != 0x00) && (BSX.nineteen != 0xff))	return -1;
//	NSLog(@"Passed BS-X Test 6");

	if(BSX.twenty != 0x00)									return -1;
//	NSLog(@"Passed BS-X Test 7");

//	if(bs_name(bsxHeader) != 0)								return -1;
	return 0;
	// It's a Satellaview ROM!
}

@end
