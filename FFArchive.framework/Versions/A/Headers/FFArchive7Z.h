
#import "FFArchive.h"

#define _LZMA_UINT32_IS_ULONG

#import "7zIn.h"
#import "7zCrc.h"
#import "7zDecode.h"

@interface FFArchive7Z : FFArchive{
	BOOL			m_encrypted;
}

typedef struct _CFileInStream{
	ISzInStream InStream;
	FILE *File;
} CFileInStream;

typedef struct FileData{
	int fp;
	int size;
	NSString *origName;
} FileData;

- (NSArray*)filesInArchive;
- (void)extractFile:(NSString*)filename toFilePath:(NSString*)toPath;

@end
