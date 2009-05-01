//
//  PotoNode.m
//  GPSLogger
//
//  Created by German Laullon on 03/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PhotoNode.h"

@implementation PhotoNode

@synthesize URL;
@synthesize date;
@synthesize gpsPoint;
@synthesize name;
@synthesize width;
@synthesize height;
@synthesize delegate;
@synthesize auxProperties;

-(void)applyGeoTags
{
	[delegate performSelector:@selector(_applyGeoTags:) withObject:self];
}

-(NSXMLElement *)getKMLElement
{
	NSString *des=[NSString stringWithFormat:@"<img src=\"%@\" width=\"%@\" height=\"%@\"/>",[[self URL] absoluteString],[self width],[self height]]; 
	
	NSXMLElement *place = [NSXMLElement elementWithName:@"Placemark"];
	[place addChild:[NSXMLElement elementWithName:@"name" stringValue:[self name]]];
	[place addChild:[NSXMLElement elementWithName:@"description" stringValue:des]];
	NSXMLElement *point=[NSXMLElement elementWithName:@"Point"];
	[point addChild:[NSXMLElement elementWithName:@"coordinates" stringValue:[NSString stringWithFormat:@"%@, %@",[gpsPoint longitud],[gpsPoint latitud]]]];
	[place addChild:point];
	return place;
}

@end
