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

-(void)readFiles:(NSArray *)files;

-(NSArray *)photos;
-(NSArray *)tracks;

@end
