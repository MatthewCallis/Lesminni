
#import "LesminniToolbarItem.h"

@implementation LesminniToolbarItem

- (LesminniToolbarItem *) initWithItemIdentifier: (NSString *) itemIdentifier{
	self = [super initWithItemIdentifier:itemIdentifier];
	enableBool = YES;

	return self;
}

- (void) setEnabled:(BOOL) enable{
	enableBool = enable;

	if(!enableBool) [self setAction:itemAction];
	else{
		itemAction = [self action];
		[self setAction:nil];
	}
}

- (BOOL) isEnabled{
	return enableBool;
}

@end
