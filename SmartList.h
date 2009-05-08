
#import <Cocoa/Cocoa.h>
#import "ListManagedObject.h"

@interface SmartList : ListManagedObject{
	NSPredicate *predicate;

	NSSet *listItems;
	NSDate *nextFetch;
}

- (NSPredicate *) getPredicate;
- (void) setPredicate:(NSPredicate *) newPredicate; 

- (NSData *) getIcon;

- (BOOL) getCanAdd;
- (void) setCanAdd: (BOOL) canAdd;

@end
