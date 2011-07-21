//
//  CStringWithUUID.m
//  Median
//
//  Created by Joshua Martin on 6/20/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import "CStringWithUUID.h"


@implementation NSString (CStringWithUUID)

+ (NSString*) stringWithUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

@end
