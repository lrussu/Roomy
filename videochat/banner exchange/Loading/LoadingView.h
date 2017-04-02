//
//  LoadingView.h
//  moreApps
//
//  Created by Farshx on 18.07.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completion)();

@interface LoadingView : UIView

+ (LoadingView *)startLoadIn:(UIView *)view;
+ (void)startLoadIn:(UIView *)view andDoBGBlock:(void(^)())block completionBlock:(completion)block2;
+ (void)removeLoading;

@end
