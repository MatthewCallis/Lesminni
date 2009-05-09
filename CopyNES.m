//  CopyNES.m
//  Lesminni
//  Created by Matthew Callis on 7/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.

#import "CopyNES.h"
#import "ftd2xx.h"
#include <time.h>

#define	RESET_COPYMODE	0
#define	RESET_PLAYMODE	1
#define	RESET_ALTPORT	2
#define	RESET_NORESET	4
#define	SLEEP_SHORT		100
#define	SLEEP_LONG		1000

FT_HANDLE ftHandleA;	// DATA BUS
FT_HANDLE ftHandleB;	// CONTROL BUS
FT_STATUS ftStatus;		// STATUS

char ROMstring[256];
char RxBuffer[64];
char TxBuffer[64];

@implementation CopyNES

/* Interface */
- (IBAction) getNesInfo:(id) sender{
	NSLog(@"CopyNES Booting...");
	[self openPort];
	[self resetNES:0];
	[self nesInfo];
}

- (IBAction) getPluginData:(id) sender{
	NSLog(@"CopyNES Plugin Test...");
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath: [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"NROM.bin"]];
	NSData *pluginBuffer = [fileHandle readDataToEndOfFile];
	NSLog(@"Plugin Data: %@", [pluginBuffer description]);
}

/* Input / Output (IO) */
-(BOOL) writeByte:(char) data{
	DWORD BytesWritten = 0;

	FT_SetTimeouts(ftHandleA, 10000, 0);
	TxBuffer[0] = data;

	ftStatus = FT_Write(ftHandleA, TxBuffer, 1, &BytesWritten);
	NSLog(@"Write Status: %i / %i", ftStatus, FT_OK);
	if(ftStatus == FT_OK){
		if(BytesWritten == 1){
			NSLog(@"Write Success!");
			// FT_Read OK
			return TRUE;
		} 
		else{
			// FT_Write Timeout 
			NSLog(@"USB Error: Write Timeout");
			return FALSE;
		}
	}
	else{
		// FT_Write Failed
		NSLog(@"FT STATUS = %i", ftStatus);
		NSLog(@"USB Error: Write Failed");
		return FALSE;
	}
}

-(BOOL)writeBlock:(char *)blockdata size:(int)size;{
	DWORD BytesWritten = 0;
	FT_SetTimeouts(ftHandleA, 10000, 0);

	ftStatus = FT_Write(ftHandleA, blockdata, size, &BytesWritten);
	if(ftStatus == FT_OK){
		if(BytesWritten == size){
			// FT_Read OK
			NSLog(@"Write Success!");
			return TRUE;
		}
		else{
			// FT_Write Timeout
			NSLog(@"USB Error: Write Timeout");
			return FALSE;
		}
	}
	else{
		// FT_Write Failed 
		NSLog(@"FT STATUS = %i", ftStatus);
		NSLog(@"USB Error: Write Failed");
		return FALSE;
	}
}


-(BOOL) readByte:(char *) data;{
	DWORD BytesReceived = 0;

	FT_SetTimeouts(ftHandleA, 10000, 0);
	ftStatus = FT_Read(ftHandleA, RxBuffer, 1, &BytesReceived);
	if(ftStatus == FT_OK){
		if(BytesReceived == 1){
			// FT_Read OK 
			NSLog(@"Read Success");
			*data = RxBuffer[0];
			return TRUE;
		} 
		else{ 
			// FT_Read Timeout 
			NSLog(@"USB Error: Read Timeout");
			return FALSE;
		}
	} 
	else{
		// FT_Read Failed
		NSLog(@"USB Error: Read Failed");
		return FALSE;
	} 
}

-(BOOL) readByteReady;{
	DWORD EventDWord = 0;
	DWORD RxBytes = 0;
	DWORD TxBytes = 0;

	FT_GetStatus(ftHandleA, &RxBytes, &TxBytes, &EventDWord);
	if(RxBytes > 0)	return TRUE;
	else			return FALSE;
}

