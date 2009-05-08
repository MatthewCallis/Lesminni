#import <Cocoa/Cocoa.h>

@interface RomFile : NSObject{
//	General
	NSString *_fileCRC32;
	NSString *_fileMD5;
	NSString *_fileSHA1;
	NSString *_romChecksum;
	NSString *_headerChecksum;
	NSString *_headerCheck;
	NSString *_gameCode;
	NSString *_internalTitle;
	NSString *_preferredTitle;
	NSString *_manufactureID;
	NSString *_manufacture;
	NSString *_romSize;
	NSString *_saveSize;
	NSString *_cartType;
	NSString *_country;
	NSString *_license;
	NSString *_filename;
	NSString *_fullPath;
	NSString *_version;
	NSString *_tvOutput;

//	Gameboy
	NSString *_color;
	NSString *_superGameboy;

//	Super Nintendo
	NSString *_romMap;
	NSString *_romSpeed;

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

- (NSString *) fileCRC32;
- (NSString *) fileMD5;
- (NSString *) fileSHA1;
- (NSString *) romChecksum;
- (NSString *) headerChecksum;
- (NSString *) headerCheck;
- (NSString *) gameCode;
- (NSString *) internalTitle;
- (NSString *) preferredTitle;
- (NSString *) manufactureID;
- (NSString *) manufacture;
- (NSString *) romSize;
- (NSString *) saveSize;
- (NSString *) cartType;
- (NSString *) country;
- (NSString *) license;
- (NSString *) filename;
- (NSString *) fullPath;
- (NSString *) version;
- (NSString *) tvOutput;

//	Super Nintendo
- (NSString *) romMap;
- (NSString *) romSpeed;

//	Gameboy
- (NSString *) color;
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

- (void)setFileCRC32:		(NSString *) fileCRC32;
- (void)setFileMD5:			(NSString *) fileMD5;
- (void)setFileSHA1:		(NSString *) fileSHA1;
- (void)setROMChecksum:		(NSString *) romChecksum;
- (void)setHeaderChecksum:	(NSString *) headerChecksum;
- (void)setHeaderCheck:		(NSString *) headerCheck;
- (void)setGameCode:		(NSString *) gameCode;
- (void)setInternalTitle:	(NSString *) internalTitle;
- (void)setPreferredTitle:	(NSString *) preferredTitle;
- (void)setManufactureID:	(NSString *) manufactureID;
- (void)setManufacture:		(NSString *) manufacture;
- (void)setRomSize:			(NSString *) romSize;
- (void)setSaveSize:		(NSString *) saveSize;
- (void)setCartType:		(NSString *) cartType;
- (void)setCountry:			(NSString *) country;
- (void)setLicense:			(NSString *) license;
- (void)setFilename:		(NSString *) filename;
- (void)setFullPath:		(NSString *) fullPath;
- (void)setVersion:			(NSString *) version;
- (void)setTVOutput:		(NSString *) tvOutput;

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
