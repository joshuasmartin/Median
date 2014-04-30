//
//  CTableView.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "CFilesTableView.h"
#import "CDataController.h"


@implementation CFilesTableView

- (void)awakeFromNib
{
    // accept only file drags and set datasource delegate and table delegate
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSFilesPromisePboardType, nil]];
    [self setDataSource:self];
    [self setDelegate:self];
    
    // double clicks should open the most recent version of the selected file
    [self setDoubleAction:@selector(openMostRecentVersion:)];
    
    // set the allowed drag source operations
    [self setDraggingSourceOperationMask:NSDragOperationNone forLocal:YES]; //local
    [self setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO]; // external
}

/**
    Delegate for drag and drop, validates the operations acceptible.
 */
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    return NSDragOperationCopy;
}

/**
    Delegate for drag and drop, performs the actual operation when the drag is accepted. Collects the list of filenames to be moved, and initiates the move with the CFileController.
 */
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    CDataController *dataController = [CDataController alloc];
    [dataController transferIndeterminate:files withTags:[tagsController selectedObjects]];
    [dataController release];
    
    return YES;
}

/**
    Delegate for drag and drop that returns whether or not a drag and drop operation should begin and sets the data to the pasteboard.
 */
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // set the pasteboard for HFS promises only
    [pboard declareTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, nil] owner:self];
    
    // the pasteboard must know the type of files being promised
    NSMutableArray *filenameExtensions = [NSMutableArray array];
    
    // iterate the selected files and get the extension from each file
    NSArray * selectedObjects = [filesController selectedObjects];
    for (File *o in selectedObjects) {
        NSString *filename = [o valueForKey:@"filename"];
        
        NSString *filenameExtension = [filename pathExtension];
        if (![filenameExtension isEqualToString:@""]) {
            [filenameExtensions addObject:filenameExtension];
        }
    }
    
    // give the pasteboard the file extensions
    [pboard setPropertyList:filenameExtensions
                    forType:NSFilesPromisePboardType];
    
    return YES;
}

/**
    Delegate for drag and drop returns an array of the filenames.
 */
- (NSArray *)tableView:(NSTableView *)aTableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet
{
    // return of the array of file names
    NSMutableArray *draggedFilenames = [NSMutableArray array];
    
    // iterate the selected files
    NSArray * selectedObjects = [filesController selectedObjects];
    for (File *f in selectedObjects) {
        [draggedFilenames addObject:[f valueForKey:@"filename"]];
        
        // the file's pretty filename (i.e. filename.txt)
        NSString *fFilename = [f valueForKey:@"filename"];
        // the file's most recent version's unique id
        NSString *vFilename = [[f mostRecentVersion] valueForKey:@"filename"];
        
        NSString *fullPathToOriginal = [NSString stringWithFormat:@"%@/%@", [[appDelegate dataDirectory] path], vFilename];
        NSString *destPath = [[dropDestination path] stringByAppendingPathComponent:fFilename];
        
        // if a file with the same name exists on the destination, append " - Copy" to the filename
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:destPath];
        
        if (fileExists)
        {
            fFilename = [NSString stringWithFormat:@"%@ - Copy.%@", [[fFilename lastPathComponent] stringByDeletingPathExtension],[fFilename pathExtension]];
        }
        
        // perform the actual copy
        CDataController *dataController = [CDataController alloc];
        [dataController performTransferFromPath:fullPathToOriginal destinationDirectory:[dropDestination path] destinationFilename:fFilename];
        [dataController release];
    }
    
    return draggedFilenames;
}

/**
    Handle delete key presses by removing the selected files.
 */
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
        [appDelegate removeFilesAfterAlert];
    }
    else
    {
        [super keyDown:event];
    }
}

@end
