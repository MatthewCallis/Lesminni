#import "FDSReader.h"
#import "NSData_CRC.h"

@implementation FDSReader

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

//	NSString *romPreferredTitle = @"";		// returns: preferredTitle
	NSString *romSideNumber;				// returns: sideNumber
	NSString *romDiskNumber;				// returns: diskNumber
	NSString *romCreationDate;				// returns: creationDate
	NSString *romPermitDate;				// returns: permitDate
	NSString *romVersion;					// returns: version
	NSString *romInternalTitle;				// returns: internalTitle
	NSString *romDeterminedSize;			// returns: determinedSize
	NSString *romManufacture;				// returns: manufacture
	NSString *romDiskCount = @"Unknown";	// returns: diskCount
	NSString *romFileCRC32;					// returns: fileCRC32
	NSMutableString *romFileSHA1;			// returns: fileSHA1
	NSMutableString *romFileMD5;			// returns: fileMD5

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
//		Header Check
//-----------------------------------------

	[fileHandle seekToFileOffset:0];
	romBuffer = [fileHandle readDataOfLength:sizeof(FanWenFDS)];
	[romBuffer getBytes:&FanWenFDS];

	NSString *headerCheck = @"No Header";
	int headerOffset;

//	NSLog(@"%02x %02x %02x %02x", FanWenFDS.fds[0], FanWenFDS.fds[1], FanWenFDS.fds[2], FanWenFDS.fds[3]);

	if( (FanWenFDS.fds[0] == 0x46) &&
		(FanWenFDS.fds[1] == 0x44) &&
		(FanWenFDS.fds[2] == 0x53) &&
		(FanWenFDS.fds[3] == 0x1A) ){
		headerCheck = @"FanWen Header";
		headerOffset = 16;

		romDiskCount = [NSString stringWithFormat:@"Disk Count: %x", FanWenFDS.diskCount];
	}
	else{
		headerOffset = 0;
		headerCheck = @"No Header";
	}

//	NSLog(@"%@ / %@", headerCheck, romDiskCount);

	[metadataDictionary setValue:romDiskCount forKey:@"diskCount"];

//-----------------------------------------
//		Initialize 'ROMHeader'
//-----------------------------------------

	[fileHandle seekToFileOffset:headerOffset];
	romBuffer = [fileHandle readDataOfLength:sizeof(FDSHeader)];
	[romBuffer getBytes:&FDSHeader];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

	switch(FDSHeader.makerCode){
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
		default:	romManufacture = @"Unidentified";					break;
	}

	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Game Name Code
//-----------------------------------------

	romInternalTitle = [NSString stringWithCString:FDSHeader.gameNameCode encoding:NSShiftJISStringEncoding];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Game Version
//-----------------------------------------
//	The version is stored as version 1.VersionByte and must be less than 128.

	romVersion = [NSString stringWithFormat:@"v1.%x", FDSHeader.version];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Side Number
//-----------------------------------------

	romSideNumber = [NSString stringWithFormat:@"Side %x", FDSHeader.sideNumber];
	[metadataDictionary setValue:romSideNumber forKey:@"sideNumber"];

//-----------------------------------------
//		Disk Number
//-----------------------------------------

	romDiskNumber = [NSString stringWithFormat:@"Disk %x", FDSHeader.diskNumber];
	[metadataDictionary setValue:romDiskNumber forKey:@"diskNumber"];

//-----------------------------------------
//		Manufracture Permit Date
//-----------------------------------------

	char year = FDSHeader.permitDate[0];
	char month = FDSHeader.permitDate[1];
	char day = FDSHeader.permitDate[2];

	if(year == (char)0xffffff86){	year = 0x61;	}
	if(year == (char)0xffffff87){	year = 0x62;	}
	if(year == (char)0xffffff88){	year = 0x63;	}
	if(year == (char)0xffffff89){	year = 0x64;	}
	if(year == (char)0xffffff90){	year = 0x65;	}
	if(year == (char)0xffffff91){	year = 0x66;	}
	if(year == (char)0xffffff92){	year = 0x67;	}
	if(year == (char)0xffffff93){	year = 0x68;	}
	if(year == (char)0xffffff94){	year = 0x69;	}

//	NSLog(@"%04d-%02x-%02x", (year + 0x761) , month, day);

	romPermitDate = [NSString stringWithFormat:@"%04d-%02x-%02x", (year + 0x761) , month, day];
	[metadataDictionary setValue:romPermitDate forKey:@"permitDate"];

//-----------------------------------------
//		Creation Date
//-----------------------------------------

	char creationYear = FDSHeader.createdDate[0];
	char creationMonth = FDSHeader.createdDate[1];
	char creationDay = FDSHeader.createdDate[2];

	if(creationYear == (char)0xffffff86)	creationYear = 0x61;
	if(creationYear == (char)0xffffff87)	creationYear = 0x62;
	if(creationYear == (char)0xffffff88)	creationYear = 0x63;
	if(creationYear == (char)0xffffff89)	creationYear = 0x64;
	if(creationYear == (char)0xffffff90)	creationYear = 0x65;
	if(creationYear == (char)0xffffff91)	creationYear = 0x66;
	if(creationYear == (char)0xffffff92)	creationYear = 0x67;
	if(creationYear == (char)0xffffff93)	creationYear = 0x68;
	if(creationYear == (char)0xffffff94)	creationYear = 0x69;

//	NSLog(@"%04d-%02x-%02x", (creationYear + 0x761) , creationMonth, creationDay);

	romCreationDate = [NSString stringWithFormat:@"%04d-%02x-%02x", (creationYear + 0x761) , creationMonth, creationDay];
	[metadataDictionary setValue:romCreationDate forKey:@"creationDate"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"fdsDatLocation"];
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

//	NSLog(@"Calculated ROM Size: %i", (wholeFileSize / 131072) );
//	NSLog(@"File CRC32: %@", romFileCRC32);
//	NSLog(@"File MD5: %@", romFileMD5);
//	NSLog(@"File SHA1: %@", romFileSHA1);
//	NSLog(@"File Size: %d", [fileSize unsignedLongLongValue]);
//	NSLog(@"Header Checksum: %04x", FDSHeader.header_crc);
//	NSLog(@"Cart Type: %@", romCartType);
//	NSLog(@"Size: %04x / %@", FDSHeader.devicecap, romMBitsSize);
//	NSLog(@"Size (1<<n): %04x", (1<<FDSHeader.devicecap) );
//	NSLog(@"Country: %02x / %@", FDSHeader.gamecode[3], romCountry);
//	NSLog(@"License: %x / %x :: %@", FDSHeader.makercode[0], FDSHeader.makercode[1], romManufacture);
//	NSLog(@"Version: v1.%x", FDSHeader.romversion);
//	NSLog(@"Game Title: %@", romInternalTitle);

//-----------------------------------------
//		Nintendo DS End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
