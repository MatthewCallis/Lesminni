// 
//  ListManagedObject.m
//  Lesminni
//
//  Created by Matthew Callis on 5/8/09.
//  Copyright 2009 eludevisibility.org. All rights reserved.
//

#import "ListManagedObject.h"

#import "RomManagedObject.h"

@implementation ListManagedObject 

@dynamic predicateString;
@dynamic version;
@dynamic name;
@dynamic author;
@dynamic icon;
@dynamic items;

- (NSString *)romCount{
	return [NSString stringWithFormat:@"%i", [[[self valueForKey:@"items"] allObjects] count]];
}

- (NSArray *)roms{
	return [[self valueForKey:@"items"] allObjects];
}

@end
