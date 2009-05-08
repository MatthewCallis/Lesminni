//  CopyNES.h
//  Lesminni
//  Created by Matthew Callis on 7/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface CopyNES : NSObject {
	NSWindow *runLog;
	BOOL isPlaying;
}

/* Interface */
- (IBAction) getNesInfo:(id)sender;
- (IBAction) getPluginData:(id)sender;

/* Input / Output (IO) */
-(BOOL) writeByte:(char)data;
-(BOOL) writeBlock:(char *)blockdata size:(int)size;
-(BOOL) readByte:(char *)data;
-(BOOL) readByteReady;
-(BOOL) openPort;
-(void) initPort;
-(void) closePort;
-(void) resetNES:(int)resetType;
-(BOOL) writeCommand:(char)a two:(char)b three:(char)c four:(char)d five:(char)e;
-(BOOL) loadPlugin:(NSString *)plugin;
-(BOOL) runCode;

/* Misc. */
-(void) nesInfo;
-(void) playCart;

@end
