//
//  PotoNode.h
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GPSPoint;

@interface PhotoNode : NSTreeNode

@property (copy) NSString* name;
@property (copy) NSString* dateO;
@property (copy) NSURL* URL;
@property (copy) NSDate* date;
@property (weak) GPSPoint* gpsPoint;

@end
