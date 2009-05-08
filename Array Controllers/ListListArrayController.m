
#import "ListListArrayController.h"
#import "SmartList.h"
#import "LesminniAppDelegate.h"
#import "RomManagedObject.h"

@implementation ListListArrayController

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard{
	return NO;
}

- (NSDragOperation) tableView:(NSTableView*) tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation) op{
	if(row < 0)									row = 0;
	if(row >= [[self arrangedObjects] count])	row = [[self arrangedObjects] count] - 1;

	ListManagedObject *list = [[self arrangedObjects] objectAtIndex:row];

	if([list isKindOfClass:[SmartList class]]) return NSDragOperationNone;

	[tv setDropRow:row dropOperation:NSTableViewDropOn];

	return NSDragOperationMove;
}

- (BOOL) tableView:(NSTableView *) tableView acceptDrop:(id <NSDraggingInfo>) info row:(int) row dropOperation:(NSTableViewDropOperation) operation{
	ListManagedObject *list = [[self arrangedObjects] objectAtIndex:row];
	NSManagedObjectContext *context = [list managedObjectContext];

	[context lock];
	NSMutableSet * items = [list mutableSetValueForKey:@"items"];
	NSArray * array = [[info draggingPasteboard] propertyListForType:@"Lesminni ROM Type"];



	NSEnumerator *dragEnumerator = [array objectEnumerator];
	NSString *currentDrag;
	while((currentDrag = [dragEnumerator nextObject])){

//	int i = 0;
//	for(i = 0; i < [array count]; i++){
//		NSURL *rom = [NSURL URLWithString:[array objectAtIndex:i]];
		NSURL *rom = [NSURL URLWithString:currentDrag];
		NSManagedObjectID * objectId = [[context persistentStoreCoordinator] managedObjectIDForURIRepresentation:rom];

		if(objectId != nil){
			RomManagedObject *object = (RomManagedObject *) [context objectWithID:objectId];
			[items addObject: object];
		}
	}
	[context unlock];

	return YES;
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView{
	return [[self arrangedObjects] count];
}

@end
