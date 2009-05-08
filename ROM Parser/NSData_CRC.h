//
//  NSData_CRC.h
//  MausX
//
// CRC algorithms for 16, 32 and 64 bit widths
//
// Put together by Arne Schween, Peter N. Lewis, Matthew Dillon and Thomas Tempelmann
//
// Be aware that there's not just only one correct CRC calculation for a given
// bit width, but many possible ones! However, most applications use some common
// calculation algorithms & parameters.
// This implementation attempts to implement the most popular ones.
//
// For more information about CRC algorithms, see: http://www.repairfaq.org/filipg/LINK/F_crc_v3.html
//
//  Wrapped in an NSData Category by Andreas on Tue Dec 16 2003.

#import <Foundation/Foundation.h>

@interface NSData(CRC)

- (NSData *)md5;
- (NSData *)sha1;

- (unsigned long)snesChecksum;

- (unsigned int)crc16;
- (unsigned long)crc32;
- (unsigned long long)crc64;

- (BOOL)containsData:(NSData *)data;

@end
