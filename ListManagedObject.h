//
//  ListManagedObject.h
//  Lesminni
//
//  Created by Matthew Callis on 5/8/09.
//  Copyright 2009 eludevisibility.org. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RomManagedObject;

@interface ListManagedObject :  NSManagedObject{}

@property (retain) NSString * predicateString;
@property (retain) NSString * version;
@property (retain) NSString * name;
@property (retain) NSString * author;
@property (retain) NSData * icon;
@property (retain) NSSet* items;

- (NSString *)romCount;
- (NSArray *)roms;

@end

@interface ListManagedObject (CoreDataGeneratedAccessors)
- (void)addItemsObject:(RomManagedObject *)value;
- (void)removeItemsObject:(RomManagedObject *)value;
- (void)addItems:(NSSet *)value;
- (void)removeItems:(NSSet *)value;

@end

