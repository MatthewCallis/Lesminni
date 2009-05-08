//  Copyright 2006 by Dave Batton. Some rights reserved.
//  http://creativecommons.org/licenses/by/2.5/
//  This class draws a horizontal splitter like the one seen in Apple Mail (Tiger), below the message list and above the message detail view. It subclasses KFSplitView from Ken Ferry so that the splitter remembers where it was last left. It also allows the splitter to expand and collapse when double-clicked. The splitter thickness is reduced a bit and a background image and dimple are drawn in the splitter.
//  Assumes the DBListSplitViewBar and DBListSplitViewDimple images are available.

#define MIN_TOP_VIEW_HEIGHT 90
#define MIN_BOTTOM_VIEW_HEIGHT 60

#import "ContentSplitView.h"

@implementation ContentSplitView

-(void)awakeFromNib{
	[self setDelegate:self];
	bottomSubview = [[self subviews] objectAtIndex:1];

	bar = [NSImage imageNamed:@"splitview-bar.png"];
	[bar setFlipped:YES];

	grip = [NSImage imageNamed:@"splitview-dot.png"];
	[grip setFlipped:YES];
}

- (float)dividerThickness{
	return (8);
}

- (void)drawDividerInRect:(NSRect)aRect{
	// Create a canvas
	NSImage *canvas = [[[NSImage alloc] initWithSize:aRect.size] autorelease];

	// Draw bar and grip onto the canvas
	NSRect canvasRect = NSMakeRect(0, 0, [canvas size].width, [canvas size].height);
	NSRect gripRect = canvasRect;
	gripRect.origin.x = (NSMidX(canvasRect) - ([grip size].width/2));
	gripRect.origin.y = (NSMidY(canvasRect) - ([grip size].height/2));
	[canvas lockFocus];
	[bar setSize:aRect.size];
	[bar drawInRect:canvasRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[grip drawInRect:gripRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[canvas unlockFocus];

	// Draw canvas to divider bar
	[self lockFocus];
	[canvas drawInRect:aRect fromRect:canvasRect operation:NSCompositeSourceOver fraction:1.0];
	[self unlockFocus];
}

#pragma mark -
#pragma mark KFSplitView Delegate Methods

- (void)splitView:(id)sender didDoubleClickInDivider:(int)index{
	BOOL currentState;

	switch(index){
		case 0:
			currentState = [self isSubviewCollapsed:bottomSubview];
			[self setSubview:bottomSubview isCollapsed:!currentState];
			[self resizeSubviewsWithOldSize:[self bounds].size];
			break;
	}
}

- (float)splitView:(id)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset{
	return proposedMax - MIN_BOTTOM_VIEW_HEIGHT;  // How close the splitter can get to the bottom.
}

- (float)splitView:(id)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset{
	return proposedMin + MIN_TOP_VIEW_HEIGHT;  // How close the splitter can get to the top.
}

- (BOOL)splitView:(id)sender canCollapseSubview:(NSView *)subview{
	return (subview == bottomSubview);
}

// This delegate method is mostly copied from the KFSplitView example application. It allows the subview to collapse and then expand to its original position when double-clicked a second time.
- (void)splitView:(id)sender resizeSubviewsWithOldSize:(NSSize)oldSize{
	// It's our responsibility to set the frame rectangles of all uncollapsed subviews.
	int i, numSubviews, numDividers;
	float heightTotal, splitViewWidth, splitViewHeight, newSubviewHeight;
	float curYAxisPos, dividerThickness, scaleFactor, availableSpace;
	float minimumFirstSubviewHeight;
	id subview, subviews;

	// setup
	subviews = [sender subviews];
	numSubviews = [subviews count];
	numDividers = numSubviews - 1;
	splitViewWidth = [sender frame].size.width;
	splitViewHeight = [sender frame].size.height;
	dividerThickness = [sender dividerThickness];

	minimumFirstSubviewHeight = 90;

	// tabulate the total space taken up by uncollapsed subviews other than the first
	heightTotal = 0;
	for(i = 1; i < numSubviews; i++){
		subview = [subviews objectAtIndex:i];
		if(![sender isSubviewCollapsed:subview]) heightTotal += [subview frame].size.height;
	}

	// if the uncollapsed subviews (not counting the first) take up too much space then we have to scale them
	availableSpace = splitViewHeight - minimumFirstSubviewHeight - numDividers*dividerThickness;
	if (heightTotal > availableSpace){
		if(availableSpace < 0){
			scaleFactor = 0;
		}
		else{
			scaleFactor = availableSpace / heightTotal;
		}
	}
	else{
		scaleFactor = 1;
	}

	// we walk up the Y-axis, setting subview frames as we go
	curYAxisPos = splitViewHeight;
	for (i = numSubviews - 1; i >0; i--){
		subview = [subviews objectAtIndex:i];
		if(![sender isSubviewCollapsed:subview]){
			// expanded subviews need to have their origin set correctly and their size scaled.
			newSubviewHeight = floor([subview frame].size.height*scaleFactor);
			curYAxisPos -= newSubviewHeight;
			[subview setFrame:NSMakeRect(0, curYAxisPos, splitViewWidth, newSubviewHeight)];
		}
		// account for the divider taking up space
		curYAxisPos -= dividerThickness;
	}

	// the first subview subview's height is whatever's left over
	subview = [subviews objectAtIndex:0];
	[subview setFrame:NSMakeRect(0, 0, splitViewWidth, curYAxisPos)];

	// if we wanted error checking, we could call adjustSubviews.  It would only change something if we messed up and didn't really tile the split view correctly.

	// [sender adjustSubviews];
}

@end
