//
//  GLFlickr.h
//  GPSLogger
//
//  Created by German Laullon on 16/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

// #### KEY #######################
// 87d05d091e021f14074ad6e2f170aeb4
// ################################

#import <Cocoa/Cocoa.h>
#import "PhotoNode.h"

@interface GLFlickr : NSObject {

	NSString *KEY;
	NSString *SECRET;
	NSString *FROB;
	NSString *TOKEN;
	NSString *NSID;
	BOOL init;
	
	IBOutlet NSArrayController *collections;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextField *progressText;

	IBOutlet NSPanel *panel;

	id appController;
	SEL addFotos;
}
- (void)_applyGeoTags:(PhotoNode *)PhotoNode;


- (void)beginSheetSelector:(NSWindow *)modalForWindow delegate:(id)modalDelegate didEndSelector:(SEL)alertDidEndSelector;
- (IBAction)endSheetSelector:(id)sender;

- (void)awakeFromNib;
- (void)initSesion;
- (NSString *)md5Hash:(NSString *)string;

-(void)listPhotos;

-(void)requestFrob;
-(BOOL)requestToken;
-(BOOL)checkToken;
-(NSArray *)loadPhotoStes;
-(NSArray *)getPhotosFromPhotoSet:(NSString *)set_id;

- (NSArray *)transformXMLDocToArray:(NSXMLDocument *)doc XQFile:(NSString *)xq;
-(NSXMLDocument *)invokeFlickrService:(NSDictionary *)args;
- (NSString *)prepareSigString:(NSDictionary *)args;
- (NSString *)prepareURLParamsString:(NSDictionary *)args;
- (NSString *)prepareURLserviceWithSig:(NSString *)service params:(NSDictionary *)args;

- (NSString *) pathForDataFile;
- (void) saveDataToDisk;
- (void) loadDataFromDisk;



@end
