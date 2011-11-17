//
//  trackPoint.h
//  GPSLogger
//
//  Created by German Laullon on 02/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TrackNode : NSTreeNode 
{
    @private
    NSMutableArray *points;
}

@property(readonly) NSMutableArray *points;

@end
