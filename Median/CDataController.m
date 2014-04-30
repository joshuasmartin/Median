//
//  CFileController.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "CDataController.h"
#import "CStringWithUUID.h"
#import "MHumanReadableFileType.h"
#import "File.h"
#import "Version.h"


static NSProgressIndicator *progressIndicator;
static NSTextField *progressText;
static AppDelegate *appDelegate;
static NSNumber *currentCopied;
//static unsigned long long totalTransferCopied;

@implementation CDataController

- (void)awakeFromNib
{
    [currentCopied initWithUnsignedLongLong:(unsigned long long)0];
    
    // hook up static progress indicator to our local one
    // that is connected in IB. allows us to update
    // the progress indicator in the callback
    progressIndicator = localProgressIndicator;
    [progressIndicator setUsesThreadedAnimation:YES];
    
    // hook up static progress text
    progressText = localProgressText;
    
    // hook up static app delegate
    appDelegate = localAppDelegate;
}

- (BOOL)transferIndeterminate:(NSArray*)paths withTags:(NSArray*)tags
{
    // Use the NSFileManager to obtain the size of our source file in bytes.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        
        for (NSString *sourcePath in paths)
        {
            BOOL sourceIsDir;
            if ([fileManager fileExistsAtPath:sourcePath isDirectory:&sourceIsDir] && !sourceIsDir)
            {
                NSString *dDirectory = [NSString stringWithFormat:@"%@%@", [[appDelegate dataDirectory] path], @"/"];
                NSString *dFilename = [NSString stringWithUUID];
                NSString *dPath = [NSString stringWithFormat:@"%@%@", dDirectory, dFilename];
                NSString *type = [NSString humanReadableFileType:sourcePath];
                
                // create a filesystem ref structure for the source and destination and
                // populate them with their respective paths
                FSRef source;
                FSRef destination;
                CFStringRef filename = (CFStringRef)dFilename;
                
                FSPathMakeRef( (const UInt8 *)[sourcePath fileSystemRepresentation], &source, NULL );
                
                Boolean isDir = true;
                FSPathMakeRef( (const UInt8 *)[dDirectory fileSystemRepresentation], &destination, &isDir );
                
                // start the progress bar and set text
                [progressIndicator startAnimation:nil];
                [progressText setStringValue:[NSString stringWithFormat:@"Copying %@", [sourcePath lastPathComponent]]];
                
                // start the sync copy
                OSStatus status = FSCopyObjectSync (&source,
                                                    &destination, // path to destination directory
                                                    filename, // use the same filename as source
                                                    NULL, // no need to reference object
                                                    kFSFileOperationDefaultOptions); // default options
                
                // copy the file
                if (status)
                {
                    NSLog(@"Failed to begin synchronous object move: %@", status);
                    return;
                }
                else
                {
                    
                }
                
                // make the file read only and owned by the current user to protect its content
                NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:400], NSFilePosixPermissions, NSUserName(), NSFileOwnerAccountName, nil];
                [fileManager setAttributes:attrs ofItemAtPath:dPath error:nil];
                
                // now save the file and version objects
                NSManagedObjectContext *context = [appDelegate managedObjectContext];
                
                // create the file entity
                NSManagedObject *file = [NSEntityDescription
                                         insertNewObjectForEntityForName:@"File"
                                         inManagedObjectContext:context];
                // file object attributes
                [file setValue:[sourcePath lastPathComponent] forKey:@"filename"];
                [file setValue:[sourcePath lastPathComponent] forKey:@"original_filename"];
                [file setValue:[sourcePath lastPathComponent] forKey:@"title"];
                [file setValue:type forKey:@"type"];
                
                [file setValue:[NSDate date] forKey:@"date"];
                [file setValue:[NSDate date] forKey:@"created"];
                
                [file setValue:[NSNumber numberWithInt:1] forKey:@"lastVersionNumber"];
                
                [file setValue:[NSSet setWithArray:tags] forKey:@"tags"];
                
                // file size
                NSDictionary *attributes = [fileManager attributesOfItemAtPath:dPath error:nil];
                NSNumber *size = [attributes objectForKey:NSFileSize];
                [file setValue:size forKey:@"filesize"];
                
                // create a new version for this file
                NSManagedObject *version = [NSEntityDescription
                                            insertNewObjectForEntityForName:@"Version"
                                            inManagedObjectContext:context];
                // version object attributes
                [version setValue:dFilename forKey:@"filename"];
                [version setValue:[NSNumber numberWithInt:1] forKey:@"number"];
                [version setValue:[NSDate date] forKey:@"created"];
                [version setValue:@"Initial" forKey:@"comments"];
                [version setValue:size forKey:@"filesize"];
                [version setValue:file forKey:@"file"];
                [[file valueForKey:@"versions"] addObject:version];
                
                // save the file
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
                
                [versionsController rearrangeObjects];
                
                // stop the animation and reset text
                [progressIndicator stopAnimation:nil];
                [progressText setStringValue:[appDelegate defaultProgressText]];
            }
            else
            {
                [progressText setStringValue:@"Failed to Copy File"];
                
                NSAlert *alert = [[[NSAlert alloc] init] autorelease];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Please provide files, not folders."];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:[appDelegate window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
            }
        }
    });
    
    return true;
}

