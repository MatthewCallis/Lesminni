
#import <Cocoa/Cocoa.h>

@interface SelectableTableView : NSTableView{
	int columnIndexWithMenu;
	int menuActionRow;
	int menuActionColumn;
}

- (void) keyDown: (NSEvent *) event;

//	Menu Functions
//	use this function to get the index of column which should show menu when clicked
- (int)columnIndexWithMenu;
//	use this function to set the index of column which you want it to show menu when clicked
- (void)setColumnIndexWithMenu: (int)columnIndex;

- (int)menuActionRow;
- (int)menuActionColumn;

@end
