#import <Cocoa/Cocoa.h>

@interface RomFileReader : NSObject{
	NSString *_fullPath;
	NSMutableDictionary	*_metadata;
}

+ (RomFileReader *)	parseFile:(NSString *)fullPath;

- (id) initWithFile:(NSString *)fullPath;

- (void) readMetadata;

@end
