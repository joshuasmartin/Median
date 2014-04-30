//
//  CFileController.h
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "File.h"
#import "Version.h"

@interface CDataController : NSObject {
@private
    IBOutlet AppDelegate *localAppDelegate;
    IBOutlet NSProgressIndicator *localProgressIndicator;
    IBOutlet NSTextField *localProgressText;
    IBOutlet NSArrayController *versionsController;
}

- (BOOL)transferIndeterminate:(NSArray*)paths withTags:(NSArray*)tags;
- (BOOL)transferIndeterminate:(NSArray*)paths forFile:(File*)file;
- (BOOL)performTransferFromPath:(NSString*)sourcePath destinationDirectory:(NSString*)destinationDirectory destinationFilename:(NSString*)destinationFilename;
- (BOOL)saveVersionIndeterminate:(Version*)version toDirectory:(NSString*)toDirectory withName:(NSString*)withName;

//- (void)transfer:(NSArray*)paths;
//
//static void statusCallback (FSFileOperationRef fileOp,
//                            const FSRef *currentItem,
//                            FSFileOperationStage stage,
//                            OSStatus error,
//                            CFDictionaryRef statusDictionary,
//                            void *info
//                            );

@end
