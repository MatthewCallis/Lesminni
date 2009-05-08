#import "NSData_CRC.h"
#import "LesminniAppDelegate.h"
#import "SmartList.h"
#import "LesminniToolbarItem.h"
#import "RomManagedObject.h"
#import "ThreadWorker.h"
//#import <time.h>

#import "RomFile.h"
#import "ParseRomDelegate.h"
#import "ListsTextCell.h"

@implementation LesminniAppDelegate

+ (void)initialize;{
	NSMutableArray *columnWidths = [NSMutableArray array];
	[columnWidths insertObject:[NSNumber numberWithFloat: 220.0] atIndex:0];
	[columnWidths insertObject:[NSNumber numberWithFloat:  90.0] atIndex:1];
	[columnWidths insertObject:[NSNumber numberWithFloat:  64.0] atIndex:2];
	[columnWidths insertObject:[NSNumber numberWithFloat: 200.0] atIndex:3];
	[columnWidths insertObject:[NSNumber numberWithFloat: 160.0] atIndex:4];


	NSMutableArray *savedSortDescriptors = [NSMutableArray array];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[savedSortDescriptors addObject:sortDescriptor];
	[sortDescriptor release];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			nil, @"lastSearch",
			columnWidths, @"columnWidths",
			savedSortDescriptors, @"tableSorting",
			nil]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setupListMenu{
	NSMenu *iconMenu = [[[NSMenu alloc] initWithTitle:@"Menu"] autorelease];

	NSMenuItem *mario;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-mario"];
	mario = [iconMenu itemAtIndex:0];
	[mario setImage:[NSImage imageNamed:@"list-mario"]];

	NSMenuItem *goomba;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-goomba"];
	goomba = [iconMenu itemAtIndex:1];
	[goomba setImage:[NSImage imageNamed:@"list-goomba"]];

	NSMenuItem *kirby;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-kirby"];
	kirby = [iconMenu itemAtIndex:2];
	[kirby setImage:[NSImage imageNamed:@"list-kirby"]];

	[iconMenu addItem:[NSMenuItem separatorItem]];

	NSMenuItem *favorite;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-favorite"];
	favorite = [iconMenu itemAtIndex:4];
	[favorite setImage:[NSImage imageNamed:@"list-favorite"]];

	NSMenuItem *cd;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-cd"];
	cd = [iconMenu itemAtIndex:5];
	[cd setImage:[NSImage imageNamed:@"list-cd"]];

	NSMenuItem *library;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-library"];
	library = [iconMenu itemAtIndex:6];
	[library setImage:[NSImage imageNamed:@"list-library"]];

	NSMenuItem *internet;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-internet"];
	internet = [iconMenu itemAtIndex:7];
	[internet setImage:[NSImage imageNamed:@"list-internet"]];

	NSMenuItem *pack;
	[iconMenu addItemWithTitle:@"" action:@selector(changeListIcon:) keyEquivalent:@"list-pack"];
	pack = [iconMenu itemAtIndex:8];
	[pack setImage:[NSImage imageNamed:@"list-pack"]];

	NSMenuItem *iconSubMenu;
	[listMenu addItemWithTitle:@"Change Icon" action:@selector(menuSelected:) keyEquivalent:@""];
	iconSubMenu = [listMenu itemAtIndex:0];
	[iconSubMenu setSubmenu:iconMenu];

	NSMenuItem *checkRomsListItem;
	[listMenu addItemWithTitle:@"Check ROMs Against DAT/List" action:@selector(checkFolderAgainstDatList:) keyEquivalent:@""];
	checkRomsListItem = [listMenu itemAtIndex:1];

	NSMenuItem *removeListItem;
	[listMenu addItemWithTitle:@"Remove List" action:@selector(removeList:) keyEquivalent:@""];
	removeListItem = [listMenu itemAtIndex:2];
}

#pragma mark -
#pragma mark Custom Cell data delegate methods

- (NSImage*) iconForCell: (ListsTextCell*) cell data: (ListManagedObject*) data {
	NSImage *newImage = [[[NSImage alloc] initWithData:[data getIcon]] autorelease];
	return newImage;
}

- (NSString*) primaryTextForCell: (ListsTextCell*) cell data: (ListManagedObject*) data {
	return [data getName];
}

- (NSString*) secondaryTextForCell: (ListsTextCell*) cell data: (ListManagedObject*) data {
	return [data getRomCount];
}

- (NSObject*) dataElementForCell: (ListsTextCell*) cell{
	NSObject* uniqueId = [cell objectValue];
//	Build up a core data fetch request
//	NSLog(@"name == \"%@\"", uniqueId);
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", uniqueId];

	NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:[self managedObjectContext]]];
	[fetch setPredicate:predicate];

	NSError * error = nil;
	NSArray * fetchedItems = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	[fetch release];

//	NSLog(@"Count: %i", [fetchedItems count]);
	ListManagedObject *list = [fetchedItems objectAtIndex:0];

	return list;
}

- (void) awakeFromNib{
//	Setup the Toolbar
	toolbar = [[NSToolbar alloc] initWithIdentifier:@"main"];
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization: YES];
	[toolbar setAutosavesConfiguration: YES];
	[toolbar setShowsBaselineSeparator: YES];

	[mainWindow setToolbar:toolbar];

//	Set the Lists Table up
	[listsTable setRowHeight:18];
	[listsTable setIntercellSpacing:NSMakeSize(2.0, 2.0)];

	NSTableColumn *mainColumn = [[listsTable tableColumns] objectAtIndex:0];
	ListsTextCell *theTextCell = [[ListsTextCell alloc] init];
	[mainColumn setDataCell:theTextCell];
	[theTextCell release];
	[theTextCell setDataDelegate: self];
	[[mainColumn headerCell] setStringValue:@"Lists"];
	[mainColumn setResizingMask:NSTableColumnAutoresizingMask];

	[mainColumn setWidth:([listsTable frame].size.width)];

//	Set up sort descriptors
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[collectionArrayController setSortDescriptors:[NSArray arrayWithObject: sort]];
	[sort release];

//	Set the splitters' autosave names.
	[contentSplitView setPositionAutosaveName:@"SourceSplitter"];
	[splitView setPositionAutosaveName:@"ListSplitter"];

//	Place the source list view in the left panel.
	[listsView setFrameSize:[listsViewPlaceholder frame].size];
	[listsViewPlaceholder addSubview:listsView];

//	Place the content view in the right panel.
	[contentView setFrameSize:[contentViewPlaceholder frame].size];
	[contentViewPlaceholder addSubview:contentView];

