
#import "RomManagedObject.h"
#import "SmartList.h"
#import "LesminniAppDelegate.h"

@implementation RomManagedObject

- (RomManagedObject *) init{
	return self;
}

- (void) didChangeValueForKey: (NSString *) key{
	[super didChangeValueForKey:key];
}

- (void) setList:(ListManagedObject *) newList{
	if([newList isKindOfClass:[SmartList class]] || newList == nil || [[self valueForKey:@"list"] isEqual:newList]) return;

	[self willChangeValueForKey:@"list"];
	[self setPrimitiveValue:newList forKey:@"list"];
	[self didChangeValueForKey:@"list"];
}

- (NSString *) getTitle{
	[self willAccessValueForKey:@"title"];
	[self primitiveValueForKey:@"title"];
	[self didAccessValueForKey:@"title"];

	return [self primitiveValueForKey:@"title"];
//	return [RomTitleString stringWithString:[self primitiveValueForKey:@"title"]];
}

- (NSString *) getSize{
	[self willAccessValueForKey:@"size"];
	[self primitiveValueForKey:@"size"];
	[self didAccessValueForKey:@"size"];

	return [self primitiveValueForKey:@"size"];
}

- (NSString *) getCRC{
	[self willAccessValueForKey:@"crc32"];
	[self primitiveValueForKey:@"crc32"];
	[self didAccessValueForKey:@"crc32"];

	return [self primitiveValueForKey:@"crc32"];
}

- (NSString *) getSHAOne{
	[self willAccessValueForKey:@"sha1"];
	[self primitiveValueForKey:@"sha1"];
	[self didAccessValueForKey:@"sha1"];

	return [self primitiveValueForKey:@"sha1"];
}

- (NSString *) getMD5{
	[self willAccessValueForKey:@"md5"];
	[self primitiveValueForKey:@"md5"];
	[self didAccessValueForKey:@"md5"];

	return [self primitiveValueForKey:@"md5"];
}

- (NSString *) getCountry{
	[self willAccessValueForKey:@"country"];
	[self primitiveValueForKey:@"country"];
	[self didAccessValueForKey:@"country"];

	return [self primitiveValueForKey:@"country"];
}

- (NSString *) getFormat{
	[self willAccessValueForKey:@"format"];
	[self primitiveValueForKey:@"format"];
	[self didAccessValueForKey:@"format"];

	return [self primitiveValueForKey:@"format"];
}

- (NSString *) getGameCode{
	[self willAccessValueForKey:@"gameCode"];
	[self primitiveValueForKey:@"gameCode"];
	[self didAccessValueForKey:@"gameCode"];

	return [self primitiveValueForKey:@"gameCode"];
}

- (NSString *) getGenre{
	[self willAccessValueForKey:@"genre"];
	[self primitiveValueForKey:@"genre"];
	[self didAccessValueForKey:@"genre"];

	return [self primitiveValueForKey:@"genre"];
}

- (NSString *) getSummary{
	[self willAccessValueForKey:@"summary"];
	[self primitiveValueForKey:@"summary"];
	[self didAccessValueForKey:@"summary"];

	return [self primitiveValueForKey:@"summary"];
}

- (NSString *) getSaveSize{
	[self willAccessValueForKey:@"saveSize"];
	[self primitiveValueForKey:@"saveSize"];
	[self didAccessValueForKey:@"saveSize"];

	return [self primitiveValueForKey:@"saveSize"];
}

- (NSString *) getListName{
	ListManagedObject * list = [self valueForKey:@"list"];

	return [list valueForKey:@"name"];
}

- (NSString *) getId{
	[self willAccessValueForKey:@"id"];
	if([self primitiveValueForKey:@"id"] == nil) [self getObjectIdString];
	[self didAccessValueForKey:@"id"];

	return [self primitiveValueForKey:@"id"];
}

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

- (NSScriptObjectSpecifier *) objectSpecifier{
	ListManagedObject *list = [self valueForKey:@"list"];
	NSIndexSpecifier *specifier = [[NSIndexSpecifier alloc] initWithContainerClassDescription:
		(NSScriptClassDescription *) [list classDescription] containerSpecifier: [list objectSpecifier] key:@"items"];

	[specifier setIndex:[[list getRoms] indexOfObject:self]];

	return [specifier autorelease];
}

