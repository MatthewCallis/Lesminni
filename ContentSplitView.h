
#import <Cocoa/Cocoa.h>
#import "KFSplitView.h"

@interface ContentSplitView : KFSplitView {
	NSImage *bar;
	NSImage *grip;
	id bottomSubview;
}

@end