- (BOOL)transferIndeterminate:(NSArray*)paths forFile:(File*)file
{   
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSString *dDirectory = [NSString stringWithFormat:@"%@%@", [[appDelegate dataDirectory] path], @"/"];
    
    for (NSString *sPath in paths)
    {
        // start the progress bar and set text
        [progressIndicator startAnimation:nil];
        [progressText setStringValue:[NSString stringWithFormat:@"Copying %@", [sPath lastPathComponent]]];
        
        NSString *dFilename = [NSString stringWithUUID];
        NSString *dPath = [NSString stringWithFormat:@"%@%@", dDirectory, dFilename];
        
        if ([self performTransferFromPath:sPath destinationDirectory:dDirectory destinationFilename:dFilename])
        {
            // make the file read only and owned by the current user to protect its content
            NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:400], NSFilePosixPermissions, NSUserName(), NSFileOwnerAccountName, nil];
            [fileManager setAttributes:attrs ofItemAtPath:dPath error:nil];
            
            // create the file entity
            NSManagedObject *version = [NSEntityDescription
                                        insertNewObjectForEntityForName:@"Version"
                                        inManagedObjectContext:context];
            
            // version object attributes
            [version setValue:file forKey:@"file"];
            [version setValue:dFilename forKey:@"filename"];
            [version setValue:[NSDate date] forKey:@"created"];
            
            // get the most recent number, and add one to it
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterNoStyle];
            NSNumber *number = [f numberFromString:[[[file mostRecentVersion] valueForKey:@"number"] stringValue]];
            [f release];
            
            int last = [number intValue];
            int new = last + 1;
            
            // set version number and the last version number of the file
            [version setValue:[NSNumber numberWithInt:new] forKey:@"number"];
            [file setValue:[NSNumber numberWithInt:new] forKey:@"lastVersionNumber"];
            
            // version's file size
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:dPath error:nil];
            NSNumber *size = [attributes objectForKey:NSFileSize];
            [version setValue:size forKey:@"filesize"];
            
            // add this new version to the file object
            [[file valueForKey:@"versions"] addObject:version];
            
            // save the file
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Couldn't save object: %@", [error localizedDescription]);
            }
            
            [progressText setStringValue:[appDelegate defaultProgressText]];
        }
        else
        {
            NSLog(@"Couldn't copy file.");
            [progressText setStringValue:@"Failed to Copy File"];
        }
        
        // stop the animation and reset text
        [progressIndicator stopAnimation:nil];
    }
    
    return true;
}

- (BOOL)performTransferFromPath:(NSString*)sourcePath destinationDirectory:(NSString*)destinationDirectory destinationFilename:(NSString*)destinationFilename
{
    // start the progress bar and set text
    [progressIndicator startAnimation:nil];
    [progressText setStringValue:[NSString stringWithFormat:@"Copying %@", [sourcePath lastPathComponent]]];
    
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL sourceIsDir;
    if ([fileManager fileExistsAtPath:sourcePath isDirectory:&sourceIsDir] && !sourceIsDir)
    {
        // create a filesystem ref structure for the source and destination and
        // populate them with their respective paths
        FSRef source;
        FSRef destination;
        CFStringRef filename = (CFStringRef)destinationFilename;
        
        FSPathMakeRef( (const UInt8 *)[sourcePath fileSystemRepresentation], &source, NULL );
        
        Boolean isDir = true;
        FSPathMakeRef( (const UInt8 *)[destinationDirectory fileSystemRepresentation], &destination, &isDir );
        
        // start the sync move
        OSStatus status = FSCopyObjectSync (&source,
                                            &destination, // path to destination directory
                                            filename, // use the same filename as source
                                            NULL, // no need to reference object
                                            kFSFileOperationDefaultOptions); // default options
        
        if (status)
        {
            NSLog(@"Failed to begin synchronous object move: %@", status);
            [progressText setStringValue:@"Failed to Copy File"];
        }
        else
        {
            success = YES;
            [progressText setStringValue:[appDelegate defaultProgressText]];
        }
    }
    
    // stop the animation and reset text
    [progressIndicator stopAnimation:nil];
    
    return success;
}

