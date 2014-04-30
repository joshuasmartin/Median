//
//  Version.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
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
    NSString *formatted;
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
                formatted = [NSString stringWithFormat:@"Today %@", [dateFormatter stringFromDate:[self valueForKey:@"created"]]];
            }
            else
            {
                [dateFormatter setDateFormat:@"eee, MM-dd HH:mm a"];
                formatted = [dateFormatter stringFromDate:[self valueForKey:@"created"]];
            }
        }
        // not current month
        else
        {
            [dateFormatter setDateFormat:@"MM-dd HH:mm a"];
            formatted = [dateFormatter stringFromDate:[self valueForKey:@"created"]];
        }
    }
    // not current year
    else
    {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm a"];
        formatted = [dateFormatter stringFromDate:[self valueForKey:@"created"]];
    }
    
    [dateFormatter release];
    return formatted;
}

@end
