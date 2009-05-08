
#import <Cocoa/Cocoa.h>

@interface RomListArrayController : NSArrayController 
{
	NSIndexSet * selectedRows;
	IBOutlet NSArrayController * listController;
}

// - (BOOL)tableView:(NSTableView *) tv writeRows:(NSArray*) rows toPasteboard:(NSPasteboard*) pboard;
// - (void) pasteboard:(NSPasteboard *) pboard provideDataForType:(NSString *) type;

@end