- (BOOL)saveVersionIndeterminate:(Version*)version toDirectory:(NSString *)toDirectory withName:(NSString *)withName
{
    NSString *sPath = [NSString stringWithFormat:@"%@/%@", [[appDelegate dataDirectory] path], [version valueForKey:@"filename"]];
    
    // create a filesystem ref structure for the source and destination and
    // populate them with their respective paths
    FSRef source;
    FSRef destination;
    CFStringRef filename = (CFStringRef)withName;
    
    FSPathMakeRef( (const UInt8 *)[sPath fileSystemRepresentation], &source, NULL );
    
    Boolean isDir = true;
    FSPathMakeRef( (const UInt8 *)[toDirectory fileSystemRepresentation], &destination, &isDir );
    
    // start the progress bar and set text
    [progressIndicator startAnimation:nil];
    [progressText setStringValue:[NSString stringWithFormat:@"Copying %@", [sPath lastPathComponent]]];
    
    // start the sync move
    OSStatus status = FSCopyObjectSync (&source,
                                        &destination, // path to destination directory
                                        filename, // use the same filename as source
                                        NULL, // no need to reference object
                                        kFSFileOperationDefaultOptions); // default options
    
    if (status)
    {
        NSLog(@"Failed to begin synchronous object copy: %@", status);
        [progressText setStringValue:@"Failed to Copy File"];
        
        return NO;
    }
    else
    {
        [progressText setStringValue:[appDelegate defaultProgressText]];
    }
    
    // stop the animation and reset text
    [progressIndicator stopAnimation:nil];
    
    return YES;
}

//- (void)transfer:(NSArray*)paths
//{
//    // Use the NSFileManager to obtain the size of our source file in bytes.
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    unsigned long long totalTransferSize = 0;
//    totalTransferCopied = 0; 
//    
//    for (NSString *sourcePath in paths)
//    {
//        NSDictionary *sourceAttributes = [fileManager attributesOfItemAtPath:sourcePath error:nil];
//        NSNumber *sourceFileSize;
//        
//        if ((sourceFileSize = [sourceAttributes objectForKey:NSFileSize]))
//        {
//            // add to total
//            totalTransferSize = totalTransferSize + [sourceFileSize unsignedLongLongValue];
//        }
//    }
//    
//    NSLog(@"before double %llu", totalTransferSize);
//    NSLog(@"after double %f", (double)totalTransferSize);
//    
//    // setup the progress bar
//    [progressIndicator setDoubleValue:0];
//    [progressIndicator setMaxValue:(double)totalTransferSize];
//    
//    for (NSString *sourcePath in paths)
//    {
//        NSLog(@"one path");
//        NSDictionary *sourceAttributes = [fileManager attributesOfItemAtPath:sourcePath error:nil];
//        NSNumber *sourceFileSize;
//        //NSString *destinationPath = [NSString stringWithFormat:@"%@%@", @"/tmp/", [sourcePath lastPathComponent]];
//        NSString *destinationPath = @"/tmp/";
//        
//        if (!(sourceFileSize = [sourceAttributes objectForKey:NSFileSize]))
//        {
//            // Couldn't get the file size so we need to bail.
//            NSLog(@"Unable to obtain size of file being copied.");
//            return;
//        }
//        
//        
//        // Get the current run loop and schedule our callback
//        CFRunLoopRef runLoop = CFRunLoopGetCurrent();
//        FSFileOperationRef fileOp = FSFileOperationCreate(kCFAllocatorDefault);
//        
//        OSStatus status = FSFileOperationScheduleWithRunLoop(fileOp, runLoop, kCFRunLoopDefaultMode);
//        if( status )
//        {
//            NSLog(@"Failed to schedule operation with run loop: %@", status);
//            return;
//        }
//        
//        // Create a filesystem ref structure for the source and destination and
//        // populate them with their respective paths from our NSTextFields.
//        FSRef source;
//        FSRef destination;
//        
//        FSPathMakeRef( (const UInt8 *)[sourcePath fileSystemRepresentation], &source, NULL );
//        
//        Boolean isDir = true;
//        FSPathMakeRef( (const UInt8 *)[destinationPath fileSystemRepresentation], &destination, &isDir );
//        
//        // Start the async copy.
//        status = FSCopyObjectAsync (fileOp,
//                                    &source,
//                                    &destination, // Full path to destination dir
//                                    NULL, // Use the same filename as source
//                                    kFSFileOperationDefaultOptions,
//                                    statusCallback,
//                                    1.0,
//                                    NULL);
//        
//        CFRelease(fileOp);
//        
//        if( status )
//        {
//            NSLog(@"Failed to begin asynchronous object copy: %@", status);
//        }
//    }
//}

//static void statusCallback (FSFileOperationRef fileOp,
//                            const FSRef *currentItem,
//                            FSFileOperationStage stage,
//                            OSStatus error,
//                            CFDictionaryRef statusDictionary,
//                            void *info )
//{
//    // If the status dictionary is valid, we can grab the current values
//    // to display status changes, or in our case to update the progress
//    // indicator.
//    if (statusDictionary)
//    {
//        CFNumberRef bytesCompleted;
//        
//        bytesCompleted = (CFNumberRef) CFDictionaryGetValue(statusDictionary, kFSOperationBytesCompleteKey);
//        
//        CGFloat floatBytesCompleted;
//        CFNumberGetValue (bytesCompleted, kCFNumberMaxType, &floatBytesCompleted);
//        
//        totalTransferCopied = (unsigned long long)floatBytesCompleted;
//        //currentCopied = [NSNumber numberWithUnsignedLongLong:(unsigned long long)floatBytesCompleted];
//        
//        NSLog(@"Copied %llu bytes so far.", totalTransferCopied);
//        [progressIndicator setDoubleValue:(double)totalTransferCopied];
//    }
//}

@end
