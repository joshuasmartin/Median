//
//  CTagsTableView.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "CTagsTableView.h"


@implementation CTagsTableView

- (void)awakeFromNib
{
    [self setDelegate:self];
}

- (void)keyDown:(NSEvent*)event
{
    BOOL deleteKeyEvent = NO;
    
    if ([event type] == NSKeyDown)
    {
        NSString* pressedChars = [event characters];
        if ([pressedChars length] == 1)
        {
            unichar pressedUnichar =
            [pressedChars characterAtIndex:0];
            
            if ( (pressedUnichar == NSDeleteCharacter) ||
                (pressedUnichar == 0xf728) )
            {
                deleteKeyEvent = YES;
            }
        }
    }
    
    // if it was a delete key, handle the event specially, otherwise call super.
    if (deleteKeyEvent)
    {
        // remove the selected files via the application delegate's method
        [appDelegate removeTagsAfterAlert];
    }
    else
    {
        [super keyDown:event];
    }
}

@end
