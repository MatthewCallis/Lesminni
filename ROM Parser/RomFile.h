#import <Cocoa/Cocoa.h>

@interface RomFile : NSObject{
//	General
	NSString *_fileCRC32;
	NSString *_fileMD5;
	NSString *_fileSHA1;
	NSString *_determinedChecksum;
	NSString *_headerCheck;
	NSString *_headerChecksum;
	NSString *_gameCode;
	NSString *_internalTitle;
	NSString *_preferredTitle;
	NSString *_manufactureID;
	NSString *_manufacture;
	NSString *_romSize;
	NSString *_determinedSize;
	NSString *_saveSize;
	NSString *_cartType;
	NSString *_country;
	NSString *_license;
	NSString *_filename;
	NSString *_fullPath;
	NSString *_version;
	NSString *_tvOutput;

//	Super Nintendo
	NSString *_romMap;
	NSString *_romSpeed;

//	Gameboy
	NSString *_color;
	NSString *_superGameboy;
	
//	Famicom Disk System
	NSString *_diskCount;
	NSString *_diskNumber;
	NSString *_sideNumber;
	NSString *_creationDate;
	NSString *_permitDate;

//	Gameboy Advance
	NSString *_unitCode;
	NSString *_startOffset;
	NSString *_logoCheck;
	NSString *_fixedValue;

//	Nintendo
	NSString *_PRGSize;
	NSString *_CHRSize;
	NSString *_mapper;
	NSString *_videoMirror;
	NSString *_trainer;
	NSString *_vsSystem;

	unsigned int _fileSize;
}

- (NSString *) fileCRC32;			// File CRC32
- (NSString *) fileMD5;				// File MD5
- (NSString *) fileSHA1;			// File SHA1
- (NSString *) determinedChecksum;	// Determined Checksum
- (NSString *) headerChecksum;		// Header Checksum
- (NSString *) headerCheck;			// Header Type
- (NSString *) gameCode;			// Game Code
- (NSString *) internalTitle;		// Internal Title
- (NSString *) preferredTitle;		// Preferred Title
- (NSString *) manufactureID;
- (NSString *) manufacture;			// Manufacture
- (NSString *) romSize;				// ROM Size
- (NSString *) determinedSize;		// Determined Size
- (NSString *) saveSize;			// Save Size (SRAM)
- (NSString *) cartType;			// Cartridge Type
- (NSString *) country;				// Country
- (NSString *) license;				// License
- (NSString *) filename;			// Filename
- (NSString *) fullPath;			// Full Path
- (NSString *) version;				// Version
- (NSString *) tvOutput;			// Video System

//	Super Nintendo
- (NSString *) romMap;				// ROM Map
- (NSString *) romSpeed;

//	Gameboy
- (NSString *) color;				// Color
- (NSString *) superGameboy;

//	Famicom Disk System
- (NSString *) diskCount;
- (NSString *) diskNumber;
- (NSString *) sideNumber;
- (NSString *) creationDate;
- (NSString *) permitDate;

//	Gameboy Advance
- (NSString *) unitCode;
- (NSString *) startOffset;
- (NSString *) logoCheck;
- (NSString *) fixedValue;

//	Nintendo
- (NSString *) PRGSize;
- (NSString *) CHRSize;
- (NSString *) mapper;
- (NSString *) videoMirror;
- (NSString *) trainer;
- (NSString *) vsSystem;

- (unsigned int) fileSize;

- (void)setFileCRC32:			(NSString *) fileCRC32;
- (void)setFileMD5:				(NSString *) fileMD5;
- (void)setFileSHA1:			(NSString *) fileSHA1;
- (void)setDeterminedChecksum:	(NSString *) determinedChecksum;
- (void)setHeaderCheck:			(NSString *) headerCheck;
- (void)setHeaderChecksum:		(NSString *) headerChecksum;
- (void)setGameCode:			(NSString *) gameCode;
- (void)setInternalTitle:		(NSString *) internalTitle;
- (void)setPreferredTitle:		(NSString *) preferredTitle;
- (void)setManufactureID:		(NSString *) manufactureID;
- (void)setManufacture:			(NSString *) manufacture;
- (void)setRomSize:				(NSString *) romSize;
- (void)setDeterminedSize:		(NSString *) determinedSize;
- (void)setSaveSize:			(NSString *) saveSize;
- (void)setCartType:			(NSString *) cartType;
- (void)setCountry:				(NSString *) country;
- (void)setLicense:				(NSString *) license;
- (void)setFilename:			(NSString *) filename;
- (void)setFullPath:			(NSString *) fullPath;
- (void)setVersion:				(NSString *) version;
- (void)setTVOutput:			(NSString *) tvOutput;

//	Super Nintendo
- (void)setROMMap:			(NSString *) romMap;
- (void)setROMSpeed:		(NSString *) romSpeed;

//	Gameboy
- (void)setColor:			(NSString *) color;
- (void)setSuperGameboy:	(NSString *) superGameboy;

//	Famicom Disk System
- (void)setDiskCount:		(NSString *) diskCount;
- (void)setDiskNumber:		(NSString *) diskNumber;
- (void)setSideNumber:		(NSString *) sideNumber;
- (void)setCreationDate:	(NSString *) creationDate;
- (void)setPermitDate:		(NSString *) permitDate;

//	Gameboy Advance
- (void)setUnitCode:		(NSString *) unitCode;
- (void)setStartOffset:		(NSString *) startOffset;
- (void)setLogoCheck:		(NSString *) logoCheck;
- (void)setFixedValue:		(NSString *) fixedValue;

//	Nintendo
- (void)setPRGSize:			(NSString *) PRGSize;
- (void)setCHRSize:			(NSString *) CHRSize;
- (void)setMapper:			(NSString *) mapper;
- (void)setVideoMirror:		(NSString *) videoMirror;
- (void)setTrainer:			(NSString *) trainer;
- (void)setVsSystem:		(NSString *) vsSystem;

- (void)setFileSize:		(unsigned int) fileSize;

- (NSComparisonResult) compareByValueDescending:(RomFile *)other;

@end
