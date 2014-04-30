//
//  AppDelegate.h
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
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
- (NSString*)defaultProgressText;

@end
