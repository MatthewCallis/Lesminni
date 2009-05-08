
#import <Cocoa/Cocoa.h>

@interface ListsTextCell : NSTextFieldCell{
	BOOL mIsEditingOrSelecting;

	NSObject* delegate;
	NSString* iconKeyPath;
	NSString* primaryTextKeyPath;
	NSString* secondaryTextKeyPath;
}

- (NSString*) truncateString:(NSString *)string forWidth:(double) inWidth andAttributes:(NSDictionary*)inAttributes;

- (void) setDataDelegate: (NSObject*) aDelegate;

- (void) setIconKeyPath: (NSString*) path;
- (void) setPrimaryTextKeyPath: (NSString*) path;
- (void) setSecondaryTextKeyPath: (NSString*) path;

@end

@interface NSObject(ListsTextCellDelegate)

- (NSImage*) iconForCell: (ListsTextCell*) cell data: (NSObject*) data;
- (NSString*) primaryTextForCell: (ListsTextCell*) cell data: (NSObject*) data;
- (NSString*) secondaryTextForCell: (ListsTextCell*) cell data: (NSObject*) data;

// optional: give the delegate a chance to set a different data object
// This is especially useful for those cases where you do not want that NSCell creates copies of your data objects (e.g. Core Data objects).
// In this case you bind a value to the NSTableColumn that enables you to retrieve the correct data object. You retrieve the objects
// in the method dataElementForCell
- (NSObject*) dataElementForCell: (ListsTextCell*) cell;

// optional
- (BOOL) disabledForCell: (ListsTextCell*) cell data: (NSObject*) data;

@end
