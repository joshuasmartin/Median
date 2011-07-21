//
//  CGradientView.h
//  Median
//
//  Created by Joshua Martin on 6/16/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CGradientView : NSView {
@private
    NSColor *startingColor;
    NSColor *endingColor;
    int angle;
}

// Define the variables as properties
@property(nonatomic, retain) NSColor *startingColor;
@property(nonatomic, retain) NSColor *endingColor;
@property(assign) int angle;

@end
