//
//  DragAndDropOutlineView.m
//  GPSLogger
//
//  Created by German Laullon on 17/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DragAndDropOutlineView.h"
#import "SideBarDataSource.h"

@implementation DragAndDropOutlineView

-(void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSMutableArray *files = [NSMutableArray array];
    for(NSPasteboardItem *item in [[sender draggingPasteboard] pasteboardItems]){
        NSURL *url = [NSURL URLWithString:[item stringForType:@"public.file-url"]];
        [files addObject:url];
    }
	SideBarDataSource *ds = self.dataSource;
    [ds readFiles:files];
    
    return YES;
}

@end
