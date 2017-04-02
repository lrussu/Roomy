//
//  LGPhonebook.m
//
//  Created by David Sahakyan on 2/6/13.
//  Copyright (c) 2013 David Sahakyan. All rights reserved.
//

#import "LGPhonebook.h"

#import <AddressBook/AddressBook.h>

@interface LGPhonebook ()

@property (nonatomic) ABAddressBookRef addressBook;

@end

static LGPhonebook *sharedInstance;

@implementation LGPhonebook

- (NSError *)callPhoneNumber:(NSString *)number
{
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"] ) {
        //Checking if phone number is provided
        if ([number length]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]]];
        } else {
            return [self errorWithMessage:NSLocalizedString(@"No phone number provided.", nil)];
        }
    } else {
        return [self errorWithMessage:NSLocalizedString(@"Your device doesn't support this feature.", nil)];
    }
    return nil;
}

- (NSError *)errorWithMessage:(NSString *)aMessage
{
    return [NSError errorWithDomain:@"com.logger.LGPhonebook"
                               code:100
                           userInfo:@{@"msg" : aMessage}];
}

- (ABAddressBookRef)addressBook
{
    if(_addressBook) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _addressBook = ABAddressBookCreate();
#pragma clang diagnostic pop
    }
    return _addressBook;
}

//-----------------------Check for iOS 6 --------------------------//
- (BOOL)isABAddressBookCreateWithOptionsAvailable
{
    return &ABAddressBookCreateWithOptions != NULL;
}
//-----------------------------------------------------------------//

- (void)addressBookInitWithCallbackHandler:(void (^)(LGPhonebook *api))callback
{
    if (![self isABAddressBookCreateWithOptionsAvailable]) {
        self.addressBook = ABAddressBookCreateWithOptions(NULL, nil);
        callback(self);
        return;
    }
    
    ABAddressBookRef addressBook;
    addressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    self.addressBook = addressBook;
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error || !granted) {
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:NSLocalizedString(@"Can't access AddressBook", nil)
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                  otherButtonTitles: nil] show];
            } else {
                CFRelease(addressBook);
                callback(self);
            }
        });
    });
}

- (void)readContactsWithCallbackHandler:(void (^)(NSArray *contacts))callback
{
    [self addressBookInitWithCallbackHandler:^(LGPhonebook *api) {
        NSArray *contacts = [self getAllContacts];
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedContacts = [contacts sortedArrayUsingDescriptors:sortDescriptors];
        callback(sortedContacts);
    }];
}

- (NSArray *)getAllContacts
{
    ABAddressBookRef addressBook = self.addressBook;
    PhoneBookContact *contact;
    NSMutableArray *contacts = [NSMutableArray array];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
//    NSMutableArray *emailList = [NSMutableArray array];
    
    
    //Cycle For All Contacts
    for ( int i = 0; i < nPeople; i++ ) {
//        [emailList removeAllObjects];
        NSString *bufName;
        NSString *bufEmail;
        //Reading From AddressBook
        
        //Getting Person
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        //Getting Name & Surname
        bufName = (__bridge NSString*)ABRecordCopyCompositeName(person);
        //Getting Email List
        ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
        
        //Getting Email Count
        long emailCount = ABMultiValueGetCount(emails);
        
        //Cycle For Emails
        for (int j = 0 ; j < emailCount ; j++) {
            CFStringRef email = ABMultiValueCopyValueAtIndex(emails, j);
            bufEmail = (__bridge NSString*) email;
//            [emailList addObject:bufEmail];
            CFRelease(email);
            break;
        }
        CFRelease(emails);
        
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(person, kABPersonPhoneProperty));
        NSString *mobile = @"";
        NSString *mobileLabel;
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
            } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
                mobile = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i);
                break ;
            }
        }
        CFDataRef imageData2 = ABPersonCopyImageData(person);
        NSData *imageData;
        if (imageData2 != nil){
            imageData = [NSData dataWithData:(__bridge NSData *)(imageData2)];
            CFRelease(imageData2);
        }
        // Initing Object
        contact = [PhoneBookContact contactWithName:bufName mobile:mobile email:bufEmail imageData: imageData];
        [contacts addObject:contact];
    }
    
    CFRelease(allPeople);
    
    return contacts;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [LGPhonebook new];
    });
    return sharedInstance;
}

@end