-(BOOL) openPort{
	ftStatus = FT_OpenEx("USB CopyNES A", FT_OPEN_BY_DESCRIPTION, &ftHandleA); //open data bus
	if(ftStatus == FT_OK){
		// success - device open 
		NSLog(@"OpenEX1 passed!");
	}
	else{
		// failure - one or both of the devices has not been opened 
		NSLog(@"USB Error: Open USB CopyNES A Failed!");
		return FALSE;
	}

	ftStatus = FT_OpenEx("USB CopyNES B", FT_OPEN_BY_DESCRIPTION,&ftHandleB); //open control bus
	if(ftStatus == FT_OK){
		// success - device open 
		NSLog(@"OpenEX2 passed");
	} 
	else{
		NSLog(@"USB Error: Open USB CopyNES B Failed!");
		// failure - one or both of the devices has not been opened 
		return FALSE;
	}
	return TRUE;
}

-(void) initPort{
	DWORD modemWord = 0;
	ftStatus = FT_GetModemStatus(ftHandleB, &modemWord);
	if(ftStatus == FT_OK){
		// success - status received
		NSLog(@"GetModemStatus passed");
		if(modemWord && 0x80){
			NSLog(@"NES is OFF - turn on then hit OK");
		}
		else{
			NSLog(@"NES is ON");
		}
	}
	else{
		NSLog(@"USB Error: Get Power Status Failed!");
		// failure
		return;
	}

	// flush receive/transmit buffers
	ftStatus = FT_Purge (ftHandleA, FT_PURGE_RX | FT_PURGE_TX);
	if(ftStatus == FT_OK){
		// success - buffers empty
		NSLog(@"Purge A passed");
	}
	else{
		NSLog(@"USB Error: Purge A Failed!");
		// failure
		return;
	}
	ftStatus = FT_Purge (ftHandleB, FT_PURGE_RX | FT_PURGE_TX);
	if(ftStatus == FT_OK){ 
		// success - buffers empty
		NSLog(@"Purge B passed");
	}
	else{
		NSLog(@"USB Error: Purge B Failed!");
		// failure
	}
}

-(void) closePort{
	FT_Close(ftHandleA);
	FT_Close(ftHandleB);
}

-(void) resetNES:(int)resetType;{
	if(resetType & RESET_PLAYMODE){
		//clr /RTS=1
		ftStatus = FT_ClrRts(ftHandleB);
		if(ftStatus == FT_OK){} // FT_ClrRts OK
		else{
			// FT_ClrRts failed
			NSLog(@"USB Error: ClrRts Failed!");
			return;
		}
	}
	else{
		//set /RTS=0
		ftStatus = FT_SetRts(ftHandleB);

		if(ftStatus == FT_OK){}	// FT_SetRts OK
		else{ 
			NSLog(@"USB Error: SetRts Failed!");
			return;
			//FT_SetRts failed
		}
	}
	if(!(resetType & RESET_NORESET)){
		// pull /RESET lowclear D2

		//set /dtr=0
		ftStatus = FT_ClrDtr(ftHandleB);
		if(ftStatus == FT_OK){} // OK
		else{
			// failed 
			NSLog(@"USB Error: ClrDtr Failed!");
			return;
		}
//		Sleep(SLEEP_SHORT);
	}

	// pull /RESET high		set D2
	// clr /dtr=1
	ftStatus = FT_SetDtr(ftHandleB);
	if(ftStatus == FT_OK){} //OK
	else{
		NSLog(@"USB Error: SetDtr Failed!");
		return;
	}
//	Sleep(SLEEP_SHORT);
	[self initPort];
//	Sleep(SLEEP_SHORT);
}

-(BOOL) writeCommand:(char)a two:(char)b three:(char)c four:(char)d five:(char)e;{
	if([self writeByte: a] && [self writeByte: b] && [self writeByte: c] && [self writeByte: d] && [self writeByte: e])
		return TRUE;
	else{
		NSLog(@"USB Error: Timeout on data transfer!");
		return FALSE;
	}
}

