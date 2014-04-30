//
//  MInfoBoxView.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "MInfoBoxView.h"
#import "NSShadow+MCAdditions.h" // from the tutorial linked to above
#import "NSBezierPath+MCAdditions.h" // from the same tutorial

@implementation MInfoBoxView


- (void)drawRect:(NSRect)dirtyRect {
    static NSShadow *kDropShadow = nil;
    static NSShadow *kInnerShadow = nil;
    static NSGradient *kBackgroundGradient = nil;
    static NSColor *kBorderColor = nil;
    
    if (kDropShadow == nil) {
        kDropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:.863 alpha:.75] offset:NSMakeSize(0, -1.0) blurRadius:1.0];
        kInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:0.0 alpha:.52] offset:NSMakeSize(0.0, -1.0) blurRadius:4.0];
        kBorderColor = [[NSColor colorWithCalibratedWhite:0.569 alpha:1.0] retain];
        // iTunes style
        /*
         kBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.929 green:0.945 blue:0.882 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.902 green:0.922 blue:0.835 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.78 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.949 green:0.961 blue:0.878 alpha:1.0],1.0, nil];
         */
        // Xcode style
        kBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.957 green:0.976 blue:1.0 alpha:1.0],0.0,[NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.918 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.831 green:0.851 blue:0.867 alpha:1.0],0.5,[NSColor colorWithCalibratedRed:0.82 green:0.847 blue:0.89 alpha:1.0],1.0, nil];
    }
    
    NSRect bounds = [self bounds];
    bounds.size.height -= 1.0;
    bounds.origin.y += 1.0;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:3.5 yRadius:3.5];
    
    [NSGraphicsContext saveGraphicsState];
    [kDropShadow set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
    
    [kBackgroundGradient drawInBezierPath:path angle:-90.0];
    
    [kBorderColor setStroke];
    [path strokeInside];
    
    [path fillWithInnerShadow:kInnerShadow];
}

@end
