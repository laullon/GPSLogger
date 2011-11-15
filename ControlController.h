//
//  ControlController.h
//  GPSLogger
//
//  Created by German Laullon on 06/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPSPoint.h"


@interface ControlController : NSObject {
	IBOutlet NSForm *iniPoint;
	IBOutlet NSForm *selPoint;
	IBOutlet NSForm *finPoint;
}

-(void)updateIniPoint:(GPSPoint *)point;
-(void)updateSelPoint:(GPSPoint *)point;
-(void)updateFinPoint:(GPSPoint *)point;

-(void)upadteForm:(NSForm *)form point:(GPSPoint *)point;

@end
