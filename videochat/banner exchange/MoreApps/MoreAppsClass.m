//
//  MoreAppsClass.m
//  moreApps
//
//  Created by Farshx on 15.07.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import "MoreAppsClass.h"
#import "BannerReviewClass.h"

@interface MoreAppsClass (){
    int countOfApps, realApps;
    CGFloat width2, width3, cornerRadius, cornerRadiusMini;
    NSMutableArray *applications, *appleIds;
}

@end
@implementation MoreAppsClass
@synthesize closeButton;

- (instancetype)init{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    [LoadingView startLoadIn:self];
    self.contentScroll = [[UIScrollView alloc] initWithFrame:self.frame];
    self.contentScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.viewsArray = [[NSMutableArray alloc] initWithCapacity:1];
    width2  = (isIpad)? 394 : 225;
    width3  = (isIpad)? 350 : 195;
    cornerRadius = (isIpad)? 12 : 8;
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (isIpad)? 60 : 44)];
    [closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:[UIImage imageNamed:@"9_close"] forState:UIControlStateNormal];
    [closeButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.01]];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(15, 0, 0, 0)];
    [self addSubview:closeButton];
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://vidlerr.com"]];
    
    [manager POST:@"/applications/reviews/more.php"
       parameters:@{@"bundle": [[NSBundle mainBundle] bundleIdentifier]}
         progress:nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              NSDictionary *resp = (NSDictionary *)responseObject;
              if (resp[@"data"] != nil && resp[@"error"] == nil){
                  applications = [[NSMutableArray alloc] initWithCapacity:1];
                  appleIds = [[NSMutableArray alloc] initWithCapacity:1];
                  for (NSDictionary *dic in resp[@"data"]) {
                      [appleIds addObject:dic[@"appleID"]];
                  }
                  [self loadAllApplications];
              }else{
                  [LoadingView removeLoading];
              }
          } failure:^(NSURLSessionDataTask *operation, NSError *error) {
              [LoadingView removeLoading];
          }];
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    self.frame = [[UIScreen mainScreen] bounds];
}

- (void)loadAllApplications{
    realApps = 0;
    for (NSString* str in appleIds) {
        [self loadItunesItems:str and:^(NSDictionary *data) {
            if (data != nil){
                [applications addObject:data[@"results"][0]];
            }
            if (applications.count == appleIds.count - realApps){
                [self createMoreApps];
            }
        }];
    }
}
- (void)loadItunesItems:(NSString *)itunesID and:(void (^)(NSDictionary* data))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *itunesLink = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", itunesID];
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:itunesLink]];
        if (jsonData != nil){
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if ([data[@"resultCount"] integerValue] != 0){
                    completion(data);
                }else{
                    realApps++;
                    completion(nil);
                }
            });
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                realApps++;
                completion(nil);
            });
        }
    });
}
- (void)setCurrentItem:(int)currentItem{
    if (currentItem < countOfApps && currentItem >= 0){
        CGFloat x = (width2 / 2 - self.frame.size.width / 2) + (currentItem * width2);
        [_contentScroll setContentOffset:CGPointMake(x, 0) animated:true];
        [UIView animateWithDuration:0.2 animations:^{
            for (int i = 0; i < self.viewsArray.count; i++){
                UIView *view = [self.viewsArray objectAtIndex:i];
                if (i != currentItem){
                    [view setFrame:CGRectMake(width2 * i + ((width2 - width3) / 2), view.frame.origin.y, width3, view.frame.size.height)];
                    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[UIButton class]]){
                            ((UIButton *)obj).backgroundColor = [UIColor clearColor];
                        }
                    }];
                }else{
                    [view setFrame:CGRectMake(width2 * i, view.frame.origin.y, width2, view.frame.size.height)];
                    [view.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[UIButton class]]){
                            ((UIButton *)obj).backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
                        }
                    }];
                }
            }
        }];
        _currentItem = currentItem;
    }
}
- (IBAction)leftSwipeAction:(id)sender{
    self.currentItem++;
}
- (IBAction)rightSwipeAction:(id)sender{
    self.currentItem--;
}

