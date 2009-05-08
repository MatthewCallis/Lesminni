
#import <Cocoa/Cocoa.h>
#import "ListsTextCell.h"

@implementation ListsTextCell

- (id) init{
	self = [super init];
	if(self != nil){
		[self setWraps:NO];  // Important so the text doesn't wrap during editing.
	}
	return self;
}

- (void)dealloc{
	[self setDataDelegate: nil];
	[self setIconKeyPath: nil];
	[self setPrimaryTextKeyPath: nil];
	[self setSecondaryTextKeyPath: nil];

	delegate = nil;
	iconKeyPath = nil;
	primaryTextKeyPath = nil;
	secondaryTextKeyPath = nil;
	[super dealloc];
}

- copyWithZone:(NSZone *)zone{
	ListsTextCell *cell = (ListsTextCell *)[super copyWithZone:zone];
	cell->delegate = nil;
	[cell setDataDelegate: delegate];
	return cell;
}

- (void) setIconKeyPath: (NSString*) path{
	[iconKeyPath autorelease];
	iconKeyPath = [path retain];
}

- (void) setPrimaryTextKeyPath: (NSString*) path{
	[primaryTextKeyPath autorelease];
	primaryTextKeyPath = [path retain];
}

- (void) setSecondaryTextKeyPath: (NSString*) path{
	[secondaryTextKeyPath autorelease];
	secondaryTextKeyPath = [path retain];
}

- (void) setDataDelegate: (NSObject*) aDelegate{
	[aDelegate retain];
	[delegate autorelease];
	delegate = aDelegate;
}

- (id) dataDelegate{
	if(delegate) return delegate;
	return self; // in case there is no delegate we try to resolve values by using key paths
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	[controlView lockFocus];

	NSObject* data = [self objectValue];

	// give the delegate a chance to set a different data object
	if([[self dataDelegate] respondsToSelector: @selector(dataElementForCell:)]){
		data = [[self dataDelegate] dataElementForCell:self];
	}

	// Set up the font attributes for the name/title string
	NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithDictionary:[[self attributedStringValue] attributesAtIndex:0 effectiveRange:NULL]];
	[attrs setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];

	cellFrame.size.width += 2;  // Added this to get it to draw the full width of the object properly. -DB

	if([self isHighlighted]){
		// If this line is selected, we want a bold white font.
		NSFont *font = [attrs objectForKey:@"NSFont"];
		NSFont *newFont = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
		[attrs setValue:newFont forKey:@"NSFont"];
		[attrs setValue:[NSColor whiteColor] forKey:@"NSColor"];
	}

//	Name Title Text
	NSString *primaryText = [[self dataDelegate] primaryTextForCell:self data: data];
	float width = cellFrame.size.width-50;	// adjust the space from the left edge so we dont overlap the count
	NSString *displayString = [self truncateString:primaryText
									forWidth:width
									andAttributes:attrs];
	[displayString drawAtPoint:NSMakePoint(cellFrame.origin.x+cellFrame.size.height+0, cellFrame.origin.y+0) withAttributes: attrs];

//	Secondary Text (Item Count), A Little Messy, but it works very well
	NSString* secondaryText = [[self dataDelegate] secondaryTextForCell:self data: data];
	float centered = 18.0+(3.0*[secondaryText length]);
	[secondaryText drawAtPoint:NSMakePoint(cellFrame.size.width-centered, cellFrame.origin.y+0) withAttributes: attrs];

//	List Icon
	[[NSGraphicsContext currentContext] saveGraphicsState];
	float yOffset = cellFrame.origin.y;
	if([controlView isFlipped]){
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy: cellFrame.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];
		yOffset = 0-cellFrame.origin.y;
	}	

	NSImage* icon = [[self dataDelegate] iconForCell:self data: data];

	NSImageInterpolation interpolation = [[NSGraphicsContext currentContext] imageInterpolation];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];

	[icon drawInRect:NSMakeRect(cellFrame.origin.x+0,yOffset+1, [icon size].width, [icon size].height)
		fromRect:NSMakeRect(0,0,[icon size].width, [icon size].height)
		operation:NSCompositeSourceOver
		fraction:1.0];

	[[NSGraphicsContext currentContext] setImageInterpolation: interpolation];
	[[NSGraphicsContext currentContext] restoreGraphicsState];

