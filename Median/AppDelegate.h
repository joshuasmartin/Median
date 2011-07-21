//
//  AppDelegate.h
//  Median
//
//  Created by Joshua Martin on 6/12/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Version.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSOpenPanel *mPanel;
    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
    IBOutlet NSArrayController *filesController;
    IBOutlet NSArrayController *tagsController;
    IBOutlet NSArrayController *versionsController;
    IBOutlet NSTableView *tagsTableView;
    IBOutlet NSTextField *textAppDirectory;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (NSURL*)applicationFilesDirectory;
- (NSURL*)dataDirectory;

- (IBAction)saveAction:sender;

- (IBAction)removeTagsAction:sender;
- (void)removeTagsAfterAlert;

- (IBAction)addFilesAction:sender;
- (IBAction)removeFilesAction:sender;
- (void)removeFilesAfterAlert;

- (IBAction)openMostRecentVersion:sender;
- (IBAction)openVersion:sender;
- (IBAction)saveMostRecentVersionAsAction:sender;
- (IBAction)saveVersionAsAction:sender;
- (void)saveVersionAs:(Version*)version;

- (IBAction)addVersionAction:sender;
- (IBAction)removeVersionsAction:sender;
- (void)removeVersionsAfterAlert;

- (IBAction)openWebsite:sender;

@end