//	Load the table column's widths
	NSEnumerator *columnsEnumerator = [[romsTable tableColumns] objectEnumerator];
	NSEnumerator *widthsEnumerator = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"columnWidths"] objectEnumerator];
	NSTableColumn *tableColumn;
	NSNumber *width;
	while((tableColumn = [columnsEnumerator nextObject]) && (width = [widthsEnumerator nextObject])){
		[tableColumn setWidth:[width floatValue]];
	}

//	Load the tables sort descriptors
	NSEnumerator *sortEnumerator = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"tableSorting"] objectEnumerator];
	NSMutableArray *sortDescriptors = [NSMutableArray array];
	NSDictionary *dict;
	while(dict = [sortEnumerator nextObject]){
		NSSortDescriptor *sort;
		NSString *key = (NSString *)[dict objectForKey:@"key"];
		if([[dict objectForKey:@"ascending"] isEqual:@"yes"])	sort = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
		else													sort = [[NSSortDescriptor alloc] initWithKey:key ascending:NO];
		[sortDescriptors addObject:sort];
		[sort release];
	}
	[romsTable setSortDescriptors:sortDescriptors];

	[columnTitle retain];
	[columnSize retain];
	[columnCRC32 retain];
	[columnMD5 retain];
	[columnSHA1 retain];
	[columnHave retain];

//	Set haveTheRom to hold an image
//	NSImageCell *cell = [NSImageCell new];
//	[columnHave setDataCell:cell];

	NSArray *tcs = [romsTable tableColumns];
	NSEnumerator *e = [tcs objectEnumerator];
	NSTableColumn *tc;
	while((tc = [e nextObject]) != nil){
		if(tc == columnTitle)		[[columnsMenu itemWithTag: 0] setState:NSOnState];
		else if(tc == columnSize)	[[columnsMenu itemWithTag: 1] setState:NSOnState];
		else if(tc == columnCRC32)	[[columnsMenu itemWithTag: 2] setState:NSOnState];
		else if(tc == columnMD5)	[[columnsMenu itemWithTag: 3] setState:NSOnState];
		else if(tc == columnSHA1)	[[columnsMenu itemWithTag: 4] setState:NSOnState];
		else if(tc == columnHave)	[[columnsMenu itemWithTag: 5] setState:NSOnState];
	}
	[[romsTable headerView] setMenu:columnsMenu];
	[romsTable setDoubleAction:@selector(getInfoWindow:)];
	[self setupListMenu];
	[listsTable setColumnIndexWithMenu:0];
	[listsTable registerForDraggedTypes:[NSArray arrayWithObject:@"Lesminni ROM Type"]];
	[mainWindow setShowsResizeIndicator:YES];

//	[NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)menuSelected: (id)sender{
//	NSLog(@"Menu triggered at:\n  row: %i\n  column: %i\n  selected menu title: %@\n", [listsTable menuActionRow], [listsTable menuActionColumn], [sender title]);
	[listsTable reloadData];
}

- (IBAction) changeListIcon:(id) sender{
	NSArray *objects = [collectionArrayController selectedObjects];
//	NSLog([sender title]);
//	NSLog([sender keyEquivalent]);
	if([objects count] == 1){
		ListManagedObject *list = [objects objectAtIndex:0];
		NSData *icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[sender keyEquivalent] ofType:@"png"]];
		[list setIcon: icon];
	}
	[listsTable reloadData];
}

- (NSManagedObjectModel *) managedObjectModel{
	if(managedObjectModel) return managedObjectModel;

	NSMutableSet *allBundles = [[NSMutableSet alloc] init];
	[allBundles addObject: [NSBundle mainBundle]];
	[allBundles addObjectsFromArray: [NSBundle allFrameworks]];

	managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];

	[allBundles release];

	return managedObjectModel;
}

- (NSString *)applicationSupportFolder{
	return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]
			stringByAppendingPathComponent:[[NSProcessInfo processInfo]
			processName]];
}

- (NSManagedObjectContext *) managedObjectContext{
	NSError *error;
	NSURL *url;
	NSString *applicationSupportFolder = [self applicationSupportFolder];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSPersistentStoreCoordinator *coordinator;

	if(managedObjectContext) return managedObjectContext;

	if(![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL]) [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];

	NSString *filePath = [applicationSupportFolder stringByAppendingPathComponent: @"Lesminni.rom-data"];

	url = [NSURL fileURLWithPath:filePath];
	coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

	// NSSQLiteStoreType / NSXMLStoreType
	if([coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
		managedObjectContext = [[NSManagedObjectContext alloc] init];
		[managedObjectContext setPersistentStoreCoordinator: coordinator];
	}
	else [[NSApplication sharedApplication] presentError:error];

	[coordinator release];

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];

	[fetch setEntity:entity];
	[fetch setPredicate:[NSPredicate predicateWithFormat:@"name != \"\""]];

	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	[fetch release];

	if(results == nil || [results count] == 0){
		NSEntityDescription *collectionDesc = [[[self managedObjectModel] entitiesByName] objectForKey:@"List"];
		NSEntityDescription *romDesc = [[[self managedObjectModel] entitiesByName] objectForKey:@"ROM"];

		[managedObjectContext lock];

		ListManagedObject *listObject = [[ListManagedObject alloc] initWithEntity:collectionDesc insertIntoManagedObjectContext:managedObjectContext];
		NSData *icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list-small" ofType:@"png"]];
		[listObject setValue:NSLocalizedString(@"My ROMs", nil) forKey:@"name"];
		[listObject setIcon:icon];

		NSMutableSet *items = [listObject mutableSetValueForKey:@"items"];
		RomManagedObject *romObject = [[RomManagedObject alloc] initWithEntity:romDesc insertIntoManagedObjectContext:managedObjectContext];

		[romObject setValue:NSLocalizedString(@"New ROM", nil) forKey:@"title"];
		[romObject setValue:NSLocalizedString(@"My ROMs", nil) forKey:@"listName"];
		[romObject setValue:@"" forKey:@"haveTheRom"];
		[items addObject:romObject];

		[romArrayController addObject:romObject];

		[listObject release];
		[romObject release];

		[managedObjectContext unlock];
	}
	return managedObjectContext;
}

- (NSUndoManager *) windowWillReturnUndoManager: (NSWindow *) window{
	return [[self managedObjectContext] undoManager];
}

- (IBAction) saveAction:(id) sender{
	NSError *error = nil;
	if([[self managedObjectContext] hasChanges]){
		if(![[self managedObjectContext] save:&error]){
			[[NSApplication sharedApplication] presentError:error];
		}
	}
}

