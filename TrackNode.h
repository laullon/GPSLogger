//
//  trackPoint.h
//  GPSLogger
//
//  Created by German Laullon on 02/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinksNode.h"


@interface TrackNode : LinksNode {
	int startPoint;
	int endPoint;
}

-(void)setStartPoint:(int)point;
-(void)setEndPoint:(int)point;

-(int)startPoint;
-(int)endPoint;
@end
