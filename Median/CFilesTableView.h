//
//  CTableView.h
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface CFilesTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate> {
@private
    IBOutlet AppDelegate *appDelegate;
    IBOutlet NSArrayController *filesController;
    IBOutlet NSArrayController *tagsController;
}

@end
