//
//  UserDefinedField.h
//  Lesminni
//
//  Created by Matthew Callis on 5/8/09.
//  Copyright 2009 eludevisibility.org. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RomManagedObject;

@interface UserDefinedField :  NSManagedObject  
{
}

@property (retain) NSString * value;
@property (retain) NSString * key;
@property (retain) RomManagedObject * rom;

@end


