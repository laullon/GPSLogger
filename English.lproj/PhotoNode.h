//
//  PotoNode.h
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#if !defined(__PhotoNode_h__)
#define __PhotoNode_h__


#import <Cocoa/Cocoa.h>
#import "LinksNode.h"
#import "GPSPoint.h"

@interface PhotoNode : LinksNode {
	NSURL* URL;
	NSDate* date;
	GPSPoint* gpsPoint;
	NSString* name;
	NSString* width;
	NSString* height;
	id delegate;
	NSDictionary *auxProperties;
}

-(NSXMLElement *)getKMLElement;
-(void)applyGeoTags;

@property (copy) NSString* name;
@property (copy) NSString* width;
@property (copy) NSString* height;
@property (copy) NSURL* URL;
@property (copy) NSDate* date;
@property (assign) GPSPoint* gpsPoint;
@property (assign) id delegate;
@property (copy) NSDictionary *auxProperties;

@end

#endif
