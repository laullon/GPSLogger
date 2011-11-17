//
//  AppController.h
//  GPSLogger
//
//  Created by German Laullon on 30/09/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class PreferencesController;
@class PhotoNode;
@class SideBarDataSource;

@interface AppController : NSObject <NSOutlineViewDelegate> {
	IBOutlet NSWindow *mainWindow;

	IBOutlet NSTextFieldCell *timeOffsetTXT;
	IBOutlet NSSlider *timeOffset;
	IBOutlet NSPopUpButton *timeZones;

	IBOutlet WebView *web;
	
	IBOutlet NSImageView *imageViewer;
			
	PhotoNode *selectedPhoto;
	TrackNode *selectedTrack;
	
	NSDateFormatter *sISO8601;
    IBOutlet __weak SideBarDataSource *sideBarDS;
    IBOutlet __weak NSOutlineView *sideBar;
}


- (IBAction)readFromLoggerAction:(id)sender;
- (IBAction)addImagesAction:(id)sender;

- (IBAction)setPrecisionOffSet:(id)sender;

- (void)_applyGeoTags:(PhotoNode *)photo;
- (BOOL)setDateDigitized:(GPSPoint *)date forPhotoWithURL:(NSURL *)URL;

- (IBAction)showAllPhotosOnMap:(id)sender;
- (IBAction)applyGeoTags:(id)sender;
- (void)applyGeoTags;

- (IBAction)exportToKML:(id) sender;
- (IBAction)exportToGPX:(id) sender;

- (void)positionImages;

- (void)updateTrack:(TrackNode *)node;

- (void)awakeFromNib;
- (NSNumber *)calcAngle:(long)angle;
- (NSDate *)calcDate:(long) date;


- (NSString *)encode:(double)pos;

- (void)webView:(WebView *)sender setStatusText:(NSString *)text;
- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector;

- (void)selectPhoto:(PhotoNode *)ph;

- (IBAction)updateTimeOffset:(id)sender;

@end
