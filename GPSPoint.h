//
//  Point.h
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TrackNode;

@interface GPSPoint : NSObject {
	NSNumber *index;
	NSNumber *latitud;
	NSNumber *longitud;
	NSDate *fecha;
	NSNumber *altitud;
	NSNumber *velocidad;
	NSNumber *tag;
	TrackNode *__weak track;
}

@property (copy) NSNumber *index;
@property (copy) NSNumber *latitud;
@property (copy) NSNumber *longitud;
@property (copy) NSDate *fecha;
@property (copy) NSNumber *altitud;
@property (copy) NSNumber *velocidad;
@property (copy) NSNumber *tag;
@property (weak) TrackNode *track;

- (NSComparisonResult)compare:(GPSPoint *)anotherGPSPoint;
-(NSString *)getAddress:(NSString *)alt;
- (NSString *)prepareURL:(NSString *)url params:(NSDictionary *)args;
@end
