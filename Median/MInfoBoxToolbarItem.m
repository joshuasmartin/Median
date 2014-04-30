//
//  MInfoBoxToolbarItem.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "MInfoBoxToolbarItem.h"

@implementation MInfoBoxToolbarItem

- (void)awakeFromNib
{
    [self setView:customView];
}

@end
