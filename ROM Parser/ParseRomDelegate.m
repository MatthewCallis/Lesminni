#import "ParseRomDelegate.h"
#import "RomFile.h"
#import "NSData_CRC.h"
#import "RomFileReader.h"

@implementation ParseRomDelegate

- (void)dealloc{
	[super dealloc];
}

- (NSArray *)listDirectory:(NSString *) dirPath{
	NSMutableString *path = [NSMutableString stringWithString:dirPath];

//	[fileProgress setIndeterminate:NO];
//	[fileStatus setStringValue:[NSString stringWithFormat:@"Reading Directory: %@", path]];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:dirPath];

	NSString *currentFilename = nil;
	NSMutableArray *content = [[NSMutableArray alloc] init];

	gameFileExtensions = [[NSMutableArray alloc] init];
	[gameFileExtensions addObject:@"gb"];	// GameBoy
	[gameFileExtensions addObject:@"gbc"];	// GameBoy Color
	[gameFileExtensions addObject:@"gba"];	// GameBoy Advance
	[gameFileExtensions addObject:@"nes"];	// Famicom / Nintendo Entertainment System
	[gameFileExtensions addObject:@"fds"];	// Famicom Disk System
	[gameFileExtensions addObject:@"nds"];	// Nintendo DS
	[gameFileExtensions addObject:@"sfc"];	// Super Nintendo
	[gameFileExtensions addObject:@"smc"];	// Super Nintendo
	[gameFileExtensions addObject:@"swc"];	// Super Nintendo
	[gameFileExtensions addObject:@"078"];	// Super Nintendo
	[gameFileExtensions addObject:@"fig"];	// Super Nintendo
	[gameFileExtensions addObject:@"n64"];	// Nintendo 64 ()
	[gameFileExtensions addObject:@"z64"];	// Nintendo 64 ()
	[gameFileExtensions addObject:@"vb"];	// Virtual Boy

	while((currentFilename = [dirEnum nextObject])){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSArray *pathComponents = [NSArray arrayWithObjects: dirPath, currentFilename, nil];
		NSString *fullPath = [NSString pathWithComponents:pathComponents];

		if([gameFileExtensions containsObject:[currentFilename pathExtension]]) [content addObject:currentFilename];
		fullPath = nil;
		[pool release];
	}

	romsArray = [[[NSMutableArray alloc] init] retain];

	NSEnumerator *fileEnumerator = [content objectEnumerator];
	NSString *currentFile;
	while((currentFile = [fileEnumerator nextObject])){
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSString *fullPath;
//		[fileProgress setDoubleValue:percentRate*(i+1)];
		// Break apart the path to the file
		if(![fileManager fileExistsAtPath:currentFile]){
//			NSLog(@"Plain File!");
			NSArray *pathComponents = [NSArray arrayWithObjects: path, currentFile, nil];
			fullPath = [NSString pathWithComponents:pathComponents];
		}
		else{
//			NSLog(@"Archived!");
			fullPath = currentFile;
		}

//		NSLog(@"Filename: %@", currentFile);
//		NSLog(@"Extension: %@", [fullPath pathExtension]);
//		NSLog(@"Full Path: %@", fullPath);
//		[fileStatus setStringValue:[NSString stringWithFormat:@"Current File: %@", currentFile]];

		RomFile *romObject = [[RomFile alloc] init];
		RomFileReader *metadataReader = [RomFileReader parseFile:fullPath];

		NSDictionary *metadata = [metadataReader valueForKey:@"metadata"];

//		Check to make sure nothing is being passed as (null) so it can be safly written
		NSString *romCartType			= [[metadata valueForKey:@"cartType"] length]			? [metadata valueForKey:@"cartType"]			: @"ROM+???";
		NSString *romColorType			= [[metadata valueForKey:@"colorType"] length]			? [metadata valueForKey:@"colorType"]			: @"NA";
		NSString *romCountry			= [[metadata valueForKey:@"country"] length]			? [metadata valueForKey:@"country"]				: @"NA";
		NSString *romDeterminedChecksum = [[metadata valueForKey:@"determinedChecksum"] length] ? [metadata valueForKey:@"determinedChecksum"]	: @"NA";
		NSString *romDeterminedSize		= [[metadata valueForKey:@"determinedSize"] length]		? [metadata valueForKey:@"determinedSize"]		: @"NA";
		NSString *romGameCode			= [[metadata valueForKey:@"gameCode"] length]			? [metadata valueForKey:@"gameCode"]			: @"NA";
		NSString *romFileCRC32			= [[metadata valueForKey:@"fileCRC32"] length]			? [metadata valueForKey:@"fileCRC32"]			: @"NA";
		NSString *romHeaderCheck		= [[metadata valueForKey:@"headerCheck"] length]		? [metadata valueForKey:@"headerCheck"]			: @"NA";
		NSString *romHeaderChecksum		= [[metadata valueForKey:@"headerChecksum"] length]		? [metadata valueForKey:@"headerChecksum"]		: @"NA";
		NSString *romGameTitle			= [[metadata valueForKey:@"internalTitle"] length]		? [metadata valueForKey:@"internalTitle"]		: @"NA";
		NSString *romLicense			= [[metadata valueForKey:@"license"] length]			? [metadata valueForKey:@"license"]				: @"NA";
		NSString *romManufacture		= [[metadata valueForKey:@"manufacture"] length]		? [metadata valueForKey:@"manufacture"]			: @"NA";
		NSString *romPreferredTitle		= [[metadata valueForKey:@"preferredTitle"] length]		? [metadata valueForKey:@"preferredTitle"]		: @"NA";
		NSString *romMap				= [[metadata valueForKey:@"romMap"] length]				? [metadata valueForKey:@"romMap"]				: @"NA";
		NSString *romSize				= [[metadata valueForKey:@"romSize"] length]			? [metadata valueForKey:@"romSize"]				: @"NA";
		NSString *romSRAMSize			= [[metadata valueForKey:@"saveSize"] length]			? [metadata valueForKey:@"saveSize"]			: @"NA";
		NSString *romSuperGB			= [[metadata valueForKey:@"superGameboy"] length]		? [metadata valueForKey:@"superGameboy"]		: @"NA";
		NSString *romVersion			= [[metadata valueForKey:@"version"] length]			? [metadata valueForKey:@"version"]				: @"NA";
		NSString *romVideoSystem		= [[metadata valueForKey:@"videoSystem"] length]		? [metadata valueForKey:@"videoSystem"]			: @"NA";
		NSString *romFileMD5			= [[metadata valueForKey:@"fileMD5"] length]			? [metadata valueForKey:@"fileMD5"]				: @"NA";
		NSString *romFileSHA1			= [[metadata valueForKey:@"fileSHA1"] length]			? [metadata valueForKey:@"fileSHA1"]			: @"NA";
//		int romFileSize					= [metadata valueForKey:@"fileSize"];

		[romObject setFileCRC32:			romFileCRC32];		// File CRC32
		[romObject setFileMD5:				romFileMD5];		// File MD5
		[romObject setFileSHA1:				romFileSHA1];		// File SHA1
		[romObject setDeterminedChecksum:	romDeterminedChecksum];	// Determined Checksum
		[romObject setHeaderChecksum:		romHeaderChecksum];	// Header Checksum
		[romObject setHeaderCheck:			romHeaderCheck];	// Header Type
		[romObject setGameCode:				romGameCode];		// Game Code
		[romObject setInternalTitle:		romGameTitle];		// Internal Title
		[romObject setPreferredTitle:		romPreferredTitle];	// Preferred Title

		[romObject setManufacture:			romManufacture];	// Manufacture
		[romObject setRomSize:				romSize];			// ROM Size
		[romObject setDeterminedSize:		romDeterminedSize];	// Determined Size
		[romObject setSaveSize:				romSRAMSize];		// Save Size (SRAM)
		[romObject setCartType:				romCartType];		// Cartridge Type
		[romObject setCountry:				romCountry];		// Country
		[romObject setLicense:				romLicense];		// License
		[romObject setFilename:				currentFile];		// Filename
		[romObject setFullPath:				fullPath];			// Full Path
		[romObject setVersion:				romVersion];		// Version
		[romObject setTVOutput:				romVideoSystem];	// Video System

		// Super Nintendo
		[romObject setROMMap:				romMap];			// ROM Map

		// Gameboy
		[romObject setColor:				romColorType];		// Color
		[romObject setSuperGameboy:			romSuperGB];		// Super GameBoy

//		[romObject setFileSize:				romFileSize];		// File Size
		[romsArray addObject:				romObject];
		[romObject release];
//		[fileProgress displayIfNeeded];

		fullPath = nil;

		[pool release];
	}
//	[fileProgress setDoubleValue:0.0];
//	[fileStatus setStringValue:[NSString stringWithFormat:@"Done!"]];

//	Sort the array alphabetically by the game title, so when we make our list it's in order
//	[romsArray sortUsingSelector:@selector(compareByValueDescending:)];
//	NSMutableArray *listArray = [tableArray arrangedObjects];
//	NSLog(@"Found %d ROMs.", [romsArray count]);

//	Set values to nil, free anything saved
	currentFilename = nil;

	[content release];
	[archiveTypes release];
	[gameFileExtensions release];

	return romsArray;
}

