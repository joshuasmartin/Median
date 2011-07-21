//
//  CTagsTokenField.h
//  Median
//
//  Created by Joshua Martin on 6/22/11.
//  Copyright 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CTagsTokenField : NSTokenField <NSTokenFieldDelegate> {
@private
    IBOutlet NSArrayController *tagsController;
    IBOutlet NSArrayController *filesController;
}

@end
