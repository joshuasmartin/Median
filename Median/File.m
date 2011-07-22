//
//  File.m
//  Median
//
//  Created by Joshua Martin on 6/29/11.
//  Copyright (c) 2011 Joshua Martin. All rights reserved.
//

#import "File.h"
#import "Tag.h"
#import "Version.h"


@implementation File
@dynamic comments;
@dynamic filesize;
@dynamic title;
@dynamic date;
@dynamic lastVersionNumber;
@dynamic filename;
@dynamic original_filename;
@dynamic type;
@dynamic versions;
@dynamic tags;

- (void)addVersionsObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"versions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"versions"] addObject:value];
    [self didChangeValueForKey:@"versions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeVersionsObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"versions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"versions"] removeObject:value];
    [self didChangeValueForKey:@"versions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addVersions:(NSSet *)value {    
    [self willChangeValueForKey:@"versions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"versions"] unionSet:value];
    [self didChangeValueForKey:@"versions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeVersions:(NSSet *)value {
    [self willChangeValueForKey:@"versions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"versions"] minusSet:value];
    [self didChangeValueForKey:@"versions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addTagsObject:(Tag *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"tags"] addObject:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeTagsObject:(Tag *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"tags"] removeObject:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addTags:(NSSet *)value {    
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"tags"] unionSet:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeTags:(NSSet *)value {
    [self willChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"tags"] minusSet:value];
    [self didChangeValueForKey:@"tags" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (NSString *)filesizeFormatted
{
    int theSize = [[self valueForKey:@"filesize"] intValue];
    float floatSize = theSize;
    
    if (theSize<999)
        return([NSString stringWithFormat:@"%i bytes",theSize]);
        floatSize = floatSize / 1000;
    
    if (floatSize<999)
        return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
        floatSize = floatSize / 1000;
    
    if (floatSize<999)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
        floatSize = floatSize / 1000;
    
    return([NSString stringWithFormat:@"%1.1f GB", floatSize]);
}

- (Version *)mostRecentVersion {
    NSSortDescriptor *sDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES] autorelease];
    NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sDescriptor, nil] autorelease];
    
    NSArray *sorted = [[self valueForKey:@"versions"] sortedArrayUsingDescriptors:sortDescriptors];
    
    return [sorted lastObject];
}

- (NSString *)createdFormatted 
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSString *formatted;
    
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
