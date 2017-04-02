//
//  LGPhonebook.h
//
//  Created by David Sahakyan on 2/6/13.
//  Copyright (c) 2013 David Sahakyan. All rights reserved.
//

#import "PhoneBookContact.h"

@interface LGPhonebook : NSObject

// Async loading of iOS contacts (alphabet sorted)
- (void)readContactsWithCallbackHandler:(void (^)(NSArray *contacts))callback;

// Calls to input number
- (NSError *)callPhoneNumber:(NSString *)number;

+ (instancetype)sharedInstance;

@end
