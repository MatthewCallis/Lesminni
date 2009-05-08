
#import "RomListArrayController.h"
#import "SmartList.h""

@implementation RomListArrayController

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rows toPasteboard:(NSPasteboard*)pboard{
	if([[listController selectedObjects] count] != 1) return NO;

	selectedRows = rows;

	NSArray * typesArray = [NSArray arrayWithObjects:@"Lesminni ROM Type", nil];

	[pboard declareTypes:typesArray owner:self];

	return YES;
}

- (void) addObjects: (NSArray *) objects{
	[super addObjects:objects];
}

- (void) pasteboard:(NSPasteboard *) pboard provideDataForType:(NSString *) type{
	if([type isEqualTo:@"Lesminni ROM Type"]){
		NSMutableArray * rowCopies = [NSMutableArray array];

		int index = 0;
		while (NSNotFound != (index = [selectedRows indexGreaterThanOrEqualToIndex:index])){
			NSURL * url = [[[[self arrangedObjects] objectAtIndex:index] objectID] URIRepresentation];
			[rowCopies addObject:[url description]];
			index++;
		}
		[pboard setPropertyList:rowCopies forType:type];
	}
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation{
	return NSDragOperationMove;
}

@end
