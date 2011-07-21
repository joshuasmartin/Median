//
//  Tag.h
//  Median
//
//  Created by Joshua Martin on 6/16/11.
//  Copyright (c) 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tag : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet* files;
@property (nonatomic, retain) NSManagedObject * section;

- (id)children;
- (NSString *)name;
- (NSString *)count;

@end
