//
//  TimeOffsetView.h
//  GPSLogger
//
//  Created by German Laullon on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimeOffsetView : NSView
{
    @private
    NSInteger seconds;
}

@property (readonly) NSInteger seconds;
@end