- (IBAction)save:(id)sender{
	NSError *error = nil;
	if(![[self managedObjectContext] save:&error]) [[NSApplication sharedApplication] presentError:error];
}

- (NSApplicationTerminateReply) applicationShouldTerminate: (NSApplication *) sender{
//	Save the table column's widths
	NSEnumerator *columnsEnumerator = [[romsTable tableColumns] objectEnumerator];
	NSMutableArray *columnWidths = [NSMutableArray array];
	NSTableColumn *tableColumn;
	while(tableColumn = [columnsEnumerator nextObject]){
		[columnWidths addObject:[NSNumber numberWithFloat:[tableColumn width]]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:columnWidths forKey:@"columnWidths"];

//	Save the tables sort descriptors
	NSMutableArray *sortDescriptors = [NSMutableArray array];
	NSEnumerator *sortEnumerator = [[romsTable sortDescriptors] objectEnumerator];
	NSSortDescriptor *sortDescriptor;
	while(sortDescriptor = [sortEnumerator nextObject]){
		NSMutableDictionary *values = [NSMutableDictionary dictionary];
		[values setObject:[sortDescriptor key] forKey:@"key"];
		if([sortDescriptor ascending])	[values setObject:@"yes" forKey:@"ascending"];
		else							[values setObject:@"no" forKey:@"ascending"];
		[sortDescriptors addObject:values];
	}
	[[NSUserDefaults standardUserDefaults] setObject:sortDescriptors forKey:@"tableSorting"];

	NSError *error;
	NSManagedObjectContext *context;
	int reply = NSTerminateNow;
	context = [self managedObjectContext];
	if(context != nil){
		if([context commitEditing]){
			if(![context save:&error]){
				// This default error handling implementation should be changed to make sure the error presented includes application specific error recovery. For now, simply display 2 panels.
				BOOL errorResult = [[NSApplication sharedApplication] presentError:error];

				// Then the error was handled
				if(errorResult == YES) reply = NSTerminateCancel;
				else{
					// Error handling wasn't implemented. Fall back to displaying a "quit anyway" panel.
					int alertReturn = NSRunAlertPanel(nil, NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", nil), NSLocalizedString(@"Quit anyway", nil), NSLocalizedString(@"Cancel", nil), nil);

					if(alertReturn == NSAlertAlternateReturn) reply = NSTerminateCancel;
				}
			}
		}
		else reply = NSTerminateCancel;
	}
	if(reply != NSTerminateCancel){
		NSFileManager *manager = [NSFileManager defaultManager];

		NSString *prefix = @"lesminni_";
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[c] %@", [prefix stringByAppendingString:@"*"]];

		NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:NSTemporaryDirectory()];
		NSString *currentFilename;
		while((currentFilename = [dirEnum nextObject])){
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			if([predicate evaluateWithObject:currentFilename]){
				if([manager fileExistsAtPath:currentFilename]) [manager removeFileAtPath:currentFilename handler:nil];
			}
			[pool release];
		}
	}
	return reply;
}

- (NSWindow *) mainWindow{
	return mainWindow;
}

- (NSWindow *) infoWindow{
	return infoWindow;
}

- (IBAction) getInfoWindow: (id) sender{
	if([infoWindow isVisible])	[infoWindow orderOut:sender];
	else						[infoWindow makeKeyAndOrderFront:sender];
}

- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) itemIdentifier willBeInsertedIntoToolbar: (BOOL) flag{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	[item setLabel:itemIdentifier];

	if([itemIdentifier isEqualToString:@"new-list"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"newList:")];
		[item setImage:[NSImage imageNamed:@"new-list"]];
		[item setLabel:NSLocalizedString(@"New List", nil)];
		[item setPaletteLabel:[item label]];
	}
	else if([itemIdentifier isEqualToString:@"new-smartlist"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"newSmartList:")];
		[item setImage:[NSImage imageNamed:@"new-smartlist"]];
		[item setLabel:NSLocalizedString(@"New Smart List", nil)];
		[item setPaletteLabel:[item label]];
	}
	else if([itemIdentifier isEqualToString:@"edit-smartlist"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"editSmartList:")];
		[item setImage:[NSImage imageNamed:@"edit-smartlist"]];
		[item setLabel:NSLocalizedString(@"Edit Smart List", nil)];
		[item setPaletteLabel:[item label]];
		editSmartList = item;
	}
	else if([itemIdentifier isEqualToString:@"remove-list"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"removeList:")];
		[item setImage:[NSImage imageNamed:@"remove-list"]];
		[item setLabel:NSLocalizedString(@"Remove List", nil)];
		[item setPaletteLabel:[item label]];
		removeList = item;
	}
	else if([itemIdentifier isEqualToString:@"remove-rom"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"removeRom:")];
		[item setImage:[NSImage imageNamed:@"remove-rom"]];
		[item setLabel:NSLocalizedString(@"Remove ROM", nil)];
		[item setPaletteLabel:[item label]];
		removeRom = item;
	}
	else if([itemIdentifier isEqualToString:@"new-rom"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"newRom:")];
		[item setImage:[NSImage imageNamed:@"new-rom"]];
		[item setLabel:NSLocalizedString(@"New ROM", nil)];
		[item setPaletteLabel:[item label]];
		newRom = item;
	}
	else if([itemIdentifier isEqualToString:@"preferences"]){
		[item setTarget:self];
		[item setAction:NSSelectorFromString(@"preferences:")];
		[item setImage:[NSImage imageNamed:@"preferences"]];
		[item setLabel:NSLocalizedString(@"Preferences", nil)];
		[item setPaletteLabel:[item label]];
	}
	else if([itemIdentifier isEqualToString:@"search"]){
		[item setView:searchField];
		[item setMinSize: NSMakeSize(120, 32)];	// set a reasonable minimum size
		[item setMaxSize: NSMakeSize(240, 32)];	// set a maximum size that allows us to stretch
		[item setLabel:NSLocalizedString(@"Search Selected List", nil)];
		[item setPaletteLabel:[item label]];
	}
