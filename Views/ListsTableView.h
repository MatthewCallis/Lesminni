
#import <Cocoa/Cocoa.h>
#import "SelectableTableView.h"

@interface ListsTableView : SelectableTableView{}

void _linearColorBlendFunction(void *info, const float *in, float *out);
void _linearColorReleaseInfoFunction(void *info);

- (void)autosizeRowHeight;

@end
