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
#import "GPSPoint.h"

@interface PhotoNode : NSTreeNode {
	NSURL* URL;
	NSDate* date;
	GPSPoint* __weak gpsPoint;
	NSString* name;
	NSString* dateO;
	NSString* width;
	NSString* height;
	id __unsafe_unretained delegate;
	NSDictionary *auxProperties;
}

-(NSXMLElement *)getKMLElement;
-(void)applyGeoTags;

@property (copy) NSString* name;
@property (copy) NSString* width;
@property (copy) NSString* dateO;
@property (copy) NSString* height;
@property (copy) NSURL* URL;
@property (copy) NSDate* date;
@property (weak) GPSPoint* gpsPoint;
@property (unsafe_unretained) id delegate;
@property (copy) NSDictionary *auxProperties;

@end

#endif
