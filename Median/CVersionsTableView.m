//
//  CVersionsTableView.m
//  Median
//
//  Created by Joshua Martin on 7/5/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import "CVersionsTableView.h"
#import "CDataController.h"


@implementation CVersionsTableView

- (void)awakeFromNib
{
    // accept only file drags and set datasource delegate
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    [self setDataSource:self];
    
    [self setDelegate:self];
    
    [self setDoubleAction:@selector(openVersion:)];
}

/**
    Delegate for drag and drop, validates the operations acceptible.
 */
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationCopy;
}

/**
    Delegate for drag and drop, performs the actual operation when the drag is accepted. Collects the list of filenames to be moved, and initiates the move with the CDataController.
 */
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    CDataController *dataController = [CDataController alloc];
    [dataController transferIndeterminate:files forFile:[[filesController selectedObjects] lastObject]];
    [dataController release];
    
    return YES;
}

- (void)keyDown:(NSEvent*)event
{
    BOOL deleteKeyEvent = NO;
    
    if ([event type] == NSKeyDown)
    {
        NSString* pressedChars = [event characters];
        if ([pressedChars length] == 1)
        {
            unichar pressedUnichar =
            [pressedChars characterAtIndex:0];
            
            if ( (pressedUnichar == NSDeleteCharacter) ||
                (pressedUnichar == 0xf728) )
            {
                deleteKeyEvent = YES;
            }
        }
    }
    
    // if it was a delete key, handle the event specially, otherwise call super.
    if (deleteKeyEvent)
    {
        // remove the selected files via the application delegate's method
        [appDelegate removeVersionsAfterAlert];
    }
    else
    {
        [super keyDown:event];
    }
}

@end
