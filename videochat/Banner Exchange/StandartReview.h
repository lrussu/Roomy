//
//  StandartReview.h
//  BraincakeApps
//
//  Created by Farshx on 01.09.15.
//  Copyright (c) 2015 Farshx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandartReview : UIView{
    NSString *title, *message, *itunesAppID;
    UIImage *icon;
    UIView *view;
}
+ (StandartReview *)SI;
-(void)showMessageInView:(UIView *)view;
@end
