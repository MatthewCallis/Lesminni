
#import <Cocoa/Cocoa.h>
#import "ListManagedObject.h"

@interface RomManagedObject : NSManagedObject{
}

- (void) didChangeValueForKey: (NSString *) key;

- (NSString *) getObjectIdString;

- (void) setList: (ListManagedObject *) newList;
- (NSString *) getListName;
- (void) writeSpotlightFile;

- (NSObject *) customValueForKey:(NSString *) key;

- (void) setValueFromString:(NSString *) valueString forKey:(NSString *) key replace:(BOOL) doReplace;

- (NSString *) getTitle;
- (NSString *) getSize;
- (NSString *) getCRC;
- (NSString *) getSHAOne;
- (NSString *) getMD5;
- (NSString *) getCountry;
- (NSString *) getFormat;
- (NSString *) getGameCode;
- (NSString *) getGenre;
- (NSString *) getSummary;
- (NSString *) getSaveSize;


@end