//	else if([itemIdentifier isEqualToString: @"progress"]){
//		[item setView: fileProgressView];
//		[item setMinSize: NSMakeSize(60, 16)];
//		[item setMaxSize: NSMakeSize(240, 16)];
//		[item setLabel: NSLocalizedString(@"% Complete", nil)];
//		[item setPaletteLabel:[item label]];
//	}
	return item;
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar{
	return [NSArray arrayWithObjects:
		@"new-list",
		@"new-smartlist",
		@"edit-smartlist",
		@"new-rom",
		@"remove-rom",
		@"remove-list",
		@"preferences",
		@"search",
//		@"progress",
		NSToolbarSeparatorItemIdentifier, 
		NSToolbarSpaceItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar{
	return [NSArray arrayWithObjects:
		NSToolbarFlexibleSpaceItemIdentifier,
		@"new-list",
		@"new-smartlist",
		@"edit-smartlist",
		@"new-rom",
		@"remove-rom",
		@"remove-list",
		NSToolbarFlexibleSpaceItemIdentifier,
		@"search", nil];
}

- (void) tableViewSelectionDidChange: (NSNotification *) notification{
	NSTableView *table = [notification object];

	if(table == romsTable){
		if(loadData != nil){
			[self loadDataFromOutside];
			loadData = nil;
		}
	}
	else if(table == listsTable){
		NSArray *selectedObjects = [collectionArrayController selectedObjects];
		if([selectedObjects count] > 0){
			ListManagedObject *list = [selectedObjects objectAtIndex:0];
			if([list isKindOfClass:[SmartList class]]){
				[newRom setAction:nil];
				[editSmartList setAction:NSSelectorFromString(@"editSmartList:")];
				[removeRom setAction:nil];
				[removeList setAction:NSSelectorFromString(@"removeList:")];
			}
			else{
				[newRom setAction:NSSelectorFromString(@"newRom:")];
				[editSmartList setAction:nil];
				[removeRom setAction:NSSelectorFromString(@"removeRom:")];
				[removeList setAction:NSSelectorFromString(@"removeList:")];
			}
		}
		else{
			[newRom setAction:nil];
			[editSmartList setAction:nil];
			[removeRom setAction:nil];
			[removeList setAction:nil];
		}
		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
		[collectionArrayController setSortDescriptors:[NSArray arrayWithObject: sort]];
		[sort release];
	}
	[contentView setNeedsDisplay:YES];
}

- (IBAction)preferences:(id)sender{
//	if([preferencesWindow isVisible])	[preferencesWindow orderOut:sender];
//	else								[preferencesWindow makeKeyAndOrderFront:sender];
}

- (void) windowWillClose: (NSNotification *) notification{
	NSWindow *window = (NSWindow *) [notification object];
	if(window == mainWindow){
		[self saveAction:self];
		[[NSApplication sharedApplication] terminate:self];
	}
}

#pragma mark -
#pragma mark ClrMamePro DAT Import Methods

- (IBAction) checkFolderAgainstDatList: (id) sender{
	NSOpenPanel *sourceDir = [NSOpenPanel openPanel];
	[sourceDir setAllowsMultipleSelection:FALSE];
	[sourceDir setCanChooseDirectories:YES];
	[sourceDir setCanChooseFiles:NO];
	[sourceDir setCanCreateDirectories:YES];
	if([sourceDir runModalForDirectory:nil file:nil] == NSFileHandlingPanelOKButton){
		ParseRomDelegate *parseRom = [[ParseRomDelegate alloc] init];
		parsedRomsArray = (NSMutableArray *)[parseRom listDirectory:[sourceDir directory]];
		[parseRom release];
	}
	else{
		return;
	}

	ListManagedObject *list = [[collectionArrayController selectedObjects] objectAtIndex:0];
//	NSLog(@"%i", [[list getRoms] count]);
	NSArray *theRoms = [list getRoms];

	NSEnumerator *romsEnumerator = [theRoms objectEnumerator];
	RomManagedObject *currentRom;

	while(currentRom = [romsEnumerator nextObject]){
		NSEnumerator *filesEnumerator = [parsedRomsArray objectEnumerator];
		RomFile *currentFile;
		while(currentFile = [filesEnumerator nextObject]){
			if([[currentRom getCRC] isEqualToString:[currentFile fileCRC32]]){
//				NSLog(@"Match! %@ == %@", [currentRom getTitle], [currentFile filename]);
//				[currentRom setValue:[currentFile fileSHA1] forKey:@"sha1"];
//				[currentRom setValue:[currentFile fileMD5] forKey:@"md5"];
				[currentRom setValue:@"√" forKey:@"haveTheRom"];
			}
		}
	}
}

- (IBAction)importDatList:(id) sender{
	[collectionArrayController rearrangeObjects];
	NSString *datLocation;

	// Open File Dialog and get the filename of the DAT we want to add
	NSOpenPanel *sourceDir = [NSOpenPanel openPanel];
	[sourceDir setAllowsMultipleSelection:NO];
	[sourceDir setCanChooseDirectories:NO];
	[sourceDir setCanChooseFiles:YES];
	[sourceDir setCanCreateDirectories:NO];
	[sourceDir setResolvesAliases:YES];
	[sourceDir setTitle: NSLocalizedString(@"Please Choose A DAT", nil)];
	[sourceDir setPrompt: NSLocalizedString(@"Choose DAT", nil)];
	if([sourceDir runModalForTypes:nil] == NSFileHandlingPanelOKButton){
		datLocation = [NSString stringWithString:[sourceDir filename]];
	}
	else{
		datLocation = nil;
		[listsTable reloadData];
	}

	if(datLocation != nil){
		// Parse the file and add the info to the list, if it's not nil
		NSString *data = [NSString stringWithContentsOfFile:datLocation encoding:NSISOLatin1StringEncoding error:NULL];
		ListManagedObject *list = [[collectionArrayController selectedObjects] objectAtIndex:0];

		// Prep things we'll need in the other thread
		NSMutableDictionary *thingsIllNeed = [NSMutableDictionary dictionary];
		[thingsIllNeed setObject:data forKey:@"datfile"];
		[thingsIllNeed setObject:list forKey:@"thelist"];
		[thingsIllNeed setObject:fileProgress forKey:@"progress"];

		[fileProgress setUsesThreadedAnimation:YES];
//		[fileProgress startAnimation:self];

		[[NSApplication sharedApplication] beginSheet:fileProgressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:nil contextInfo:NULL];

		// Start work on new thread
		_datThread = [[ThreadWorker workOn:self
						withSelector:@selector(datImportTask:worker:)
						withObject:thingsIllNeed
						didEndSelector:@selector(importDatFinished:)] retain];

		// All done!
		datLocation = nil;
	}
}

- (id)datImportTask:(id)userInfo worker:(ThreadWorker *)tw{
	NSDictionary		*thingsIllNeed;
	id					returnVal = nil;
	ListManagedObject	*list = nil;
	NSString			*data = nil;
	NSProgressIndicator *progress;

	// Get stuff I'll need to talk to on the other thread.
	thingsIllNeed	= (NSDictionary *)userInfo;
	list			= (ListManagedObject *)[thingsIllNeed objectForKey:@"thelist"];
	data			= (NSString *)[thingsIllNeed objectForKey:@"datfile"];
	progress		= (NSProgressIndicator *)[thingsIllNeed objectForKey:@"progress"];

	BOOL datNameEntry = YES;
	BOOL datDescEntry = YES;

	NSArray *lines = [data componentsSeparatedByString:@"\n"];
	NSEnumerator *objectsEnumerator = [lines objectEnumerator];

	[romsTable lockFocus];

//	clock_t before, after;
//	double delta;
//	before = clock();
	int totalLines = [lines count];

	if([progress isIndeterminate]){
		[progress stopAnimation:self];
		[progress setIndeterminate:NO];
	}
//	NSLog(@"totalLines: %i", totalLines );
	[progress setMaxValue: (totalLines)*1.0];

	int i = 1;
	while(lines = [objectsEnumerator nextObject]){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *datName = nil;
		NSString *datVersion = nil;
		NSString *datAuthor = nil;
		NSString *datDescription = nil;
		NSString *datCategory = nil;

		NSString *romName = nil;
		NSString *romSize = nil;
		NSString *romCRC = nil;
		NSString *romSHA1 = nil;
		NSString *romMD5 = nil;

		NSScanner *theScanner = [NSScanner scannerWithString:(NSString *)lines];
		NSString *searchString = nil;

//		Set DAT List Information (Name, Date, Version)
		[theScanner scanUpToString: @" " intoString: &searchString];
		if([searchString isEqualToString:@"clrmamepro"]) continue;
		if([searchString isEqualToString:@"name"] && datNameEntry == YES){
			datNameEntry = NO;
			[theScanner scanUpToString: @"\n" intoString: &datName];
			datName = [datName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]];
			[list setName: datName];
		}
		if([searchString isEqualToString:@"description"] && datDescEntry == YES){
			datDescEntry = NO;
			[theScanner scanUpToString: @"\n" intoString: &datDescription];
		}
		if([searchString isEqualToString:@"author"])		[theScanner scanUpToString: @"\n" intoString: &datAuthor];
		if([searchString isEqualToString:@"category"])		[theScanner scanUpToString: @"\n" intoString: &datCategory];
		if([searchString isEqualToString:@"version"])		[theScanner scanUpToString: @"\n" intoString: &datVersion];
/**
		NSLog(@"Found: %@", searchString);
		NSLog(@"DAT Name: %@", datName);
		NSLog(@"DAT Author: %@", datAuthor);
		NSLog(@"DAT Category: %@", datCategory);
		NSLog(@"DAT Description: %@", datDescription);
		NSLog(@"DAT Version: %@", datVersion);
**/
		if([searchString isEqualToString:@"game"])			continue;
		if([searchString isEqualToString:@"name"])			continue; // [theScanner scanUpToString: @"\n\r" intoString: &romName];
		if([searchString isEqualToString:@"description"])	continue;
		else if([searchString isEqualToString:@"rom"]){
			[theScanner scanUpToString: @" " intoString: NULL];
			[theScanner scanUpToString: @" " intoString: NULL];
			[theScanner scanUpToString: @" size" intoString: &romName];
			[theScanner scanUpToString: @" " intoString: NULL];
			[theScanner scanUpToString: @" crc" intoString: &romSize];
			[theScanner scanUpToString: @" " intoString: NULL];
			[theScanner scanUpToString: @" " intoString: &romCRC];
			[theScanner scanUpToString: @" " intoString: NULL];
			[theScanner scanUpToString: @" " intoString: &romSHA1];
			[theScanner scanUpToString: @" " intoString: NULL];
			if(![theScanner scanUpToString: @" )" intoString: &romMD5] == TRUE) romMD5 = @"None";
			if([romSHA1 length] != 40){
				if([romSHA1 length] == 32 && [romMD5 length] == 40){
					NSString *temporaryA = [NSString stringWithString:romMD5];
					romMD5 = [NSString stringWithString:romSHA1];
					if([temporaryA length] == 40){
						romSHA1 = [NSString stringWithString:temporaryA];
					}
					else romSHA1 = @"None";
				}
			}
/**
			NSLog(@"Name: %@", [romName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]]);
			NSLog(@"Size: %@", romSize);
			NSLog(@"CRC : %@", romCRC);
			NSLog(@"SHA1: %@", romSHA1);
			NSLog(@"MD5 : %@", romMD5);
**/
			NSManagedObjectContext *contextRom = [self managedObjectContext];
			NSManagedObjectModel *modelRom = [self managedObjectModel];
			NSEntityDescription *descRom = [[modelRom entitiesByName] objectForKey:@"ROM"];

			RomManagedObject *objectRom = [[RomManagedObject alloc] initWithEntity:descRom insertIntoManagedObjectContext:contextRom];
			[contextRom lock];

			[objectRom setList: list];
			[objectRom setValue: datName forKey:@"listName"];
			[objectRom setValue: [[romName stringByDeletingPathExtension] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]] forKey:@"title"];
			[objectRom setValue: [romName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]] forKey:@"filename"];
			[objectRom setValue: romSize forKey:@"size"];
			[objectRom setValue: romCRC forKey:@"crc32"];
			[objectRom setValue: romMD5 forKey:@"md5"];
			[objectRom setValue: romSHA1 forKey:@"sha1"];
			[objectRom setValue: @"" forKey:@"haveTheRom"];

			[contextRom insertObject:objectRom];
			[romArrayController addObject: objectRom];
			[contextRom unlock];

			[objectRom release];
		}
		[pool release];
		[progress setDoubleValue:(i*1.0)];
		i++;
	}
