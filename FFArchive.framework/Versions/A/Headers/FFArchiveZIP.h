// $Id: FFArchiveZIP.h 541 2006-08-20 13:47:14Z ravemax $

#import "FFArchive.h"

@interface FFArchiveZIP : FFArchive {
	NSMutableArray*	m_corruptNames[2]; // 0=Filename w/ encoding, 1=original data
	BOOL			m_encrypted;
}

- (id)initWithFile:(NSString*)filePath fallbackEncoding:(NSStringEncoding)enc;
- (NSArray*)filesInArchive;
- (void)extractFile:(NSString*)filename toFilePath:(NSString*)toPath;

@end
