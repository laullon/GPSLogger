//
//  AppController.m
//  GPSLogger
//
//  Created by German Laullon on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <WebKit/WebKit.h>
#include "PhotoNode.h"
#include "AppController.h"
#include "SideBarDataSource.h"

@interface AppController (hiddem)
-(GPSPoint *)findPoint:(NSDate *)fecha;
+(GPSPoint *)findPoint:(NSDate *)fecha track:(TrackNode *)track ini:(int)ini fin:(int)fin;
@end

@implementation AppController

#define FLICKR_BT 1
#define DISCK_BT 2


- (IBAction)addImagesAction:(id)sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg",nil]];
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if(result==NSFileHandlingPanelOKButton){
            NSArray *files=[panel URLs];
            [sideBarDS addImagesFromDisk:files];
        }
        [self positionImages];
    }];
}

- (void)_applyGeoTags:(PhotoNode *)photo
{
	NSLog(@"-- applyGeoTags --- %@ -----------",[photo URL]);
	if([self setDateDigitized:[photo gpsPoint] forPhotoWithURL:[photo URL]])
		NSLog(@"-- applyGeoTags --- ok -----------");
}

- (BOOL)setDateDigitized:(GPSPoint *)point forPhotoWithURL:(NSURL *)URL;
{
    CGImageSourceRef source = CGImageSourceCreateWithURL( (__bridge CFURLRef) URL,NULL);
    if (!source)
    {
        NSLog(@"***Could not create image source ***");
        return NO;
    }
    
    //get all the metadata in the image
    //NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    
    //make the metadata dictionary mutable so we can add properties to it
    //NSMutableDictionary *metadataAsMutable = [[metadata mutableCopy]autorelease];
    NSMutableDictionary *metadataAsMutable = [NSMutableDictionary dictionaryWithCapacity:10];
	NSMutableDictionary *EXIFDictionary = [NSMutableDictionary dictionary];
    //[metadata release];
    
    //NSMutableDictionary *EXIFDictionary = [[[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy]autorelease];
    
    //if(!EXIFDictionary)
    //{
	//if the image does not have an EXIF dictionary (not all images do), then create one for us to use
	//EXIFDictionary = [NSMutableDictionary dictionary];
    //}
    
    
    //we need to format the date so it conforms to the EXIF spec and can be read by other apps
	
    /*NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	 [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	 [dateFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"]; //the date format for EXIF dates as from http://www.abmt.unibas.ch/dokumente/ExIF.pdf
	 NSString *EXIFFormattedCreatedDate = [dateFormatter stringFromDate:date]; //use the date formatter to get a string from the date we were passed in the EXIF format
	 [dateFormatter release];*/
    
	/****
	 24 : <CFString 0xa0531938 [0xa03ee1a0]>{contents = "{GPS}"} = <CFDictionary 0x10c2c30 [0xa03ee1a0]>{type = mutable, count = 7, capacity = 12, pairs = (
	 1 : <CFString 0xa0531168 [0xa03ee1a0]>{contents = "AltitudeRef"} = <CFNumber 0x101ab80 [0xa03ee1a0]>{value = +0, type = kCFNumberSInt32Type}
	 3 : <CFString 0xa05311a8 [0xa03ee1a0]>{contents = "LatitudeRef"} = <CFString 0xa03fc540 [0xa03ee1a0]>{contents = "N"}
	 4 : <CFString 0xa0531188 [0xa03ee1a0]>{contents = "LongitudeRef"} = <CFString 0xa03fe130 [0xa03ee1a0]>{contents = "W"}
	 6 : <CFString 0xa0531178 [0xa03ee1a0]>{contents = "Longitude"} = <CFNumber 0x10c2b20 [0xa03ee1a0]>{value = +21.95479202270507812500, type = kCFNumberFloat64Type}
	 7 : <CFString 0xa0531158 [0xa03ee1a0]>{contents = "Altitude"} = <CFNumber 0x10c2b30 [0xa03ee1a0]>{value = +4.0000000000, type = kCFNumberFloat32Type}
	 9 : <CFString 0xa0531198 [0xa03ee1a0]>{contents = "Latitude"} = <CFNumber 0x10c2ce0 [0xa03ee1a0]>{value = +64.18233489990234375000, type = kCFNumberFloat64Type}
	 14 : <CFString 0xa05311b8 [0xa03ee1a0]>{contents = "GPSVersion"} = <CFArray 0x10c2c80 [0xa03ee1a0]>{type = mutable-small, count = 2, values = (
	 0 : <CFNumber 0x101a180 [0xa03ee1a0]>{value = +2, type = kCFNumberSInt32Type}
	 1 : <CFNumber 0x101ab80 [0xa03ee1a0]>{value = +0, type = kCFNumberSInt32Type}
	 */
	
	NSString *latRef, *lonRef;
	if([[point latitud] doubleValue]>0) latRef=@"N"; else latRef=@"S";
	if([[point longitud] doubleValue]>0) lonRef=@"E"; else lonRef=@"W";
	NSNumber *lat=[NSNumber numberWithDouble:fabs([[point latitud] doubleValue])];
	NSNumber *lon=[NSNumber numberWithDouble:fabs([[point longitud] doubleValue])];
	
    [EXIFDictionary setObject:lat forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [EXIFDictionary setObject:lon forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [EXIFDictionary setObject:latRef forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    [EXIFDictionary setObject:lonRef forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    
    //add our modified EXIF data back into the imageÕs metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(source); //this is the type of image (e.g., public.jpeg)
    
    //this will be the data CGImageDestinationRef will write into
    NSMutableData *data = [NSMutableData data];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,UTI,1,NULL);
    
    if(!destination)
    {
        NSLog(@"***Could not create image destination ***");
        return NO;
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
    
    //tell the destination to write the image data and metadata into our data object.
    //It will return false if something goes wrong
    BOOL success = NO;
    success = CGImageDestinationFinalize(destination);
    
    if(!success)
    {
        NSLog(@"***Could not create data from image destination ***");
        return NO;
    }
    
    
    //now we have the data ready to go, so do whatever you want with it
    //here we just write it to disk at the same path we were passed
    [data writeToURL:URL atomically:YES];
    
    //cleanup
    CFRelease(destination);
    CFRelease(source);
    
    return YES;
}   

- (IBAction)applyGeoTags:(id)sender
{
	[self performSelectorInBackground:@selector(applyGeoTags) withObject:nil];
}

- (void)applyGeoTags
{
    for(PhotoNode *photo in sideBarDS.photos){
        [photo applyGeoTags];
    }
}

- (void)positionImages
{
	NSTimeZone *tz=[NSTimeZone timeZoneWithName:[timeZones titleOfSelectedItem]];
	NSNumber *off=[NSNumber numberWithInt:[timeOffset intValue]];
	NSLog(@"positionImages start");
	NSLog(@"off='%@'", off);
	
	id win = [web windowScriptObject];	
	
	NSDateFormatter *df=[[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
	
	int c=0;
	[win callWebScriptMethod:@"clearPhotos" withArguments:nil];
	for(PhotoNode *photo in [sideBarDS photos]){
        
		NSMutableString *dateS=[NSMutableString stringWithString:[photo dateO]];
		[dateS appendString:@" "];
		[dateS appendString:[tz abbreviation]];
		[photo setDate:[df dateFromString:dateS]];
        
		NSDate *date=[[photo date] dateByAddingTimeInterval:[off doubleValue]];
		GPSPoint *point=[self findPoint:date];
        if(point){
            [photo setGpsPoint:point];		
            
            NSLog(@"------------------------------------------------------");
            NSLog(@"foto: %d-%lu",++c,[[sideBarDS photos] count]);
            NSLog(@"         tz: '%@'",tz);
            NSLog(@"photo.dateO: '%@'",[photo dateO]);
            NSLog(@"      dateS: '%@'",dateS);
            NSLog(@" photo.date: '%@'",[photo date]);
            NSLog(@"       date: '%@'",[[photo date] descriptionWithCalendarFormat:nil timeZone:[NSTimeZone timeZoneWithName:@"UTC"] locale:nil]);
            NSLog(@"point.fecha: '%@'",[[point fecha] descriptionWithCalendarFormat:nil timeZone:[NSTimeZone timeZoneWithName:@"UTC"] locale:nil]);
            NSLog(@"point.fecha: '%@'",[point fecha]);
            
            NSMutableArray *args = [NSMutableArray new];
            [args addObject:[photo name]];
            [args addObject:[point latitud]];
            [args addObject:[point longitud]];
            [win callWebScriptMethod:@"addPhoto" withArguments:args];
            NSLog(@"foto: %d-%lu OK",++c,[[sideBarDS photos] count]);
            
            if(selectedPhoto!=nil){
                [self selectPhoto:selectedPhoto];
            }
        }
	}
	NSLog(@"positionImages start");
}

-(GPSPoint *)findPoint:(NSDate *)fecha
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    GPSPoint *res=nil;
    for(TrackNode *track in [sideBarDS tracks]){
        GPSPoint *pi = [track.points objectAtIndex:0];
        GPSPoint *pf = [track.points lastObject];
        
        if(([fecha compare:pi.fecha]==NSOrderedDescending) && ([fecha compare:pf.fecha] == NSOrderedAscending)){
            res = [AppController findPoint:fecha track:track ini:0 fin:track.points.count-1];
        }
    }
    return res;
}

+(GPSPoint *)findPoint:(NSDate *)fecha track:(TrackNode *)track ini:(int)ini fin:(int)fin
{
	GPSPoint *pi;
	GPSPoint *pf;
	
	int c=ini+((fin-ini)/2);
	GPSPoint *pc=[track.points objectAtIndex:c];
	pi=[track.points objectAtIndex:ini];
	pf=[track.points objectAtIndex:fin];
	
	if((fin-ini)==1){		
		double di=abs([fecha timeIntervalSinceDate:[pi fecha]]);
		double df=abs([fecha timeIntervalSinceDate:[pf fecha]]);
		if(di<df)
			return pi;
		else
			return pf;
	}else{
		NSComparisonResult d=[[pc fecha] compare:fecha];
		if(d==NSOrderedSame)
			return pc;
		else if(d==NSOrderedAscending)
			return [AppController findPoint:fecha track:track ini:c fin:fin];
		else if(d==NSOrderedDescending)
			return [AppController findPoint:fecha track:track ini:ini fin:c];
	}
	return nil;
}

- (IBAction)setPrecisionOffSet:(id)sender{
    //	int limit=[sender tag];
    //	limit=(limit*60)/2;
    //	[timeOffset setMaxValue:limit];
    //	[timeOffset setMinValue:(limit*-1)];
    //	[timeOffset setIntValue:0];
}

- (void)awakeFromNib
{		
	NSLog(@"Awake from Nib called!!!");
	
	NSError *error=nil;
	NSString *path=[[NSBundle mainBundle] pathForResource:@"mapa" ofType:@"html"];
	NSString *html=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	if(error)
	{
		NSLog(@"%@:%@ loading html: %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
	}
	[[web mainFrame] loadHTMLString:html baseURL:[NSURL URLWithString:@"http://laullon.com"]];	
	
	[[web preferences] setPlugInsEnabled:NO];
	[[web preferences] setJavaEnabled:NO];
	
	NSArray *timeZoneNames = [[[NSTimeZone abbreviationDictionary] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSString *tzName;
	[timeZones removeAllItems];
	for(tzName in timeZoneNames){
		[timeZones addItemWithTitle:tzName];
	}
	[timeZones setTitle:[[NSTimeZone localTimeZone] name]];
	[timeZones selectItemWithTitle:[[NSTimeZone localTimeZone] name]];
    
#ifdef DEBUG 
	[self performSelectorInBackground:@selector(debugInit) withObject:nil];
#endif 
}

-(void)debugInit
{
	[sideBarDS readFromGPXFile:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost/Users/laullon/Desktop/todo.gpx"]]];
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Users/laullon/Desktop/new_orleans_bourbon_st" error:nil];
	NSMutableArray *files=[NSMutableArray arrayWithCapacity:[dirContents count]];
	for(NSString *fileName in dirContents){
		[files addObject:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost/Users/laullon/Desktop/new_orleans_bourbon_st/%@",fileName]]];
	}
	[sideBarDS addImagesFromDisk:files];
    [self positionImages];
	[self showAllPhotosOnMap:nil];
}


- (IBAction)updateTimeOffset:(id)sender{
	int time=[timeOffset intValue];
	char s=((time>=0)?'+':'-');
	time=abs(time);
	int h=time/60;
	int m=time-(h*60);
	NSString *st=[NSString stringWithFormat:@"%c%0#2d:%0#2d",s,h,m];
	[timeOffsetTXT setStringValue:st];
    
	NSLog(@"-> %@",sender);
	NSLog(@"-> %@",[mainWindow currentEvent]);
	
	if(sender==timeZones){
		[timeZones setTitle:[timeZones titleOfSelectedItem]];
        
	}
	
	if([[mainWindow currentEvent] type]==NSLeftMouseUp){
		[self positionImages];
	}
}

-(NSString *)encode:(double)pos
{
	bool debug=false;
	NSMutableString *res=[NSMutableString stringWithCapacity:7];
	
	long long n=round(pos * 1e5);		// steps 1,2,3
	if(debug) NSLog(@"pos='%f' n='%qi' n='%qx'",pos,n,n);
	n=(n << 1);							// step 4	
	if(debug) NSLog(@"pos='%f' n='%qi' n='%qx'",pos,n,n);
	if(n<0) n=(n ^ 0xffffffff);			// step 5	
	if(debug) NSLog(@"pos='%f' n='%qi' n='%qx'",pos,n,n);
	
	int fin=6;
	while((((n>>(5*(fin-1)))&0x1f)==0) && (fin>1)) fin--;
	if(debug) NSLog(@"fin='%d'",fin);
	
	for(int i=0;i<fin;i++){
		char c=(n & 0x1f);				// step 7
		if(debug) NSLog(@"i='%d' c=%dx",i,c);
		if(i!=(fin-1))
			c=(c | 0x20);				// step 8 (todo menos el ultimo)
		c=(c + 63);						// steps 9,10		
		[res appendFormat:@"%c",c];		// steps 11
		n=n>>5;
	}
	if(debug) NSLog(@"res='%@'",res);
	return res;
}

- (void)selectPhoto:(PhotoNode *)ph
{
	NSImage *img=[[NSImage alloc] initByReferencingURL:[ph URL]];
	[imageViewer setImage:img];
	selectedPhoto=ph;
	
	GPSPoint *point=[selectedPhoto gpsPoint];
	if(point!=nil){
		NSMutableArray *args = [NSMutableArray new];
		[args addObject:[point latitud]];
		[args addObject:[point longitud]];
		[[web windowScriptObject] callWebScriptMethod:@"movePhotoIcon" withArguments:args];
	}
}

- (IBAction)showAllPhotosOnMap:(id)sender{
	[[web windowScriptObject] callWebScriptMethod:@"showAllPhotos" withArguments:nil];
}

- (void)updateTrack:(TrackNode *)node
{
	if(node==selectedTrack) return;
	selectedTrack=node;
	
	id win = [web windowScriptObject];	
	NSMutableArray *args = [NSMutableArray new];
	NSMutableArray *coordinates = [NSMutableArray new];
	for(GPSPoint *point in node.points){
		[coordinates addObject:[point latitud]];
		[coordinates addObject:[point longitud]];
	}	
	[args addObject:coordinates];
	[win callWebScriptMethod:@"setTrak" withArguments:args];
}

- (IBAction)readFromLoggerAction:(id)sender
{
	NSOpenPanel *panel;			
    panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"gpx",@"log",nil]];
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result) {
        if(result==NSFileHandlingPanelOKButton){ // todo: run this in a async queue
            for(NSURL *url in [panel URLs]){
            	[sideBarDS readFromGPXFile:url];
            }
        }
        [sideBar reloadData];
    }];
}

- (NSDate *)calcDate:(long) date
{
	//NSLog(@"%d",date);
	long second =  date        & 63;
	long minute = (date >> 6)  & 63;
	long hour   = (date >> 12) & 31;
	long day    = (date >> 17) & 31;
	long month  = (date >> 22) & 15;
	long year   = (date >> 26) & 63;
	
	NSString *fecha=[NSString stringWithFormat:@"20%02d-%02d-%02d %02d-%02d-%02d +0000",year,month,day,hour,minute,second];
	NSDate *res=[NSDate dateWithString:fecha];
	
	return res;
}

- (NSNumber *)calcAngle:(long)angle
{
	long na=angle;
	
	if(na>=0x80000000){
		na -=0x80000000;
		na *=-1;
	}
	long na_dec=(na-((na/1000000)*1000000))*100/60;	
	na/=1000000;
	
	double r=na_dec;
	r = (r*1e-6);
	r = (na+r);
	
	NSNumber *res=[NSNumber numberWithDouble:r];
	
	//NSLog(@"* %d.%06d",na,abs(na_dec));
	//NSLog(@"  %@",[res description]);
	return res;
}

- (IBAction)exportToGPX:(id) sender
{
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"gpx"];
	[root addAttribute:[NSXMLNode attributeWithName:@"creator" stringValue:@"http://gpslogger.laullon.ocm"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.topografix.com/GPX/1/0"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd"]];
	
	for(TrackNode *track in sideBarDS.tracks){
		NSXMLElement *trk=[NSXMLElement elementWithName:@"trk"];
		[root addChild:trk];
		[trk addChild:[NSXMLElement elementWithName:@"name" stringValue:[track representedObject]]];
		NSXMLElement *trkseg=[NSXMLElement elementWithName:@"trkseg"];
		[trk addChild:trkseg];
		for(GPSPoint *gp in track.points){
			NSXMLElement *point=[NSXMLElement elementWithName:@"trkpt"];
			[point addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[[gp latitud] stringValue]]];
			[point addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[[gp longitud] stringValue]]];
			
			[point addChild:[NSXMLElement elementWithName:@"ele" stringValue:[[gp altitud] stringValue]]];
			NSString *fecha=[[gp  fecha] descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ" timeZone:nil locale:nil];
			[point addChild:[NSXMLElement elementWithName:@"time" stringValue:fecha]];
			
			/*NSDictionary *ext=[NSDictionary dictionaryWithObjectsAndKeys:[gp velocidad],@"vel",nil];
			 NSData *extData=[NSPropertyListSerialization dataFromPropertyList:ext format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
			 NSString *extString=[[NSString alloc] initWithData:extData encoding:NSASCIIStringEncoding];
			 [point addChild:[NSXMLElement elementWithName:@"extensions" stringValue:extString]];*/
			
			[trkseg addChild:point];
		}
	}
	
	NSXMLDocument *xmlRequest = [NSXMLDocument documentWithRootElement:root];
	
	NSData *xml=[xmlRequest XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);
	
	NSSavePanel *p=[NSSavePanel savePanel];
	[p setAllowedFileTypes:[NSArray arrayWithObject:@"gpx"]];
	if([p runModal]==NSFileHandlingPanelOKButton)
		[xml writeToFile:[[p URL] path] atomically:true];
	
}

- (IBAction)exportToKML:(id) sender
{
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"kml"];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.opengis.net/kml/2.2"]];
	
	NSXMLElement *doc = [[NSXMLElement alloc] initWithName:@"Document"];
	[root addChild:doc];
	
	NSXMLElement *fotos=[[NSXMLElement alloc] initWithName:@"Folder"];
	[fotos addChild:[[NSXMLElement alloc] initWithName:@"name" stringValue:@"fotos"]];
	[fotos addChild:[[NSXMLElement alloc] initWithName:@"description" stringValue:@"description"]];
	
	PhotoNode *photo;
	for(photo in sideBarDS.photos){
		[fotos addChild:[photo getKMLElement]];
	}
	
	NSMutableString *coors=[NSMutableString string];
	GPSPoint *gp;
	for(gp in selectedTrack.points){
		[coors appendFormat:@"%@,%@,%@ \n",[gp longitud],[gp latitud],[gp altitud]];
	}
	
	NSXMLElement *linestring=[[NSXMLElement alloc] initWithName:@"LineString"];
	[linestring addChild:[[NSXMLElement alloc] initWithName:@"coordinates" stringValue:coors]];
	
	NSXMLElement *line=[[NSXMLElement alloc] initWithName:@"Placemark"];
	[line addChild:[[NSXMLElement alloc] initWithName:@"name" stringValue:@"camino"]];
	[line addChild:[[NSXMLElement alloc] initWithName:@"description" stringValue:@"description"]];
	[line addChild:linestring];
	
	[doc addChild:fotos];
	[doc addChild:line];
	
	NSXMLDocument *xmlRequest = [NSXMLDocument documentWithRootElement:root];
	
	NSData *xml=[xmlRequest XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);
    
	NSSavePanel *p=[NSSavePanel savePanel];
	[p setAllowedFileTypes:[NSArray arrayWithObject:@"kml"]];
	if([p runModal]==NSFileHandlingPanelOKButton)
		[xml writeToFile:[[p URL] path] atomically:true];
}

#pragma mark - webviewDelegate

- (void)webView:(WebView *)webView addMessageToConsle:(NSDictionary *)dictionary
{
	NSLog(@"addMessageToConsole == %@ ==",dictionary);
}

- (void)webView:(WebView *)sender setStatusText:(NSString *)text
{
	NSLog(@"setStatusText == %@ ==",text);
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
	NSLog(@"runJavaScriptAlertPanelWithMessage == %@ ==",message);
}

- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame
{ 
	[windowObject setValue:self forKey:@"appController"]; 	
} 

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if ( selector == @selector(selectPhotoById:) ) {
        return NO;
    }
    return YES;
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSTreeNode *node = [sideBar itemAtRow:sideBar.selectedRow];
    if([node isKindOfClass:[TrackNode class]]){
        [self updateTrack:(TrackNode *)node];
    }else if([node isKindOfClass:[PhotoNode class]]){
        [self selectPhoto:(PhotoNode *)node];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    NSTreeNode *node = (NSTreeNode *)item;
    return ([node isKindOfClass:[TrackNode class]] || [node isKindOfClass:[PhotoNode class]]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    NSTreeNode *node = (NSTreeNode *)item;
    return !([node isKindOfClass:[TrackNode class]] || [node isKindOfClass:[PhotoNode class]]);
}


@end
