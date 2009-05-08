#import "ListsTableView.h"
#import "SelectableTableView.h"
#import "LesminniAppDelegate.h"

@interface ListsTableView (Private)
- (void)_windowDidChangeKeyNotification:(NSNotification *)notification;
@end

// CoreGraphics gradient helpers
typedef struct{
	float red1, green1, blue1, alpha1;
	float red2, green2, blue2, alpha2;
} _twoColorsType;

/*
I don't see the release for _twoColorsType *twoColors =
malloc(sizeof(_twoColorsType)); in OAGradientTableView.m.
*/

void _linearColorBlendFunction(void *info, const float *in, float *out){
	_twoColorsType *twoColors = info;

	out[0] = (1.0 - *in) * twoColors->red1 + *in * twoColors->red2;
	out[1] = (1.0 - *in) * twoColors->green1 + *in * twoColors->green2;
	out[2] = (1.0 - *in) * twoColors->blue1 + *in * twoColors->blue2;
	out[3] = (1.0 - *in) * twoColors->alpha1 + *in * twoColors->alpha2;
}

void _linearColorReleaseInfoFunction(void *info){
	free(info);
}

static const CGFunctionCallbacks linearFunctionCallbacks = {0, &_linearColorBlendFunction, &_linearColorReleaseInfoFunction};

@implementation ListsTableView

- (void)autosizeRowHeight{
	NSTableColumn	* col = [[self tableColumns] objectAtIndex:0];
	NSFont			* font = [[col dataCell] font];

	[self setRowHeight:[font maximumAdvancement].height];
}

//	Gradient
//	NSObject
- (void)dealloc;{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

//	NSView
- (void)viewWillMoveToWindow:(NSWindow *)newWindow;{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidChangeKeyNotification:) name:NSWindowDidResignKeyNotification object:newWindow];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidChangeKeyNotification:) name:NSWindowDidBecomeKeyNotification object:newWindow];
}

//	NSTableView
- (void)highlightSelectionInClipRect:(NSRect)rect;{
	// Take the color apart
	NSColor *alternateSelectedControlColor = [NSColor alternateSelectedControlColor];
	float hue, saturation, brightness, alpha;
	[[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];

	// Create synthetic darker and lighter versions
	NSColor *lighterColor = [NSColor colorWithDeviceHue:hue saturation:MAX(0.0, saturation-.12) brightness:MIN(1.0, brightness+0.30) alpha:alpha];
	NSColor *darkerColor = [NSColor colorWithDeviceHue:hue saturation:MIN(1.0, (saturation > .04) ? saturation+0.12:0.0) brightness:MAX(0.0, brightness-0.045) alpha:alpha];

	// If this view isn't key, use the gray version of the dark color.
	// Note that this varies from the standard gray version that NSCell returns as its highlightColorWithFrame: when the cell is not in a
	// key view, in that this is a lot darker. Mike and I think this is justified for this kind of view -- if you're using the dark
	// selection color to show the selected status, it makes sense to leave it dark.
	NSResponder *firstResponder = [[self window] firstResponder];
	if(![firstResponder isKindOfClass:[NSView class]] || ![(NSView *)firstResponder isDescendantOf:self] || ![[self window] isKeyWindow]){
		alternateSelectedControlColor = [[alternateSelectedControlColor
		colorUsingColorSpaceName:NSDeviceWhiteColorSpace]
		colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		lighterColor = [[lighterColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		darkerColor = [[darkerColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	}

	// Set up the helper function for drawing washes
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_twoColorsType *twoColors = malloc(sizeof(_twoColorsType));
	// We malloc() the helper data because we may draw this wash during printing, in which case it won't necessarily be evaluated immediately. We need for all the data the shading function needs to draw to potentially outlive us.
	[lighterColor getRed:&twoColors->red1 green:&twoColors->green1 blue:&twoColors->blue1 alpha:&twoColors->alpha1];
	[darkerColor getRed:&twoColors->red2 green:&twoColors->green2 blue:&twoColors->blue2 alpha:&twoColors->alpha2];
	static const float domainAndRange[8] = {0.0, 0.5, 0.5, 1.0,	0.0, 0.8, 0.2, 1.0};
//	static const float domainAndRange[8] = {0.0, 1.0, 0.0, 1.0,	0.0, 1.0, 0.0, 1.0};
	CGFunctionRef linearBlendFunctionRef = CGFunctionCreate(twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);

	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	unsigned int rowIndex = [selectedRowIndexes indexGreaterThanOrEqualToIndex:0];

	while(rowIndex != NSNotFound){
		unsigned int endOfCurrentRunRowIndex, newRowIndex = rowIndex;
		do{
			endOfCurrentRunRowIndex = newRowIndex;
			newRowIndex = [selectedRowIndexes
			indexGreaterThanIndex:endOfCurrentRunRowIndex];
		}
		while(newRowIndex == endOfCurrentRunRowIndex + 1);

		NSRect rowRect = NSUnionRect([self rectOfRow:rowIndex],
		[self rectOfRow:endOfCurrentRunRowIndex]);

		NSRect topBar, washRect;
		NSDivideRect(rowRect, &topBar, &washRect, 1.0, NSMinYEdge);

		// Draw the top line of pixels of the selected row in the alternateSelectedControlColor
		[alternateSelectedControlColor set];
		NSRectFill(topBar);

		// Draw a soft wash underneath it
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState(context); {
			CGContextClipToRect(context, (CGRect){{NSMinX(washRect), NSMinY(washRect)}, {NSWidth(washRect), NSHeight(washRect)}});
			CGShadingRef cgShading = CGShadingCreateAxial(colorSpace, CGPointMake(0, NSMinY(washRect)), CGPointMake(0, NSMaxY(washRect)), linearBlendFunctionRef, NO, NO);
			CGContextDrawShading(context, cgShading);
			CGShadingRelease(cgShading);
		} CGContextRestoreGState(context);

		rowIndex = newRowIndex;
	}
	CGFunctionRelease(linearBlendFunctionRef);
	CGColorSpaceRelease(colorSpace);
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend;{
	[super selectRow:row byExtendingSelection:extend];
	[self setNeedsDisplay:YES]; // we display extra because we draw multiple contiguous selected rows differently, so changing one row's selection can change how others draw.
}

- (void)deselectRow:(int)row;{
	[super deselectRow:row];
	[self setNeedsDisplay:YES]; // we display extra because we draw multiple contiguous selected rows differently, so changing one row's selection can change how others draw.
}

// NSTableView (Private)
- (id)_highlightColorForCell:(NSCell *)cell;{
	return nil;
}

- (void)drawRow:(int)rowIndex clipRect:(NSRect)clipRec{
	NSRange columnsToFixTextColorIn = [self columnsInRect:clipRec];
	NSColor* newTextColor = ([[self selectedRowIndexes] containsIndex:rowIndex]) ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];

	int i;
	for(i = columnsToFixTextColorIn.location; i < columnsToFixTextColorIn.location + columnsToFixTextColorIn.length; i++){
		NSCell* rowCell = [[[self tableColumns] objectAtIndex:i] dataCellForRow:rowIndex];
		if([rowCell isKindOfClass:[NSTextFieldCell class]]){
			[(NSTextFieldCell*)rowCell setTextColor:newTextColor];
		}
	}
	[super drawRow:rowIndex clipRect:clipRec];
}

@end

@implementation SelectableTableView (Private)

- (void)_windowDidChangeKeyNotification:(NSNotification *)notification;{
	[self setNeedsDisplay:YES];
}

@end
