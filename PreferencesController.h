//
//  PreferencesController.h
//  GPSLogger
//
//  Created by German Laullon on 18/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppController;


@interface PreferencesController : NSObject {
	IBOutlet NSTextField *DD;
	IBOutlet NSTextField *HH;
	IBOutlet NSTextField *MM;
	IBOutlet NSTextField *SS;
	IBOutlet NSComboBox *gpstz;
	IBOutlet NSComboBox *phototz;
	IBOutlet NSPanel *panel;
	
	IBOutlet AppController *appController;

	IBOutlet NSArrayController *timezonesController;
	
}

- (void)awakeFromNib;

- (IBAction)show:(id)sender;
- (IBAction)hide:(id)sender;

- (IBAction)setupDD:(id)sender;
- (IBAction)setupHH:(id)sender;
- (IBAction)setupMM:(id)sender;
- (IBAction)setupSS:(id)sender;

@end
