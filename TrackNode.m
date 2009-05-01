//
//  trackPoint.m
//  GPSLogger
//
//  Created by German Laullon on 02/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TrackNode.h"
#import "LinksNode.h"

@implementation TrackNode
-(void)setStartPoint:(int)point
{
	startPoint=point;
}

-(void)setEndPoint:(int)point
{
	endPoint=point;
}

-(int)startPoint
{
	return startPoint;
}

-(int)endPoint
{
	return endPoint;
}
@end
