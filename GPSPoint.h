//
//  Point.h
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrackNode.h"

@interface GPSPoint : NSObject {
	NSNumber *index;
	NSNumber *latitud;
	NSNumber *longitud;
	NSDate *fecha;
	NSNumber *altitud;
	NSNumber *velocidad;
	NSNumber *tag;
	TrackNode *track;
}

@property (copy) NSNumber *index;
@property (copy) NSNumber *latitud;
@property (copy) NSNumber *longitud;
@property (copy) NSDate *fecha;
@property (copy) NSNumber *altitud;
@property (copy) NSNumber *velocidad;
@property (copy) NSNumber *tag;
@property (assign) TrackNode *track;

- (NSComparisonResult)compare:(GPSPoint *)anotherGPSPoint;

@end
