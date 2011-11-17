//
//  SideBarDataSource.h
//  GPSLogger
//
//  Created by German Laullon on 16/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SideBarDataSource : NSObject <NSOutlineViewDataSource>
{
    @private
    NSTreeNode *root;
	NSTreeNode *tracks;
	NSTreeNode *photos;
}

-(void)readFromNMEA0183:(NSURL *)file;
-(void)readFromGPXFile:(NSURL *)file;
-(void)addImagesFromDisk:(NSArray *)files;

-(NSArray *)photos;
-(NSArray *)tracks;

-(NSNumber *)calcAngleXML:(NSXMLNode *)angle;
-(NSDate *)calcDateXML:(NSXMLNode *)date;

@end