- (NSString *) description{
	return [self valueForKey:@"title"];
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

	if(![[NSFileManager defaultManager] fileExistsAtPath:[plistPath stringByDeletingLastPathComponent]])
		[[NSFileManager defaultManager] createDirectoryAtPath:[plistPath stringByDeletingLastPathComponent] attributes:nil];

	NSString *error = nil;
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:romInfo format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];

	[[NSFileManager defaultManager] createFileAtPath:plistPath contents:plistData attributes:nil];
}

- (NSObject *) valueForKey:(NSString *) key{
	NSObject *value = nil;

	NS_DURING
		value = [super valueForKey:key];
	NS_HANDLER
		value = [self customValueForKey:key];
	NS_ENDHANDLER

	return value;
}

- (NSObject *) customValueForKey:(NSString *) key{
	if([key isEqualToString:@"crc32"] || [key isEqualToString:@"md5"] || [key isEqualToString:@"sha1"] || [key isEqualToString:@"list"]) return nil;

	NSSet *userFieldSet = (NSSet *) [self valueForKey:@"userFields"];
	NSArray *userFieldArray = [userFieldSet allObjects];

	int j = 0;
	for(j = 0; j < [userFieldArray count]; j++){
		NSManagedObject *fieldPair = [userFieldArray objectAtIndex:j];
		NSString *name = [[fieldPair valueForKey:@"key"] description];

		if([name isEqualToString:key]){
			NSObject * value = [fieldPair valueForKey:@"value"];
			return value;
		}
	}
	return nil;
}

- (void) setValueFromString:(NSString *) valueString forKey:(NSString *) key replace:(BOOL) doReplace{
	RomManagedObject *romObject = self;
	NSObject *value = nil;

	NS_DURING
		value = [romObject valueForKey:key];
	NS_HANDLER
		value = @"";
	NS_ENDHANDLER

	if([key isEqual:@"title"]){
		if(!(value == nil || [value isEqual:NSLocalizedString(@"New ROM", nil)] || [value isEqual:@""] || doReplace == YES)) return;
	}
	else if(value != nil && ![value isEqual:@""] && doReplace == NO) return;

	NSManagedObjectContext *context = [romObject managedObjectContext];

	if([key isEqual:@"title"]){
		value = [NSMutableString stringWithString:valueString];
		[(NSMutableString *) value replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [(NSMutableString *) value length])];
	}
	else value = valueString;

	if(value == nil || key == nil) return;

	[context lock];

	NS_DURING
		[romObject setValue:value forKey:key];
	NS_HANDLER
		NS_DURING
			LesminniAppDelegate *delegate = [[NSApplication sharedApplication] delegate];
			NSMutableSet *userFields = [romObject mutableSetValueForKey:@"userFields"];
			BOOL hasField = NO;
			NSArray * objects = [userFields allObjects];

			int i = 0;
			for (i = 0; i < [objects count] && hasField == NO; i++){
				NSManagedObject * field = [objects objectAtIndex:i];

				if([((NSString *)[field valueForKey:@"key"]) isEqualToString:key]) hasField = YES;
			}
			if(hasField == NO){
				NSManagedObjectModel *model = [delegate managedObjectModel];
				NSEntityDescription *fieldDesc = [[model entitiesByName] objectForKey:@"UserDefinedField"];
				NSManagedObject *fieldObject = [[NSManagedObject alloc] initWithEntity:fieldDesc insertIntoManagedObjectContext:context];

				[fieldObject setValue:key forKey:@"key"];
				[fieldObject setValue:value forKey:@"value"];

				[userFields addObject:fieldObject];
				[fieldObject release];
			}
		NS_HANDLER
			NSLog(@"%@", [localException reason]);
		NS_ENDHANDLER
	NS_ENDHANDLER
	
	[context unlock];
}

- (void)dealloc{
	[self setList:nil];
	[super dealloc];
}

@end
