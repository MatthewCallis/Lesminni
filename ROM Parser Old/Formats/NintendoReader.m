#import "NintendoReader.h"
#import "NSData_CRC.h"

@implementation NintendoReader

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

	NSString *romFileCRC32;				// returns: fileCRC32, determinedChecksum
	NSMutableString *romFileSHA1;		// returns: fileSHA1
	NSMutableString *romFileMD5;		// returns: fileMD5

	NSString *headerCheck;				// returns: headerCheck
	NSString *romInternalTitle;			// returns: internalTitle
	NSString *romManufacture;			// returns: manufacture
//	NSString *romPreferredTitle = @"";	// returns: preferredTitle
	NSString *romVideoSystem;			// returns: videoSystem
	NSString *romSize;					// returns: romSize,
	NSString *romSaveSize;				// returns: saveSize

	NSString *romPRGSize;				// returns: PRGSize
	NSString *romCHRSize;				// returns: CHRSize
	NSString *romMapper;				// returns: mapper
	NSString *romVideoMirror;			// returns: videoMirror
	NSString *romTrainer;				// returns: trainer
	NSString *romVSSystem;				// returns: vsSystem

//-----------------------------------------
//		Pre-Header Check
//-----------------------------------------

//	This is to load all of the data into our struct, iNESHeader, so we don't have so many variables
	[fileHandle seekToFileOffset: 0];
	romBuffer = [fileHandle readDataOfLength:sizeof(iNESHeader)];
	[romBuffer getBytes:&iNESHeader];

	int headerOffset;

	if( (iNESHeader.signature[0] = 0x4e) &&
		(iNESHeader.signature[1] = 0x45) &&
		(iNESHeader.signature[2] = 0x53) &&
		(iNESHeader.signature[3] = 0x1a) ){
		headerCheck =  [NSString stringWithString:@"iNES Header"];
		headerOffset = 16;
	}
	else headerOffset = 0;

//-----------------------------------------
//		File CRC32, MD5, SHA1
//-----------------------------------------

	[fileHandle seekToFileOffset: headerOffset];
	romBuffer = [fileHandle readDataToEndOfFile];
	romFileCRC32 = [NSString stringWithFormat:@"%08x", [romBuffer crc32]];
	[metadataDictionary setValue:romFileCRC32 forKey:@"determinedChecksum"];

	[fileHandle seekToFileOffset: 0];
	romBuffer = [fileHandle readDataToEndOfFile];
	romFileCRC32 = [NSString stringWithFormat:@"%08x", [romBuffer crc32]];

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
//		Initialize 'iNESHeader'
//-----------------------------------------

//	This is to load all of the data into our struct, iNESHeader, so we don't have so many variables
	[fileHandle seekToFileOffset: 0];
	romBuffer = [fileHandle readDataOfLength:sizeof(iNESHeader)];
	[romBuffer getBytes:&iNESHeader];

//-----------------------------------------/-----------------------------------------
//		Internal Size
//-----------------------------------------/-----------------------------------------

	int internalSize = (((iNESHeader.prgSize << 14) + (iNESHeader.chrSize << 13)) / 131072);
	romSize = [NSString stringWithFormat:@"%d MBits", internalSize];