//	after = clock();
//	delta = after;
//	delta -= before;
//	delta /= CLOCKS_PER_SEC;
//	NSLog(@"Import Using 'continue': %f", delta);
	[romsTable unlockFocus];
	return returnVal;
}

-(void)importDatFinished:(id)userInfo{
//	NSLog(@"Import DAT Finished");

	[_datThread release];
	_datThread = nil;

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[collectionArrayController setSortDescriptors:[NSArray arrayWithObject: sort]];
	[sort release];

	[[NSApplication sharedApplication] endSheet:fileProgressWindow];
	[fileProgressWindow orderOut:self];

	[listsTable reloadData];
}

- (IBAction)writeClrMameProDat:(id)sender{
	[collectionArrayController arrangedObjects];
	[romArrayController arrangedObjects];

	if([[collectionArrayController selectedObjects] count] == 1){
		ListManagedObject *list = [[collectionArrayController selectedObjects] objectAtIndex:0];
		NSMutableString *romBunch = [[NSMutableString alloc] init];

		if([[list getRoms] count] == 0) return;

//		Build the ClrMamePro Header
		[romBunch appendString: @"clrmamepro (\n"];
		[romBunch appendFormat: @"\tname \"%@\"\n", [list valueForKey:@"name"]];
		[romBunch appendFormat: @"\tdescription \"%@\"\n", [list valueForKey:@"name"]];
		[romBunch appendString: @"\tversion 2007\n"];
		[romBunch appendFormat: @"\tauthor \"%@\"\n", [list valueForKey:@"name"]];
		[romBunch appendString: @")\n\n"];

		NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
		NSArray *listArray = [[list getRoms] sortedArrayUsingDescriptors:[NSArray arrayWithObject: sort]];
		[sort release];

		NSEnumerator *filesEnumerator = [listArray objectEnumerator];
		RomManagedObject *currentRom;
		while(currentRom = [filesEnumerator nextObject]){
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[romBunch appendString: @"game (\n"];

			if([currentRom valueForKey:@"title"] != nil){
				[romBunch appendFormat: @"\tname \"%@\"\n", [currentRom valueForKey:@"title"]];
				[romBunch appendFormat: @"\tdescription \"%@\"\n", [currentRom valueForKey:@"title"]];
			}

			if([currentRom valueForKey:@"filename"] != nil){
				[romBunch appendFormat: @"\trom ( name \"%@\" ", [currentRom valueForKey:@"filename"]];
			}

			if([currentRom valueForKey:@"size"] != nil){
				[romBunch appendFormat: @"size %@ ", [currentRom valueForKey:@"size"]];
			}
			else{
				[romBunch appendFormat: @"size 0 ", [currentRom valueForKey:@"size"]];
			}

			if([currentRom valueForKey:@"crc32"] != nil){
				[romBunch appendFormat: @"crc %@ ", [currentRom valueForKey:@"crc32"]];
			}

			if([currentRom valueForKey:@"md5"] != nil){
				[romBunch appendFormat: @"md5 %@ ", [currentRom valueForKey:@"md5"]];
			}

			if([currentRom valueForKey:@"sha1"] != nil){
				[romBunch appendFormat: @"sha1 %@ ", [currentRom valueForKey:@"sha1"]];
			}
			[romBunch appendString: @")\n)\n\n"];
			[pool release];
		}

		// Save File Dialog
		NSOpenPanel *sp = [NSOpenPanel openPanel];
		NSString *resultUrl;
		int fileDialogResult;
		int alertResult = NSAlertAlternateReturn;

		[sp setTitle: NSLocalizedString(@"Save DAT To...", nil)];
		[sp setPrompt: NSLocalizedString(@"Save", nil)];
		[sp setCanChooseDirectories:YES];
		[sp setCanChooseFiles:NO];
		[sp setCanCreateDirectories:YES];
		[sp setResolvesAliases:YES];

		alertResult = NSAlertAlternateReturn;
		fileDialogResult = [sp runModalForDirectory:nil file:nil];
		if(fileDialogResult == NSOKButton){
			alertResult = NSRunAlertPanel(	NSLocalizedString(@"Export ClrMamePro DAT", nil),
											NSLocalizedString(@"Directory isn't empty, old files may be overwritten. Continue?", nil),
											NSLocalizedString(@"No", nil),
											NSLocalizedString(@"Yes", nil), nil);
		}

//		while((fileDialogResult == NSOKButton) && (alertResult == NSAlertDefaultReturn));
		if(fileDialogResult == NSOKButton){
			resultUrl = [[sp directory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.dat", [list getName]] ];
//			NSLog(@"resultUrl: %@", resultUrl);
		}
		else return;

//		NSLog(@"Trying to write to file");

		NSMutableString *writeStatus = [[NSMutableString alloc] init];
//		Try to write the file
		if([romBunch writeToFile:resultUrl encoding:NSUTF8StringEncoding atomically:NO error:nil])
			[writeStatus setString:NSLocalizedString(@"Write was successfull!", nil)];
		else
			[writeStatus setString:NSLocalizedString(@"Write Failed!", nil)];

//		Tell the user what happened
		NSRunInformationalAlertPanel(NSLocalizedString(@"Status Of Save Operation", nil), writeStatus, NSLocalizedString(@"Ok", nil), nil, nil);

//		NSLog(@"Done writing to file.");
		[writeStatus release];
		[romBunch release];
	}
}


#pragma mark -
#pragma mark ROM Methods

- (IBAction)newRom:(id) sender{
	NSArray *objects = [collectionArrayController selectedObjects];
	if([objects count] < 1){}
	else if([objects count] == 1){
		ListManagedObject *list = [objects objectAtIndex:0];

		if([list isKindOfClass:[SmartList class]]){}
		else{
			[romsTable lockFocus];

			NSManagedObjectContext *context = [self managedObjectContext];
			NSManagedObjectModel *model = [self managedObjectModel];
			NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"ROM"];

			[context lock];
			RomManagedObject *object = [[RomManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:context];

			[object setValue:NSLocalizedString(@"New ROM", nil) forKey:@"title"];
			[object setValue:[list getName] forKey:@"listName"];
			[object setValue:@"" forKey:@"haveTheRom"];
			[context insertObject:object];

			[romArrayController addObject:object];
			[context unlock];

			[object release];

			if(![infoWindow isVisible]) [self getInfoWindow:nil];

			[romsTable unlockFocus];
		}
	}
	else{}
}

- (IBAction)newRomFromFile:(id) sender{
	NSOpenPanel *sourceDir = [NSOpenPanel openPanel];
	[sourceDir setAllowsMultipleSelection:YES];
	[sourceDir setCanChooseDirectories:NO];
	[sourceDir setCanChooseFiles:YES];
	[sourceDir setCanCreateDirectories:NO];
	[sourceDir setResolvesAliases:YES];
	[sourceDir setTitle: NSLocalizedString(@"Please Choose A ROM", nil)];
	[sourceDir setPrompt: NSLocalizedString(@"Choose ROM", nil)];
	if([sourceDir runModalForTypes:nil] == NSFileHandlingPanelOKButton){
		ParseRomDelegate *parseRom = [[ParseRomDelegate alloc] init];
		parsedRomsArray = (NSMutableArray *)[parseRom listFiles:[sourceDir filenames]];
		[parseRom release];

	}
	else return;

	NSArray *objects = [collectionArrayController selectedObjects];
	if([objects count] < 1){}
	else if([objects count] == 1){
		ListManagedObject *list = [objects objectAtIndex:0];
		if([list isKindOfClass:[SmartList class]]){}
		else{
			[romsTable lockFocus];

			NSEnumerator *filesEnumerator = [parsedRomsArray objectEnumerator];
			RomFile *currentFile;
			while(currentFile = [filesEnumerator nextObject]){
				NSManagedObjectContext *context = [self managedObjectContext];
				NSManagedObjectModel *model = [self managedObjectModel];
				NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"ROM"];

				[context lock];
				RomManagedObject *object = [[RomManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:context];
				[object setValue:[list getName] forKey:@"listName"];
				[object setValue:[currentFile cartType] forKey:@"cartType"];
				[object setValue:[currentFile country] forKey:@"country"];
				[object setValue:[currentFile fileCRC32] forKey:@"crc32"];
				[object setValue:[currentFile gameCode] forKey:@"gameCode"];
				[object setValue:[currentFile version] forKey:@"gameVersion"];
				[object setValue:[currentFile headerCheck] forKey:@"headerCheck"];
				[object setValue:[currentFile internalTitle] forKey:@"internalTitle"];
				[object setValue:[currentFile manufacture] forKey:@"manufacturer"];
				[object setValue:[currentFile fileMD5] forKey:@"md5"];
				[object setValue:[currentFile saveSize] forKey:@"saveSize"];
				[object setValue:[currentFile fileSHA1] forKey:@"sha1"];
				[object setValue:[currentFile romSize] forKey:@"size"];
				[object setValue:[[currentFile filename] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]] forKey:@"filename"];
				[object setValue:[[currentFile filename] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"\"\n\r"]] forKey:@"title"];
				[object setValue:@"√" forKey:@"haveTheRom"];

				[context insertObject:object];

				[romArrayController addObject:object];
				[context unlock];

				[object release];
			}
			[romsTable unlockFocus];
		}
	}
	else{}
	[romsTable reloadData];
}

