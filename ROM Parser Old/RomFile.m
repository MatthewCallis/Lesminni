#import "RomFile.h"

@implementation RomFile

- (NSString *) fileCRC32		{ return _fileCRC32; }
- (NSString *) fileMD5			{ return _fileMD5; }
- (NSString *) fileSHA1			{ return _fileSHA1; }
- (NSString *) romChecksum		{ return _romChecksum; }
- (NSString *) headerChecksum	{ return _headerChecksum; }
- (NSString *) headerCheck		{ return _headerCheck; }
- (NSString *) gameCode			{ return _gameCode; }
- (NSString *) internalTitle	{ return _internalTitle; }
- (NSString *) preferredTitle	{ return _preferredTitle; }
- (NSString *) manufactureID	{ return _manufactureID; }
- (NSString *) manufacture		{ return _manufacture; }
- (NSString *) cartType			{ return _cartType; }
- (NSString *) romSize			{ return _romSize; }
- (NSString *) saveSize			{ return _saveSize; }
- (NSString *) country			{ return _country; }
- (NSString *) license			{ return _license; }
- (NSString *) fullPath			{ return _fullPath; }
- (NSString *) filename			{ return _filename; }
- (NSString *) version			{ return _version; }
- (NSString *) tvOutput			{ return _tvOutput; }

//	Super Nintendo
- (NSString *) romMap			{ return _romMap; }
- (NSString *) romSpeed			{ return _romSpeed; }

//	Gameboy
- (NSString *) color			{ return _color; }
- (NSString *) superGameboy		{ return _superGameboy; }

//	Famicom Disk System
- (NSString *) diskCount		{ return _diskCount; }
- (NSString *) diskNumber		{ return _diskNumber; }
- (NSString *) sideNumber		{ return _sideNumber; }
- (NSString *) creationDate		{ return _creationDate; }
- (NSString *) permitDate		{ return _permitDate; }

//	Gameboy Advance
- (NSString *) unitCode			{ return _unitCode; }
- (NSString *) startOffset		{ return _startOffset; }
- (NSString *) logoCheck		{ return _logoCheck; }
- (NSString *) fixedValue		{ return _fixedValue; }

//	Nintendo
- (NSString *) PRGSize			{ return _PRGSize; }
- (NSString *) CHRSize			{ return _CHRSize; }
- (NSString *) mapper			{ return _mapper; }
- (NSString *) videoMirror		{ return _videoMirror; }
- (NSString *) trainer			{ return _trainer; }
- (NSString *) vsSystem			{ return _vsSystem; }

- (unsigned int)fileSize		{ return _fileSize; }

- (id) init {
	self = [super init];
	if(self != nil){}
	return self;
}

- (void)setFileCRC32:	(NSString *) fileCRC32{			[_fileCRC32 autorelease];			_fileCRC32 = [fileCRC32 copy];			}
- (void)setFileMD5:		(NSString *) fileMD5{			[_fileMD5 autorelease];				_fileMD5 = [fileMD5 copy];				}
- (void)setFileSHA1:	(NSString *) fileSHA1{			[_fileSHA1 autorelease];			_fileSHA1 = [fileSHA1 copy];			}
- (void)setROMChecksum:	(NSString *) romChecksum{		[_romChecksum autorelease];			_romChecksum = [romChecksum copy];		}
- (void)setHeaderChecksum:(NSString *) headerChecksum{	[_headerChecksum autorelease];		_headerChecksum = [headerChecksum copy];	}
- (void)setHeaderCheck:	(NSString *) headerCheck{		[_headerCheck autorelease];			_headerCheck = [headerCheck copy];		}
- (void)setGameCode:	(NSString *) gameCode{			[_gameCode autorelease];			_gameCode = [gameCode copy];			}
- (void)setInternalTitle:(NSString *) internalTitle{	[_internalTitle autorelease];		_internalTitle = [internalTitle copy];	}
- (void)setPreferredTitle:(NSString *) preferredTitle{	[_preferredTitle autorelease];		_preferredTitle = [preferredTitle copy];	}
- (void)setManufactureID:(NSString *) manufactureID{	[_manufactureID autorelease];		_manufactureID = [manufactureID copy];	}
- (void)setManufacture:	(NSString *) manufacture{		[_manufacture autorelease];			_manufacture = [manufacture copy];		}
- (void)setRomSize:		(NSString *) romSize{			[_romSize autorelease];				_romSize = [romSize copy];				}
- (void)setSaveSize:	(NSString *) saveSize{			[_saveSize autorelease];			_saveSize = [saveSize copy];			}
- (void)setCartType:	(NSString *) cartType{			[_cartType autorelease];			_cartType = [cartType copy];			}
- (void)setCountry:		(NSString *) country{			[_country autorelease];				_country = [country copy];				}
- (void)setLicense:		(NSString *) license{			[_license autorelease];				_license = [license copy];				}
- (void)setFullPath:	(NSString *) fullPath{			[_fullPath autorelease];			_fullPath = [fullPath copy];			}
- (void)setFilename:	(NSString *) filename{			[_filename autorelease];			_filename = [filename copy];			}
- (void)setVersion:		(NSString *) version{			[_version autorelease];				_version = [version copy];				}
- (void)setTVOutput:	(NSString *) tvOutput{			[_tvOutput autorelease];			_tvOutput = [tvOutput copy];			}

