//
//  AppDelegate.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"
#import "CDataController.h"
#import "CTagsValueTransformer.h"
#import "CStringWithUUID.h"
#import "MHumanReadableFileType.h"
#import "File.h"

@implementation AppDelegate

@synthesize window;

- (NSArray *)fetchAllWithEntity:(NSString *)entity
                          error:(NSError **)error
{
    NSFetchRequest *request;
    NSEntityDescription *desc;
    
    desc = [NSEntityDescription entityForName:entity
                       inManagedObjectContext:[self managedObjectContext]];
    
    request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:desc];
    
    return [[self managedObjectContext] executeFetchRequest:request error:error];	
}

- (id)init
{
    [super init];
    
    // initialize the in-memory context for an outline view
    NSError *error;
    NSURL *url = [NSURL URLWithString:@"memory://store"];
    id memoryStore = [[self persistentStoreCoordinator] persistentStoreForURL:url];
    
    NSManagedObject *section = [[NSEntityDescription insertNewObjectForEntityForName:@"Section"
                                             inManagedObjectContext:[self managedObjectContext]] retain];
    [section setValue:@"TAGS" forKey:@"name"];
    [[self managedObjectContext] assignObject:section
                            toPersistentStore:memoryStore];
    
    NSArray *items = [self fetchAllWithEntity:@"Tag" error:&error];
    for (id item in items) {
        [item setValue:section forKey:@"section"];
    }
    
    // initialize the value transformers
    CTagsValueTransformer *tagsTransformer = [[[CTagsValueTransformer
                                                        alloc] init] autorelease];
    [NSValueTransformer setValueTransformer:tagsTransformer forName:@"TagsSetToStringArray"];
    
    return self;
}

/**
    Code here runs after the application is initialized.
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // this sort descriptor says to sort alphabetically, in ascending order (A then B then C)
	// based on the property called title
    NSSortDescriptor* sortAcsendingByTitle = [[NSSortDescriptor alloc] 
                                              initWithKey:@"title" ascending:YES];
    NSSortDescriptor* sortAcsendingByNumber = [[NSSortDescriptor alloc] 
                                              initWithKey:@"number" ascending:YES];
	// tell our array controller to use our sort descriptor
	[filesController setSortDescriptors:[NSArray arrayWithObject: sortAcsendingByTitle]];
    [tagsController setSortDescriptors:[NSArray arrayWithObject: sortAcsendingByTitle]];
    [versionsController setSortDescriptors:[NSArray arrayWithObject: sortAcsendingByNumber]];
    
    [sortAcsendingByTitle release];
    [sortAcsendingByNumber release];
    
    // create the "Untagged" tag if necessary
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // fetch or create the "Untagged" tag so that if we delete a tag and its
    // files are not tagged anywhere else, the file can still exist
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // predicate to make sure we get only the "Untagged"
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(title = 'Untagged')"];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    // check if "Untagged" tag exists, if not, create it
    if ([fetchedObjects count] == 0)
    {
        // "Untagged" tag not found, create it
        NSManagedObject *untaggedTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        [untaggedTag setValue:@"Untagged" forKey:@"title"];
        
        // save our changes
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    [fetchRequest release];
    
    // set the text of the Application Directory textfield
    [textAppDirectory setStringValue:[[self applicationFilesDirectory] path]];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication hasVisibleWindows:(BOOL)flag
{
    [window makeKeyAndOrderFront:nil];
    return true;
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Median" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Median"];
}

/**
    Returns the directory the application uses to store the data files. This code uses directory named "Data" in the user's Library/Median directory.
 */
