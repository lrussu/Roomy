//
//  StandartReview.m
//  BraincakeApps
//
//  Created by Farshx on 01.09.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import "StandartReview.h"
#import "BannerReviewClass.h"

@implementation StandartReview

- (instancetype)init{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    itunesAppID = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://vidlerr.com/"]];
    [manager POST:@"applications/reviews/braincakeApps.php?type=selfID"
       parameters:@{@"bundle": /*@"com.ss.smartalarmfree"}*/[[NSBundle mainBundle] bundleIdentifier]}
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              if (responseObject != nil){
                  [self loadItunesItems:responseObject[@"url"] and:^(NSDictionary *data) {
                      itunesAppID = responseObject[@"url"];//data[@"results"][0][@"trackId"];
                      [[MCImageCache sharedCache] loadImageWithURLPath:data[@"results"][0][@"artworkUrl512"] index:0 completionBlock:^(UIImage *image, NSUInteger returnIndex) {
                          if (returnIndex == 0){
                              icon = image;
                          }
                      }];
                  }];
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              
          }];
    title = [NSString stringWithFormat:@"Do you like %@?", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    message = @"Please take a minute to rate\nit in the AppStore.";
    
    return self;
}
+ (StandartReview *)SI
{
    static StandartReview* SI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SI = [[StandartReview alloc] init];
    });
    return SI;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    [UIView animateWithDuration:(isIpad)?0.4:0.3 animations:^{
        self.frame = [[UIScreen mainScreen] bounds];
        view.center = self.center;
    }];
}

- (void)loadItunesItems:(NSString *)itunesID and:(void (^)(NSDictionary* data))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *pattern = @"/id(.*)\\?ls";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:nil error:nil];
        NSTextCheckingResult *result = [regex firstMatchInString:itunesID options:nil range:NSMakeRange(0, itunesID.length)];
        NSRange range = [result rangeAtIndex:1];
        if (range.location != NSNotFound){
            NSString *substring = [itunesID substringWithRange:range];
            NSString *itunesLink = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", substring];
            NSData *jsonData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:itunesLink]];
            if (jsonData != nil){
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if ([data[@"resultCount"] integerValue] != 0){
                        completion(data);
                    }
                });
            }
        }
    });
}

-(void)showMessageInView:(UIView *)vieww{
    NSUserDefaults *UD = [NSUserDefaults standardUserDefaults];
    NSDate *date = [UD objectForKey:@"standartReview"];
    if (date != nil){
        NSTimeInterval dif = [[NSDate date] timeIntervalSinceDate:date] / 3600;
        if (dif < 24){
            return;
        }
    }
    if (view == nil){
        [self showNotification:vieww title:title message:message];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
        view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }];
}

- (void)showNotification:(UIView *)inView title:(NSString *)title2 message:(NSString *)message2{
    if (self.superview != nil){
        [self removeFromSuperview];
    }
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    UIImage *image = [UIImage imageNamed:@"alert-border"];
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    view.center = self.center;
    [self addSubview:view];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [view addSubview:imageView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.size.width, 40)];
    [view addSubview:titleLabel];
    titleLabel.text = title2;
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
    titleLabel.textColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, 183, 103)];
    [view addSubview:textLabel];
    textLabel.text = message2;
    textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    textLabel.textColor = [UIColor colorWithRed:16/255.0 green:16/255.0 blue:16/255.0 alpha:1.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.numberOfLines = 0;
    
    UIImage *iconImage = icon;
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.frame = CGRectMake(15, 56, 72, 72);
    iconImageView.layer.masksToBounds = true;
    iconImageView.layer.cornerRadius = 15;
    [view addSubview:iconImageView];
    
    UIButton *notNowButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 145, 142, 41)];
    [notNowButton setTitle:@"Not Now" forState:UIControlStateNormal];
    [notNowButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [notNowButton addTarget:self action:@selector(notNowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    notNowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
    [view addSubview:notNowButton];
    
    UIButton *rateNowButton = [[UIButton alloc] initWithFrame:CGRectMake(142, 145, 142, 41)];
    [rateNowButton setTitle:@"Rate Now" forState:UIControlStateNormal];
    [rateNowButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [rateNowButton addTarget:self action:@selector(rateNowButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    rateNowButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    [view addSubview:rateNowButton];
    
    [inView addSubview:self];
    self.alpha = 0;
    view.transform = CGAffineTransformMakeScale(0.5, 0.5);
}
-(IBAction)notNowButtonAction:(UIButton *)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [view removeFromSuperview];
        view = nil;
    }];
}
-(IBAction)rateNowButtonAction:(id)sender{
    [self notNowButtonAction:sender];
    NSURL *url = [NSURL URLWithString:itunesAppID];
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]){
        [app openURL:url];
    }
//    [[BannerReviewClass sharedInstance] openAppInAppStore:itunesAppID inController:(UIViewController *)[[self superview] nextResponder]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"standartReview"];
}


@end
