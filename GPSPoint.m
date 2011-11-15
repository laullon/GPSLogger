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

-(NSString *)getAddress:(NSString *)alt
{
	NSError *error=nil;
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:
						@"true",@"sensor",
						[NSString stringWithFormat:@"%@,%@",[self latitud],[self longitud]],@"latlng",
						nil];
	
	NSURL *url=[NSURL URLWithString:[self prepareURL:@"http://maps.google.com/maps/api/geocode/xml" params:args]];
	
	NSLog(@"getAddress url => %@",url);
	
	NSXMLDocument *doc=[[NSXMLDocument alloc] initWithContentsOfURL:url
															options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
															  error:&error];	
	if(error)
	{
		NSLog(@"%@:%@ Error saving context: %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
	}
	
	NSString *xq=[[NSBundle mainBundle] pathForResource:@"google_city" ofType:@"xq"];

	NSArray *cities=[doc objectsForXQuery:[NSString stringWithContentsOfFile:xq encoding:NSUTF8StringEncoding error:nil] error:&error];
	if(error || [cities count]<1)
	{
		NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
		NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);
		NSLog(@"%@:%@ error: %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
		return alt;
	}
	if([cities count]>0){
		NSLog(@"---> %@",[cities objectAtIndex:0]);
		return [cities objectAtIndex:0];
	}
	return alt;
}

- (NSString *)prepareURL:(NSString *)url params:(NSDictionary *)args
{
	NSMutableString *res=[[NSMutableString alloc] init];
	[res appendFormat:@"%@?",url];
	for(id key in args)
		[res appendFormat:@"&%@=%@",key,[args objectForKey:key]];
	return res;
}

@end