- (NSURL *)dataDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *dataDirectory = [[self applicationFilesDirectory] URLByAppendingPathComponent:@"Data"];
    NSError *error = nil;
    
    NSDictionary *properties = [dataDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[dataDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [dataDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    return dataDirectory;
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Median1.0.0" withExtension:@"momd"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Median.1.0.0" ofType:@"mom" inDirectory:@"Median.momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Median.storedata"];
    
    NSMutableDictionary *storeOptions = [[NSMutableDictionary alloc] init];
	[storeOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
        [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }
    
    url = [NSURL URLWithString:@"memory://store"];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                  configuration:nil URL:url options:nil
                                                    error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction) saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)addTagsAction:(id)sender
{
	NSManagedObject *insertedObject = [tagsController newObject];
	//unsigned newRow = [tagsTableView numberOfRows];
    int newRow = (int)[tagsTableView numberOfRows];
	[tagsController insertObject:insertedObject atArrangedObjectIndex:newRow];
	[tagsTableView editColumn:0 row:newRow withEvent:nil select:YES];
	[insertedObject release];
}

/**
    Action called via selector to execute the removeTags method, which initiates the actual remove operation after an NSAlert is displayed.
 */
- (IBAction)removeTagsAction:(id)sender
{
    [self removeTagsAfterAlert];
}

/**
    Displays an alert asking permission from the user to delete the selected tags in the array controller.
 */
- (void)removeTagsAfterAlert
{
    NSBeginAlertSheet(
                      @"Do you really want to delete the selected tags?",
                      // sheet message
                      @"Delete",              // default button label
                      nil,                    // no third button
                      @"Cancel",              // other button label
                      [self window],                 // window sheet is attached to
                      self,                   // we’ll be our own delegate
                      @selector(sheetDidEndShouldRemoveTags:returnCode:contextInfo:),
                      // did-end selector
                      NULL,                   // no need for did-dismiss selector
                      self,                 // context info
                      @"Any files in these tags that do not appear under any other tags will be moved to the \"Untagged\" tag.");
}

/**
    Method for the alert displayed in removeFile action. Performs the actual deletion of files if the alert was "approved".
 */
- (void)sheetDidEndShouldRemoveTags: (NSWindow *)sheet returnCode: (NSInteger)returnCode contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSError *error;
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSManagedObject *untaggedTag;
        
        // fetch or create the "Untagged" tag so that if we delete a tag and its
        // files are not tagged anywhere else, the file can still exist
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        // predicate to make sure we get only the "Untagged"
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(title = 'Untagged')"];
        [fetchRequest setPredicate:predicate];
        
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        // check if "Untagged" tag exists, if not, create it
        if ([fetchedObjects count] != 0)
        {
            untaggedTag = [fetchedObjects lastObject];
        }
        else
        {
            // "Untagged" tag not found, create it
            untaggedTag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
            [untaggedTag setValue:@"Untagged" forKey:@"title"];
        }
        [fetchRequest release];
        
        // iterate the selected tags
        for (NSManagedObject *t in [tagsController selectedObjects])
        {
            if ([[t valueForKeyPath:@"title"] isEqualToString:@"Untagged"] == NO)
            {
                // iterate each tag's files
                for (NSManagedObject *f in [t valueForKey:@"files"])
                {
                    // if this file has only one tag
                    if ([[f valueForKey:@"tags"] count] == 1)
                    {
                        // add the file to the untagged
                        [[f valueForKeyPath:@"tags"] addObject:untaggedTag];
                        [[untaggedTag valueForKeyPath:@"files"] addObject:f];
                    }
                }
                
                [context deleteObject:t];
            }
        }
        
        // save our changes
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

/**
    Displays a dialog from which the user may select files to be added to the selected tag.
 */
- (IBAction)addFilesAction:(id)sender
{
    mPanel = [NSOpenPanel openPanel];
    NSURL *startingDir = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"StartingDirectory"]];
    if (!startingDir)
        startingDir = [NSURL URLWithString:NSHomeDirectory()];
    [mPanel setDirectoryURL:startingDir];
    [mPanel setAllowsMultipleSelection:YES];
    [mPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        
        // if user clicked OK button
        if (result == NSFileHandlingPanelOKButton) {
            
            CDataController *dataController = [CDataController alloc];
            NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
            
            for (NSURL *url in [mPanel URLs])
            {
                [paths addObject:[url path]];
            }
            
            [dataController transferIndeterminate:paths withTags:[tagsController selectedObjects]];
            [dataController release];
        }
    }];
}

/**
    Action called by the remove button below the files table and the menu item.
 */
- (IBAction)removeFilesAction:(id)sender
{
    [self removeFilesAfterAlert];
}

/**
    Displays an alert asking permission from the user to delete the selected files in the array controller.
 */
- (void)removeFilesAfterAlert
{
    NSBeginAlertSheet(
                      @"Do you really want to delete the selected files?",
                      // sheet message
                      @"Delete",              // default button label
                      nil,                    // no third button
                      @"Cancel",              // other button label
                      window,                 // window sheet is attached to
                      self,                   // we’ll be our own delegate
                      @selector(sheetDidEndShouldRemoveFile:returnCode:contextInfo:),
                      // did-end selector
                      NULL,                   // no need for did-dismiss selector
                      self,                 // context info
                      @"The file data will be destroyed. This cannot be undone!");
}

/**
    Method for the alert displayed in removeFile action. Performs the actual deletion of files if the alert was "approved".
 */
- (void)sheetDidEndShouldRemoveFile: (NSWindow *)sheet returnCode: (NSInteger)returnCode contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // iterate the selected Files
        for (NSManagedObject *o in [filesController selectedObjects])
        {
            // now iterate and delete the selected Versions, delete their actual
            // files in the Data directory, and delete the File
            for (NSManagedObject *v in [o valueForKey:@"versions"])
            {
                [fileManager removeItemAtURL:[[self dataDirectory] URLByAppendingPathComponent:[v valueForKey:@"filename"]] error:nil];
            }
            
            [context deleteObject:o];
        }
        
        // save our changes
        NSError *error;
        
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [filesController rearrangeObjects];
    }
}

- (IBAction)openMostRecentVersion:(id)sender
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *dDirectory = [NSString stringWithFormat:@"%@%@", [[self dataDirectory] path], @"/"];
    
    for (File *o in [filesController selectedObjects])
    {
        NSString *dPath = [NSString stringWithFormat:@"%@%@", dDirectory, [[o mostRecentVersion] valueForKey:@"filename"]];
        [workspace openFile:dPath];
        
//        [progressIndicator stopAnimation:nil];
    }
}

