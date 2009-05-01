//
//  PointNode.h
//  GPSLogger
//
//  Created by German Laullon on 02/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinksNode.h"

@interface PointNode : LinksNode {
	int pointIndex;
}

-(void)setPointIndex:(int)point;
-(int)pointIndex;

@end
