//
//  SideBarDataSource.m
//  GPSLogger
//
//  Created by German Laullon on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SideBarDataSource.h"
#import "PhotoNode.h"
#import "TrackNode.h"
#import "GPSPoint.h"

@implementation SideBarDataSource

- (void)awakeFromNib
{
    root = [NSTreeNode treeNodeWithRepresentedObject:@"root"];
	
	tracks = [NSTreeNode treeNodeWithRepresentedObject:@"Tacks"];
	photos = [NSTreeNode treeNodeWithRepresentedObject:@"Fotos"];
	
	[root.mutableChildNodes addObject:tracks];
	[root.mutableChildNodes addObject:photos];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    NSTreeNode *node = (NSTreeNode *)item;
    if(!node){
        node = root;
    }
    return [node.childNodes objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return !([item isKindOfClass:[TrackNode class]] || [item isKindOfClass:[PhotoNode class]]);
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    NSTreeNode *node = (NSTreeNode *)item;
    if(!node){
        node = root;
    }
	return [node childNodes].count;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSTreeNode *node = (NSTreeNode *)item;
    return node.representedObject;
}

#pragma mark - props

-(NSArray *)photos
{
    return photos.childNodes;
}

-(NSArray *)tracks
{
    return tracks.childNodes;
}

#pragma mark - read

-(void)readFromNMEA0183:(NSURL *)file
{
    NSError *err=nil;
    NSString *log = [NSString stringWithContentsOfURL:file encoding:NSASCIIStringEncoding error:&err];
	if(err)
	{
		NSLog(@"readFromGPXFile => Error = %@",err);
		return;
	}
    
    NSString *str;
    int n=0;
    
    NSScanner *scanner = [NSScanner scannerWithString:log];
    TrackNode *tn=[TrackNode treeNodeWithRepresentedObject:[file lastPathComponent]];
    
    while ([scanner scanUpToString:@"$GP" intoString:nil]) {
        if([scanner scanUpToString:@"," intoString:&str]){
            //            NSLog(@"< %@ >",str);
            if([str isEqualToString:@"$GPRMC"]){
                if([scanner scanUpToString:@"*" intoString:&str]){
                    str = [str substringFromIndex:1]; // quitamos la primera ,
                    //                    NSLog(@"- %@ -",str);
                    NSArray *comps = [str componentsSeparatedByString:@","];
                    
                    if([[comps objectAtIndex:1] isEqualToString:@"A"]){
                        GPSPoint *gp=[GPSPoint alloc];
                        [gp setIndex:[NSNumber numberWithInt:n++]];
                        
                        double rawLatLng = [[comps objectAtIndex:4] doubleValue];
                        double d = floor(rawLatLng / 100) +  ((rawLatLng - (floor(rawLatLng / 100) * 100)) / 60);
                        //                        NSLog(@"> %f => %f",rawLatLng,d);
                        if([[comps objectAtIndex:5] isEqualToString:@"W"]){
                            d = d*-1;
                        }
                        [gp setLongitud:[NSNumber numberWithDouble:d]];
                        
                        rawLatLng = [[comps objectAtIndex:2] doubleValue];
                        d = floor(rawLatLng / 100) +  ((rawLatLng - (floor(rawLatLng / 100) * 100)) / 60);
                        //                        NSLog(@"> %f => %f",rawLatLng,d);
                        if([[comps objectAtIndex:5] isEqualToString:@"S"]){
                            d = d*-1;
                        }
                        [gp setLatitud:[NSNumber numberWithDouble:d]];
                                                
                        //enlazamos con el track
                        [gp setTrack:tn];
                        [tn.points addObject:gp];
                    }
                }
			}
        }        
    }
    [[tracks mutableChildNodes] addObject:tn];
    
}

-(void)readFromGPXFile:(NSURL *)file
{
    NSError *err=nil;
	
	NSLog(@"readFromGPXFile => file = '%@'",file);
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:file options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
	if(err)
	{
		NSLog(@"readFromGPXFile => Error = %@",err);
        [self readFromNMEA0183:file];
		return;
	}
	
	NSArray *trks=[[xmlDoc rootElement]elementsForName:@"trk"];
	NSXMLElement *trk;
	int n=0;
		
	for(trk in trks){
		NSString *name=[NSString stringWithFormat:@" Track %d",[[tracks childNodes] count]];
		NSArray *names=[trk elementsForName:@"name"];
		if([names count]==1) name=[[names objectAtIndex:0] stringValue];
		TrackNode *tn=[TrackNode treeNodeWithRepresentedObject:name];
		
		for(NSXMLElement *seg in [trk children]){
			for(NSXMLElement *node in [seg children]){
				if([[node name] isEqual:@"trkpt"])
				{
					GPSPoint *gp=[GPSPoint alloc];
					[gp setIndex:[NSNumber numberWithInt:n]];
					[gp setLongitud:[self calcAngleXML:[node attributeForName:@"lon"]]];
					[gp setLatitud:[self calcAngleXML:[node attributeForName:@"lat"]]];
					[gp setTag:[NSNumber numberWithInt:0]];
					
					for(NSXMLElement *hijo in [node children]){
						NSString *hn=[hijo name];
						if([hn isEqual:@"time"]){
							[gp setFecha:[self calcDateXML:hijo]];				
//						}else if([hn isEqual:@"name"]){
//							NSString *name=[hijo stringValue];
//							PointNode *nodo=[PointNode treeNodeWithRepresentedObject:name];
//							[nodo setPointIndex:n];
//							[[tn mutableChildNodes] addObject:nodo];
						}else if([hn isEqual:@"ele"]){
							[gp setAltitud:[NSNumber numberWithInt:[[hijo stringValue] intValue]]];
						}
					}
					
					//enlazamos con el track
					[gp setTrack:tn];
                    [tn.points addObject:gp];
				}
			}
		}
		[[tracks mutableChildNodes] addObject:tn];
	}
}

- (void)addImagesFromDisk:(NSArray *)files
{
	for(NSURL *fileName in files)
	{
		NSLog(@"fileName='%@'",fileName);
		FSRef ref;
		FSPathMakeRef((const UInt8 *)[[fileName path] fileSystemRepresentation], &ref, NULL);
		
		CGImageSourceRef source = CGImageSourceCreateWithURL( (CFURLRef) CFURLCreateFromFSRef(kCFAllocatorDefault,&ref), NULL);
		NSDictionary* metadata = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
		NSDictionary *exifs=[metadata objectForKey:@"{Exif}"];
		NSMutableString *dateS=[[exifs objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal] mutableCopy];
		[dateS replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, 10)];
		NSString *name=[fileName lastPathComponent];		

		PhotoNode *photo=[PhotoNode treeNodeWithRepresentedObject:name];
		[photo setName:name];
		[photo setDate:[NSDate dateWithString:dateS]];
		[photo setDateO:dateS];
		[photo setURL:fileName];
        [[photos mutableChildNodes] addObject:photo];
	}
}

#pragma mark - utils

- (NSNumber *)calcAngleXML:(NSXMLNode *)angle
{
	NSNumber *res=[NSNumber numberWithDouble:[[angle stringValue]doubleValue]];
	//NSLog(@"%@",[date stringValue]);
	return res;
}

- (NSDate *)calcDateXML:(NSXMLNode *)date
{
	//NSLog(@"%@",[date stringValue]);
	NSCalendarDate *res=[NSCalendarDate dateWithString:[date stringValue] calendarFormat:@"%Y-%m-%dT%H:%M:%SZ"];
	return res;
}

@end