-(BOOL) loadPlugin:(NSString *)plugin;{
//	NSData *pluginData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plugin ofType:@"png"]];
	int w;
	char pluginBytes;
	NSData *pluginBuffer;

	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Plugins/%@", plugin] ofType:@"bin"]];
	[fileHandle seekToFileOffset:128];
	pluginBuffer = [fileHandle readDataOfLength:1024];
	[pluginBuffer getBytes:&pluginBytes];
	[pluginBuffer getBytes:&ROMstring];

	// Write to CPU space
	if(![self writeCommand:0x4B two:0x00 three:0x04 four:0x04 five:0xB4]){
		// failed to load plugin
		return FALSE;
	}

	BOOL status = [self writeBlock:&pluginBytes size:1024];
	if(!status){
		return FALSE;
	}

//	for(w = 0; sizeof(pluginBytes); w++)
//		&ROMstring[w] = pluginBytes[w];
	ROMstring[w] = 0;
//	StatusPercent(0);
//	Sleep(SLEEP_SHORT);

	return TRUE;
}

-(BOOL) runCode{
	return [self writeCommand:0x7E two:0x00 three:0x04 four:0x00 five:0xE7];
}

/* Dumping */
-(BOOL) dumpCart;{
	NSString *selectedPlugin;
	NSString *fileExtension;
//	NSString *outputFilename;
	NSSavePanel *selectOutput = [NSSavePanel savePanel];
//	NSString *resultUrl;

//	int dtype = 2;
	int rbyte = 0;
	int rcount = 0;

	int cmode;
	int battery;
	int bytes;
	int numk;

	char ctype;
	WORD nblks;
//	FILE *CRC;
//	FILE *DATA;

	int fileDialogResult;
	int alertResult = NSAlertAlternateReturn;

	[selectOutput setTitle: NSLocalizedString(@"Save Files To...", nil)];
	[selectOutput setPrompt: NSLocalizedString(@"Save", nil)];
	[selectOutput setCanCreateDirectories:YES];


	alertResult = NSAlertAlternateReturn;
	fileDialogResult = [selectOutput runModalForDirectory:nil file:nil];
	if(fileDialogResult == NSOKButton){
		NSLog(@"Filename: %@", [selectOutput filename]);
//		alertResult = NSRunAlertPanel(	NSLocalizedString(@"Export ClrMamePro DAT", nil),
//										NSLocalizedString(@"Directory isn't empty, old files may be overwritten. Continue?", nil),
//										NSLocalizedString(@"No", nil),
//										NSLocalizedString(@"Yes", nil), nil);
	}


	// select board name
//	PromptTitle = "Choose a ROM filename (omit extension)";
//	if(!Prompt(topHWnd)) return FALSE;
//	strcpy(filename ,PromptResult);

//	OpenStatus(topHWnd);
	NSLog(@"Resetting USB CopyNES...");
	[self resetNES:RESET_COPYMODE];

	NSLog(@"Unloading any existing plugin...");
	if(![self loadPlugin:@"clear"]){
//		CloseStatus();
		return FALSE;
	}
	[self runCode];
//	Sleep(SLEEP_SHORT);

	NSLog(@"Resetting USB CopyNES...");
	[self resetNES:RESET_COPYMODE];
	NSLog(@"Loading plugin...");
	if([self loadPlugin: selectedPlugin]){
//		CloseStatus();
		return FALSE;
	}
	NSLog(@"Running plugin...");
	[self runCode];
//	Sleep(SLEEP_LONG);

//	if(SaveCRC) CRC = fopen(strjoin3(fnamebuf,Path_CRC,filename,".txt"),"wb");

	cmode = 0;
	// mirroring
	if([self readByte:((char *)&cmode)]){
//		CloseStatus();
		return FALSE;
	}
	battery = 0;
	while(1){
		// for the first 'header' byte, wait longer than usual
		// since the plugin might be busy doing size detection, which can take a while
		int s;
		if([self readByte:((char *)&nblks)] || [self readByte:((char *)&nblks+1)]){
//			CloseStatus();
			return FALSE;
		}
		bytes = nblks << 8;
		numk = bytes / 1024;
		if(![self readByte:(&ctype)]){
//			CloseStatus();
			return FALSE;
		}
		if(ctype == 0) break;
		switch(ctype){
		case 1:
			fileExtension = [NSString stringWithString:@".prg"];
			NSLog(@"Dumping %iK PRG ROM...", numk);
			break;
		case 2:
			fileExtension = [NSString stringWithString:@".chr"];
			NSLog(@"Dumping %iK CHR ROM...", numk);
			break;
		case 3:
			fileExtension = [NSString stringWithString:@".sav"];
			NSLog(@"Dumping %iK WRAM...", numk);
			battery = 1;
			break;
		case 4:
			rbyte = nblks / 4;
			continue;
		default:
			NSLog(@"Unknown block type %i! Aborting...", ctype);
//			StatusOK();
			return FALSE;
			break;
		}


		NSMutableData *outputData;
		for(s = 0; s < numk; s++){
			int a;
			char n;
			for(a = 0; a < 1024; a++){
				if([self readByte:(&n)]){
//					CloseStatus();
					return FALSE;
				}
				[outputData appendBytes:&n length:1];
			}
			if(rbyte){
				rcount++;
				if(rbyte <= rcount){
					rcount = 0;
					NSLog(@"Resetting USB CopyNES as requested by plugin...");
					[self resetNES:RESET_COPYMODE];
					NSLog(@"Reloading plugin...");
					[self loadPlugin: selectedPlugin];
					NSLog(@"Rerunning plugin...");
					[self runCode];
					rbyte = 0;
					if(![self readByte:((char *)&rbyte)] || ![self readByte:((char *)&rbyte+1)]){
//						CloseStatus();
						return FALSE;
					}
					rbyte /= 4;
				}
			}
//			StatusPercent((s * 100) / numk);
		}
//		StatusPercent(100);
		NSLog(@"...done!");
//		if(SaveCRC) fprintf(CRC, "%s%s %08X\n", filename, ext, GetCRC(DATA));
//		NSlog(@"%@%@ %08X\n", NSString *fileExtension;, fileExtension, GetCRC(DATA));
//		fclose(DATA);
	}

//	if(SaveCRC) fclose(CRC);
	NSLog(@"Dump complete!");
//	StatusOK();
	[self resetNES:RESET_COPYMODE];
	{
/*
		int scrn4 = (cmode & 0x2) >> 1;
		int mirror = (~cmode & 0x1);
		int mcon = (cmode & 0x4) >> 2;
		if(plugin->num == 999) return TRUE;
		WriteNES(filename,plugin->num,battery,mirror,scrn4);
		if(MakeUnif == 1) WriteUNIF(filename,plugin->name,battery,mirror,scrn4,mcon);
		if(SaveFiles == 0){
			unlink(strjoin3(fnamebuf,Path_CHR,filename,".chr"));
			unlink(strjoin3(fnamebuf,Path_PRG,filename,".prg"));
		}
*/
	}
	return TRUE;
}

/* Misc. */
-(void) nesInfo{
	char version[256];
	int i;
	NSLog(@"Retrieving internal version string...");
	[self writeByte: 0xA1];

	for(i = 0; i < 256; i++){
		[self readByte: &version[i]];
		if(!version[i]) break;
	}
	NSLog(@"Version: %s", version);
	return;
}

-(void) playCart;{
	if(!isPlaying){
		isPlaying = TRUE;
		[self resetNES:RESET_PLAYMODE];
		NSLog(@"Playing game - press OK to terminate");
	}
	else{
		isPlaying = FALSE;
		[self resetNES:RESET_COPYMODE];
	}
	return;
}

@end
