//
//  PhoneBookContact.m
//  Find The Words
//
//  Created by David Sahakyan on 1/12/13.
//  Copyright (c) 2013 Davit Sahakyan. All rights reserved.
//

#import "PhoneBookContact.h"
#import "BannerReviewClass.h"

@implementation PhoneBookContact

+ (UIImage *)imageWithImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outImage;
}

+ (PhoneBookContact *)contactWithName:(NSString *)name
                               mobile:(NSString *)mobile
                                email:(NSString *)email
                            imageData:(NSData *)imageData;
{
    PhoneBookContact *obj = [[PhoneBookContact alloc] init];
    //initing
    if (!name) {
        name = @"<Unknown contact>";
    }
    if (!email){
        email = @"No email";
    }
    if (imageData){
        obj.image = [PhoneBookContact imageWithImage:[UIImage imageWithData:imageData] scaleToSize:(isIpad) ? CGSizeMake(62, 62) : CGSizeMake(44, 44)];
    }else{
        obj.image = [UIImage imageNamed:@"6_no_user_img"];
    }
    obj.name = [NSString stringWithString:name];
    obj.email = [NSString stringWithString:email];

    NSString *originalString = mobile;
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:originalString.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:originalString];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
            
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    originalString = strippedString;
    if (strippedString.length == 0){
        originalString = @"<Unknown phone number>";
    }
    obj.mobile = originalString;
    return obj;
}

@end
