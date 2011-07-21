//
//  Version.h
//  Median
//
//  Created by Joshua Martin on 7/1/11.
//  Copyright (c) 2011 Joshua Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class File;

@interface Version : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * filesize;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) File * file;

- (NSString *)createdFormatted;

@end