//-----------------------------------------/-----------------------------------------
//		PRG Size / ROM Size
//-----------------------------------------/-----------------------------------------

	int prgSize = ((iNESHeader.prgSize << 14) / 131072);

	switch(iNESHeader.prgSize){
		case 0x01:	romPRGSize = [NSString stringWithString:@"1 x 128Kbit Banks (128 Kbit / 16384 bytes)"];	break;
		case 0x02:	romPRGSize = [NSString stringWithString:@"2 x 128Kbit Banks (256 Kbit / 32768 bytes)"];	break;
		case 0x03:	romPRGSize = [NSString stringWithFormat:@"3 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x04:	romPRGSize = [NSString stringWithFormat:@"4 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x05:	romPRGSize = [NSString stringWithFormat:@"5 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x06:	romPRGSize = [NSString stringWithFormat:@"6 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x07:	romPRGSize = [NSString stringWithFormat:@"7 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x08:	romPRGSize = [NSString stringWithFormat:@"8 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x09:	romPRGSize = [NSString stringWithFormat:@"9 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0a:	romPRGSize = [NSString stringWithFormat:@"10 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0b:	romPRGSize = [NSString stringWithFormat:@"11 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0c:	romPRGSize = [NSString stringWithFormat:@"12 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0d:	romPRGSize = [NSString stringWithFormat:@"13 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0e:	romPRGSize = [NSString stringWithFormat:@"14 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x0f:	romPRGSize = [NSString stringWithFormat:@"15 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x10:	romPRGSize = [NSString stringWithFormat:@"16 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x11:	romPRGSize = [NSString stringWithFormat:@"17 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x12:	romPRGSize = [NSString stringWithFormat:@"18 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x13:	romPRGSize = [NSString stringWithFormat:@"19 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x14:	romPRGSize = [NSString stringWithFormat:@"20 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x15:	romPRGSize = [NSString stringWithFormat:@"21 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x16:	romPRGSize = [NSString stringWithFormat:@"22 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x17:	romPRGSize = [NSString stringWithFormat:@"23 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x18:	romPRGSize = [NSString stringWithFormat:@"24 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x19:	romPRGSize = [NSString stringWithFormat:@"25 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1a:	romPRGSize = [NSString stringWithFormat:@"26 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1b:	romPRGSize = [NSString stringWithFormat:@"27 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1c:	romPRGSize = [NSString stringWithFormat:@"28 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1d:	romPRGSize = [NSString stringWithFormat:@"29 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1e:	romPRGSize = [NSString stringWithFormat:@"30 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x1f:	romPRGSize = [NSString stringWithFormat:@"31 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x20:	romPRGSize = [NSString stringWithFormat:@"32 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x21:	romPRGSize = [NSString stringWithFormat:@"33 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x22:	romPRGSize = [NSString stringWithFormat:@"34 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x23:	romPRGSize = [NSString stringWithFormat:@"35 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x24:	romPRGSize = [NSString stringWithFormat:@"36 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x25:	romPRGSize = [NSString stringWithFormat:@"37 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x26:	romPRGSize = [NSString stringWithFormat:@"38 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x27:	romPRGSize = [NSString stringWithFormat:@"39 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x28:	romPRGSize = [NSString stringWithFormat:@"40 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x29:	romPRGSize = [NSString stringWithFormat:@"41 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2a:	romPRGSize = [NSString stringWithFormat:@"42 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2b:	romPRGSize = [NSString stringWithFormat:@"43 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2c:	romPRGSize = [NSString stringWithFormat:@"44 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2d:	romPRGSize = [NSString stringWithFormat:@"45 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2e:	romPRGSize = [NSString stringWithFormat:@"46 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x2f:	romPRGSize = [NSString stringWithFormat:@"47 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x30:	romPRGSize = [NSString stringWithFormat:@"48 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x31:	romPRGSize = [NSString stringWithFormat:@"49 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x32:	romPRGSize = [NSString stringWithFormat:@"50 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x33:	romPRGSize = [NSString stringWithFormat:@"51 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x34:	romPRGSize = [NSString stringWithFormat:@"52 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x35:	romPRGSize = [NSString stringWithFormat:@"53 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x36:	romPRGSize = [NSString stringWithFormat:@"54 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x37:	romPRGSize = [NSString stringWithFormat:@"55 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x38:	romPRGSize = [NSString stringWithFormat:@"56 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x39:	romPRGSize = [NSString stringWithFormat:@"57 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3a:	romPRGSize = [NSString stringWithFormat:@"58 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3b:	romPRGSize = [NSString stringWithFormat:@"59 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3c:	romPRGSize = [NSString stringWithFormat:@"60 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3d:	romPRGSize = [NSString stringWithFormat:@"61 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3e:	romPRGSize = [NSString stringWithFormat:@"62 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x3f:	romPRGSize = [NSString stringWithFormat:@"63 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		case 0x40:	romPRGSize = [NSString stringWithFormat:@"64 x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
		default:	romPRGSize = [NSString stringWithFormat:@"? x 128Kbit Banks (%d MBits / %d bytes)", prgSize, (prgSize * 131072)];	break;
	}
	[metadataDictionary setValue:romPRGSize forKey:@"prgSize"];

//-----------------------------------------/-----------------------------------------
//		CHR Size / VROM Size
//-----------------------------------------/-----------------------------------------

	int chrSize = ((iNESHeader.chrSize << 13) / 131072);

	switch(iNESHeader.chrSize){
		case 0x00:	romCHRSize = [NSString stringWithFormat:@"0 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x01:	romCHRSize = [NSString stringWithString:@"1 x 64Kbit Banks (64 Kbit / 8192 Bytes)"];								break;
		case 0x02:	romCHRSize = [NSString stringWithString:@"2 x 64Kbit Banks (128 Kbit / 24567 Bytes)"];								break;
		case 0x03:	romCHRSize = [NSString stringWithString:@"2 x 64Kbit Banks (192 Kbit / 16384 Bytes)"];								break;
		case 0x04:	romCHRSize = [NSString stringWithString:@"4 x 64Kbit Banks (256 KBits / 32768 bytes)"];								break;
		case 0x05:	romCHRSize = [NSString stringWithFormat:@"5 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x06:	romCHRSize = [NSString stringWithFormat:@"6 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x07:	romCHRSize = [NSString stringWithFormat:@"7 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x08:	romCHRSize = [NSString stringWithFormat:@"8 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x09:	romCHRSize = [NSString stringWithFormat:@"9 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0a:	romCHRSize = [NSString stringWithFormat:@"10 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0b:	romCHRSize = [NSString stringWithFormat:@"11 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0c:	romCHRSize = [NSString stringWithFormat:@"12 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0d:	romCHRSize = [NSString stringWithFormat:@"13 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0e:	romCHRSize = [NSString stringWithFormat:@"14 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x0f:	romCHRSize = [NSString stringWithFormat:@"15 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x10:	romCHRSize = [NSString stringWithFormat:@"16 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x11:	romCHRSize = [NSString stringWithFormat:@"17 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x12:	romCHRSize = [NSString stringWithFormat:@"18 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x13:	romCHRSize = [NSString stringWithFormat:@"19 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x14:	romCHRSize = [NSString stringWithFormat:@"20 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x15:	romCHRSize = [NSString stringWithFormat:@"21 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x16:	romCHRSize = [NSString stringWithFormat:@"22 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x17:	romCHRSize = [NSString stringWithFormat:@"23 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x18:	romCHRSize = [NSString stringWithFormat:@"24 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x19:	romCHRSize = [NSString stringWithFormat:@"25 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1a:	romCHRSize = [NSString stringWithFormat:@"26 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1b:	romCHRSize = [NSString stringWithFormat:@"27 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1c:	romCHRSize = [NSString stringWithFormat:@"28 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1d:	romCHRSize = [NSString stringWithFormat:@"29 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1e:	romCHRSize = [NSString stringWithFormat:@"30 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x1f:	romCHRSize = [NSString stringWithFormat:@"31 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x20:	romCHRSize = [NSString stringWithFormat:@"32 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x21:	romCHRSize = [NSString stringWithFormat:@"33 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x22:	romCHRSize = [NSString stringWithFormat:@"34 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x23:	romCHRSize = [NSString stringWithFormat:@"35 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x24:	romCHRSize = [NSString stringWithFormat:@"36 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x25:	romCHRSize = [NSString stringWithFormat:@"37 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x26:	romCHRSize = [NSString stringWithFormat:@"38 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x27:	romCHRSize = [NSString stringWithFormat:@"39 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x28:	romCHRSize = [NSString stringWithFormat:@"40 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x29:	romCHRSize = [NSString stringWithFormat:@"41 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2a:	romCHRSize = [NSString stringWithFormat:@"42 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2b:	romCHRSize = [NSString stringWithFormat:@"43 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2c:	romCHRSize = [NSString stringWithFormat:@"44 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2d:	romCHRSize = [NSString stringWithFormat:@"45 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2e:	romCHRSize = [NSString stringWithFormat:@"46 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x2f:	romCHRSize = [NSString stringWithFormat:@"47 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x30:	romCHRSize = [NSString stringWithFormat:@"48 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x31:	romCHRSize = [NSString stringWithFormat:@"49 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x32:	romCHRSize = [NSString stringWithFormat:@"50 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x33:	romCHRSize = [NSString stringWithFormat:@"51 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x34:	romCHRSize = [NSString stringWithFormat:@"52 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x35:	romCHRSize = [NSString stringWithFormat:@"53 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x36:	romCHRSize = [NSString stringWithFormat:@"54 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x37:	romCHRSize = [NSString stringWithFormat:@"55 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x38:	romCHRSize = [NSString stringWithFormat:@"56 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x39:	romCHRSize = [NSString stringWithFormat:@"57 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3a:	romCHRSize = [NSString stringWithFormat:@"58 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3b:	romCHRSize = [NSString stringWithFormat:@"59 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3c:	romCHRSize = [NSString stringWithFormat:@"60 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3d:	romCHRSize = [NSString stringWithFormat:@"61 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3e:	romCHRSize = [NSString stringWithFormat:@"62 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x3f:	romCHRSize = [NSString stringWithFormat:@"63 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		case 0x40:	romCHRSize = [NSString stringWithFormat:@"64 x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
		default:	romCHRSize = [NSString stringWithFormat:@"? x 64Kbit Banks (%d MBits / %d bytes)", chrSize, (chrSize * 131072)];	break;
	}
	[metadataDictionary setValue:romCHRSize forKey:@"chrSize"];

//-----------------------------------------
//		Mapper
//-----------------------------------------

	int mapperByte = (iNESHeader.ctrl1 >> 4) | (iNESHeader.ctrl2 & 0xf0);

	if(iNESHeader.ctrl2 & 0xf) romMapper = [NSString stringWithFormat:@"%d (%d)", mapperByte, (mapperByte | ((iNESHeader.ctrl2 & 0xf) << 8))];
	else romMapper = [NSString stringWithFormat:@"%d", mapperByte];

	[metadataDictionary setValue:romMapper forKey:@"mapper"];

//-----------------------------------------/-----------------------------------------
//		Video System, Video Mirroring, RAM Size, SRAM, 512 byte Trainer, VS-System
//-----------------------------------------/-----------------------------------------
//	Video System
	romVideoSystem = (iNESHeader.ctrl3 & INES_TVID) ? @"PAL" : @"NTSC";
	[metadataDictionary setValue:romVideoSystem forKey:@"videoSystem"];

//	Video Mirroring
	if(iNESHeader.ctrl1 & INES_MIRROR)			romVideoMirror = @"Vertical";
	else if(iNESHeader.ctrl1 & INES_4SCREEN)	romVideoMirror = @"Four Screens";
	else										romVideoMirror = @"Horizontal";
	[metadataDictionary setValue:romVideoMirror forKey:@"videoMirror"];

//	RAM Size
//	romSize = iNESHeader.ram_size ? [NSString stringWithFormat:@"%d", (iNESHeader.ram_size * 8)] : @"8";
//	[metadataDictionary setValue:romSize forKey:@"romSize"];

//	SRAM
	romSaveSize = (iNESHeader.ctrl1 & INES_SRAM) ? @"Yes" : @"No";
	[metadataDictionary setValue:romSaveSize forKey:@"saveSize"];

//	512 byte Trainer
	romTrainer = (iNESHeader.ctrl1 & INES_TRAINER) ? @"Yes" : @"No";
	[metadataDictionary setValue:romTrainer forKey:@"trainer"];

//	VS-System
	romVSSystem = (iNESHeader.ctrl2 & 0x01) ? @"Yes" : @"No";
	[metadataDictionary setValue:romVSSystem forKey:@"vsSystem"];

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
//		Internal Title
//-----------------------------------------

	int titleOffset = 0;

	if(iNESHeader.prgSize <= 0x07)											titleOffset = 16368;	//	0x3ff0
	else if((iNESHeader.prgSize >= 0x07) && (iNESHeader.prgSize < 0x10))	titleOffset = 131056;	//	0x1fff0
	else if((iNESHeader.prgSize <= 0x10) && (iNESHeader.prgSize < 0x20))	titleOffset = 262128;	//	0x3fff0
	else																	titleOffset = 524272;	//	0x7fff0

	[fileHandle seekToFileOffset: titleOffset];
	romBuffer = [fileHandle readDataOfLength:sizeof(NESTitle)];
	[romBuffer getBytes:&NESTitle];

	char *ROMName = (char *)NESTitle.gameTitle;
	ROMName[16] = '\0';
	romInternalTitle = [NSString stringWithCString:ROMName];
//	romInternalTitle = [NSString stringWithCString:ROMName encoding:NSShiftJISStringEncoding];

	if([romInternalTitle isEqualToString:nil]) romInternalTitle = [NSString stringWithString:@"Not Fount"];

	[metadataDictionary setValue:romInternalTitle forKey:@"internalTitle"];

//-----------------------------------------
//		Manufacture
//-----------------------------------------

	switch(NESTitle.makerCode){
//		case 0x00:	romManufacture = @"Unknown";						break;
		case 0x01:	romManufacture = @"Nintendo";						break;
		case 0x02:	romManufacture = @"Rocket Games / Ajinomoto";		break;
		case 0x07:	romManufacture = @"Enix";							break;
		case 0x08:	romManufacture = @"Capcom";							break;
		case 0x0a:	romManufacture = @"Jaleco";							break;
		case 0x0b:	romManufacture = @"Coconuts Japan";					break;
		case 0x0c:	romManufacture = @"Coconuts Japan / G.X.Media";		break;
		case 0x0d:	romManufacture = @"Micronet";						break;
		case 0x0e:	romManufacture = @"Technos";						break;
		case 0x0f:	romManufacture = @"Mebio Software";					break;
		case 0x12:	romManufacture = @"Infocom";						break;
		case 0x13:	romManufacture = @"Electronic Arts Japan";			break;
		case 0x15:	romManufacture = @"Cobra Team";						break;
		case 0x16:	romManufacture = @"Human/Field";					break;
		case 0x17:	romManufacture = @"KOEI";							break;
		case 0x18:	romManufacture = @"Hudson Soft";					break;
		case 0x19:	romManufacture = @"S.C.P.";							break;
		case 0x1a:	romManufacture = @"Yanoman";						break;
		case 0x1c:	romManufacture = @"Tecmo Products";					break;
		case 0x1d:	romManufacture = @"Japan Glary Business";			break;
		case 0x1e:	romManufacture = @"Forum / OpenSystem";				break;
		case 0x1f:	romManufacture = @"Virgin Games";					break;
		case 0x20:	romManufacture = @"Destination Software / KSS";		break;
		case 0x21:	romManufacture = @"Sunsoft / Tokai Engineering";	break;
		case 0x22:	romManufacture = @"POW/VR 1 Japan";					break;
		case 0x23:	romManufacture = @"Micro World";					break;
		case 0x25:	romManufacture = @"San-X";							break;
		case 0x26:	romManufacture = @"Enix";							break;
		case 0x27:	romManufacture = @"Loriciel / Electro Brain";		break;
		case 0x28:	romManufacture = @"Kemco Japan";					break;
		case 0x29:	romManufacture = @"Seta";							break;
		case 0x2a:	romManufacture = @"Culture Brain";					break;
		case 0x2c:	romManufacture = @"Palsoft";						break;
		case 0x2d:	romManufacture = @"Visit Co., Ltd.";				break;
		case 0x2e:	romManufacture = @"Intec";							break;
		case 0x2f:	romManufacture = @"System Sacom";					break;
		case 0x30:	romManufacture = @"Viacom";											break;
		case 0x31:	romManufacture = @"Carrozzeria";									break;
		case 0x32:	romManufacture = @"Dynamic";										break;
		case 0x33:	romManufacture = @"N/A";											break;
		case 0x34:	romManufacture = @"Magifact";										break;
		case 0x35:	romManufacture = @"Hect";											break;
		case 0x36:	romManufacture = @"Codemasters";									break;
		case 0x37:	romManufacture = @"Taito/GAGA Communications";						break;
		case 0x38:	romManufacture = @"Laguna";											break;
		case 0x39:	romManufacture = @"Telstar Fun & Games/Event/Taito";				break;
		case 0x3B:	romManufacture = @"Arcade Zone Ltd";								break;
		case 0x3C:	romManufacture = @"Entertainment International/Empire Software";	break;
		case 0x3D:	romManufacture = @"Loriciel";										break;
		case 0x3E:	romManufacture = @"Gremlin Graphics";								break;
		case 0x3F:	romManufacture = @"K.Amusement Leasing Co.";						break;
		case 0x40:	romManufacture = @"Seika Corp.";									break;
		case 0x41:	romManufacture = @"Ubi Soft Entertainment";							break;
		case 0x42:	romManufacture = @"Sunsoft";										break;
		case 0x46:	romManufacture = @"System 3";										break;
		case 0x47:	romManufacture = @"Spectrum Holobyte";								break;
		case 0x49:	romManufacture = @"IREM";											break;
		case 0x4B:	romManufacture = @"Raya Systems";									break;
		case 0x4C:	romManufacture = @"Renovation Products";							break;
		case 0x4D:	romManufacture = @"Malibu Games";									break;
		case 0x4F:	romManufacture = @"Eidos/U.S. Gold";					break;
		case 0x50:	romManufacture = @"Absolute Entertainment";				break;
		case 0x51:	romManufacture = @"Acclaim";							break;
		case 0x52:	romManufacture = @"Activision";							break;
		case 0x53:	romManufacture = @"American Sammy";						break;
		case 0x54:	romManufacture = @"Take 2 Interactive";					break;
		case 0x56:	romManufacture = @"LJN LTD.";							break;
		case 0x58:	romManufacture = @"Mattel";								break;
		case 0x5A:	romManufacture = @"Mindscape";							break;
		case 0x5B:	romManufacture = @"Romstar";							break;
		case 0x5C:	romManufacture = @"Taxan";								break;
		case 0x5D:	romManufacture = @"Midway";								break;
		case 0x5F:	romManufacture = @"American Softworks";					break;
		case 0x60:	romManufacture = @"Titus";								break;
		case 0x61:	romManufacture = @"Virgin Interactive";					break;
		case 0x62:	romManufacture = @"Maxis";								break;
		case 0x64:	romManufacture = @"LucasArts Entertainment";			break;
		case 0x67:	romManufacture = @"Ocean";								break;
		case 0x69:	romManufacture = @"Electronic Arts";					break;
		case 0x6B:	romManufacture = @"Laser Beam";							break;
		case 0x6E:	romManufacture = @"Elite Systems";						break;
		case 0x6F:	romManufacture = @"Electro Brain";						break;
		case 0x70:	romManufacture = @"Infogrames";							break;
		case 0x71:	romManufacture = @"Interplay";							break;
		case 0x72:	romManufacture = @"JVC";								break;
		case 0x73:	romManufacture = @"Parker Brothers";					break;
		case 0x75:	romManufacture = @"Sales Curve";						break;
		case 0x78:	romManufacture = @"THQ";								break;
		case 0x79:	romManufacture = @"Accolade";							break;
		case 0x7A:	romManufacture = @"Triffix Entertainment";				break;
		case 0x7C:	romManufacture = @"Microprose Software";				break;
		case 0x7D:	romManufacture = @"Universal Interactive / Sierra / Simon & Schuster";	break;
		case 0x7F:	romManufacture = @"Kemco";								break;
		case 0x80:	romManufacture = @"Misawa";								break;
		case 0x81:	romManufacture = @"Teichiku";							break;
		case 0x82:	romManufacture = @"Namco Ltd.";							break;
		case 0x83:	romManufacture = @"LOZC";								break;
		case 0x84:	romManufacture = @"KOEI";								break;
		case 0x86:	romManufacture = @"Tokuma Shoten Intermedia";			break;
		case 0x87:	romManufacture = @"Tsukuda Original";					break;
		case 0x88:	romManufacture = @"DATAM-Polystar";						break;
		case 0x8B:	romManufacture = @"BulletProof Software";				break;
		case 0x8C:	romManufacture = @"Vic Tokai Inc.";						break;
		case 0x8E:	romManufacture = @"Character Soft";						break;
		case 0x8F:	romManufacture = @"I'Max";								break;
		case 0x90:	romManufacture = @"Takara Amusement";					break;
		case 0x91:	romManufacture = @"Chun Soft";							break;
		case 0x92:	romManufacture = @"Video System/McO'River";				break;
		case 0x93:	romManufacture = @"BEC";								break;
		case 0x95:	romManufacture = @"Varie";								break;
		case 0x96:	romManufacture = @"Yonezawa/S'pal";						break;
		case 0x97:	romManufacture = @"Kaneko";								break;
		case 0x99:	romManufacture = @"Victor Interactive Software";		break;
		case 0x9A:	romManufacture = @"Nichibutsu/Nihon Bussan";			break;
		case 0x9B:	romManufacture = @"Tecmo";								break;
		case 0x9C:	romManufacture = @"Imagineer";							break;
		case 0x9F:	romManufacture = @"Nova";								break;
		case 0xA0:	romManufacture = @"Telenet";							break;
		case 0xA1:	romManufacture = @"Hori";								break;
		case 0xA4:	romManufacture = @"Konami";								break;
		case 0xA5:	romManufacture = @"K.Amusement Leasing Co.";			break;
		case 0xA6:	romManufacture = @"Kawada";								break;
		case 0xA7:	romManufacture = @"Takara";								break;
		case 0xA9:	romManufacture = @"Technos Japan Corp.";				break;
		case 0xAA:	romManufacture = @"JVC/Victor Musical Indutries";		break;
		case 0xAC:	romManufacture = @"Toei Animation";						break;
		case 0xAD:	romManufacture = @"Toho";								break;
		case 0xAF:	romManufacture = @"Namco";								break;
		case 0xB0:	romManufacture = @"Acclaim Japan";						break;
		case 0xB1:	romManufacture = @"ASCII/Nexoft";						break;
		case 0xB2:	romManufacture = @"Bandai";								break;
		case 0xB4:	romManufacture = @"Enix";								break;
		case 0xB6:	romManufacture = @"HAL Laboratory";						break;
		case 0xB7:	romManufacture = @"SNK";								break;
		case 0xB9:	romManufacture = @"Pony Canyon";						break;
		case 0xBA:	romManufacture = @"Culture Brain";						break;
		case 0xBB:	romManufacture = @"Sunsoft";							break;
		case 0xBC:	romManufacture = @"Toshiba EMI";						break;
		case 0xBD:	romManufacture = @"Sony Imagesoft";						break;
		case 0xBF:	romManufacture = @"Sammy";								break;
		case 0xC0:	romManufacture = @"Taito";								break;
		case 0xC2:	romManufacture = @"Kemco";								break;
		case 0xC3:	romManufacture = @"Square";								break;
		case 0xC4:	romManufacture = @"Tokuma Shoten";						break;
		case 0xC5:	romManufacture = @"Data East";							break;
		case 0xC6:	romManufacture = @"Tonkin House/Tokyo Shoseki";			break;
		case 0xC8:	romManufacture = @"Koei";								break;
		case 0xCA:	romManufacture = @"Konami/Ultra/Palcom";				break;
		case 0xCB:	romManufacture = @"NTVIC/VAP";							break;
		case 0xCC:	romManufacture = @"Use Co.,Ltd.";						break;
		case 0xCD:	romManufacture = @"Meldac";								break;
		case 0xCE:	romManufacture = @"Pony Canyon(Japan)/FCI(USA)";		break;
		case 0xCF:	romManufacture = @"Angel/Sotsu Agency/Sunrise";			break;
		case 0xD0:	romManufacture = @"Taito/Disco";						break;
		case 0xD1:	romManufacture = @"Sofel";								break;
		case 0xD2:	romManufacture = @"Quest/Bothtec";						break;
		case 0xD3:	romManufacture = @"Sigma";								break;
		case 0xD4:	romManufacture = @"Ask Kodansha";						break;
		case 0xD6:	romManufacture = @"Naxat";								break;
		case 0xD7:	romManufacture = @"Copya System";						break;
		case 0xD8:	romManufacture = @"Capcom Co., Ltd.";					break;
		case 0xD9:	romManufacture = @"Banpresto";							break;
		case 0xDA:	romManufacture = @"TOMY";								break;
		case 0xDB:	romManufacture = @"LJN Japan";							break;
		case 0xDD:	romManufacture = @"NCS";								break;
		case 0xDE:	romManufacture = @"Human Entertainment";				break;
		case 0xDF:	romManufacture = @"Altron";								break;
		case 0xE0:	romManufacture = @"Jaleco";								break;
		case 0xE1:	romManufacture = @"Unknown";							break;
		case 0xE2:	romManufacture = @"Yutaka";								break;
		case 0xE3:	romManufacture = @"Varie";								break;
		case 0xE4:	romManufacture = @"T&E Soft";							break;
		case 0xE5:	romManufacture = @"Epoch";								break;
		case 0xE7:	romManufacture = @"Athena";								break;
		case 0xE8:	romManufacture = @"Asmik";								break;
		case 0xE9:	romManufacture = @"Natsume";							break;
		case 0xEA:	romManufacture = @"King Records";						break;
		case 0xEB:	romManufacture = @"Atlus";								break;
		case 0xEC:	romManufacture = @"Epic/Sony Records (Japan)";			break;
		case 0xEE:	romManufacture = @"Information Global Service";			break;
		case 0xF0:	romManufacture = @"A Wave";								break;
		case 0xF1:	romManufacture = @"Motown Software";					break;
		case 0xF2:	romManufacture = @"Left Field Entertainment";			break;
		case 0xF3:	romManufacture = @"Extreme Ent. Grp.";					break;
		case 0xF4:	romManufacture = @"TecMagik";							break;
		case 0xF9:	romManufacture = @"Cybersoft";							break;
		case 0xFB:	romManufacture = @"Psygnosis";							break;
		case 0xFE:	romManufacture = @"Davidson / Western Tech.";			break;
		default:	romManufacture = [NSString stringWithFormat:@"Unidentified (0x%02x)",NESTitle.makerCode];	break;
	}

	[metadataDictionary setValue:romManufacture forKey:@"manufacture"];

//-----------------------------------------
//		Prefered Title
//-----------------------------------------
/*
	NSString *datLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"nesDatLocation"];
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
//	NSLog(@"Header Check:\t%@", headerCheck);
	NSLog(@"PRG ROM:\t\t%@", romPRGSize);
	NSLog(@"CHR ROM:\t\t%@", romCHRSize);
	NSLog(@"Mirroring:\t\t%@", romVideoMirror);
	NSLog(@"TV System:\t\t%@", romVideoSystem);
//	NSLog(@"RAM Size:\t\t%@", romSize);
	NSLog(@"SRAM:\t\t\t%@", romSaveSize);
	NSLog(@"Trainer:\t\t%@", romTrainer);
	NSLog(@"VS-System:\t\t%@", romVSSystem);
	NSLog(@"Mapper:\t\t\t%@", romMapper);
	NSLog(@"Internal Size:\t %@", romSize);
//	NSLog(@"Title Offset: %d", titleOffset);
	NSLog(@"Internal Title: %@", romInternalTitle);
	NSLog(@"Manufacture:\t%@", romManufacture);
//	NSLog(@"Prefered Title: %@", romPreferredTitle);
	NSLog(@"File CRC32:\t\t%@", romFileCRC32);
	NSLog(@"File MD5:\t\t%@", romFileMD5);
	NSLog(@"File SHA1:\t\t%@", romFileSHA1);
*/
//-----------------------------------------
//		Nintendo End
//-----------------------------------------

	[self setValue:metadataDictionary forKey:@"metadata"];
}

@end
