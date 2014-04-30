//
//  Tag.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "Tag.h"


@implementation Tag
@dynamic title;
@dynamic files;
@dynamic section;

- (void)addFilesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"files" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"files"] addObject:value];
    [self didChangeValueForKey:@"files" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeFilesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"files" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"files"] removeObject:value];
    [self didChangeValueForKey:@"files" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addFiles:(NSSet *)value {    
    [self willChangeValueForKey:@"files" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"files"] unionSet:value];
    [self didChangeValueForKey:@"files" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeFiles:(NSSet *)value {
    [self willChangeValueForKey:@"files" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"files"] minusSet:value];
    [self didChangeValueForKey:@"files" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (id)children 
{
    return nil;
}

- (NSString *)name 
{
    return [self valueForKey:@"title"];
}

- (NSString *)count 
{
    NSInteger count = [[self valueForKeyPath:@"files"] count];
    if (count == 0)
    {
        return @"";
    }
    else
    {
        return [NSString stringWithFormat:@"%d", count];
    }
}

@end
