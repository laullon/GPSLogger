//
//  AppController.m
//  GPSLogger
//
//  Created by German Laullon on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <WebKit/WebKit.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <complex.h>


#import "AppController.h"
#import "Device.h"

@class Device;
@class PhotoNode;
@class ImageAndTextCell;

@implementation AppController

@synthesize statusBar;
@synthesize devicePath;

#define FLICKR_BT 1
#define DISCK_BT 2


- (IBAction)addImagesAction:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	NSButton *bt=[alert addButtonWithTitle:@"From Disk"];
	[bt setTag:DISCK_BT];
	bt=[alert addButtonWithTitle:@"From Flickr"];
	[bt setTag:FLICKR_BT];
	bt=[alert addButtonWithTitle:@"Cancel"];
	[bt setTag:-1];
	[alert setMessageText:@"Add Photos"];
	[alert setInformativeText:@"Select the source of Photos:"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(addImages:returnCode:contextInfo:) contextInfo:nil];
	
}

- (void)addImages:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSLog(@"addImages returnCode=%d",returnCode);
	[[alert window] orderOut:self];
	
	if(returnCode==DISCK_BT){
		NSOpenPanel * panel = [NSOpenPanel openPanel];
		[panel setAllowsMultipleSelection:YES];
		[panel beginSheetForDirectory:nil 
								 file:nil 
								types:[NSArray arrayWithObjects:@"jpg",nil]
					   modalForWindow:mainWindow
						modalDelegate:self
					   didEndSelector:@selector(addImagesFromDisk:returnCode:contextInfo:)
						  contextInfo:nil];
	}else if(returnCode==FLICKR_BT){
		[flickr beginSheetSelector:mainWindow delegate:self didEndSelector:@selector(addImages:)];
	}
}

- (void)_applyGeoTags:(PhotoNode *)photo
{
	NSLog(@"-- applyGeoTags --- %@ -----------",[photo URL]);
	if([self setDateDigitized:[photo gpsPoint] forPhotoWithURL:[photo URL]])
		NSLog(@"-- applyGeoTags --- ok -----------");
}

- (BOOL)setDateDigitized:(GPSPoint *)point forPhotoWithURL:(NSURL *)URL;
{
    CGImageSourceRef source = CGImageSourceCreateWithURL( (CFURLRef) URL,NULL);
    if (!source)
    {
        NSLog(@"***Could not create image source ***");
        return NO;
    }
    
    //get all the metadata in the image
    //NSDictionary *metadata = (NSDictionary *) CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    
    //make the metadata dictionary mutable so we can add properties to it
    //NSMutableDictionary *metadataAsMutable = [[metadata mutableCopy]autorelease];
    NSMutableDictionary *metadataAsMutable = [[NSMutableDictionary dictionaryWithCapacity:10]autorelease];
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
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)data,UTI,1,NULL);
    
    if(!destination)
    {
        NSLog(@"***Could not create image destination ***");
        return NO;
    }
    
    //add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImageFromSource(destination,source,0, (CFDictionaryRef) metadataAsMutable);
    
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
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[progressText setStringValue:@"Applying GeoTags"];
	[progress setIndeterminate:NO];
	[progress setMaxValue:[[photos childNodes] count]];
	[progress setDoubleValue:0];
	
	for(PhotoNode *photo in [photos childNodes]){
		[progress incrementBy:1];
		[photo applyGeoTags];
	}
		
	[pool release];
}

- (void)openProgress:(NSString *)txt count:(NSNumber *)count
{
	[progressText setStringValue:txt];
	[progress setHidden:NO];
	[progress setIndeterminate:NO];
	[progress setMaxValue:[count doubleValue]];
	[progress setDoubleValue:0];
}

- (void)closeProgress
{
	[progressText setStringValue:@""];
	[progress setHidden:YES];

}

