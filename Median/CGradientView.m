//
//  CGradientView.m
//  Median
//
//  Created by Joshua Martin on 6/16/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import "CGradientView.h"


@implementation CGradientView

// Automatically create accessor methods
@synthesize startingColor;
@synthesize endingColor;
@synthesize angle;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]];
        [self setEndingColor:[NSColor colorWithCalibratedWhite:0.7 alpha:1.0]];
        [self setAngle:270];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)rect {
    if (endingColor == nil || [startingColor isEqual:endingColor]) {
        // Fill view with a standard background color
        [startingColor set];
        NSRectFill(rect);
    }
    else {
        // Fill view with a top-down gradient
        // from startingColor to endingColor
        NSGradient* aGradient = [[NSGradient alloc]
                                 initWithStartingColor:startingColor
                                 endingColor:endingColor];
        [aGradient drawInRect:[self bounds] angle:angle];
        [aGradient dealloc];
    }
}

@end