- (void)createMoreApps{
    
    
    UISwipeGestureRecognizer *leftSwipe  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeAction:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeAction:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.contentScroll setScrollEnabled:false];
    [self.contentScroll addGestureRecognizer:leftSwipe];
    [self.contentScroll addGestureRecognizer:rightSwipe];
    
    
    
    CGFloat width1  = (isIpad)? 157 : 90;
    CGFloat height1 = (isIpad)? 157 : 90, height2 = (isIpad)? 699 : 400;
    
    [self.contentScroll setContentSize:CGSizeMake((applications.count * width2), self.frame.size.height)];
    
    for (int i = 0; i < applications.count; i++){
        CGRect iconSize;
        CGRect imageSize;
        CGFloat screenWidth = width2;
        
        CGFloat x1 = screenWidth / 2 - width1 / 2, x2 = screenWidth / 2 - width2 / 2;
        CGFloat y1 = (isIpad) ? 12 : 4, y2 = (isIpad) ? 66 : 44;
        iconSize = CGRectMake(x1, y1, width1, height1);
        imageSize = CGRectMake(x2, y2, width2, height2);
        
        CGRect newFrame = CGRectMake(i * width2, closeButton.frame.size.height + ((isIpad) ? 50 : 0), width2, self.frame.size.height - closeButton.frame.size.height - ((isIpad) ? 50 : 0));
        UIView *appView = [[UIView alloc] initWithFrame:newFrame];
        [appView setAutoresizesSubviews:true];
        appView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        
        UIImage *appleButtonImage = [UIImage imageNamed:@"9_button"];
        UIButton *appleButton = [[UIButton alloc] initWithFrame:CGRectMake(newFrame.size.width / 2 - appleButtonImage.size.width / 2,
                                                                           newFrame.size.height - appleButtonImage.size.height -  ((isIpad) ? 110 : 18),
                                                                           appleButtonImage.size.width, appleButtonImage.size.height)];
        [appleButton addTarget:self action:@selector(openApple:) forControlEvents:UIControlEventTouchUpInside];
        [appleButton setImage:appleButtonImage forState:UIControlStateNormal];
        appleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        appleButton.layer.masksToBounds = true;
        appleButton.layer.cornerRadius = (isIpad) ? 4 : 3;
        appleButton.tag = i;
        [appView addSubview:appleButton];
        appleButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        UIImageView *icon = [[UIImageView alloc] initWithFrame:iconSize];
        UIImageView *image = [[UIImageView alloc] initWithFrame:imageSize];
        
        [icon.layer setMasksToBounds:true];
        [image.layer setMasksToBounds:true];
        
        [self setAutoresizingTo:icon];
        [self setAutoresizingTo:image];
        [self setAutoresizingTo:appleButton.imageView];
        
        [icon.layer setCornerRadius:cornerRadius];
        [image.layer setCornerRadius:cornerRadius];
        
        NSString *iconLink = applications[i][@"artworkUrl512"];
        
        NSString *screenLink = @"";
        if (isIpad){
            screenLink = applications[i][@"ipadScreenshotUrls"][0];
        }else{
            screenLink = applications[i][@"screenshotUrls"][0];
        }
        [[MCImageCache sharedCache] loadImageWithURLPath:iconLink index:0 completionBlock:^(UIImage *image, NSUInteger returnIndex) {
            if (returnIndex == 0){
                icon.image = image;
            }
        }];
        [[MCImageCache sharedCache] loadImageWithURLPath:screenLink index:1 completionBlock:^(UIImage *img, NSUInteger returnIndex) {
            if (returnIndex == 1){
                image.image = img;
            }
        }];
        
        [appView addSubview:image];
        [appView addSubview:icon];
        [appView bringSubviewToFront:appleButton];
        [self.contentScroll addSubview:appView];
        [self.viewsArray addObject:appView];
    }
    [self addSubview:self.contentScroll];
    [self bringSubviewToFront:closeButton];
    
    
    
    countOfApps = (int)applications.count;
    self.currentItem = 0;
    
    [LoadingView removeLoading];
}
- (void)setAutoresizingTo:(UIView *)view{
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleBottomMargin];
    
    [view setContentMode:UIViewContentModeScaleAspectFit];
    
}
- (void)showMoreAppsIn:(UIView *)view{
    [view addSubview:self];
    [view bringSubviewToFront:self];
}
- (IBAction)closeAction:(id)sender{
    [self removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:false withAnimation:UIStatusBarAnimationFade];
}
- (IBAction)openApple:(UIButton *)sender{
    [[BannerReviewClass sharedInstance] openAppInAppStore:applications[sender.tag][@"trackId"]
                                             inController:(UIViewController *)[[self superview] nextResponder]];
}


@end
