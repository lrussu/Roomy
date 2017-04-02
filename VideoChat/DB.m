//
//  DB.m
//  VideoWorkouts
//
//  Created by Farshx on 21/12/15.
//  Copyright © 2015 Farshx. All rights reserved.
//

#import "DB.h"

@interface DB (){
    NSString *db_full_path, *db_full_file_name, *db_path, *db_file_name, *db_file_extention;
}

@end

@implementation DB

+ (DB *)SI
{
    static DB* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DB alloc] init];
        [sharedInstance createVars];
        [sharedInstance openSQL];
    });
    return sharedInstance;
}
- (void)dealloc{
    sqlite3_close(self.contactDB);
}

- (void)createVars{
    db_path = [NSString stringWithFormat:@"%@/Documents/", NSHomeDirectory()];
    db_file_name = @"roomy";
    db_file_extention = @"db";
    db_full_file_name = [NSString stringWithFormat:@"%@.%@", db_file_name, db_file_extention];
    db_full_path = [NSString stringWithFormat:@"%@%@", db_path, db_full_file_name];
    
    NSFileManager* FM = [NSFileManager defaultManager];
    if (![FM fileExistsAtPath:db_full_path]){
        NSString *tempPath = [[NSBundle mainBundle] pathForResource:db_file_name ofType:db_file_extention];
        NSError *error;
        [FM copyItemAtPath:tempPath toPath:db_full_path error:&error];
        NSLog(@"%@", db_full_path);
        if (error){
            NSLog(@"Error copy db_file: %@", error);
        }
    }
    
}

- (void)setParametres:(NSArray *)params toStatement:(sqlite3_stmt *)statement{
    if (params != nil && params.count != 0){
        for (int i = 0; i < params.count; i++) {
            sqlite3_bind_text(statement, i+1, [[NSString stringWithFormat:@"%@", params[i]] UTF8String], -1, SQLITE_TRANSIENT);
        }
    }
}
- (BOOL)openSQL{
    const char *dbpath = [db_full_path UTF8String];
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK) {
        return true;
    }
    return false;
}

- (NSDictionary *)selectRowWithQyery:(NSString *)query andParams:(NSArray *)params{
    NSMutableDictionary *outData = [[NSMutableDictionary alloc] initWithCapacity:1];
    sqlite3_stmt *statement;
    const char *query_stmt = [query UTF8String];
    if (sqlite3_prepare_v2(_contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
        [self setParametres:params toStatement:statement];
        if (sqlite3_step(statement) == SQLITE_ROW){
            int countOfColums = sqlite3_column_count(statement);
            for (int i = 0; i < countOfColums; i++){
                NSString *columnKey, *columnValue;
                if (sqlite3_column_name(statement, i) != nil){
                    columnKey = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_name(statement, i)];
                }
                if (sqlite3_column_text(statement, i) != nil){
                    columnValue = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, i)];
                }
                sqlite3_column_type(statement, i);
                if (columnValue != nil && columnKey != nil){
                    [outData setObject:columnValue forKey:columnKey];
                }
            }
        }
        sqlite3_finalize(statement);
    }
    return outData;
}

- (NSArray *)selectRowsWithQyery:(NSString *)query andParams:(NSArray *)params{
    NSMutableArray *outData = [[NSMutableArray alloc] initWithCapacity:1];
    if (query != nil && ![query  isEqual: @""]){
        sqlite3_stmt *statement;
        const char *query_stmt = [query UTF8String];
        if (sqlite3_prepare_v2(_contactDB, query_stmt, -1, &statement, NULL) == SQLITE_OK){
            [self setParametres:params toStatement:statement];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int countOfColums = sqlite3_column_count(statement);
                NSMutableDictionary *tempData = [[NSMutableDictionary alloc] initWithCapacity:1];
                for (int i = 0; i < countOfColums; i++){
                    NSString *columnValue, *columnKey;
                    if (sqlite3_column_name(statement, i) != nil){
                        columnKey = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_name(statement, i)];
                    }
                    if (sqlite3_column_text(statement, i) != nil){
                        columnValue = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, i)];
                    }
                    if (columnValue != nil && columnKey != nil){
                        [tempData setObject:columnValue forKey:columnKey];
                    }
                }
                if (tempData != nil){
                    [outData addObject:tempData];
                }
            }
            sqlite3_finalize(statement);
        }
    }
    return outData;
}

- (BOOL)requestWithQuery:(NSString *)query andParams:(NSArray *)params{
    sqlite3_stmt*statement;
    sqlite3_prepare_v2(_contactDB, [query UTF8String], -1, &statement, NULL);
    [self setParametres:params toStatement:statement];
    BOOL finished = sqlite3_step(statement) == SQLITE_DONE;
    if (!finished){
        NSLog(@"%@", [[NSString alloc] initWithUTF8String:(const char *)sqlite3_errmsg(_contactDB)]);
    }
    sqlite3_finalize(statement);
    return finished;
}

@end
