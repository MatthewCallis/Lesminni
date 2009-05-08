#import "SmartListWindowDelegate.h"
#import "SmartListRuleView.h"

@implementation SmartListWindowDelegate

- (NSPredicate *) getPredicate{
	NSArray * ruleViews = [[rulesBox contentView] subviews];
	NSMutableArray * predicates = [NSMutableArray array];

	int i = 0;
	for(i = 0; i < [ruleViews count]; i++){
		SmartListRuleView *view = (SmartListRuleView *) [ruleViews objectAtIndex:i];
		NSComparisonPredicate *p = (NSComparisonPredicate *) [view getPredicate];

		if(p != nil) [predicates addObject:p];
	}

	if([predicates count] == 0) return nil;

	if([[joiner titleOfSelectedItem] isEqualToString:NSLocalizedString(@"Any", nil)])
		return [[NSCompoundPredicate orPredicateWithSubpredicates:predicates] retain];
	else
		return [[NSCompoundPredicate andPredicateWithSubpredicates:predicates] retain];
}

- (void) resetViews{
	NSArray * ruleViews = [[rulesBox contentView] subviews];

	int i = 0;
	for(i = 0; i < [ruleViews count]; i++){
		SmartListRuleView * view = (SmartListRuleView *) [ruleViews objectAtIndex:i];
		[view setPredicate:nil];
	}
}

- (void) setPredicate: (NSPredicate *) predicate{
	NSCompoundPredicate * compPredicate = nil;

	if(![predicate isKindOfClass:[NSCompoundPredicate class]] && predicate != nil)
		compPredicate = (NSCompoundPredicate *) [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObject:predicate]];
	else
		compPredicate = (NSCompoundPredicate *) predicate;

	[self resetViews];

	if(predicate == nil) return;

	NSArray * ruleViews = [[rulesBox contentView] subviews];
	NSArray * subs = [compPredicate subpredicates];

	if([subs count] == 1){
		SmartListRuleView * view = (SmartListRuleView *) [ruleViews objectAtIndex:0];
		[view setPredicate:compPredicate];
	}
	else{
		int i = 0;
		for(i = 0; i < [subs count]; i++){
			SmartListRuleView * view = (SmartListRuleView *) [ruleViews objectAtIndex:i];
			NSComparisonPredicate * p = [subs objectAtIndex:i];

			[view setPredicate:p];
		}
	}

	if([compPredicate compoundPredicateType] == NSAndPredicateType)
		[joiner selectItemWithTitle:NSLocalizedString(@"All", nil)];
	else
		[joiner selectItemWithTitle:NSLocalizedString(@"Any", nil)];
}

@end