- (IBAction)openVersion:(id)sender
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *dDirectory = [NSString stringWithFormat:@"%@%@", [[self dataDirectory] path], @"/"];
    
    NSString *dPath = [NSString stringWithFormat:@"%@%@", dDirectory, [[[versionsController selectedObjects] lastObject] valueForKey:@"filename"]];
    [workspace openFile:dPath];
}

- (IBAction)saveMostRecentVersionAsAction:(id)sender
{
    Version *version = [[[filesController selectedObjects] lastObject] mostRecentVersion];
    [self saveVersionAs:version];
}

- (IBAction)saveVersionAsAction:(id)sender
{
    Version *version = [[versionsController selectedObjects] lastObject];
    [self saveVersionAs:version];
}

- (void)saveVersionAs:(Version*)version
{
    NSSavePanel *sPanel = [NSSavePanel savePanel];
    NSURL *startingDir = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"StartingDirectory"]];
    if (!startingDir)
        startingDir = [NSURL URLWithString:NSHomeDirectory()];
    [sPanel setDirectoryURL:startingDir];
    [sPanel setCanCreateDirectories:YES];
    [sPanel setNameFieldStringValue:[[version valueForKey:@"file"] valueForKey:@"filename"]];
    [sPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        
        // if user clicked OK button
        if (result == NSFileHandlingPanelOKButton) {
            
            CDataController *dataController = [CDataController alloc];
            [dataController saveVersionIndeterminate:version toDirectory:[[sPanel directoryURL] path] withName:[sPanel nameFieldStringValue]];
            [dataController release];
        }
    }];
}

/**
    Displays a dialog from which the user may select a file to be added as a version to the selected file.
 */
- (IBAction)addVersionAction:(id)sender
{
    File *file = [[filesController selectedObjects] lastObject];
    mPanel = [NSOpenPanel openPanel];
    NSURL *startingDir = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"StartingDirectory"]];
    if (!startingDir)
        startingDir = [NSURL URLWithString:NSHomeDirectory()];
    [mPanel setDirectoryURL:startingDir];
    [mPanel setAllowsMultipleSelection:NO];
    [mPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        
        // if user clicked OK button
        if (result == NSFileHandlingPanelOKButton) {
            
            CDataController *dataController = [CDataController alloc];
            NSMutableArray *paths = [NSMutableArray arrayWithCapacity:0];
            
            for (NSURL *url in [mPanel URLs])
            {
                NSString *type = [file valueForKey:@"type"];
                if ([type isEqualToString:[NSString humanReadableFileType:[url path]]])
                {
                    [paths addObject:[url path]];
                    [dataController transferIndeterminate:paths forFile:file];
                }
                else
                {
                    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
                    [alert addButtonWithTitle:@"OK"];
                    [alert setMessageText:@"Verion's filetype does not match other versions' filetypes."];
                    [alert setInformativeText:@"You cannot mix and match multiple types of file formats for a File's Versions (i.e. all future versions must be PDF if the original version is PDF)."];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
                }
            }
            
            [dataController release];
        }
    }];
}

/**
    Action called by the remove button below the versions table.
 */
- (IBAction)removeVersionsAction:(id)sender
{
    [self removeVersionsAfterAlert];
}

/**
    Displays an alert asking permission from the user to delete the selected versions in the array controller.
 */
- (void)removeVersionsAfterAlert
{
    File *file = [[filesController selectedObjects] lastObject];
    
    if ([[file valueForKey:@"versions"] count] > 1)
    {
        NSBeginAlertSheet(
                          @"Do you really want to delete the selected versions?",
                          // sheet message
                          @"Delete",              // default button label
                          nil,                    // no third button
                          @"Cancel",              // other button label
                          window,                 // window sheet is attached to
                          self,                   // we’ll be our own delegate
                          @selector(sheetDidEndShouldRemoveVersion:returnCode:contextInfo:),
                          // did-end selector
                          NULL,                   // no need for did-dismiss selector
                          self,                 // context info
                          @"The file data will be destroyed. This cannot be undone!");
    }
    else
    {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Must have at least one version per file."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
}

/**
    Method for the alert displayed in removeVersionAfterAlert action. Performs the actual deletion of version if the alert was "approved".
 */
- (void)sheetDidEndShouldRemoveVersion: (NSWindow *)sheet returnCode: (NSInteger)returnCode contextInfo: (void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn)
    {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // iterate the selected Files
        for (NSManagedObject *v in [versionsController selectedObjects])
        {
            // now delete the actual file in the Data directory, and delete the Version
            [fileManager removeItemAtURL:[[self dataDirectory] URLByAppendingPathComponent:[v valueForKey:@"filename"]] error:nil];
            
            [context deleteObject:v];
        }
        
        // save our changes
        NSError *error;
        
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [versionsController rearrangeObjects];
    }
}

- (IBAction)openWebsite:(id)sender
{
    NSLog(@"clckd");
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.mediandocs.com/"]];
}

- (NSString*)defaultProgressText
{
    return @"Welcome to Median";
}

/**
    Delegate method for application. Called before application exits.
 */
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [super dealloc];
}

@end