- (void)positionImages
{
	NSTimeZone *tz=[NSTimeZone timeZoneWithName:[timeZones titleOfSelectedItem]];
	NSNumber *off=[NSNumber numberWithInt:[timeOffset intValue]];
	NSLog(@"positionImages");
	NSLog(@"off='%@'", off);
	
	if([points count]==0) return;
	if([[photos childNodes] count]==0) return;
	if(tz==nil) return;
		
	id win = [web windowScriptObject];	
	
	/*[progressText setStringValue:@"Positioning photos on map"];
	 [progress setIndeterminate:NO];
	 [progress setMaxValue:[[photos childNodes] count]];
	 [progress setDoubleValue:0];*/
	
	NSDateFormatter *df=[[NSDateFormatter alloc] init];
	[df setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
	
	[win callWebScriptMethod:@"clearPhotos" withArguments:nil];
	for(PhotoNode *photo in [photos childNodes]){

		NSMutableString *dateS=[NSMutableString stringWithString:[photo dateO]];
		[dateS appendString:@" "];
		[dateS appendString:[tz abbreviation]];
		[photo setDate:[df dateFromString:dateS]];

		NSDate *date=[[photo date] dateByAddingTimeInterval:[off doubleValue]];
		GPSPoint *point=[self findPoint:date ini:0 fin:([points count]-1)];
		[photo setGpsPoint:point];		

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
	}
}

- (void)addImages:(NSArray *)arrayPhotos
{
	photosByName=[NSMutableDictionary dictionaryWithCapacity:[arrayPhotos count]];
	for(NSDictionary *p in arrayPhotos){
		PhotoNode *photo=[PhotoNode treeNodeWithRepresentedObject:[p objectForKey:@"name"]];
		
		NSMutableString *dateS=[[p objectForKey:@"date"] mutableCopy];
		[dateS appendString:@" +0000"];
		NSLog(@"--> (%@) %@",dateS,[NSDate dateWithString:dateS]);
		
		[photo setName:[p objectForKey:@"name"]];
		[photo setWidth:[p objectForKey:@"width"]];
		[photo setHeight:[p objectForKey:@"height"]];
		[photo setDelegate:[p objectForKey:@"delegate"]];
		[photo setDate:[NSDate dateWithString:dateS]];
		[photo setDateO:[p objectForKey:@"date"]];
		[photo setURL:[NSURL URLWithString:[p objectForKey:@"url"]]];
		[photo setAuxProperties:p];
		
		[[photos mutableChildNodes] addObject:photo];
		[photosByName setObject:photo forKey:[photo name]];
	}
	
	[self positionImages];
}

- (void)addImagesFromDisk:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	NSArray *files=[panel filenames];
	[self addImagesFromDisk:files];
}

- (void)addImagesFromDisk:(NSArray *)files
{
	NSString *fileName;
	NSMutableArray *res=[NSMutableArray arrayWithCapacity:[files count]];
	for(fileName in files)
	{
		NSLog(@"fileName='%@'",fileName);
		FSRef ref;
		FSPathMakeRef((const UInt8 *)[fileName fileSystemRepresentation], &ref, NULL);
		
		CGImageSourceRef source = CGImageSourceCreateWithURL( (CFURLRef) CFURLCreateFromFSRef(kCFAllocatorDefault,&ref), NULL);
		NSDictionary* metadata = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
		NSDictionary *exifs=[metadata objectForKey:@"{Exif}"];
		NSMutableString *dateS=[[exifs objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal] mutableCopy];
		[dateS replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, 10)];
		[dateS appendString:@" +0000"];
		
		NSString *name=[fileName lastPathComponent];
		NSString *url=[NSString stringWithFormat:@"file://%@",[[NSURL URLWithString:fileName] absoluteString]];
		
		[res addObject:[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",url,@"url",dateS,@"date",self,@"delegate",nil]];
	}
	[self addImages:res];
}

-(GPSPoint *)findPoint:(NSDate *)fecha ini:(int)ini fin:(int)fin
{
	GPSPoint *pi;
	GPSPoint *pf;
	
	int c=ini+((fin-ini)/2);
	GPSPoint *pc=[points objectAtIndex:c];
	pi=[points objectAtIndex:ini];
	pf=[points objectAtIndex:fin];
	
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
			return [self findPoint:fecha ini:c fin:fin];
		else if(d==NSOrderedDescending)
			return [self findPoint:fecha ini:ini fin:c];
	}
	return nil;
}