//	NSRect inset = [self drawingRectForBounds:cellFrame];
//	inset.origin.x += 2; // Nasty to hard-code this. Can we get it to draw its own content, or determine correct inset?
//	float width = inset.size.width;
//	NSString *displayString = [self truncateString:[self stringValue]
//									forWidth:width
//									andAttributes:attrs];
//	[displayString drawAtPoint:inset.origin withAttributes:attrs];

	[controlView unlockFocus];
}

// Not from Matt's class. Added this later. -DB
- (NSString*)truncateString:(NSString *)string forWidth:(double) inWidth andAttributes:(NSDictionary*)inAttributes{
	unichar  ellipsesCharacter = 0x2026;
	NSString* ellipsisString = [NSString stringWithCharacters:&ellipsesCharacter length:1];

	NSString* truncatedString = [NSString stringWithString:string];
	int truncatedStringLength = [truncatedString length];

	if((truncatedStringLength > 2) && ([truncatedString sizeWithAttributes:inAttributes].width > inWidth)){
		double targetWidth = inWidth - [ellipsisString sizeWithAttributes:inAttributes].width;
		NSCharacterSet* whiteSpaceCharacters = [NSCharacterSet whitespaceAndNewlineCharacterSet];

		while([truncatedString sizeWithAttributes:inAttributes].width > targetWidth && truncatedStringLength){
			truncatedStringLength--;
			while([whiteSpaceCharacters characterIsMember:[truncatedString characterAtIndex:(truncatedStringLength -1)]]){
				// never truncate immediately after whitespace
				truncatedStringLength--;
			}
			truncatedString = [truncatedString substringToIndex:truncatedStringLength];
		}
		truncatedString = [truncatedString stringByAppendingString:ellipsisString];
	}
	return truncatedString;
}

//	This method is from Red Sweater Software's RSVerticallyCenteredTextField class.
//  It was not part of the original SourceListTableView routines from Matt Gemmell.
//  Created by Daniel Jalkut on 6/17/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//	MIT License
- (NSRect)drawingRectForBounds:(NSRect)theRect{
	// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];

	// When the text field is being edited or selected, we have to turn off the magic because it screws up the configuration of the field editor.  We sneak around this by intercepting selectWithFrame and editWithFrame and sneaking a reduced, centered rect in at the last minute.
	if(mIsEditingOrSelecting == NO){
		// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];

		// Center that in the proposed rect
		float heightDelta = newRect.size.height - textSize.height;	
		if(heightDelta > 0) {
			newRect.size.height -= heightDelta;
			newRect.origin.y += (heightDelta / 2);
		}
		newRect.size.width -= 1;
	}
	return newRect;
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength{
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;	
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	mIsEditingOrSelecting = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent{
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
	mIsEditingOrSelecting = NO;
}

#pragma mark - 
#pragma mark Delegate methods

- (NSImage*) iconForCell: (ListsTextCell*) cell data: (NSObject*) data{
	if(iconKeyPath) return [data valueForKeyPath: iconKeyPath];

	return nil;
}

- (NSString*) primaryTextForCell: (ListsTextCell*) cell data: (NSObject*) data{
	if(primaryTextKeyPath) return [data valueForKeyPath: primaryTextKeyPath];

	return nil;
}

- (NSString*) secondaryTextForCell: (ListsTextCell*) cell data: (NSObject*) data{
	if(secondaryTextKeyPath) return [data valueForKeyPath: secondaryTextKeyPath];

	return nil;
}

@end
