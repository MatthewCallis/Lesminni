
#import <Cocoa/Cocoa.h>

@interface ListManagedObject : NSManagedObject{
	NSData *iconData;
}

- (NSData *) getIcon;
- (void) setIcon: (NSData*) icon;

- (NSArray *) getRoms;
- (NSString *) getRomCount;

- (BOOL) getCanAdd;
- (void) setCanAdd: (BOOL) canAdd;

- (NSString *) getName;
- (void) setName:(NSString*)name;

- (NSString *) getAuthor;
- (void) setAuthor:(NSString*)author;

- (NSString *) getVersion;
- (void) setVersion:(NSString*)version;

@end
