//
//  CTagsTableView.h
//  Median
//
//  Created by Joshua Martin on 6/23/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface CTagsTableView : NSTableView <NSTableViewDelegate> {
@private
    IBOutlet AppDelegate *appDelegate;
}

@end