- (void)awakeFromNib
{	
	/*sISO8601 = [[NSDateFormatter alloc] init];
	 [sISO8601 setTimeStyle:NSDateFormatterFullStyle];
	 [sISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];*/
	
	// googel maps test
	NSLog(@"-> %@",[self encode:-179.98321]);
	NSLog(@"-> %@",[self encode:38.5]);
	NSLog(@"-> %@",[self encode:40.7-38.5]);
	NSLog(@"-> %@",[self encode:43.252-40.7]);
	NSLog(@"-> %@",[self encode:-120.2]);
	NSLog(@"-> %@",[self encode:-120.95-(-120.2)]);
	NSLog(@"-> %@",[self encode:-126.453-(-120.95)]);
	
	initUSB(self);
	
	rootArray = [NSMutableArray new];
	
	wayPoints = [NSTreeNode treeNodeWithRepresentedObject:@"WayPoints"];
	tracks = [NSTreeNode treeNodeWithRepresentedObject:@"Tacks"];
	photos = [NSTreeNode treeNodeWithRepresentedObject:@"Fotos"];
	
	[rootArray addObject:wayPoints];
	[rootArray addObject:tracks];
	[rootArray addObject:photos];
	
	NSLog(@"Awake from Nib called!!!");
	
	[links setContent:rootArray];
	
	NSString *path=[[NSBundle mainBundle] pathForResource:@"mapa" ofType:@"html"];
	
	[[web preferences] setPlugInsEnabled:NO];
	[[web preferences] setJavaEnabled:NO];
	
	NSLog(@"p -->%@",[[web preferences] arePlugInsEnabled]);
	NSLog(@"j -->%@",[[web preferences] isJavaEnabled]);
	
	//NSData *data=[NSData dataWithContentsOfFile:path];
	NSString *html=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	[[web mainFrame]loadHTMLString:html baseURL:[NSURL URLWithString:@"http://laullon.com"]];
	
	NSArray *timeZoneNames = [[[NSTimeZone abbreviationDictionary] allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSString *tzName;
	[timeZones removeAllItems];
	for(tzName in timeZoneNames){
		[timeZones addItemWithTitle:tzName];
	}
	[timeZones setTitle:[[NSTimeZone localTimeZone] name]];
	
#ifdef DEBUG 
	[self performSelectorInBackground:@selector(debugInit) withObject:nil];
#endif 
}

-(void)debugInit
{
	//[self readFromGPXFile:@"/Users/laullon/Desktop/todo.gpx"];
	[self readFromLogger];
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Users/laullon/Desktop/pike_market" error:nil];
	NSString *fileName;
	NSMutableArray *files=[NSMutableArray arrayWithCapacity:[dirContents count]];
	for(fileName in dirContents){
		[files addObject:[NSString stringWithFormat:@"/Users/laullon/Desktop/pike_market/%@",fileName]];
	}
	[self addImagesFromDisk:files];
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

- (IBAction)noveSelectedPoind:(id)sender
{
	NSString *cell = [sender labelForSegment:[sender selectedSegment]];
	
	int i=[cell intValue]+selectedPoint;
	if(i<0) i=0;
	if(i>=[points count]) i=[points count]-1;
	
	[self setSelectedPoint:i];
	NSLog(@"--> %@",cell);
}

-(IBAction)setIniMapPointAction:(id)sender
{
	[self setIniMapPoint:selectedPoint];
	[self updateMap];
}

-(void)setIniMapPoint:(int)point
{
	if([iniLock state]!=1){
		iniMapaPoint=point;
		[control updateIniPoint:[points objectAtIndex:point]];
	}
}

-(IBAction)setFinMapPointAction:(id)sender{
	[self setFinMapPoint:selectedPoint];
	[self updateMap];
}

-(void)setFinMapPoint:(int)point
{
	if([finLock state]!=1){
		finMapaPoint=point;
		[control updateFinPoint:[points objectAtIndex:point]];
	}
}

-(void)updateMap
{
	NSDictionary *trackEncoded=[self encodeTrack:iniMapaPoint to:finMapaPoint];
	
	id win = [web windowScriptObject];	
	NSMutableArray *args = [NSMutableArray new];
	[args addObject:[trackEncoded objectForKey:@"polyline"]];
	[args addObject:[trackEncoded objectForKey:@"leves"]];
	id res=[win callWebScriptMethod:@"setMap" withArguments:args];
	NSLog(@"%@",res);
}

-(IBAction)updateView:(id)sender
{
	if([sender isKindOfClass:[NSOutlineView class]])
	{
		NSTreeNode *node=[[[links selectedNodes] objectAtIndex:0] representedObject];
		if([node isKindOfClass:[PointNode class]]){
			[self updateWayPoint:(PointNode *)node];
		}else if([node isKindOfClass:[TrackNode class]]){
			[self updateTrack:(TrackNode *)node];
			//}else if([node isKindOfClass:[PhotoNode class]]){
			//[self showPhoto:(PhotoNode *)node];
		}
		/*	}else if([sender isKindOfClass:[NSTableView class]])
		 {
		 GPSPoint *point=[[datos selectedObjects] objectAtIndex:0];*/
	}
}

- (void)showPhoto:(PhotoNode *)node
{
	[self setSelectedPhoto:[[[node gpsPoint] index] intValue]];
}

- (void)updateWayPoint:(PointNode *)node
{
	[self setSelectedPoint:[node pointIndex]];	
}

- (void)setSelectedPoint:(int)index
{
	selectedPoint=index;
	GPSPoint *point = [points objectAtIndex:selectedPoint];	
	[control updateSelPoint:point];
	NSString *cmd=[NSString stringWithFormat:@"setWayPoint(%@, %@)",[point latitud],[point longitud]];	
	
	[self updateTrack:(TrackNode *)[point track]];
	
	id win = [web windowScriptObject];	
	[win evaluateWebScript:cmd];
}

- (void)setSelectedPhoto:(int)index
{
	[self setSelectedPoint:index];
	selectedPhoto=index;
	GPSPoint *point = [points objectAtIndex:selectedPhoto];	
	NSString *cmd=[NSString stringWithFormat:@"setPoint(%@, %@)",[point latitud],[point longitud]];
	
	id win = [web windowScriptObject];	
	[win evaluateWebScript:cmd];
}

- (NSDictionary *)encodeTrack:(int)ini to:(int)fin
{
	NSLog(@"encodeTrack %d-%d (%d)",ini,fin,fin-ini);
	
	NSRange range = {ini, (fin-ini)};
	[datos setContent:[points subarrayWithRange:range]];
	
	NSMutableString *polyline=[NSMutableString stringWithCapacity:((fin-ini)*3)];
	NSMutableString *leves=[NSMutableString stringWithCapacity:(fin-ini)];
	GPSPoint *prevPoint=nil;
	double la,lo;
	double min=1e-5;
	
	//fin=ini+30;
	
	for(;ini<=fin;ini++){
		GPSPoint *point = [points objectAtIndex:ini];
		la=[[point latitud] doubleValue];
		lo=[[point longitud] doubleValue];
		if(prevPoint!=nil){
			la=la-[[prevPoint latitud] doubleValue];
			lo=lo-[[prevPoint longitud] doubleValue];
		}
		//NSLog(@"la=%f lo=%f min=%f",la,lo,1e-5);
		//NSLog(@"la=%f lo=%f min=%f - %@(%@)",cabs(la),cabs(lo),min,[prevPoint index],[point index]);
		if((cabs(la)>=min) || (cabs(lo)>=min)){
			[polyline appendString:[self encode:la]];
			[polyline appendString:[self encode:lo]];
			if(prevPoint==nil)
				[leves appendString:@"B"];
			else if(ini==fin)
				[leves appendString:@"B"];
			else if([[point velocidad]intValue]>10)
				[leves appendString:@"B"];
			else
				[leves appendString:@"B"];
			prevPoint=point;
		}
	}
	
	NSLog(@"polyline => %@",polyline);
	NSLog(@"leves => %@",leves);
	NSLog(@"leves l => %d",[leves length]);
	
	NSDictionary *res=[NSDictionary dictionaryWithObjectsAndKeys:polyline,@"polyline",leves,@"leves",nil];
	return res;
}

- (void)updateTrack:(TrackNode *)node
{
	if(node==selectedTrack) return;
	selectedTrack=node;
	
	//NSLog(@"TrackNode %d-%d",[node startPoint],[node endPoint]);
	
	NSDictionary *trackEncoded=[self encodeTrack:[node startPoint] to:[node endPoint]];
	
	id win = [web windowScriptObject];	
	NSMutableArray *args = [NSMutableArray new];
	[args addObject:[trackEncoded objectForKey:@"polyline"]];
	[args addObject:[trackEncoded objectForKey:@"leves"]];
	[win callWebScriptMethod:@"setTrak" withArguments:args];
	//[self setSelectedPoint:[node startPoint]];	
}

- (IBAction)readFromLoggerAction:(id)sender
{
	NSAlert *alert = [[NSAlert alloc] init];
	NSButton *bt=[alert addButtonWithTitle:@"From GPX File"];
	[bt setTag:1];
	bt=[alert addButtonWithTitle:@"From Device"];
	[bt setTag:2];
	bt=[alert addButtonWithTitle:@"Cancel"];
	[bt setTag:-1];
	[alert setMessageText:@"Read GPS Data"];
	[alert setInformativeText:@"Select the source of GPS Data:"];
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(readData:returnCode:contextInfo:) contextInfo:nil];
}

- (void)readData:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	NSOpenPanel *panel;			
	[[alert window] orderOut:self];
	switch(returnCode){
		case 1:
			panel = [NSOpenPanel openPanel];
			[panel setAllowsMultipleSelection:NO];
			[panel beginSheetForDirectory:nil 
									 file:nil 
									types:[NSArray arrayWithObjects:@"gpx",nil]
						   modalForWindow:mainWindow
							modalDelegate:self
						   didEndSelector:@selector(readFromGPXFile:returnCode:contextInfo:)
							  contextInfo:nil];
			break;
		case 2:
			[self performSelectorInBackground:@selector(readFromLogger) withObject:nil];
			break;
	}
}

- (void)readFromGPXFile:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	NSString *file=[panel filename];
	[self performSelectorInBackground:@selector(readFromGPXFile:) withObject:file];
}

