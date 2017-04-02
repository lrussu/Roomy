//
//  MoreAppsClass.h
//  moreApps
//
//  Created by Farshx on 15.07.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCImageCache.h"
#import "LoadingView.h"

@interface MoreAppsClass : UIView

@property (nonatomic, setter=setCurrentItem:) int currentItem;
@property (nonatomic, strong) UIScrollView *contentScroll;
@property (nonatomic, strong) NSMutableArray *viewsArray;
@property (nonatomic, strong) UIButton *closeButton;

- (instancetype)init;

- (void)createMoreApps;

- (void)showMoreAppsIn:(UIView *)view;

@end
