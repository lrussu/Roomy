//
//  VisitCard.h
//  faces
//
//  Created by user on 4/14/15.
//  Copyright (c) 2015 BrainCake. All rights reserved.
//
#import <ImageIO/ImageIO.h>
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#define isIpad ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)


@interface VisitCard : UIView<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

+(UIImage *)getStickerFromImage:(UIImage*)getim
                  andBackGround:(UIImage*)background;
+(UIImage *)setSongName:(NSString*) name ToImage:(UIImage*)i wihtPhoto:(BOOL) havePhoto andLabel:(UILabel*)lab;
@end
