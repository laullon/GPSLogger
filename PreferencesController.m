//
//  PreferencesController.m
//  GPSLogger
//
//  Created by German Laullon on 18/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"
@class AppController;

@implementation PreferencesController

- (void)awakeFromNib
{
	/*NSArray *timezoneNames = [NSTimeZone knownTimeZoneNames];
	NSMutableArray *timezones = [NSMutableArray arrayWithCapacity:[timezoneNames count]];
	for (NSString *name in
		 [timezoneNames sortedArrayUsingSelector:@selector(compare:)])
	{
		[(NSMutableArray *)timezones addObject:[NSTimeZone timeZoneWithName:name]];
	}
	[timezonesController setContent:timezones];*/
	
	[DD setIntValue:0];
	[MM setIntValue:0];
	[HH setIntValue:0];
	[SS setIntValue:0];
}

- (IBAction)show:(id)sender
{
	[NSApp beginSheet:panel modalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)hide:(id)sender
{
	NSLog(@"PreferencesController hide");
	NSNumber *off=[NSNumber numberWithInt:((([MM intValue]*60)+([HH intValue]*3600)+[SS intValue]))*-1];
	//[appController timeOffSet:off];
	[appController performSelector:@selector(setTimeOffSet:) withObject:off];
	[appController performSelector:@selector(positionImages)];

	[NSApp endSheet:panel];
	[panel orderOut:self];
}

- (IBAction)setupDD:(id)sender
{
	[DD setIntValue:[sender intValue]];
	[DD setNeedsDisplay];
}

- (IBAction)setupHH:(id)sender
{
	[HH setIntValue:[sender intValue]];
}

- (IBAction)setupMM:(id)sender
{
	[MM setIntValue:[sender intValue]];
}

- (IBAction)setupSS:(id)sender
{
	[SS setIntValue:[sender intValue]];
}

@end