-(void)readFromGPXFile:(NSString *)file
{
	NSMutableArray *tmpPoints = [NSMutableArray new];
    NSError *err=nil;
	
	[self openProgress:@"Loading GPX File" count:0];
	
	NSLog(@"readFromGPXFile => file = '%@'",file);
	NSURL *furl = [NSURL fileURLWithPath:file];
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
	if(err)
	{
		NSLog(@"readFromGPXFile => Error = %@",err);
		return;
	}
	
	NSArray *trks=[[xmlDoc rootElement]elementsForName:@"trk"];
	NSXMLElement *trk;
	int n=0;
	
	[self openProgress:@"Loading GPX File" count:[NSNumber numberWithDouble:[trks count]]];
	
	for(trk in trks){
		[progress incrementBy:1];
		NSString *name=[NSString stringWithFormat:@" Track %d",[[tracks childNodes] count]];
		NSArray *names=[trk elementsForName:@"name"];
		if([names count]==1) name=[[names objectAtIndex:0] stringValue];
		TrackNode *tn=[TrackNode treeNodeWithRepresentedObject:name];
		[tn setStartPoint:n];			
		
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
						}else if([hn isEqual:@"name"]){
							NSString *name=[hijo stringValue];
							PointNode *nodo=[PointNode treeNodeWithRepresentedObject:name];
							[nodo setPointIndex:n];
							[[tn mutableChildNodes] addObject:nodo];
						}else if([hn isEqual:@"ele"]){
							[gp setAltitud:[NSNumber numberWithInt:[[hijo stringValue] intValue]]];
						}
					}
					[tmpPoints addObject:gp];
					
					//enlazamos con el track
					[gp setTrack:tn];
					[tn setEndPoint:n];			
					n++;
				}
			}
		}
		NSLog(@"TrackNode %d-%d (%d)",[tn startPoint],[tn endPoint],[[tn mutableChildNodes]count]);
		[[tracks mutableChildNodes] addObject:tn];
	}
	
	
	NSLog(@"readFromGPXFile => end");
	[self closeProgress];
	points=[tmpPoints copy];
	[points retain];
	[tmpPoints release];
}

