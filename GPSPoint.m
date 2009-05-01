//
//  Point.m
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GPSPoint.h"
#import "TrackNode.h"

@implementation GPSPoint

@synthesize index;
@synthesize latitud;
@synthesize longitud;
@synthesize fecha;
@synthesize altitud;
@synthesize velocidad;
@synthesize tag;
@synthesize track;

- (NSComparisonResult)compare:(GPSPoint *)anotherGPSPoint
{
	return [fecha compare:[anotherGPSPoint fecha]];
}
@end
