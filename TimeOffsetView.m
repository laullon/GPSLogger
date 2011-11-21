//
//  TimeOffsetView.m
//  GPSLogger
//
//  Created by German Laullon on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeOffsetView.h"

@implementation TimeOffsetView

@synthesize seconds;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        seconds = 0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSGradient *backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor grayColor] endingColor:[NSColor blackColor]];
	[backgroundGradient drawInRect:dirtyRect angle:90];
    
	NSMutableDictionary *drawStringAttributes = [[NSMutableDictionary alloc] init];
	[drawStringAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[drawStringAttributes setValue:[NSFont fontWithName:@"Andale Mono" size:24] forKey:NSFontAttributeName];
	NSShadow *stringShadow = [[NSShadow alloc] init];
	[stringShadow setShadowColor:[NSColor blackColor]];
	NSSize shadowSize;
	shadowSize.width = 2;
	shadowSize.height = -2;
	[stringShadow setShadowOffset:shadowSize];
	[stringShadow setShadowBlurRadius:6];
	[drawStringAttributes setValue:stringShadow forKey:NSShadowAttributeName];	
	
    NSString *sig = seconds >= 0 ? @"+" : @"-"; 
	NSString *MRString = [NSString stringWithFormat:@"%@ %02ld:%02ld Sec.",sig,abs(seconds/60),abs(seconds%60)];
	NSString *budgetString = [NSString stringWithFormat:@"%@", MRString];
	NSSize stringSize = [budgetString sizeWithAttributes:drawStringAttributes];
	NSPoint centerPoint;
	centerPoint.x = (dirtyRect.size.width / 2) - (stringSize.width / 2);
	centerPoint.y = dirtyRect.size.height / 2 - (stringSize.height / 2);
	[budgetString drawAtPoint:centerPoint withAttributes:drawStringAttributes];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if([theEvent deltaY]!=0){
        seconds = seconds + ([theEvent deltaY]/1.5);
        if(seconds>(30*60)) seconds=(30*60);
        if(seconds<-(30*60)) seconds=(-30*60);
        [self setNeedsDisplay:YES];
    }
}

@end
