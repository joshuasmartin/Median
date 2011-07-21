//
//  MHumanReadableFileType.m
//  Median
//
//  Created by Joshua Martin on 7/6/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import "MHumanReadableFileType.h"


@implementation NSString (MHumanReadableFileType)

+ (NSString *)humanReadableFileType:(NSString *)path
{
    NSString *kind = nil;
    NSURL *url = [NSURL fileURLWithPath:[path stringByExpandingTildeInPath]];
    LSCopyKindStringForURL((CFURLRef)url, (CFStringRef *)&kind);
    return kind ? [kind autorelease] : @"";
}

@end
