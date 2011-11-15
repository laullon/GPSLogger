//
//  GLFlickr.m
//  GPSLogger
//
//  Created by German Laullon on 16/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GLFlickr.h"
#import <CommonCrypto/CommonDigest.h>
#import "GPSPoint.h"

@implementation GLFlickr

- (void)awakeFromNib{
	KEY=@"87d05d091e021f14074ad6e2f170aeb4";
	SECRET=@"96ab771e145f5bef";
	
	[self loadDataFromDisk]; 	
	[self initSesion];
	[self saveDataToDisk];
	[progressText setObjectValue:@""];
}

- (void)_applyGeoTags:(PhotoNode *)photo
{
	NSString *photo_id=[[photo auxProperties] objectForKey:@"id"];
	GPSPoint *point=[photo gpsPoint];
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:TOKEN,@"auth_token",photo_id,@"photo_id",[point latitud],@"lat",[point longitud],@"lon",@"flickr.photos.geo.setLocation",@"method",nil];
	[self invokeFlickrService:args];
}

- (void)beginSheetSelector:(NSWindow *)modalForWindow delegate:(id)delegate didEndSelector:(SEL)alertDidEndSelector
{
	appController=delegate;
	addFotos=alertDidEndSelector;
	
	[NSApp beginSheet:panel modalForWindow:modalForWindow modalDelegate:self didEndSelector:nil contextInfo:nil];
	[progress startAnimation:self];
	NSArray *sets=[self loadPhotoStes];
	[collections setContent:sets];
	[progress stopAnimation:self];
	
}

- (void)endSheetSelector:(id)sender
{
	//[self listPhotos];
	[self performSelector:@selector(listPhotos) withObject:nil];
	//[self performSelectorInBackground:@selector(listPhotos) withObject:nil];
	
}

-(void)listPhotos
{
	[progress startAnimation:self];
	
	NSDictionary *set=[[collections selectedObjects] objectAtIndex:0];
	NSArray *photos=[self getPhotosFromPhotoSet:[set objectForKey:@"id"]];
	
	NSMutableArray *res=[NSMutableArray arrayWithCapacity:[photos count]];
	for(NSDictionary *p in photos)
	{
		NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:[p objectForKey:@"id"],@"photo_id",@"flickr.photos.getSizes",@"method",nil];
		NSXMLDocument *doc=[self invokeFlickrService:args];
		NSString *xq=[[NSBundle mainBundle] pathForResource:@"photosize" ofType:@"xq"];
		NSArray *sizes=[self transformXMLDocToArray:doc XQFile:xq];
		NSMutableDictionary *r=[NSMutableDictionary dictionaryWithDictionary:p];
		[r addEntriesFromDictionary:[sizes objectAtIndex:0]];
		[r setObject:self forKey:@"delegate"];
		[res addObject:r];
		
		[progressText setObjectValue:[NSString stringWithFormat:@"%d / %d",[photos count],[res count]]];
	}
	
	
	[appController performSelector:addFotos withObject:res];
	
	[NSApp endSheet:panel];
	[panel orderOut:self];
	
	
	
}

-(NSArray *)getPhotosFromPhotoSet:(NSString *)set_id
{
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:set_id,@"photoset_id",@"date_taken",@"extras",@"flickr.photosets.getPhotos",@"method",nil];
	NSXMLDocument *doc=[self invokeFlickrService:args];
	NSString *xq=[[NSBundle mainBundle] pathForResource:@"photolist" ofType:@"xq"];
	NSArray *res=[self transformXMLDocToArray:doc XQFile:xq];
	return res;
}

