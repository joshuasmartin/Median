//
//  File.h
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Version.h"

@class Tag;

@interface File : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSNumber * filesize;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * lastVersionNumber;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * original_filename;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet* versions;
@property (nonatomic, retain) NSSet* tags;

- (Version *)mostRecentVersion;
- (NSString *)filesizeFormatted;
- (NSString *)createdFormatted;

@end
