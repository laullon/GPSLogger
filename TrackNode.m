//
//  trackPoint.m
//  GPSLogger
//
//  Created by German Laullon on 02/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TrackNode.h"

@implementation TrackNode

@synthesize points;

- (id)initWithRepresentedObject:(id)modelObject
{
    if ((self = [super initWithRepresentedObject:modelObject])) {
        points = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
