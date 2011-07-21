//
//  MHumanReadableFileType.h
//  Median
//
//  Created by Joshua Martin on 7/6/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (MHumanReadableFileType)

+ (NSString*)humanReadableFileType:(NSString*)path;

@end