//	Super Nintendo
- (void)setROMMap:		(NSString *) romMap{			[_romMap autorelease];				_romMap = [romMap copy];				}
- (void)setROMSpeed:	(NSString *) romSpeed{			[_romSpeed autorelease];			_romSpeed = [romSpeed copy];			}

//	Gameboy
- (void)setColor:		(NSString *) color{				[_color autorelease];				_color = [color copy];					}
- (void)setSuperGameboy:(NSString *) superGameboy{		[_superGameboy autorelease];		_superGameboy = [superGameboy copy];	}

//	Famicom Disk System
- (void)setDiskCount:	(NSString *) diskCount{			[_diskCount autorelease];			_diskCount = [diskCount copy];			}
- (void)setDiskNumber:	(NSString *) diskNumber{		[_diskNumber autorelease];			_diskNumber = [diskNumber copy];		}
- (void)setSideNumber:	(NSString *) sideNumber{		[_sideNumber autorelease];			_sideNumber = [sideNumber copy];		}
- (void)setCreationDate:(NSString *) creationDate{		[_creationDate autorelease];		_creationDate = [creationDate copy];	}
- (void)setPermitDate:	(NSString *) permitDate{		[_permitDate autorelease];			_permitDate = [permitDate copy];		}

//	Gameboy Advance
- (void)setUnitCode:	(NSString *) unitCode{			[_unitCode autorelease];				_unitCode = [unitCode copy];		}
- (void)setStartOffset:	(NSString *) startOffset{		[_startOffset autorelease];				_startOffset = [startOffset copy];	}
- (void)setLogoCheck:	(NSString *) logoCheck{			[_logoCheck autorelease];				_logoCheck = [logoCheck copy];		}
- (void)setFixedValue:	(NSString *) fixedValue{		[_fixedValue autorelease];				_fixedValue = [fixedValue copy];	}

//	Nintendo
- (void)setPRGSize:		(NSString *) PRGSize{			[_PRGSize autorelease];				_PRGSize = [PRGSize copy];				}
- (void)setCHRSize:		(NSString *) CHRSize{			[_CHRSize autorelease];				_CHRSize = [CHRSize copy];				}
- (void)setMapper:		(NSString *) mapper{			[_mapper autorelease];				_mapper = [mapper copy];				}
- (void)setVideoMirror:	(NSString *) videoMirror{		[_videoMirror autorelease];			_videoMirror = [videoMirror copy];		}
- (void)setTrainer:		(NSString *) trainer{			[_trainer autorelease];				_trainer = [trainer copy];				}
- (void)setVsSystem:	(NSString *) vsSystem{			[_vsSystem autorelease];			_vsSystem = [vsSystem copy];			}

- (void)setFileSize:(unsigned int)fileSize{													_fileSize = fileSize;					}

- (NSComparisonResult) compareByValueDescending:(RomFile *)other{
	NSString* string1 = [self internalTitle];
	NSString* string2 = [other internalTitle];

	return [string1 localizedCaseInsensitiveCompare: string2];
/*
//	Sorts Wrong for strings due to not using string isEqualTo
	if([self name] == [other name]){ return NSOrderedSame; }
	else if([self name] < [other name]){ return NSOrderedDescending; }
	else{ return NSOrderedAscending; }
*/
}

- (void)dealloc{
	[self setFileCRC32:nil];
	[self setFileMD5:nil];
	[self setFileSHA1:nil];
	[self setROMChecksum:nil];
	[self setHeaderChecksum:nil];
	[self setHeaderCheck:nil];
	[self setGameCode:nil];
	[self setInternalTitle:nil];
	[self setPreferredTitle:nil];
	[self setManufactureID:nil];
	[self setManufacture:nil];
	[self setRomSize:nil];
	[self setSaveSize:nil];
	[self setCartType:nil];
	[self setCountry:nil];
	[self setLicense:nil];
	[self setFullPath:nil];
	[self setFilename:nil];
	[self setVersion:nil];
	[self setTVOutput:nil];

	[self setROMMap:nil];
	[self setROMSpeed:nil];

	[self setColor:nil];
	[self setSuperGameboy:nil];

	[self setDiskCount:nil];
	[self setDiskNumber:nil];
	[self setSideNumber:nil];
	[self setCreationDate:nil];
	[self setPermitDate:nil];

	[self setUnitCode:nil];
	[self setStartOffset:nil];
	[self setLogoCheck:nil];
	[self setFixedValue:nil];

	[self setPRGSize:nil];
	[self setCHRSize:nil];
	[self setMapper:nil];
	[self setVideoMirror:nil];
	[self setTrainer:nil];
	[self setVsSystem:nil];
	[self setFileSize:nil];

	[super dealloc];
}


@end