- (IBAction) removeRom:(id) sender{
	if([[romArrayController selectedObjects] count] <= 0){}
	else if([[romArrayController selectedObjects] count] == 1){
		ListManagedObject *list = [[collectionArrayController selectedObjects] objectAtIndex:0];

		if([list isKindOfClass:[SmartList class]]){}
		else{
			[romsTable lockFocus];
			int choice = NSRunAlertPanel(	NSLocalizedString(@"Delete Selected ROMs?", nil),
											NSLocalizedString(@"Are you sure you want to delete the selected ROMs?", nil),
											NSLocalizedString(@"No", nil),
											NSLocalizedString(@"Yes", nil), nil);

			if(choice == NSAlertAlternateReturn) [romArrayController remove:self];
			[romsTable unlockFocus];
		}
	}
}

- (NSArray *) getSelectedRoms{
	NSArray * selectedObjects = [romArrayController selectedObjects];

	if([selectedObjects count] > 0){
		return selectedObjects;
	}

	return [romArrayController arrangedObjects];
}

- (NSArray *) getAllRoms{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title != \"\""];
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"ROM" inManagedObjectContext:[self managedObjectContext]]];
	[fetch setPredicate:predicate];

	NSError *error = nil;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	[fetch release];

	return [results retain];
}


#pragma mark -
#pragma mark List Methods

