//
//  Device.m
//  GPSLogger
//
//  Created by German Laullon on 26/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Device.h"
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <sys/ioctl.h>
#include <sys/termios.h>

@implementation Device

@synthesize deviceName;

NSFileHandle *device;

- (void)writeString:(NSString *)string handle:(NSFileHandle*)file
{
	[file writeData:[NSData dataWithBytes:[string UTF8String] length:[string length]]];
	[file synchronizeFile];
}

-(NSData *)readData:(NSUInteger)bytes
{
	NSLog(@"=> readData");
	NSMutableData *dp_data=[NSMutableData dataWithLength:0];
	NSData *data;
	while([dp_data length]<bytes){
		data=[device availableData];
		if([data length]==0) break;
		
		NSLog(@"read %d bytes",[data length]);
		NSLog(@"%@",[data description]);
		
		[dp_data appendData:data];
		
		/*NSString *m = [NSString stringWithCString:[[dp_data subdataWithRange:NSMakeRange([data length]-1,1)] bytes] length:1];
		 if([@"\0" isEqualToString:m])
		 fin=true;
		 }else{
		 fin=true;
		 }*/
	}
	NSLog(@"<= readData");
	
	return dp_data;
}

-(NSString *)test
{
	NSLog(@"=> test");
	[self writeString:@"W'P Camera Detect\0" handle:device];
	
	NSData *data=[self readData:42];
	
	NSMutableString* res = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	[res replaceOccurrencesOfString:@"\r\n" withString:@"" options:0 range:NSMakeRange(0,[res length])];
	[res replaceOccurrencesOfString:@"\0" withString:@" " options:0 range:NSMakeRange(0,[res length])];
	
	NSLog(@"txt = %@ (%d)",res,[res length]);
	NSLog(@"<= test");
	return res;
}

-(NSDictionary *)getConfig
{
	NSLog(@"=> getConfig");
	
	NSMutableData *res=[NSMutableData dataWithLength:0];
	
	char ds_msg[]={0x5B,0xB0,0,0,0,0,0};
	NSData *msg=[NSData dataWithBytes:ds_msg length:7];
	[device writeData:msg];
	[res appendData:[self readData:103]];
	
	char ds_msg2[]={0x62,0xB6,0,0,0,0,0};
	msg=[NSData dataWithBytes:ds_msg2 length:7];
	[device writeData:msg];
	
	NSData *raw_data=[self readData:271];	
	DeviceSettings *ds=malloc(sizeof(DeviceSettings));
	NSLog(@"%d - %d",sizeof(DeviceSettings),[raw_data length]);
	[raw_data getBytes:ds];
	
	NSArray *sense = [NSArray arrayWithObjects: @"disabled", @"middle", @"high", @"low", nil];
	
	NSString *time = (ds->time!=0xffffffff)? [NSString stringWithFormat:@"%d sec",ds->time] :  @"N/A";
	NSString *distance = (ds->distance!=0xffffffff)? [NSString stringWithFormat:@"%d",ds->distance] :  @"N/A";
	NSString *sensitivy = (ds->sensitivy>=0) ? [sense objectAtIndex:ds->sensitivy] : @"--";
	NSString *tag=(ds->tag==1)? @"On" : @"Off";
	NSString *vMin = (ds->vMin!=0)? [NSString stringWithFormat:@"%d Km/h",(ds->vMin*1.852)] :  @"N/A";

	NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
							time,@"time",
							distance,@"distance",
							sensitivy,@"sensitivy",
							tag,@"tag",
							vMin,@"vMin",
							nil];
	NSLog(@"%@",[settings description]);
	NSLog(@"<= getConfig");
	return settings;
}

- (NSData *)leer:(NSProgressIndicator *)progress
{
	[self test];
	[self getConfig];
	[progress setIndeterminate:NO];
	[progress setMaxValue:4000000];
	[progress setMinValue:0];
	
	NSLog(@"DUMP");
	char dp_msg[]={0x60,0xB5,0,0,0,0,0};
	NSData *msg=[NSData dataWithBytes:dp_msg length:7];
	[device writeData:msg];
	
	NSMutableData *dp_data=[NSMutableData dataWithLength:0];
	int fin=false;
	NSData *data;
	while(!fin){
		data=[device availableData];
		//NSLog(@"--->%d (%4d)",[dp_data length],[data length] );
		
		if([data length]!=15){
			[dp_data appendData:data];
			[progress setDoubleValue:[dp_data length]];
		}else{
			NSString *m = [NSString stringWithCString:[[data subdataWithRange:NSMakeRange(0,14)] bytes] encoding:NSASCIIStringEncoding];
			NSLog(@"-%@-",m);
			if([@"WP Update Over" isEqualToString:m])
				fin=true;
			else
				[dp_data appendData:data];
		}
		
	}
	return dp_data;
}

-(void)open
{
	
	
	struct termios  options,gOriginalTTYAttrs;
	
	device =[NSFileHandle fileHandleForUpdatingAtPath:deviceName];
    int fileDescriptor = [device fileDescriptor];
	
	if (ioctl(fileDescriptor, TIOCEXCL) == -1)		
    {		
        printf("Error setting TIOCEXCL on %s - %s(%d).\n",[deviceName cStringUsingEncoding:NSASCIIStringEncoding], strerror(errno), errno);		
		exit(-1);
    }
	
	if (fcntl(fileDescriptor, F_SETFL, 0) == -1)
    {
        printf("Error clearing O_NONBLOCK %s - %s(%d).\n", [deviceName cStringUsingEncoding:NSASCIIStringEncoding], strerror(errno), errno);
		exit(-1);
    }
	
	if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1)
    {
		printf("Error getting tty attributes %s - %s(%d).\n", [deviceName cStringUsingEncoding:NSASCIIStringEncoding], strerror(errno), errno);
		exit(-1);
    }
	
	options = gOriginalTTYAttrs;
    NSLog(@"Current input baud rate is %d", (int) cfgetispeed(&options));
    NSLog(@"Current output baud rate is %d", (int) cfgetospeed(&options));
	
	cfmakeraw(&options);
	cfsetspeed(&options, B115200);
	options.c_cflag |= (CS8);
	
	if (tcsetattr(fileDescriptor, TCSANOW, &options) == -1)		
    {		
        printf("Error setting tty attributes %s - %s(%d).\n", [deviceName cStringUsingEncoding:NSASCIIStringEncoding], strerror(errno), errno);
		exit(-1);
    }
	NSLog(@"Input baud rate changed to %d\n", (int) cfgetispeed(&options));
    NSLog(@"Output baud rate changed to %d\n", (int) cfgetospeed(&options));
	[self writeString:@"WP AP-Exit\0" handle:device];
	
}



-(void)close
{
	[self writeString:@"WP AP-Exit\0" handle:device];
	[device closeFile];
}

/*- (IBAction)buscar:(id)sender
 {
 [dispositivos removeAllItems];
 
 NSEnumerator *enumerator = [AMSerialPortList portEnumerator];
 AMSerialPort *aPort;
 while (aPort = [enumerator nextObject]) {
 // print port name
 [salida insertText:[aPort name]];
 [salida insertText:@" - "];
 [salida insertText:[aPort bsdPath]];
 [salida insertText:@" - "];
 [salida insertText:[aPort type]];
 [salida insertText:@"\r"];
 
 [dispositivos addItemWithObjectValue:[aPort bsdPath]];
 }
 [salida setNeedsDisplay:YES];
 [dispositivos setNeedsDisplay:YES];
 }*/

@end