- (NSDate *)calcDateXML:(NSXMLNode *)date
{
	//NSLog(@"%@",[date stringValue]);
	NSCalendarDate *res=[NSCalendarDate dateWithString:[date stringValue] calendarFormat:@"%Y-%m-%dT%H:%M:%SZ"];
	return res;
}

- (NSNumber *)calcAngleXML:(NSXMLNode *)angle
{
	NSNumber *res=[NSNumber numberWithDouble:[[angle stringValue]doubleValue]];
	//NSLog(@"%@",[date stringValue]);
	return res;
}

- (void)readFromLogger
{
	NSMutableArray *tmpPoints = [NSMutableArray new];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	Device *d=[Device alloc];
	[d setDeviceName:[self devicePath]];
	[d open];
	NSData *raw_data=[d leer:progress];
	[d close];
	
	Memory *data=malloc(sizeof(Memory));
	NSLog(@"%d - %d",sizeof(Memory),[raw_data length]);
	[raw_data getBytes:data];
	
	[progress setIndeterminate:YES];
	
	int n=0;
	int fin=false;
	
	
	
	while((!fin)){
		[progress startAnimation:self];
		Record *point = &(data->recodrs[n]);
		if((n%1000)==0) NSLog(@"%d",n);
		if((point->longitud!=-1) && (point->latitude!=-1))
		{			
			GPSPoint *gp=[GPSPoint alloc];
			[gp setLongitud:[self calcAngle:point->longitud]];
			[gp setLatitud:[self calcAngle:point->latitude]];
			[gp setAltitud:[NSNumber numberWithLong:(point->alt+18)]];
			[gp setVelocidad:[NSNumber numberWithChar:point->speed]];
			[gp setTag:[NSNumber numberWithChar:point->tag]];
			[gp setFecha:[self calcDate:point->date]];
			
			[tmpPoints addObject:gp];
			
		}else
		{
			fin=true;
		}
		n++;
	}
	
	free(data);
	[self parsePoints:tmpPoints];
	
	[pool release];
}

