//
//  LoadingView.m
//  moreApps
//
//  Created by Farshx on 18.07.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import "LoadingView.h"
#import "PCAngularActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface LoadingView ()

@property (nonatomic, strong) PCAngularActivityIndicatorView *loader;

@end

@implementation LoadingView
@synthesize loader;

static LoadingView *loadingView = nil;

+ (LoadingView *)startLoadIn:(UIView *)view{
    if (loadingView){
        [self removeLoading];
    }
    loadingView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds] inView:view];
    return loadingView;
}

+ (void)startLoadIn:(UIView *)view andDoBGBlock:(void(^)())block completionBlock:(completion)block2{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (loadingView){
                [self removeLoading];
            }
            loadingView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds] inView:view];
        });
        if (block != nil){
            block();
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (block2 != nil){
                block2();
            }
            [self removeLoading];
        });
    });
}

- (instancetype)initWithFrame:(CGRect)frame inView:(UIView*)view{
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.7]];
    loader = [[PCAngularActivityIndicatorView alloc] initWithActivityIndicatorStyle:PCAngularActivityIndicatorViewStyleLarge];
    loader.color = [UIColor colorWithRed:29/255.0 green:210/255.0 blue:1.0 alpha:1.0];
    [loader startAnimating];
    [loader setCenter:self.center];
    [self addSubview:loader];
    [view addSubview:self];
    return self;
}
- (void)dealloc{
    if ([loadingView isEqual:self]){
        loadingView = nil;
    }
}

+ (void)removeLoading{
    if (!loadingView){
        return;
    }else{
        [loadingView.loader stopAnimating];
        [loadingView.loader removeFromSuperview];
        loadingView.loader = nil;
        [loadingView removeFromSuperview];
        loadingView = nil;
    }
}


@end
