
#import <Cocoa/Cocoa.h>

@interface SmartListWindowDelegate : NSObject{
	IBOutlet id joiner;
	IBOutlet id rulesBox;
}

- (NSPredicate *) getPredicate;
- (void) setPredicate: (NSPredicate *) predicate;

@end
