
#import <Cocoa/Cocoa.h>

@interface LesminniToolbarItem : NSToolbarItem{
	BOOL enableBool;
	SEL itemAction;
}

- (void) setEnabled:(BOOL) enable;
- (BOOL) isEnabled;

@end
