//
//  BannerReviewClass.h
//  Locker
//
//  Created by Mihail on 10.11.14.
//  Copyright (c) 2014 Mihail. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "AFNetworking.h"
#import "MoreAppsClass.h"
#import <MessageUI/MessageUI.h>
#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>
#import "StandartReview.h"
#import "VisitCard.h"

#define isIpad ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
#define kScreen ([UIScreen mainScreen].bounds)

@interface BannerReviewClass : NSObject <MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate>


@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *reviewURL;
@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) UIViewController *controller2;
@property (nonatomic, strong) MoreAppsClass *moreApps;

+ (BannerReviewClass *)sharedInstance;

- (UIImage *) screenshotFromController:(UIViewController *)controller;

- (BOOL)connected;

- (void)showBannerInController:(UIViewController *)controller;

- (void)showReview:(void(^)())block1 andDoBlock:(void(^)())block2;

- (void)doThis:(void(^)())block1 block:(void(^)())block2;

- (void)showMoreAppsInView:(UIView *)view;

- (void)support:(id)controller andEmail:(NSString *)email;


//-----
- (void)isOn:(NSString *)string doF:(void (^)())block1 elseDoS:(void(^)())block2;
- (void)getOn:(NSString *)string andDo:(void (^)())block1 elseDoS:(void (^)())block2 inView:(UIView *)view;
- (void)reset:(UIView *)view;
- (NSString *)md5String:(NSString *)string;

//-----
- (void)openAppInAppStore:(NSString *)itunesID inController:(UIViewController *)controller;

@end
