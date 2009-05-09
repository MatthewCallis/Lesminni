//
//  RomManagedObject.h
//  Lesminni
//
//  Created by Matthew Callis on 5/8/09.
//  Copyright 2009 eludevisibility.org. All rights reserved.
//

#import <CoreData/CoreData.h>

@class ListManagedObject;
@class UserDefinedField;

@interface RomManagedObject :  NSManagedObject  
{
}

@property (retain) NSString * size;
@property (retain) NSString * keywords;
@property (retain) NSString * cartType;
@property (retain) NSString * haveTheRom;
@property (retain) NSString * revision;
@property (retain) NSString * summary;
@property (retain) NSString * country;
@property (retain) NSString * saveSize;
@property (retain) NSString * sha1;
@property (retain) NSString * manufacturer;
@property (retain) NSString * crc32;
@property (retain) NSString * headerCheck;
@property (retain) NSString * md5;
@property (retain) NSString * gameCode;
@property (retain) NSString * gameVersion;
@property (retain) NSString * genre;
@property (retain) NSString * title;
@property (retain) NSString * listName;
@property (retain) NSString * filename;
@property (retain) NSString * id;
@property (retain) NSString * internalTitle;
@property (retain) ListManagedObject * list;
@property (retain) NSSet* userFields;

- (void)writeSpotlightFile;
- (NSString *)getObjectIdString;

@end

@interface RomManagedObject (CoreDataGeneratedAccessors)
- (void)addUserFieldsObject:(UserDefinedField *)value;
- (void)removeUserFieldsObject:(UserDefinedField *)value;
- (void)addUserFields:(NSSet *)value;
- (void)removeUserFields:(NSSet *)value;

@end

