//
//  CVersionsTableView.h
//  Median
//
//  Created by Joshua Martin on 7/5/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface CVersionsTableView : NSTableView <NSTableViewDataSource, NSTableViewDelegate> {
@private
    IBOutlet AppDelegate *appDelegate;
    IBOutlet NSArrayController *filesController;
}

@end