- (IBAction)newSmartList:(id)sender{
	NSString *name = @"New Smart List";
	NSArray *lists = [collectionArrayController arrangedObjects];
	NSEnumerator *listEnumerator = [lists objectEnumerator];
	ListManagedObject *listObject;
	while((listObject = [listEnumerator nextObject])){
		if([listObject isMemberOfClass:[SmartList class]]){
			if([name isEqual:[listObject valueForKey:@"name"]]){
				[collectionArrayController setSelectedObjects:[NSArray arrayWithObject:listObject]];
				return;
			}
		}
	}

	NSManagedObjectContext *context = [self managedObjectContext];
	NSManagedObjectModel *model = [self managedObjectModel];
	NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"SmartList"];

	SmartList *sc = [[SmartList alloc] initWithEntity:desc insertIntoManagedObjectContext:context];
	[sc setValue:NSLocalizedString(@"New Smart List", nil) forKey:@"name"];

	[context lock];
	[context insertObject: sc];
	[context unlock];

	[sc release];
	[listsTable reloadData];

	[self editSmartList:sender];


}

- (IBAction) newList:(id) sender{
	NSString *name = @"New List";
	NSArray *lists = [collectionArrayController arrangedObjects];
	NSEnumerator *listEnumerator = [lists objectEnumerator];
	ListManagedObject *listObject;
	while((listObject = [listEnumerator nextObject])){
		if(![listObject isMemberOfClass:[SmartList class]]){
			if([name isEqual:[listObject valueForKey:@"name"]]){
				[collectionArrayController setSelectedObjects:[NSArray arrayWithObject:listObject]];
				return;
			}
		}
	}

	[listsTable lockFocus];
	NSManagedObjectContext *context = [self managedObjectContext];
	NSManagedObjectModel *model = [self managedObjectModel];
	NSEntityDescription *desc = [[model entitiesByName] objectForKey:@"List"];

	[context lock];
	ListManagedObject *object = [[ListManagedObject alloc] initWithEntity:desc insertIntoManagedObjectContext:context];

	NSData *icon = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list-small" ofType:@"png"]];
	[object setValue:NSLocalizedString(@"New List", nil) forKey:@"name"];
	[object setIcon:icon];

	[context insertObject:object];
	[context unlock];

	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[collectionArrayController setSortDescriptors:[NSArray arrayWithObject: sort]];
	[sort release];

	[listsTable unlockFocus];
	[listsTable reloadData];
}

- (IBAction) removeList:(id) sender{
	[[[searchTextField cell] cancelButtonCell] performClick:self];

	if([[collectionArrayController selectedObjects] count] == 1){
		ListManagedObject * list = [[collectionArrayController selectedObjects] objectAtIndex:0];

		[listsTable lockFocus];
		if([list isKindOfClass:[SmartList class]]) [collectionArrayController remove:self];
		else{
			NSMutableSet * items = [list mutableSetValueForKey:@"items"];

			if([items count] != 0){
				int choice = NSRunAlertPanel(	NSLocalizedString(@"Delete Non-Empty List?", nil),
												NSLocalizedString(@"Are you sure you want to delete this list? It still contains items.", nil),
												NSLocalizedString(@"No", nil),
												NSLocalizedString(@"Yes", nil), nil);

				if(choice == NSAlertAlternateReturn){
					[romArrayController setSelectedObjects:[romArrayController arrangedObjects]];
					[romArrayController remove:self];

					[collectionArrayController remove:self];
				}
			}
			else [collectionArrayController remove:self];
		}
		[listsTable unlockFocus];
	}
}

