// $Id: FFArchive.h 541 2006-08-20 13:47:14Z ravemax $

@protocol FFArchiveHelper

- (NSString*)getPasswordForFilename:(NSString*)filename;

@end

#pragma mark -

// Keys for the dictionaries returned by "filesInArchive"
extern NSString*	FFFilename; // type: NSString*
extern NSString*	FFCompressedFileSize; // type: unsigned long long
extern NSString*	FFUncompressedFileSize; // = NSFileSize
extern NSString*	FFFileCreationDate; // = NSFileCreationDate
extern NSString*	FFEncrypted; // type: bool - TRUE=encrypted

@interface FFArchive : NSObject {
	NSString*			m_filePath;
	NSStringEncoding	m_encoding;
	NSString*			m_password;
}

+ (void)setHelper:(id<FFArchiveHelper>)hlp;

// May return 'nil' if the filetype could not be determined
// Important: No autorelease!
+ (id)archiveWithFile:(NSString*)filePath fallbackEncoding:(NSStringEncoding)enc;

- (id)initWithFile:(NSString*)filePath fallbackEncoding:(NSStringEncoding)enc;
- (NSString*)filePath;

- (NSArray*)filesInArchive;
- (void)extractFile:(NSString*)filename toFilePath:(NSString*)toPath;

// Internal, shared methods
- (const char*)_getPassword;

@end
