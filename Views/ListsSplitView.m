//  This subclass of KFSplitView (by Ken Ferry) sets up the main split view with special attributes:
//	- the vertical splitter next to the source list remembers where it was last left
//	- sets the splitter thickness to 1 pixel and draws it as a solid gray line
//	- constrains the minimum sizes for both the source list and the right side of the splitter

#define MIN_LEFT_VIEW_WIDTH 120
#define MIN_RIGHT_VIEW_WIDTH 450

#import "ListsSplitView.h"

@implementation ListsSplitView

- (void)awakeFromNib{
	[super awakeFromNib];
	[self setDelegate:self];
	leftSubview = [[self subviews] objectAtIndex:0];
	rightSubview = [[self subviews] objectAtIndex:1];
}

- (float)dividerThickness{
	return 1.0;
}

- (void)drawDividerInRect:(NSRect)aRect{
	[[NSColor lightGrayColor] set];
	NSRectFill (aRect);
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset{
	return (proposedMin + MIN_LEFT_VIEW_WIDTH);
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset{
	return (proposedMax - MIN_RIGHT_VIEW_WIDTH);
}

- (void)splitView:(id)sender resizeSubviewsWithOldSize:(NSSize)oldSize{
	float newHeight = [sender frame].size.height;
	float newWidth = [sender frame].size.width - [leftSubview frame].size.width - [self dividerThickness];

	NSRect newFrame = [leftSubview frame];
	newFrame.size.height = newHeight;
	[leftSubview setFrame:newFrame];

	newFrame = [rightSubview frame];
	newFrame.size.width = newWidth;
	newFrame.size.height = newHeight;
	[rightSubview setFrame:newFrame];

	[sender adjustSubviews];
}

@end
