//
//  AppController.h
//  GPSLogger
//
//  Created by German Laullon on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TrackNode.h"
#import "ControlController.h"
#import "PointNode.h"

@class PreferencesController;
@class PhotoNode;

@interface AppController : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSArrayController *datos;
	IBOutlet NSTreeController *links;
	IBOutlet NSTableView *tabla;

	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSTextFieldCell *progressText;

	IBOutlet NSTextFieldCell *__weak statusBar;
	IBOutlet NSTextFieldCell *timeOffsetTXT;
	IBOutlet NSSlider *timeOffset;
	IBOutlet NSPopUpButton *timeZones;

	IBOutlet WebView *web;
	
	IBOutlet ControlController *control;
	IBOutlet NSButton *iniLock;
	IBOutlet NSButton *finLock;
	
	IBOutlet NSImageView *imageViewer;
	
	IBOutlet NSForm *deviceInfo;
		
	NSMutableArray *rootArray;
	NSArray *points;
	NSTreeNode *wayPoints;
	NSTreeNode *tracks;
	NSTreeNode *photos;
	
	int selectedPoint;
	PhotoNode *selectedPhoto;
	int iniMapaPoint;
	int finMapaPoint;
	TrackNode *selectedTrack;

	NSMutableDictionary *photosByName;

	NSString *devicePath;
	
	NSDateFormatter *sISO8601;
}

@property (readonly) NSTextFieldCell *statusBar;
@property (copy) NSString *devicePath;
@property (copy) PhotoNode *selectedPhoto;

- (void)addImages:(NSArray *)arrayPhotos;

- (IBAction)readFromLoggerAction:(id)sender;
- (IBAction)addImagesAction:(id)sender;
- (IBAction)noveSelectedPoind:(id)sender;

- (IBAction)setPrecisionOffSet:(id)sender;

- (void)_applyGeoTags:(PhotoNode *)photo;
- (BOOL)setDateDigitized:(GPSPoint *)date forPhotoWithURL:(NSURL *)URL;

- (IBAction)showAllPhotosOnMap:(id)sender;
- (IBAction)applyGeoTags:(id)sender;
- (void)applyGeoTags;

- (IBAction)exportToKML:(id) sender;
- (IBAction)exportToGPX:(id) sender;

- (void)positionImages;

-(IBAction)setIniMapPointAction:(id)sender;
-(IBAction)setFinMapPointAction:(id)sender;
-(void)setIniMapPoint:(int)point;
-(void)setFinMapPoint:(int)point;
-(void)updateMap;

- (NSDictionary *)encodeTrack:(int)ini to:(int)fin;

- (void)addImagesFromDisk:(NSArray *)files;

- (IBAction)updateView:(id)sender;
- (void)updateTrack:(TrackNode *)node;
- (void)updateWayPoint:(PointNode *)node;

- (void)setSelectedPoint:(int)index;

- (void)awakeFromNib;
- (NSProgressIndicator *)progress;
- (NSNumber *)calcAngle:(long)angle;
- (NSDate *)calcDate:(long) date;
- (GPSPoint *)findPoint:(NSDate *)fecha ini:(int)ini fin:(int)fin;

- (NSDate *)calcDateXML:(NSXMLNode *)date;

- (NSString *)encode:(double)pos;
- (NSNumber *)calcAngleXML:(NSXMLNode *)angle;

- (void)parsePoints:(NSArray *)tmpPoints;

- (void)webView:(WebView *)sender setStatusText:(NSString *)text;
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;

- (void)selectPhotoById:(NSString *)txt;
- (void)selectPhoto:(PhotoNode *)ph;

- (void)readFromGPXFile:(NSString *)file;
- (void)readFromNMEA0183:(NSURL *)file;

- (IBAction)updateTimeOffset:(id)sender;

static void initUSB(AppController *app);
static void MyDeviceAddedCallback(void *refCon, io_iterator_t it);
static void MyDeviceRemovedCallback(void *refCon, io_iterator_t it);

@end
