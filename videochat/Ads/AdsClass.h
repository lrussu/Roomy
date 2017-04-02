//
//  AdsClass.h
//  PushUps
//
//  Created by Farshx on 05/02/16.
//  Copyright © 2016 99Sports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@import GoogleMobileAds;

@interface AdsClass : NSObject <GADInterstitialDelegate, GADBannerViewDelegate>{
    void(^comm)(void);
    UIViewController *bannerController;
}

+ (AdsClass *)SI;

- (void)googleInterstitial:(NSString *)unitID andPresentController:(UIViewController *)controller completion:(void(^)())completion;
- (void)showGoogleBanner:(CGPoint)origin controller:(UIViewController *)controller inView:(UIView *)view unitID:(NSString *) unitID andSize:(GADAdSize)size;

@property (nonatomic, strong) IBOutlet GADInterstitial *gadInterstitial;

@end
