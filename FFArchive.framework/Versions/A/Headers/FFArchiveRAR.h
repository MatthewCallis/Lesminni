// $Id: FFArchiveRAR.h,v 1.2 2004/07/11 14:09:26 ravemax Exp $

#import "FFArchive.h"

@interface FFArchiveRAR : FFArchive

- (NSArray*)filesInArchive;
- (void)extractFile:(NSString*)filename toFilePath:(NSString*)toPath;

@end
