#import "N64Reader.h"
#import "NSData_CRC.h"

@implementation N64Reader

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

	NSString *romCountry;				// returns: country
//	NSString *romDeterminedChecksum;	// returns: determinedChecksum
	NSString *romDeterminedSize;		// returns: determinedSize
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle
	NSString *romInternalTitle;			// returns: internalTitle
	NSString *romHeaderChecksum;		// returns: headerChecksum
	NSString *romManufacture;			// returns: manufacture
	NSString *romGameCode;				// returns: gameCode
	NSString *romVersion;				// returns: version

	NSString *romClockRate;				// returns: clockRate !!!
	NSString *romRegisters;				// returns: registers !!!

	NSString *romFileCRC32;				// returns: fileCRC32
	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5

	unsigned long fileCRC;
	unsigned int wholeFileSize;			// returns: fileSize

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

	int mbit = wholeFileSize / 1024 / 1024;
	int megabits = wholeFileSize / 131072;

	romDeterminedSize = [NSString stringWithFormat:@"%iMB (%iMBits)", mbit, megabits];
	[metadataDictionary setValue:romDeterminedSize forKey:@"determinedSize"];

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
//		Initialize 'N64Header'
//-----------------------------------------

	[fileHandle seekToFileOffset:0];
	romBuffer = [fileHandle readDataOfLength:sizeof(N64Header)];
	[romBuffer getBytes:&N64Header];

//-----------------------------------------
//		Registers
//-----------------------------------------

	romRegisters = [NSString stringWithFormat:@"%x %x %x %x", N64Header.latRegister, N64Header.psgRegister, N64Header.pwdRegister, N64Header.pgsRegister2];
	[metadataDictionary setValue:romRegisters forKey:@"registers"];

//-----------------------------------------
//		Clock Rate
//-----------------------------------------

	romClockRate = [NSString stringWithFormat:@"%x", sl((unsigned int)N64Header.clockRate)];
	[metadataDictionary setValue:romClockRate forKey:@"clockRate"];

//-----------------------------------------
//		Version
//-----------------------------------------

	romVersion = [NSString stringWithFormat:@"%x", sl((unsigned int)N64Header.version)];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Country Code
//-----------------------------------------

	switch(N64Header.countryCode){
		case 0x44:	romCountry = @"Germany";		break;	// D
		case 0x45:	romCountry = @"USA";			break;	// E
		case 0x46:	romCountry = @"France";			break;	// F
		case 0x48:	romCountry = @"Holland";		break;	// H
		case 0x49:	romCountry = @"Italy";			break;	// I
		case 0x4A:	romCountry = @"Japan";			break;	// J
		case 0x4B:	romCountry = @"Korea";			break;	// K
		case 0x50:	romCountry = @"Europe";			break;	// P
		case 0x53:	romCountry = @"Spain";			break;	// S
		case 0x55:	romCountry = @"Australia";		break;	// U
		case 0x58:	romCountry = @"Europien Union";	break;	// X
		default:	romCountry = @"Unidentified";	break;
	}
	[metadataDictionary setValue:romCountry forKey:@"country"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

//	unsigned char *ROMMaker = N64Header.makerCode;
//	NSString *romManufactureCode = [NSString stringWithCString:ROMMaker];
//	NSString *romManufactureCode = [NSString stringWithFormat:@"%02x", N64Header.makerCode];

	switch(N64Header.makerCode){
		case 0x43000000:	romManufacture = @"Nintendo";			break;
		case 0x4E000000:	romManufacture = @"Nintendo";			break;	// 'N'
		default:			romManufacture = @"Unidentified";		break;
	}
	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Cartridge ID
//-----------------------------------------

	romGameCode = [NSString stringWithFormat:@"%04x", N64Header.cartridgeID];
	[metadataDictionary setValue:romGameCode forKey:@"gameCode"];

//-----------------------------------------
//		Header Checksum
//-----------------------------------------

	romHeaderChecksum = [NSString stringWithFormat:@"%x %x", sl((unsigned int)N64Header.crc1), sl((unsigned int)N64Header.crc2)];
	[metadataDictionary setValue:romHeaderChecksum forKey:@"headerChecksum"];

//-----------------------------------------
//		Determined Checksum
//-----------------------------------------

//	romDeterminedChecksum = [NSString stringWithFormat:@"%x", sl((unsigned int)N64Header.crc2)];
//	[metadataDictionary setValue:romDeterminedChecksum forKey:@"determinedChecksum"];

//-----------------------------------------
//		Game Title
//-----------------------------------------

	char *ROMName = (char *)N64Header.internalName;
	romInternalTitle = [NSString stringWithCString:ROMName encoding:1];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"n64DatLocation"];
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
	NSLog(@"Registers: %@", romRegisters);
	NSLog(@"Clock Rate: %@", romClockRate);
	NSLog(@"Version: %@", romVersion);
	NSLog(@"Header Checksum: %@", romHeaderChecksum);
	NSLog(@"Game Title: %@", romInternalTitle);
	NSLog(@"Country: %@", romCountry);
	NSLog(@"Registers: %@", romRegisters);
	NSLog(@"Manufacture: %@ (%@)", romManufacture, romManufactureCode);
	NSLog(@"File Size: %@ (%d bytes)", romDeterminedSize, wholeFileSize);
	NSLog(@"Cartridge ID: %@", romGameCode);
	NSLog(@"CRC32: %@", romFileCRC32);
	NSLog(@"File MD5: %@", romFileMD5);
	NSLog(@"File SHA1: %@", romFileSHA1);
	NSLog(@"No-Intro Title: %@", romPreferredTitle);
*/
//-----------------------------------------
//		GameBoy Advanced End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