- (void)parsePoints:(NSArray *)tmpPoints
{
	
	points=[[tmpPoints sortedArrayUsingSelector:@selector(compare:)] retain];
	
	
	TrackNode *tn;
	GPSPoint *lastPoint;
	
	NSString *name=[NSString stringWithFormat:@" Track %d",[[tracks childNodes] count]];
	tn=[TrackNode treeNodeWithRepresentedObject:name];
	[tn setStartPoint:0];
	name=[NSString stringWithFormat:@" Ini. WayPoint"];
	PointNode *nodo=[PointNode treeNodeWithRepresentedObject:name];
	[nodo setPointIndex:0];
	[[tn mutableChildNodes] addObject:nodo];
	
	lastPoint=[points objectAtIndex:0];
	for(int n=0;n<[points count];n++){
		GPSPoint *gp=[points objectAtIndex:n];
		[gp setIndex:[NSNumber numberWithInt:n]];
		
		if([[gp fecha] timeIntervalSinceDate:[lastPoint fecha]]>(30*60))
		{
			NSString *name=[NSString stringWithFormat:@"End WayPoint"];
			PointNode *nodo=[PointNode treeNodeWithRepresentedObject:name];
			[nodo setPointIndex:n-1];
			[[tn mutableChildNodes] addObject:nodo];
			[tn setEndPoint:n-1];			
			NSLog(@"TrackNode %d-%d (%d)",[tn startPoint],[tn endPoint],[[tn mutableChildNodes]count]);
			
			[[tracks mutableChildNodes] addObject:tn];
			name=[NSString stringWithFormat:@" Track %d",[[tracks mutableChildNodes] count]];
			tn=[TrackNode treeNodeWithRepresentedObject:name];
			[tn setStartPoint:n];
			name=[NSString stringWithFormat:@" Ini. WayPoint"];
			nodo=[PointNode treeNodeWithRepresentedObject:name];
			[nodo setPointIndex:n];
			[[tn mutableChildNodes] addObject:nodo];
		}else if([[gp tag]intValue]!=-1)
		{
			NSString *name=[NSString stringWithFormat:@" WayPoint %d",[[tn mutableChildNodes] count]];
			PointNode *nodo=[PointNode treeNodeWithRepresentedObject:name];
			[nodo setPointIndex:n];
			[[tn mutableChildNodes] addObject:nodo];
		}
		[gp setTrack:tn];
		lastPoint=gp;
	}
	
	[tn setEndPoint:[points count]-1];
	name=[NSString stringWithFormat:@" Ini. WayPoint"];
	nodo=[PointNode treeNodeWithRepresentedObject:name];
	[nodo setPointIndex:[points count]-1];
	[[tn mutableChildNodes] addObject:nodo];
	
	[[tracks mutableChildNodes] addObject:tn];
	
	
	[self positionImages];
	
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

- (NSProgressIndicator *)progress
{
	return progress;
}

- (IBAction)exportToGPX:(id) sender
{
	NSXMLElement *root = [[NSXMLElement alloc] initWithName:@"gpx"];
	[root addAttribute:[NSXMLNode attributeWithName:@"creator" stringValue:@"http://gpslogger.laullon.ocm"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.topografix.com/GPX/1/0"]];
	[root addAttribute:[NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd"]];
	
	for(TrackNode *track in [tracks childNodes]){
		NSXMLElement *trk=[NSXMLElement elementWithName:@"trk"];
		[root addChild:trk];
		[trk addChild:[NSXMLElement elementWithName:@"name" stringValue:[track representedObject]]];
		NSXMLElement *trkseg=[NSXMLElement elementWithName:@"trkseg"];
		[trk addChild:trkseg];
		NSRange range = {[track startPoint], ([track endPoint]-[track startPoint])};
		for(GPSPoint *gp in [points subarrayWithRange:range]){
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
	[p setRequiredFileType:@"gpx"];
	if([p runModal]==NSFileHandlingPanelOKButton)
		[xml writeToFile:[p filename] atomically:true];
	
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
	for(photo in [photos childNodes]){
		[fotos addChild:[photo getKMLElement]];
	}
	
	NSMutableString *coors=[NSMutableString stringWithCapacity:((finMapaPoint-iniMapaPoint)*(12*2))];
	GPSPoint *gp;
	NSRange range = {iniMapaPoint, (finMapaPoint-iniMapaPoint)};
	for(gp in [points subarrayWithRange:range]){
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
	[root release];
	
	NSData *xml=[xmlRequest XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);

	NSSavePanel *p=[NSSavePanel savePanel];
	[p setRequiredFileType:@"kml"];
	if([p runModal]==NSFileHandlingPanelOKButton)
		[xml writeToFile:[p filename] atomically:true];
	
	
	//return [xmlRequest XMLData];
}

-(void)displayDeviceConfig:(NSDictionary *)config
{
	for (id key in config)
	{
		NSLog(@"key: %@, value: %@", key, [config objectForKey:key]);
		NSFormCell *cell=[deviceInfo addEntry:key];
		[cell setEditable:NO];
		[cell setStringValue:[config objectForKey:key]];
	}
	[deviceInfo setNeedsDisplay:YES];
}

AppController *appController;
static void initUSB(AppController *app)
{
	appController=app;
	CFMutableDictionaryRef matchingServices = IOServiceMatching(kIOSerialBSDServiceValue);
	CFDictionarySetValue(matchingServices, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDModemType));
	
	notePort = IONotificationPortCreate(kIOMasterPortDefault);
	runLoopSource = IONotificationPortGetRunLoopSource(notePort);
	
	CFRetain(matchingServices);
	IOServiceAddMatchingNotification(notePort, kIOFirstMatchNotification, matchingServices, MyDeviceAddedCallback, NULL, &addedIter);
	MyDeviceAddedCallback(NULL, addedIter);
	IOServiceAddMatchingNotification(notePort, kIOTerminatedNotification, matchingServices, MyDeviceRemovedCallback, NULL, &removedIter);
	MyDeviceRemovedCallback(NULL, removedIter);
	
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);
}


static void MyDeviceAddedCallback(void *refCon, io_iterator_t it)
{
	io_object_t svc;
	
	while (svc = IOIteratorNext(it)) {
		CFTypeRef name = IORegistryEntryCreateCFProperty(svc, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0);
		CFTypeRef basename = IORegistryEntryCreateCFProperty(svc, CFSTR(kIOTTYBaseNameKey), kCFAllocatorDefault, 0);
		CFTypeRef path = IORegistryEntryCreateCFProperty(svc, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		if ((NULL != name) && (NULL != basename) && (NULL != path)) {
			NSLog(@"-->name:'%@' basename:'%@' path:'%@'",name,basename,path);
			if([@"usbmodem" isEqual:[NSString stringWithFormat:@"%@",basename]]){
				Device *d=[Device alloc];
				[d setDeviceName:[NSString stringWithFormat:@"%@",path]];
				[d open];
				NSString *res=[d test];
				NSLog(@"test result --- '%@'",res);
				if([res hasPrefix:@"WondeProud Tech. Co. BT-CD110"] || [res hasPrefix:@"WP GPS+BT"]){
					[[appController statusBar] setStringValue:[NSString stringWithFormat:@"Device: '%@' Path: '%@'",res,path]];
					[appController setDevicePath:[NSString stringWithFormat:@"%@",path]];
					[d setDeviceName:[NSString stringWithFormat:@"%@",path]];
					[appController displayDeviceConfig:[d getConfig]];
				}else{
					
				}
				[d close];
			}
			CFRelease(path);
		}
		CFRelease(name);
	}
	IOObjectRelease(svc);
	
}

static void MyDeviceRemovedCallback(void *refCon, io_iterator_t it)
{
	io_object_t svc;
	
	while (svc = IOIteratorNext(it)) {
		CFTypeRef name = IORegistryEntryCreateCFProperty(svc, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0);
		if (NULL != name) {
			CFTypeRef path = IORegistryEntryCreateCFProperty(svc, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
			if (NULL != path) {
				NSLog(@"->%@",path);
				if([[appController devicePath] isEqualToString:[NSString stringWithFormat:@"%@",path]]){
					[[appController statusBar] setStringValue:[NSString stringWithFormat:@"Device: NO GPS DEVICE"]];
					[appController setDevicePath:@""];
				}
				CFRelease(path);
			}
			CFRelease(name);
		}
		IOObjectRelease(svc);
	}
}

- (void)webView:(WebView *)webView addMessageToConsole:(NSDictionary *)dictionary
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
    if ( selector == @selector(hola:) ) {
        return NO;
    }
    return YES;
}

- (NSString *)hola:(NSString *)txt
{
	PhotoNode *ph=[photosByName objectForKey:txt];
	NSString *res=[NSString stringWithFormat:@"<img src=\"%@\" width=\"%@\" height=\"%@\"/>",[[ph URL] absoluteString],[ph width],[ph height]]; 
	NSLog(@"html='%@'",res);
	return res;
}

//**************************//
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{ 
	/*ImageAndTextCell *imageAndTextCell = (ImageAndTextCell *)cell;
	 // Set the image here since the value returned from outlineView:objectValueForTableColumn:... didn't specify the image part...
	 [imageAndTextCell setTitle:@"ppppp"];
	 
	 NSLog(@"---------willDisplayCell---------");
	 if([item isKindOfClass:[NSTreeNode class]]){
	 
	 NSLog(@"---------%@---------",[item description]);
	 NSLog(@"---------%@---------",[[item representedObject]class]);
	 }
	 NSLog(@"---------willDisplayCell---------");
	*/
}
@end
