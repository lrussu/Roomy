//
//  AdsClass.m
//  PushUps
//
//  Created by Farshx on 05/02/16.
//  Copyright © 2016 99Sports. All rights reserved.
//

#import "AdsClass.h"
#import "BannerReviewClass.h"

//#error In-App Remove Ads
//#define kRemoveAds @""
@implementation AdsClass

+ (AdsClass *)SI{
    static AdsClass* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AdsClass alloc] init];
    });
    return sharedInstance;
}
- (void)completionBlock{
    if (comm != nil){
        comm();
    }
}

#pragma mark - Google Interstitial
- (void)googleInterstitial:(NSString *)unitID andPresentController:(UIViewController *)controller completion:(void(^)())completion{
//    if (![MKStoreManager isFeaturePurchased:kRemoveAds]){
        [LoadingView startLoadIn:controller.view];
        comm = completion;
        bannerController = controller;
        _gadInterstitial = [[GADInterstitial alloc] initWithAdUnitID:unitID];
        _gadInterstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        request.testDevices = @[
                                @"2eb8fcd4086aac223f9b6dc755cfea74",
                                @"d01c460023065d7b525a7ea142c79c66",
                                @"f1169bae3c6bfd1e80328cc8baa2a0d1",
                                @"d3644835ddfa4c909f513698302cc43c",
                                @"b97f279f696745fa401d13ea6483ee0f",
                                @"8c34ab6a9636f39c2584be50335b1f31",
                                kGADSimulatorID
                                ];
        [_gadInterstitial loadRequest:request];
//    }else{
//        if (completion != nil){
//            completion();
//        }
//    }
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    [LoadingView removeLoading];
    NSString *interstitiateShownKey = [NSString stringWithFormat:@"interstitiateViewLastShown_%@", ad.adUnitID];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSDate *lastShown = [userDef objectForKey:interstitiateShownKey];
    if (lastShown) {
        // calc time interval
        double timeInterval = [lastShown timeIntervalSinceNow];
        timeInterval = fabs(floor(timeInterval/60)); // minutes
        
        if (timeInterval >= 3) {
            [userDef setObject:[NSDate date] forKey:interstitiateShownKey];
            [_gadInterstitial presentFromRootViewController:bannerController];
        }else{
            [self completionBlock];
        }
    } else {
        [userDef setObject:[NSDate date] forKey:interstitiateShownKey];
        [_gadInterstitial presentFromRootViewController:bannerController];
    }
    [userDef synchronize];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"[GADInterstitial] error = %@", error);
    [LoadingView removeLoading];
    [self completionBlock];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    [LoadingView removeLoading];
//    UIAlertController *adsAlert = [UIAlertController alertControllerWithTitle:@"Remove Ads" message:@"Would you like to remove ads?" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove Ads" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[BannerReviewClass sharedInstance] getOn:kRemoveAds andDo:^{
//            [self completionBlock];
//        } elseDoS:^{
//            [self completionBlock];
//        } inView:bannerController.view];
//    }];
//    UIAlertAction *restoreAction = [UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[BannerReviewClass sharedInstance] reset:bannerController.view];
//        [self completionBlock];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [adsAlert dismissViewControllerAnimated:true completion:nil];
        [self completionBlock];
//    }];
//    [adsAlert addAction:removeAction];
//    [adsAlert addAction:restoreAction];
//    [adsAlert addAction:cancelAction];
//    [bannerController presentViewController:adsAlert animated:true completion:nil];
}

#pragma mark - Google BannerView
- (void)showGoogleBanner:(CGPoint)origin controller:(UIViewController *)controller inView:(UIView *)view unitID:(NSString *) unitID andSize:(GADAdSize)size{
//    if (![MKStoreManager isFeaturePurchased:kRemoveAds]){
        CGFloat bannerHeight = 0;
        if (isIpad) {
            bannerHeight = 90;
        } else {
            bannerHeight = 50;
        }
        GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:size origin:origin];
        bannerView.adUnitID = unitID;
        bannerView.rootViewController = controller;
        GADRequest *request = [GADRequest request];
        request.testDevices = @[
                                @"2eb8fcd4086aac223f9b6dc755cfea74",
                                @"d01c460023065d7b525a7ea142c79c66",
                                @"f1169bae3c6bfd1e80328cc8baa2a0d1",
                                @"d3644835ddfa4c909f513698302cc43c",
                                @"b97f279f696745fa401d13ea6483ee0f",
                                @"8c34ab6a9636f39c2584be50335b1f31",
                                kGADSimulatorID
                                ];
        [bannerView loadRequest:request];
        [bannerView setDelegate:self];
        [view addSubview:bannerView];
//    }
}

#pragma mark - GADBannerViewDelegate
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSInteger clicks = [[userDef objectForKey:@"gadBannerViewUserClicks"] integerValue];
    clicks++;
    [userDef setObject:[NSNumber numberWithInt:clicks] forKey:@"gadBannerViewUserClicks"];
    if (clicks >= 3) {
        bannerView.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"gadBannerViewLastShown"];
    }
    [userDef synchronize];
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    NSString *bannerClicksKey = [NSString stringWithFormat:@"gadBannerViewUserClicks_%@", bannerView.adUnitID];
    NSString *bannerDateKey = [NSString stringWithFormat:@"gadBannerViewLastShown_%@", bannerView.adUnitID];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSInteger clicks = [[userDef objectForKey:bannerClicksKey] integerValue];
    if (clicks) {
        // calc time interval
        NSDate *lastShown = [userDef objectForKey:bannerDateKey];
        double timeInterval = [lastShown timeIntervalSinceNow];
        timeInterval = fabs(floor(timeInterval/60)); // minutes
        if (clicks >=3 && timeInterval >= 4) {
            [userDef setObject:[NSNumber numberWithInt:0] forKey:bannerClicksKey];
            bannerView.hidden = NO;
        } else {
            bannerView.hidden = NO;
        }
        [userDef synchronize];
    } else {
        bannerView.hidden = NO;
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"[GADBannerView] didFailToReceiveAdWithError = %@", error);
    bannerView.hidden = true;
}

@end
