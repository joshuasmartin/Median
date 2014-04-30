//
//  Version.h
//  Median Document Organizer
//
//  Copyright 2014 Joshua Shane Martin. Licensed under MIT license.
//
//  A copy of the MIT license may be found in the LICENSE file
//  or online at http://www.opensource.org/licenses/mit-license.php
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
