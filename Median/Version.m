//
//  Version.m
//  Median
//
//  Created by Joshua Martin on 7/1/11.
//  Copyright (c) 2011 Joshua Martin. All rights reserved.
//

#import "Version.h"
#import "File.h"


@implementation Version
@dynamic filesize;
@dynamic number;
@dynamic filename;
@dynamic created;
@dynamic comments;
@dynamic file;


- (NSString *)createdFormatted 
{
    //NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyy/MM/dd" options:0 locale:nil];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *cHistory = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[self valueForKey:@"created"]];
    NSDateComponents *cToday = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[[NSDate alloc] init]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // if current year
    if ([cHistory year] == [cToday year])
    {
        // if current month
        if ([cHistory month] == [cToday month])
        {
            // day
            if ([cHistory day] == [cToday day])
            {
                [dateFormatter setDateFormat:@"HH:mm a"];
                return [NSString stringWithFormat:@"Today %@", [dateFormatter stringFromDate:[self valueForKey:@"created"]]];
            }
            else
            {
                [dateFormatter setDateFormat:@"eee, MM-dd HH:mm a"];
                return [dateFormatter stringFromDate:[self valueForKey:@"created"]];
            }
        }
        // not current month
        else
        {
            [dateFormatter setDateFormat:@"MM-dd HH:mm a"];
            return [dateFormatter stringFromDate:[self valueForKey:@"created"]];
        }
    }
    // not current year
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm a"];
        return [dateFormatter stringFromDate:[self valueForKey:@"created"]];
    }
}

@end
