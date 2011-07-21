//
//  CTagsTableView.m
//  Median
//
//  Created by Joshua Martin on 6/23/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
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
