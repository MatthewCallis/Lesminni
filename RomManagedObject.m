// 
//  RomManagedObject.m
//  Lesminni
//
//  Created by Matthew Callis on 5/8/09.
//  Copyright 2009 eludevisibility.org. All rights reserved.
//

#import "RomManagedObject.h"

#import "ListManagedObject.h"
#import "UserDefinedField.h"

@implementation RomManagedObject 

@dynamic size;
@dynamic keywords;
@dynamic cartType;
@dynamic haveTheRom;
@dynamic revision;
@dynamic summary;
@dynamic country;
@dynamic saveSize;
@dynamic sha1;
@dynamic manufacturer;
@dynamic crc32;
@dynamic headerCheck;
@dynamic md5;
@dynamic gameCode;
@dynamic gameVersion;
@dynamic genre;
@dynamic title;
@dynamic listName;
@dynamic filename;
@dynamic id;
@dynamic internalTitle;
@dynamic list;
@dynamic userFields;

- (NSString *) getObjectIdString{
	[self willAccessValueForKey:@"id"];
	NSString * objId = [self primitiveValueForKey:@"id"];
	[self didAccessValueForKey:@"id"];

	if(objId == nil || [objId isEqualToString:@""]){
		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
		[self setValue:uuidString forKey:@"id"];
		return [self valueForKey:@"id"];
	}
	return objId;
}

- (void) writeSpotlightFile{
	NSArray *keys = [[[self entity] attributesByName] allKeys];
	NSMutableDictionary *romInfo = [NSMutableDictionary dictionary];

	int i = 0;
	for(i = 0; i < [keys count]; i++){
		NSString *key = [keys objectAtIndex:i];
		NSLog(@"%@: %@", key, [self valueForKey:key]);
		[romInfo setValue:[self valueForKey:key] forKey:key];
	}

	NSString *plistPath = [NSString stringWithFormat:@"%@%@%@.RomsItem", NSHomeDirectory(), @"/Library/Caches/Metadata/Roms/", [self getObjectIdString]];

	if(![[NSFileManager defaultManager] fileExistsAtPath:[plistPath stringByDeletingLastPathComponent]]){
		[[NSFileManager defaultManager] createDirectoryAtPath:[plistPath stringByDeletingLastPathComponent] attributes:nil];
	}

	NSString *error = nil;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:romInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];

	[[NSFileManager defaultManager] createFileAtPath:plistPath contents:plistData attributes:nil];
}

@end
