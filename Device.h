//
//  Device.h
//  GPSLogger
//
//  Created by German Laullon on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h> 
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

@interface Device : NSObject {
	NSString *deviceName;
}

@property (copy) NSString *deviceName;

//- (IBAction)buscar:(id)sender;
- (NSData *)leer:(NSProgressIndicator *)progress;
- (void)writeString:(NSString *)string handle:(NSFileHandle*)file;
-(NSData *)readData:(NSUInteger)bytes;
-(NSDictionary *)getConfig;
-(void)open;
-(NSString *)test;
-(void)close;

@end

IONotificationPortRef notePort;
CFRunLoopSourceRef runLoopSource;
io_iterator_t addedIter;
io_iterator_t removedIter;

typedef struct _DeviceInfo {
	unsigned long dummy_0;
	unsigned long serial;
	char dummy_1[32];
	char type[8];
	char dummy_2[65];
} DeviceInfo;

typedef struct _DeviceSettings{
	unsigned long time;
	unsigned long distance;
	char sensitivy;
	char tag;
	char dummy_1[15];
	char vMin;
	char dummy_2[243];
}DeviceSettings;
	
typedef struct _record{
	long longitud;
	long latitude;
	long date;
	short alt;
	char speed;
	char tag;
} Record;

typedef struct _memory{
	Record recodrs[249855];
} Memory;