- (NSArray *)listFiles:(NSArray *)selectedFiles{
	NSFileManager *fileManager = [NSFileManager defaultManager];

	gameFileExtensions = [[NSMutableArray alloc] init];
	[gameFileExtensions addObject:@"gb"];	// GameBoy
	[gameFileExtensions addObject:@"gbc"];	// GameBoy Color
	[gameFileExtensions addObject:@"gba"];	// GameBoy Advance
	[gameFileExtensions addObject:@"nes"];	// Famicom / Nintendo Entertainment System
	[gameFileExtensions addObject:@"fds"];	// Famicom Disk System
	[gameFileExtensions addObject:@"nds"];	// Nintendo DS
	[gameFileExtensions addObject:@"sfc"];	// Super Nintendo
	[gameFileExtensions addObject:@"smc"];	// Super Nintendo
	[gameFileExtensions addObject:@"swc"];	// Super Nintendo
	[gameFileExtensions addObject:@"078"];	// Super Nintendo
	[gameFileExtensions addObject:@"fig"];	// Super Nintendo
	[gameFileExtensions addObject:@"n64"];	// Nintendo 64 ()
	[gameFileExtensions addObject:@"z64"];	// Nintendo 64 ()
	[gameFileExtensions addObject:@"vb"];	// Virtual Boy

	NSMutableArray *content = [[NSMutableArray alloc] init];

	NSEnumerator *selectionEnumerator = [selectedFiles objectEnumerator];
	NSString *currentFile;
	while((currentFile = [selectionEnumerator nextObject])){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		if([gameFileExtensions containsObject:[currentFile pathExtension]]) [content addObject:currentFile];

		[pool release];
	}

	romsArray = [[[NSMutableArray alloc] init] retain];

	NSEnumerator *fileEnumerator = [content objectEnumerator];
	NSString *currentRom;
	while((currentRom = [fileEnumerator nextObject])){
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		NSString *fullPath;
		// Break apart the path to the file
		if(![fileManager fileExistsAtPath:currentFile]){
//			NSLog(@"Plain File!");
			NSArray *pathComponents = [NSArray arrayWithObjects: currentRom, nil];
			fullPath = [NSString pathWithComponents:pathComponents];
		}
		else{
//			NSLog(@"Archived!");
			fullPath = currentRom;
		}

//		NSLog(@"Filename: %@", [fullPath lastPathComponent]);
//		NSLog(@"Extension: %@", [fullPath pathExtension]);
//		NSLog(@"Full Path: %@", fullPath);
//		[fileStatus setStringValue:[NSString stringWithFormat:@"Current File: %@", currentFile]];

		RomFile *romObject = [[RomFile alloc] init];
		RomFileReader *metadataReader = [RomFileReader parseFile:fullPath];

		NSDictionary *metadata = [metadataReader valueForKey:@"metadata"];

//		Check to make sure nothing is being passed as (null) so it can be safly written
		NSString *romCartType			= [[metadata valueForKey:@"cartType"] length]			? [metadata valueForKey:@"cartType"]			: @"ROM+???";
		NSString *romColorType			= [[metadata valueForKey:@"colorType"] length]			? [metadata valueForKey:@"colorType"]			: @"NA";
		NSString *romCountry			= [[metadata valueForKey:@"country"] length]			? [metadata valueForKey:@"country"]				: @"NA";
		NSString *romDeterminedChecksum = [[metadata valueForKey:@"determinedChecksum"] length] ? [metadata valueForKey:@"determinedChecksum"]	: @"NA";
		NSString *romDeterminedSize		= [[metadata valueForKey:@"determinedSize"] length]		? [metadata valueForKey:@"determinedSize"]		: @"NA";
		NSString *romFileCRC32			= [[metadata valueForKey:@"fileCRC32"] length]			? [metadata valueForKey:@"fileCRC32"]			: @"NA";
		NSString *romGameCode			= [[metadata valueForKey:@"gameCode"] length]			? [metadata valueForKey:@"gameCode"]			: @"NA";
		NSString *romHeaderCheck		= [[metadata valueForKey:@"headerCheck"] length]		? [metadata valueForKey:@"headerCheck"]			: @"NA";
		NSString *romHeaderChecksum		= [[metadata valueForKey:@"headerChecksum"] length]		? [metadata valueForKey:@"headerChecksum"]		: @"NA";
		NSString *romGameTitle			= [[metadata valueForKey:@"internalTitle"] length]		? [metadata valueForKey:@"internalTitle"]		: @"NA";
		NSString *romLicense			= [[metadata valueForKey:@"license"] length]			? [metadata valueForKey:@"license"]				: @"NA";
		NSString *romManufacture		= [[metadata valueForKey:@"manufacture"] length]		? [metadata valueForKey:@"manufacture"]			: @"NA";
		NSString *romPreferredTitle		= [[metadata valueForKey:@"preferredTitle"] length]		? [metadata valueForKey:@"preferredTitle"]		: @"NA";
		NSString *romMap				= [[metadata valueForKey:@"romMap"] length]				? [metadata valueForKey:@"romMap"]				: @"NA";
		NSString *romSize				= [[metadata valueForKey:@"romSize"] length]			? [metadata valueForKey:@"romSize"]				: @"NA";
		NSString *romSRAMSize			= [[metadata valueForKey:@"saveSize"] length]			? [metadata valueForKey:@"saveSize"]			: @"NA";
		NSString *romSuperGB			= [[metadata valueForKey:@"superGameboy"] length]		? [metadata valueForKey:@"superGameboy"]		: @"NA";
		NSString *romVersion			= [[metadata valueForKey:@"version"] length]			? [metadata valueForKey:@"version"]				: @"NA";
		NSString *romVideoSystem		= [[metadata valueForKey:@"videoSystem"] length]		? [metadata valueForKey:@"videoSystem"]			: @"NA";
		NSString *romFileMD5			= [[metadata valueForKey:@"fileMD5"] length]			? [metadata valueForKey:@"fileMD5"]				: @"NA";
		NSString *romFileSHA1			= [[metadata valueForKey:@"fileSHA1"] length]			? [metadata valueForKey:@"fileSHA1"]			: @"NA";
//		int romFileSize					= [metadata valueForKey:@"fileSize"];

		[romObject setFileCRC32:			romFileCRC32];		// File CRC32
		[romObject setFileMD5:				romFileMD5];		// File MD5
		[romObject setFileSHA1:				romFileSHA1];		// File SHA1
		[romObject setDeterminedChecksum:	romDeterminedChecksum];	// Determined Checksum
		[romObject setHeaderChecksum:		romHeaderChecksum];	// Header Checksum
		[romObject setHeaderCheck:			romHeaderCheck];	// Header Type
		[romObject setGameCode:				romGameCode];		// Game Code
		[romObject setInternalTitle:		romGameTitle];		// Internal Title
		[romObject setPreferredTitle:		romPreferredTitle];	// Preferred Title
		
		[romObject setManufacture:			romManufacture];	// Manufacture
		[romObject setRomSize:				romSize];			// ROM Size
		[romObject setDeterminedSize:		romDeterminedSize];	// Determined Size
		[romObject setSaveSize:				romSRAMSize];		// Save Size (SRAM)
		[romObject setCartType:				romCartType];		// Cartridge Type
		[romObject setCountry:				romCountry];		// Country
		[romObject setLicense:				romLicense];		// License
		[romObject setFilename:	[fullPath lastPathComponent]];	// Filename
		[romObject setFullPath:				fullPath];			// Full Path
		[romObject setVersion:				romVersion];		// Version
		[romObject setTVOutput:				romVideoSystem];	// Video System
		
		// Super Nintendo
		[romObject setROMMap:				romMap];			// ROM Map
		
		// Gameboy
		[romObject setColor:				romColorType];		// Color
		[romObject setSuperGameboy:			romSuperGB];		// Super GameBoy

//		[romObject setFileSize:			romFileSize];						// File Size
		[romsArray addObject:			romObject];
		[romObject release];
//		[fileProgress displayIfNeeded];

		fullPath = nil;

		[pool release];
	}
//	[fileProgress setDoubleValue:0.0];
//	[fileStatus setStringValue:[NSString stringWithFormat:@"Done!"]];

//	Set values to nil, free anything saved
	[content release];
	[archiveTypes release];
	[gameFileExtensions release];

//	NSLog(@"Found %d ROMs.", [romsArray count]);
	return romsArray;
}

- (BOOL)directoryEmpty:(NSDirectoryEnumerator *)dEnum{
	NSString *filename;
	BOOL result = YES;
//	Check whether directory contains only hidden files => then it's regarded empty (LINUX/UNIX specific!)
	while((filename = [dEnum nextObject]) && result){
		result = [[filename substringToIndex:1] isEqualToString:@"."];
	}
	return result;
}

@end
