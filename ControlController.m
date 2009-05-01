//
//  ControlController.m
//  GPSLogger
//
//  Created by German Laullon on 06/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ControlController.h"
#import "GPSPoint.h"; 


@implementation ControlController

-(void)updateIniPoint:(GPSPoint *)point
{
	[self upadteForm:iniPoint point:point];
}

-(void)updateSelPoint:(GPSPoint *)point
{
	[self upadteForm:selPoint point:point];
}

-(void)updateFinPoint:(GPSPoint *)point
{
	[self upadteForm:finPoint point:point];
}

-(void)upadteForm:(NSForm *)form point:(GPSPoint *)point
{
	[[form cellAtIndex:0] setObjectValue:[NSString stringWithFormat:@"%@, %@",[point latitud],[point longitud]]];
}
@end
