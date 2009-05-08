
#import <Cocoa/Cocoa.h>

@interface SmartListRuleView : NSView {
	IBOutlet NSPopUpButton * field;
	IBOutlet NSPopUpButton * operation;
	IBOutlet NSTextField * value;
}

- (NSPredicate *) getPredicate;
- (void) setPredicate: (NSPredicate *) predicate;

@end
