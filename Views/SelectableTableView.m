
#import "SelectableTableView.h"
#import "LesminniAppDelegate.h"

@implementation SelectableTableView

//	Key Down
- (void) keyDown: (NSEvent *) event{
	unichar arrow = [[event characters] characterAtIndex:0];

	if(arrow == NSLeftArrowFunctionKey)			[((LesminniAppDelegate *) [[NSApplication sharedApplication] delegate]) selectListsTable:self];
	else if(arrow == NSRightArrowFunctionKey)	[((LesminniAppDelegate *) [[NSApplication sharedApplication] delegate]) selectRomsTable:self];
//	else if(arrow == ' ')						[((LesminniAppDelegate *) [[NSApplication sharedApplication] delegate]) pageContent:self];
	else										[super keyDown:event];
}
/*
- (void)mouseDown: (NSEvent *)theEvent{
	NSPoint eventPoint;							// the point where mouse was down
	[super mouseDown: theEvent];				// forward this mouse event to NSTableView

	if(![self menu]){							// no menu = no need to go any further
		menuActionRow = menuActionColumn = -1;	// set both to -1 to indicate there wasn't any menu action
		return;
	}

	eventPoint = [theEvent locationInWindow];	// get the event location from window
	eventPoint = [self convertPoint: eventPoint fromView: nil];
	// convert the location from window to MenuTableView

	menuActionRow = [super rowAtPoint: eventPoint];	// get the row index where mouse was down
	menuActionColumn = [super columnAtPoint: eventPoint];
	// get the column index where mouse was down

	if((menuActionColumn == columnIndexWithMenu) && (menuActionRow != -1)){
		[NSMenu popUpContextMenu: [self menu] withEvent: theEvent forView: self];
		// show the menu
	}
	else{
		menuActionRow = menuActionColumn = -1;
		// set both to -1 to indicate there wasn't any menu action
	}
}
*/
- (void)rightMouseDown: (NSEvent *)theEvent{
	NSPoint eventPoint;	// the point where mouse was down

	if(![self menu]){	// no menu = no need to go any further
		menuActionRow = menuActionColumn = -1;
		// set both to -1 to indicate there wasn't any menu action
		return;
	}

	eventPoint = [theEvent locationInWindow];	// get the event location from window
	eventPoint = [self convertPoint: eventPoint fromView: nil];
	// convert the location from window to MenuTableView

	menuActionRow = [super rowAtPoint: eventPoint];	// get the row index where mouse was down
	menuActionColumn = [super columnAtPoint: eventPoint];
	// get the column index where mouse was down

	if((menuActionColumn == columnIndexWithMenu) && (menuActionRow != -1)){
		[NSMenu popUpContextMenu: [self menu] withEvent: theEvent forView: self];
		// show the menu
	}
	else{
		menuActionRow = menuActionColumn = -1;
		// set both to -1 to indicate there wasn't any menu action
	}
}

- (NSMenu *)menuForEvent: (NSEvent *)theEvent{
	return nil;
}

//	Menu Accessors
- (int)columnIndexWithMenu{
	return columnIndexWithMenu;
}

- (void)setColumnIndexWithMenu: (int)columnIndex{
	columnIndexWithMenu = columnIndex;
}

- (int)menuActionRow{
	return menuActionRow;
}

- (int)menuActionColumn{
	return menuActionColumn;
}

@end