-(void)initSesion
{
	if(![self checkToken]){
		[self requestFrob];
		
		NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys: FROB,@"frob",@"write",@"perms",nil];
		NSURL *url=[NSURL URLWithString:[self prepareURLserviceWithSig:@"http://www.flickr.com/services/auth" params:args]];
		
		// XXX comprobar el resulatdo de esta funcion
		NSInteger res=NSRunInformationalAlertPanel(@"This program requires your authorization before it can read or modify your photos an data on Flickr" , 
												   @"Authorizing is a simple process which takes place in your web browser. When you're finished, return to this window to complete authorization and begin using GPSLogger\n\n(You must be connected to the Internet in order to authorize this program.)" ,
												   @"Authorize..." , @"cancel" , nil);
		if(res==1){
			[[NSWorkspace sharedWorkspace] openURL:url];
			res=NSRunInformationalAlertPanel(@"Return to this window after you have finished the authorization process on Flickr.com" , 
											 @"Once you're done, click the 'Complete Authorization' button below and you can begin using GPSLogger.\n\n(You can revoke this program's authorization at any time in your account page on Flickr.com)" ,
											 @"Complete Authorization" , @"cancel" , nil);
			if(res==1){
				
				init=[self requestToken];
			}
		}
	}
}

-(NSArray *)loadPhotoStes
{
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:NSID,@"user_id",@"flickr.photosets.getList",@"method",nil];
	NSXMLDocument *doc=[self invokeFlickrService:args];
	NSString *xq=[[NSBundle mainBundle] pathForResource:@"photosets" ofType:@"xq"];
	NSArray *res=[self transformXMLDocToArray:doc XQFile:xq];
	
	return res;
}

-(NSXMLDocument *)invokeFlickrService:(NSDictionary *)args
{
    NSError *error=nil;
	
	NSURL *url=[NSURL URLWithString:[self prepareURLserviceWithSig:@"http://api.flickr.com/services/rest/" params:args]];
	
	NSLog(@"invokeFlickrService url => %@",url);
	
	NSXMLDocument *doc=[[NSXMLDocument alloc] initWithContentsOfURL:url
															options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
															  error:&error];	
	if(error)
	{
		NSLog(@"%@:%@ Error saving context: %@", [self class], NSStringFromSelector(_cmd), [error localizedDescription]);
	}
	NSLog(@"OK");
	
	NSXMLElement *root=[doc rootElement];
	NSString *stat=[[root attributeForName:@"stat"]stringValue];
	BOOL res=[stat isEqualToString:@"ok"];
	if(!res){
		NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
		NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);
	}
	
	return doc;
}

-(NSArray *)transformXMLDocToArray:(NSXMLDocument *)doc XQFile:(NSString *)xq
{
	NSError *error;
	NSArray *titles=[doc objectsForXQuery:[NSString stringWithContentsOfFile:xq encoding:NSUTF8StringEncoding error:nil] error:&error];
	if(error)
	{
		NSLog(@"%@:%s error: %@", [self class], _cmd, [error localizedDescription]);
		NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
		NSLog(@"transformXMLDocToArray XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);

		return nil;
	}
	
	NSMutableArray *res=[NSMutableArray arrayWithCapacity:[titles count]];
	for(NSString *title in titles){
		NSLog(@"%@",title);
		
		@try {
			[res addObject:[title propertyList]];
		}
		@catch (id exception) {
			NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
		}
	}
	return res;
}

-(BOOL)checkToken
{
	NSError *error;
	if(TOKEN==nil) return false;
	
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:TOKEN,@"auth_token",@"flickr.auth.checkToken",@"method",nil];
	NSURL *url=[NSURL URLWithString:[self prepareURLserviceWithSig:@"http://api.flickr.com/services/rest/" params:args]];
	
	NSXMLDocument *doc=[NSXMLDocument alloc];
	[doc initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];
	
	NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"checkToken XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);

	NSXMLElement *root=[doc rootElement];
	NSString *stat=[[root attributeForName:@"stat"]stringValue];
	BOOL res=[stat isEqualToString:@"ok"];
	
	if(res){
		NSXMLElement *auth=[[root elementsForName:@"auth"] objectAtIndex:0];
		NSID=[[[[auth elementsForName:@"user"] objectAtIndex:0] attributeForName:@"nsid"]stringValue];
		NSString *perms=[[[auth elementsForName:@"perms"] objectAtIndex:0] objectValue];
		if(![perms isEqualToString:@"write"]) return false;
	}
	
	return res; 
}

