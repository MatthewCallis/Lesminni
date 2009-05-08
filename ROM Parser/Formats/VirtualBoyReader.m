#import "VirtualBoyReader.h"
#import "NSData_CRC.h"

@implementation VirtualBoyReader

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
	NSString *romInternalTitle;			// returns: internalTitle
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle
	NSString *romManufacture;			// returns: manufacture
	NSString *romVersion;				// returns: version

	NSString *romFileCRC32;				// returns: fileCRC32
	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5

	unsigned long fileCRC;
//	unsigned int wholeFileSize;			// returns: fileSize
	int headerOffset;

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
//		Initialize 'VBHeader'
//-----------------------------------------
	
	headerOffset = [romBuffer length] - 0x220;

	[fileHandle seekToFileOffset:headerOffset];
	romBuffer = [fileHandle readDataOfLength:sizeof(VBHeader)];
	[romBuffer getBytes:&VBHeader];

//-----------------------------------------
//		Game Title
//-----------------------------------------

	char *ROMName = (char *)VBHeader.gameTitle;
	romInternalTitle = [NSString stringWithCString:ROMName encoding:NSShiftJISStringEncoding];
	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Game Code
//-----------------------------------------

	NSString *romGameCode = [NSString stringWithCString:(char *)VBHeader.gameCode];
	[metadataDictionary setValue:romGameCode forKey:@"gameCode"];

//-----------------------------------------
//		Country Code
//-----------------------------------------

	switch(VBHeader.gameCode[3]){
		case 0x45:	romCountry = @"USA";			break;	// E
		case 0x4A:	romCountry = @"Japan";			break;	// J
		case 0x58:	romCountry = @"Europien Union";	break;	// X
		default:	romCountry = @"Unidentified";	break;
	}
	[metadataDictionary setValue:romCountry forKey:@"country"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

	char *ROMMaker = (char *)VBHeader.manufacture;
	ROMMaker[2] = '\0';
//	NSString *romManufactureCode = [NSString stringWithCString:ROMMaker];

	switch(VBHeader.manufacture[0]){
		case 0x30:
			switch(VBHeader.manufacture[1]){
				case 0x31:	romManufacture = @"Nintendo";							break;
				case 0x42:	romManufacture = @"Coconuts Japan";						break;
				default:	romManufacture = @"Unidentified (0x30)";				break;
			}	break;
		case 0x31:
			switch(VBHeader.manufacture[1]){
				case 0x38:	romManufacture = @"Hudson Soft";						break;
				default:	romManufacture = @"Unidentified (0x31)";				break;
			}	break;
		case 0x32:
			switch(VBHeader.manufacture[1]){
				case 0x38:	romManufacture = @"Kemco Japan";						break;
				default:	romManufacture = @"Unidentified (0x32)";				break;
			}	break;
		case 0x36:
			switch(VBHeader.manufacture[1]){
				case 0x37:	romManufacture = @"Ocean";								break;
				default:	romManufacture = @"Unidentified (0x36)";				break;
			}	break;
		case 0x37:
			switch(VBHeader.manufacture[1]){
				case 0x46:	romManufacture = @"Kemco (US)";							break;
				default:	romManufacture = @"Unidentified (0x37)";				break;
			}	break;
		case 0x38:
			switch(VBHeader.manufacture[1]){
				case 0x42:	romManufacture = @"Bulletproof Software";				break;
				case 0x46:	romManufacture = @"I'Max";								break;
				default:	romManufacture = @"Unidentified (0x38)";				break;
			}	break;
		case 0x39:
			switch(VBHeader.manufacture[1]){
				case 0x39:	romManufacture = @"T*HQ";								break;
				default:	romManufacture = @"Unidentified (0x39)";				break;
			}	break;
		case 0x41:
			switch(VBHeader.manufacture[1]){
				case 0x42:	romManufacture = @"Amos Bieler";						break;
				default:	romManufacture = @"Unidentified (0x41)";				break;
			}	break;
		case 0x43:
			switch(VBHeader.manufacture[1]){
				case 0x52:	romManufacture = @"KR155E (Christian Radke)";			break;
				default:	romManufacture = @"Unidentified (0x43)";				break;
			}	break;
		case 0x44:
			switch(VBHeader.manufacture[1]){
				case 0x42:	romManufacture = @"Reality Boy (David Tucker)";			break;
				case 0x50:	romManufacture = @"Pat Daderko";						break;
				case 0x57:	romManufacture = @"VeeBee (David Williamson)";			break;
				default:	romManufacture = @"Unidentified (0x44)";				break;
			}	break;
		case 0x45:
			switch(VBHeader.manufacture[1]){
				case 0x34:	romManufacture = @"T&E Soft";							break;
				case 0x42:	romManufacture = @"Atlus";								break;
				default:	romManufacture = @"Unidentified (0x45)";				break;
			}	break;
		case 0x56:
			switch(VBHeader.manufacture[1]){
				case 0x42:	romManufacture = @"Parasyte";							break;
				case 0x45:	romManufacture = @"Virtual-E (Alberto Covarrubias)";	break;
				default:	romManufacture = @"Unidentified (0x56)";				break;
			}	break;
		case 0x58:
			switch(VBHeader.manufacture[1]){
				case 0x58:	romManufacture = @"Pat Daderko";						break;
				default:	romManufacture = @"Unidentified (0x58)";				break;
			}	break;
		default:	romManufacture = @"Unidentified";								break;
	}
	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Header Check / Version
//-----------------------------------------

	romVersion = [NSString stringWithFormat:@"v1.%d", VBHeader.version];
	[metadataDictionary setValue:romVersion forKey:@"version"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"vbDatLocation"];
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
//		Clean Up
//-----------------------------------------

	[fileHandle closeFile];

//-----------------------------------------
//		Debug Info
//-----------------------------------------
/*
	NSLog(@"Game Title: %@", romInternalTitle);
	NSLog(@"Game Code: %@", romGameCode);
	NSLog(@"Manufacture: %@ (%@)", romManufactureCode, romManufacture);
	NSLog(@"Country: %@", romCountry);
	NSLog(@"Version: %@", romVersion);
	NSLog(@"CRC32: %@", romFileCRC32);
	NSLog(@"File MD5: %@", romFileMD5);
	NSLog(@"File SHA1: %@", romFileSHA1);
//	NSLog(@"File Size: %d", wholeFileSize);
*/
//-----------------------------------------
//		GameBoy End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
