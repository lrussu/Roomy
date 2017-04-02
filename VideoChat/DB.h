//
//  DB.h
//  VideoWorkouts
//
//  Created by Farshx on 21/12/15.
//  Copyright © 2015 Farshx. All rights reserved.
//

#import <sqlite3.h>
#import <UIKit/UIKit.h>

@interface DB : NSObject

@property (nonatomic) sqlite3 *contactDB;

+ (DB *)SI;

- (NSDictionary *)selectRowWithQyery:(NSString *)query andParams:(NSArray *)params;
- (NSArray *)selectRowsWithQyery:(NSString *)query andParams:(NSArray *)params;
- (BOOL)requestWithQuery:(NSString *)query andParams:(NSArray *)params;

@end