-(BOOL)requestToken
{
	NSError *error;
	
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:FROB,@"frob",@"flickr.auth.getToken",@"method",nil];
	NSURL *url=[NSURL URLWithString:[self prepareURLserviceWithSig:@"http://api.flickr.com/services/rest/" params:args]];
	
	NSXMLDocument *doc=[NSXMLDocument alloc];
	[doc initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];
	
	NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);

	NSXMLElement *root=[doc rootElement];
	NSString *stat=[[root attributeForName:@"stat"]stringValue];
	if([stat isEqualToString:@"ok"]){
		NSXMLElement *auth=[[root elementsForName:@"auth"] objectAtIndex:0];
		TOKEN=[[[auth elementsForName:@"token"] objectAtIndex:0] objectValue];
		NSLog(@"TOKEN = %@",TOKEN);
		return true;
	}else{
		return false;
	}
}

-(void)requestFrob
{
	NSError *error;
	
	NSDictionary *args=[NSDictionary dictionaryWithObjectsAndKeys:@"flickr.auth.getFrob",@"method",nil];
	NSURL *url=[NSURL URLWithString:[self prepareURLserviceWithSig:@"http://api.flickr.com/services/rest/" params:args]];
	
	NSXMLDocument *doc=[NSXMLDocument alloc];
	[doc initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:&error];
	
	NSData *xml=[doc XMLDataWithOptions:NSXMLNodePrettyPrint];
	NSLog(@"XML Document\n%@", [NSString stringWithCString:[xml bytes] encoding:NSUTF8StringEncoding]);

	NSXMLElement *root=[doc rootElement];
	NSString *stat=[[root attributeForName:@"stat"]stringValue];
	if([stat isEqualToString:@"ok"]){
		FROB=[[[root elementsForName:@"frob"] objectAtIndex:0] objectValue];
		NSLog(@"FROB = %@",FROB);
	}
}

- (NSString *)prepareURLserviceWithSig:(NSString *)service params:(NSDictionary *)args
{
	NSString *api_sig=[self prepareSigString:args];
	NSString *res=[NSString stringWithFormat:@"%@?%@&api_sig=%@",service,[self prepareURLParamsString:args],api_sig];
	NSLog(@"URL => %@",res);
	return res;
}

/* **********************************************************************************
 ** OJO ***************************************************************************
 ** Ordena tu lista de argumentos alfabéticamente según el nombre del parámetro. **
 ********************************************************************************** */
- (NSString *)prepareSigString:(NSDictionary *)args
{
	NSMutableString *sig=[NSMutableString stringWithString:SECRET];
	[sig appendFormat:@"api_key%@",KEY];
	
	NSArray * paramas=[[args allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	for(id key in paramas)
		[sig appendFormat:@"%@%@",key,[args objectForKey:key]];
	NSString *res=[self md5Hash:sig];
	NSLog(@"prepareSigString sig => %@",sig);
	NSLog(@"prepareSigString res => %@",res);
	return res;
}

- (NSString *)prepareURLParamsString:(NSDictionary *)args
{
	NSMutableString *res=[[NSMutableString alloc] init];
	[res appendFormat:@"api_key=%@",KEY];
	for(id key in args)
		[res appendFormat:@"&%@=%@",key,[args objectForKey:key]];
	return res;
}

- (NSString *)md5Hash:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}



- (NSString *) pathForDataFile
{
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	NSString *folder = @"~/Library/Application Support/GPSLogger/";
	folder = [folder stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath: folder] == NO) {
		[fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
	} 
	NSString *fileName = @"GPSLogger.flickr";
	return [folder stringByAppendingPathComponent: fileName]; 
} 

- (void) saveDataToDisk
{
	NSString * path = [self pathForDataFile];
	NSMutableDictionary * rootObject; rootObject = [NSMutableDictionary dictionary]; 
	[rootObject setValue:TOKEN forKey:@"TOKEN"];
	[NSKeyedArchiver archiveRootObject: rootObject toFile: path];
} 

- (void) loadDataFromDisk
{
	NSString * path = [self pathForDataFile];
	NSDictionary * rootObject;
	rootObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	TOKEN=[rootObject valueForKey:@"TOKEN"];
} 
@end
