#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>
#import "ListManagedObject.h"
#import "ThreadWorker.h"

#import "ListsSplitView.h"
#import "ContentSplitView.h"

#import "ListsTableView.h"
#import "SelectableTableView.h"

@interface LesminniAppDelegate : NSObject{
//	Windows
	IBOutlet NSWindow * mainWindow;
	IBOutlet NSWindow * infoWindow;
	IBOutlet NSWindow * smartListEditorWindow;

//	Tableds & Views
	IBOutlet SelectableTableView * romsTable;
	IBOutlet ListsTableView * listsTable;

	IBOutlet ListsSplitView * splitView;
	IBOutlet ContentSplitView *contentSplitView;

	IBOutlet NSView *listsView;
	IBOutlet NSView *contentView;

	IBOutlet NSView *listsViewPlaceholder;
	IBOutlet NSView *contentViewPlaceholder;


//	Table Columns & Related
	IBOutlet NSMenu *columnsMenu;
	IBOutlet NSMenu *listMenu;

	IBOutlet NSTableColumn * columnTitle;
	IBOutlet NSTableColumn * columnCRC32;
	IBOutlet NSTableColumn * columnSize;
	IBOutlet NSTableColumn * columnMD5;
	IBOutlet NSTableColumn * columnSHA1;
	IBOutlet NSTableColumn * columnHave;

//	Array Controleds & Managed Objects
	IBOutlet NSArrayController * collectionArrayController;
	IBOutlet NSArrayController * romArrayController;
	IBOutlet NSObjectController * selectedRom;

	NSManagedObjectModel * managedObjectModel;
	NSManagedObjectContext * managedObjectContext;

//	Toolbar
	NSToolbar *toolbar;
	NSToolbarItem * editSmartList;
	NSToolbarItem * newRom;
	NSToolbarItem * removeRom;
	NSToolbarItem * removeList;

//	Search Field
	IBOutlet NSView * searchField;
	IBOutlet NSSearchField * searchTextField;

//	Progress Indicator
	IBOutlet NSWindow * fileProgressWindow;
	IBOutlet NSView * fileProgressView;
	IBOutlet NSProgressIndicator *fileProgress;

	NSString * newTitle;
	NSData * loadData;
	ThreadWorker *_datThread;

	NSMutableArray *parsedRomsArray;
}

- (IBAction)toggleColumn:(id)sender;
//- (IBAction)preferences:(id)sender;
- (void) windowWillClose: (NSNotification *) aNotification;

- (void)setupListMenu;

- (IBAction)saveAction:(id)sender;
- (IBAction)save: (id)sender;

- (NSManagedObjectModel *) managedObjectModel;
- (NSManagedObjectContext *) managedObjectContext;
- (NSWindow *) mainWindow;
- (NSWindow *) infoWindow;
- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *) sender;

// Toolbar Methods
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;

- (void) awakeFromNib;

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification;

- (IBAction) newRom:(id) sender;
- (IBAction) newRomFromFile:(id) sender;

- (IBAction) newList:(id) sender;
- (IBAction) newSmartList:(id)sender;
- (IBAction) editSmartList:(id) sender;
- (IBAction) saveSmartList:(id) sender;
- (IBAction) cancelSmartList:(id) sender;
- (IBAction) getInfoWindow:(id)sender;

- (NSArray *) getSelectedRoms;
- (NSArray *) getAllRoms;
- (NSArray *) getAllLists;
- (NSArray *) getAllSmartLists;

- (void) selectRomsTable: (id) sender;
- (void) selectListsTable: (id) sender;

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;

- (ListManagedObject *) getSelectedList;
- (void) setSelectedList: (ListManagedObject *) list;

- (NSArray *) getRomlists;

// Spotlight
- (void)loadDataFromOutside;
- (IBAction)updateSpotlightIndex: (id) sender;
- (IBAction)clearSpotlightIndex: (id) sender;

// Importing
- (IBAction) importDatList:(id)sender;
- (IBAction) checkFolderAgainstDatList:(id)sender;
- (id) datImportTask:(id)userInfo worker:(ThreadWorker *)tw;
- (void) importDatFinished:(id)userInfo;

// Exporting
- (IBAction)writeClrMameProDat:(id)sender;

@end
