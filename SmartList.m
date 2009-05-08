
#import "SmartList.h"

@implementation SmartList

- (NSPredicate *) getPredicate{
	if(predicate == nil){
		[self willAccessValueForKey:@"predicateString"];
//		NSString * p = [self primitiveValueForKey:@"predicateString"];
		[self primitiveValueForKey:@"predicateString"];
		[self didAccessValueForKey:@"predicateString"];

		predicate = [[NSPredicate predicateWithFormat: [self primitiveValueForKey:@"predicateString"]] retain];
	}
	return predicate;
}

- (void) setPredicateString: (NSString *) newRules{
	NSPredicate * rules = [NSPredicate predicateWithFormat:newRules];

	[self setPredicate:rules];
}

- (void )setPredicate:(NSPredicate *) newPredicate{
	NSString * p = [newPredicate predicateFormat];

	[self willChangeValueForKey:@"items"];

	predicate = newPredicate;

	[self willChangeValueForKey:@"predicateString"];
	[self setPrimitiveValue:p forKey:@"predicateString"];
	[self didChangeValueForKey:@"predicateString"];

	[listItems release];
	listItems = nil;

	[self didChangeValueForKey:@"items"];
}

- (NSSet *) getItems{
	if(predicate == nil) predicate = [self getPredicate];

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"ROM" inManagedObjectContext:[self managedObjectContext]]];
	[fetch setPredicate:predicate];

	NSMutableSet *set = [[NSMutableSet alloc] init];
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:nil];

	if(results != nil) [set addObjectsFromArray:results];

	listItems = set;

	[fetch release];	//	ADDED MDC

	return listItems;
}

/*
- (NSString *) getName{
	return [SmartListNameString stringWithString:[self primitiveValueForKey:@"name"]];
}
*/

- (void) setItems: (NSSet *)set{}

- (NSData *) getIcon{
	if(iconData == nil) iconData = [[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smartlist-small" ofType:@"png"]] retain];
	return iconData;
}

- (BOOL) getCanAdd{
	return NO;
}

- (void) setCanAdd: (BOOL) canAdd{}

- (void)dealloc{
	[self setPredicateString:nil];
	[self setPredicate:nil];
	[self setItems:nil];
	[super dealloc];
}

@end
