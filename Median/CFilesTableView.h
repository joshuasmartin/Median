//
//  CTableView.h
//  Median
//
//  Created by Joshua Martin on 6/16/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
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
