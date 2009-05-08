#import "RomFileReader.h"

#import "GameBoyReader.h"
#import "GBAReader.h"
#import "N64Reader.h"
#import "NDSReader.h"
#import "FDSReader.h"
#import "NintendoReader.h"
#import "SuperNintendoReader.h"
#import "VirtualBoyReader.h"

@implementation RomFileReader

+ (RomFileReader *) parseFile:(NSString *)fullPath{
	NSParameterAssert(nil != fullPath);
	RomFileReader *result = nil;
	NSString *pathExtension = [[fullPath pathExtension] lowercaseString];

	if([pathExtension isEqualToString:@"gb"] || [pathExtension isEqualToString:@"gbc"]){
		result = [[GameBoyReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"smc"] || [pathExtension isEqualToString:@"sfc"] || [pathExtension isEqualToString:@"078"] || [pathExtension isEqualToString:@"swc"] || [pathExtension isEqualToString:@"fig"]){
		result = [[SuperNintendoReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"n64"] || [pathExtension isEqualToString:@"z64"] || [pathExtension isEqualToString:@"v64"]){
		result = [[N64Reader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"nes"]){
		result = [[NintendoReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"nds"]){
		result = [[NDSReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"fds"]){
		result = [[FDSReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"gba"]){
		result = [[GBAReader alloc] initWithFile:fullPath];
	}
	else if([pathExtension isEqualToString:@"vb"]){
		result = [[VirtualBoyReader alloc] initWithFile:fullPath];
	}
	else result = nil;
	return [result autorelease];
}

- (id) initWithFile:(NSString *)fullPath;{
	if((self = [super init])){
		_fullPath = [fullPath retain];
		return self;
	}
	return nil;
}

- (void) dealloc{
	[_fullPath release];
	[_metadata release];

	[super dealloc];
}

- (void)readMetadata{}

@end
