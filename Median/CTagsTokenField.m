//
//  CTagsTokenField.m
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import "CTagsTokenField.h"
#import "Tag.h"


@implementation CTagsTokenField

- (void)awakeFromNib
{
    [self setDelegate:self];
}

/**
    Delegate method for NSTokenField. We don't want the user to see a list of tags the file
    already has, so we filter the completion list to not display them.
 */
- (NSArray *)tokenField:(NSTokenField *)tokenFieldArg completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex {
    
    // get all the tags that match the users input
    NSArray *allTags = [[tagsController content] valueForKey:@"name"];
    NSMutableArray *matchingTags = [NSMutableArray arrayWithArray:[allTags filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]]];
    
    // tags in the current file selection
    NSArray *existingTags = [[filesController selection] valueForKey:@"tags"];

    // will hold our tags to remove from the completion list
    NSMutableArray *removeTags = [[NSMutableArray alloc] initWithCapacity:0];
    
    // loop the completion list and add the ones we already
    // have to an array of ones to remove
    for (NSString *mTitle in matchingTags)
    {
        for (Tag *eTag in existingTags)
        {
            NSString *eTitle = [eTag valueForKey:@"title"];
            
            if (eTitle == mTitle)
            {
                [removeTags addObject:mTitle];
            }
        }
    }
    
    // remove the tags in the array
    for (NSObject *o in removeTags)
    {
        [matchingTags removeObject:o];
    }
    
    [removeTags dealloc];
    
    return matchingTags;
}

@end
