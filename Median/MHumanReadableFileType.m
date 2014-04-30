//
//  MHumanReadableFileType.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
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
