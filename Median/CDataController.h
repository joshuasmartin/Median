//
//  CFileController.h
//  Median
//
//  Created by Joshua Martin on 6/17/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "File.h"
#import "Version.h"


static NSProgressIndicator *progressIndicator;
static AppDelegate *appDelegate;
static NSNumber *currentCopied;
static unsigned long long totalTransferCopied;

@interface CDataController : NSObject {
@private
    IBOutlet AppDelegate *localAppDelegate;
    IBOutlet NSProgressIndicator *localProgressIndicator;
    IBOutlet NSArrayController *versionsController;
}

- (BOOL)transferIndeterminate:(NSArray*)paths withTags:(NSArray*)tags;
- (BOOL)transferIndeterminate:(NSArray*)paths forFile:(File*)file;
- (BOOL)performTransferFromPath:(NSString*)sourcePath destinationDirectory:(NSString*)destinationDirectory destinationFilename:(NSString*)destinationFilename;
- (BOOL)saveVersionIndeterminate:(Version*)version toDirectory:(NSString*)toDirectory withName:(NSString*)withName;

- (void)transfer:(NSArray*)paths;

static void statusCallback (FSFileOperationRef fileOp,
                            const FSRef *currentItem,
                            FSFileOperationStage stage,
                            OSStatus error,
                            CFDictionaryRef statusDictionary,
                            void *info
                            );

@end