- (IBAction) editSmartList:(id) sender{
	NSArray *objects = [collectionArrayController selectedObjects];

	if([objects count] == 1){
		ListManagedObject *list = [objects objectAtIndex:0];

		if([list isKindOfClass:[SmartList class]]){
			[[smartListEditorWindow delegate] setPredicate:[((SmartList *)list) getPredicate]];

			[[NSApplication sharedApplication] beginSheet:smartListEditorWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:nil contextInfo:NULL];
		}
	}
}

- (IBAction) saveSmartList:(id) sender{
	NSArray * objects = [collectionArrayController selectedObjects];

	if([objects count] == 1){
		ListManagedObject * list = [objects objectAtIndex:0];

		[list willChangeValueForKey:@"items"];

		if([list isKindOfClass:[SmartList class]]){
			NSPredicate * p = [[smartListEditorWindow delegate] getPredicate];
			[((SmartList *)list) setPredicate:p];
		}

		[list didChangeValueForKey:@"items"];

		NSIndexSet * selection = [collectionArrayController selectionIndexes];

		[collectionArrayController setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
		[collectionArrayController setSelectionIndexes:selection];
	}
	[romsTable reloadData];

	[[NSApplication sharedApplication] endSheet:smartListEditorWindow];
	[smartListEditorWindow orderOut:self];
}

- (IBAction) cancelSmartList:(id) sender{
	[[NSApplication sharedApplication] endSheet:smartListEditorWindow];
	[smartListEditorWindow orderOut:self];
}

- (NSArray *) getAllLists{
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"name != \"\""];

	NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:[self managedObjectContext]]];
	[fetch setPredicate:predicate];

	NSError * error = nil;
	NSMutableArray * results = [NSMutableArray array];
	NSArray * fetchedItems = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	int i = 0;
	for(i = 0; i < [fetchedItems count]; i++){
		if(![[fetchedItems objectAtIndex:i] isKindOfClass:[SmartList class]])
			[results addObject:[fetchedItems objectAtIndex:i]];
	}

	[fetch release];

	return [results retain];
}

- (NSArray *) getAllSmartLists{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != \"\""];

	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity:[NSEntityDescription entityForName:@"SmartList" inManagedObjectContext:[self managedObjectContext]]];
	[fetch setPredicate:predicate];

	NSError * error = nil;
	NSArray *results = [[self managedObjectContext] executeFetchRequest:fetch error:&error];

	[fetch release];

	return [results retain];
}

- (ListManagedObject *) getSelectedList{
	return [[collectionArrayController selectedObjects] objectAtIndex:0];
}

- (void) setSelectedList: (ListManagedObject *) list{
	[collectionArrayController setSelectedObjects:[NSArray arrayWithObject:list]];
}

- (NSArray *) getRomlists{
	return [collectionArrayController arrangedObjects];
}

#pragma mark -
#pragma mark View / Other Methods

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key{
	if([key isEqualToString:@"selectedList"])	return YES;
	if([key isEqualToString:@"romlists"])		return YES;
	if([key isEqualToString:@"selectedRoms"])	return YES;

	return NO;
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	loadData = [[NSData dataWithContentsOfFile:filename] retain];
	[self loadDataFromOutside];
	return YES;
}

- (void) selectListsTable: (id) sender{
	[mainWindow makeFirstResponder:listsTable];
}

- (void) selectRomsTable: (id) sender{
	[mainWindow makeFirstResponder:romsTable];
}

- (void) loadDataFromOutside{
	NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
	NSString *error = nil;
	NSDictionary *metadata = [NSPropertyListSerialization propertyListFromData:loadData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];

	NSEnumerator *listEnumerator = [[collectionArrayController arrangedObjects] objectEnumerator];
	ListManagedObject *listObject;
	while((listObject = [listEnumerator nextObject])){
		NSString * name = [listObject valueForKey:@"name"];

		if([name isEqualToString:[metadata valueForKey:@"listName"]]){
			[collectionArrayController setSelectedObjects:[NSArray arrayWithObject:listObject]];
		}
	}

	NSEnumerator *romEnumerator = [[romArrayController arrangedObjects] objectEnumerator];
	RomManagedObject *romObject;
	while(romObject = [romEnumerator nextObject]){
		NSString *romid = [romObject valueForKey:@"id"];

		if([romid isEqualToString:[metadata valueForKey:@"id"]]){
			[romArrayController setSelectedObjects:[NSArray arrayWithObject:romObject]];
		}
	}
}

- (IBAction)toggleColumn:(id)sender{
	NSTableColumn *tc = nil;

	switch([sender tag]){
		case 0: tc = columnTitle; break;
		case 1: tc = columnSize; break;
		case 2: tc = columnCRC32; break;
		case 3: tc = columnMD5; break;
		case 4: tc = columnSHA1; break;
		case 5: tc = columnHave; break;
	}

	if(tc == nil){
		return;
	}

	if([sender state] == NSOffState){
		[sender setState:NSOnState];
		[romsTable addTableColumn:tc];
	}
	else{
		[sender setState:NSOffState];
		[romsTable removeTableColumn:tc];
	}
}

#pragma mark -
#pragma mark Spotlight Methods

- (IBAction) updateSpotlightIndex: (id) sender{
	[[NSApplication sharedApplication] beginSheet:fileProgressWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:nil contextInfo:NULL];

	[fileProgress setIndeterminate:YES];
	[fileProgress startAnimation:self];

	NSEnumerator *listEnumerator = [[collectionArrayController arrangedObjects] objectEnumerator];
	ListManagedObject *listObject;
	while(listObject = [listEnumerator nextObject]){
		if(![listObject isKindOfClass:[SmartList class]]){
			NSEnumerator *romEnumerator = [[listObject getRoms] objectEnumerator];
			RomManagedObject *romObject;
			while(romObject = [romEnumerator nextObject]){
				[romObject writeSpotlightFile];
			}
		}
	}
	[fileProgress stopAnimation:self];
	[[NSApplication sharedApplication] endSheet:fileProgressWindow];
	[fileProgressWindow orderOut:self];
}

- (IBAction) clearSpotlightIndex: (id) sender{
	BOOL isDir;
	NSString * path = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), @"/Library/Caches/Metadata/Lesminni"];

	NSFileManager * manager = [NSFileManager defaultManager];
	if([manager fileExistsAtPath:path isDirectory:&isDir]){
		[manager removeFileAtPath:path handler:nil];
	}
}

- (void)dealloc{
	[toolbar release];

	[columnTitle release];
	[columnSize release];
	[columnCRC32 release];
	[columnMD5 release];
	[columnSHA1 release];
	[columnHave release];

	[mainWindow release];
	[infoWindow release];

	[super dealloc];
}

@end
