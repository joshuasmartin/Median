//
//  CTagsValueTransformer.m
//  Median
//
//  Created by Joshua Martin on 6/20/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import "CTagsValueTransformer.h"
#import "Tag.h"


@implementation CTagsValueTransformer

- (id)transformedValue:(id)value {
    if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = (NSSet *)value;
        NSMutableArray *ary = [NSMutableArray arrayWithCapacity:[set count]];
        for (Tag *tag in [set allObjects]) {
            [ary addObject:tag.name];
        }
        return ary;
    }
    return nil;
}

- (id)reverseTransformedValue:(id)value {
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *ary = (NSArray *)value;
        if ([ary count] != 0)
        {
            // Check each NSString in the array representing a Tag name if a corresponding
            // tag managed object already exists
            NSMutableSet *tagSet = [NSMutableSet setWithCapacity:[ary count]];
            for (NSString *tagName in ary) {
                NSManagedObjectContext *context = [[NSApp delegate] managedObjectContext];
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                
                NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"title = %@", tagName];
                NSEntityDescription *entity = [NSEntityDescription entityForName:[Tag className] inManagedObjectContext:context];
                
                [request setEntity:entity];
                [request setPredicate:searchFilter];
                
                NSError *error = nil;
                NSArray *results = [context executeFetchRequest:request error:&error];
                if ([results count] > 0) {
                    [tagSet addObjectsFromArray:results];
                }
                else {
                    Tag *tag = [[Tag alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
                    tag.title = tagName;
                    
                    [tagSet addObject:tag];
                    [tag release];
                }
            }
            return tagSet;
        }
    }
    return nil;
}

@end
