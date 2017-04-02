//
//  VisitCard.m
//  faces
//
//  Created by user on 4/14/15.
//  Copyright (c) 2015 BrainCake. All rights reserved.
//

#import "VisitCard.h"

@implementation VisitCard


+(UIImage *)setSongName:(NSString*) name ToImage:(UIImage*)i wihtPhoto:(BOOL) havePhoto andLabel:(UILabel*)lab
{   UILabel* l = [[UILabel alloc] init];
    l.font = [UIFont fontWithName:lab.font.fontName size:(isIpad) ? 87 : 47];
    l.textColor = [UIColor whiteColor];
    l.text = name;
    [l sizeToFit];
    l.frame = (isIpad) ? CGRectMake( 998, 186, 110, l.frame.size.height) : CGRectMake( 515, 94, 58, l.frame.size.height);
    l.textAlignment = NSTextAlignmentCenter;
    UIImageView*im =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, i.size.width, i.size.height)];
    im.image = i;
    [im addSubview:l];
    UIGraphicsBeginImageContext(im.frame.size);
    [im.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* final = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return final;
    
}


+(UIImageView*)getFaceFromImage:(UIImage*)myImage{
    UIImageView* resultView =[[UIImageView alloc ]init];
    UIImage* i = [UIImage imageWithCGImage:myImage.CGImage scale:myImage.scale orientation:UIImageOrientationLeftMirrored];
    CIImage* si = [CIImage imageWithCGImage:i.CGImage];
    CIContext *context = [CIContext contextWithOptions:nil];                    // 1
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };      // 2
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    int exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top.
    
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
    
    NSArray* features = [[NSArray alloc] init];
    features= [detector featuresInImage:si options:imageOptions];
    if (features.count <= 0){
        [[[UIAlertView alloc] initWithTitle:@"Please take\na new photo with your face\nin portrait mode!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return nil;
    }else{
        for (CIFaceFeature *f in features){
            CIImage* croppedImage = [si imageByCroppingToRect:CGRectMake(f.bounds.origin.x-80, f.bounds.origin.y-80, f.bounds.size.width+160, f.bounds.size.height+160)];
            UIImage *result =[UIImage imageWithCIImage:croppedImage];
            
            resultView.frame = CGRectMake(0, 0, f.bounds.size.width, f.bounds.size.height);
            resultView.image = result;
            resultView.transform = CGAffineTransformMakeRotation(M_PI_2);
        }
    }
    
    return resultView;
}
+(UIImage *)getStickerFromImage:(UIImage*)getim
                  andBackGround:(UIImage*)background{
    UIImage* finalImage;
    UIImageView * im=[self getFaceFromImage:getim];
    if (im == nil){
        return nil;
    }
    float scale,cornerRadius;
    
    if (im.frame.size.width>im.frame.size.height) {
        scale = 210 / im.frame.size.width;
        cornerRadius = im.frame.size.height/2;
    }
    else{
        scale = 210/im.frame.size.height;
        cornerRadius = im.frame.size.width/2;
    }
    im.transform = CGAffineTransformScale(im.transform, scale, scale);
    im.frame = CGRectMake(751, 40, im.frame.size.width, im.frame.size.height);
    [im.layer setMasksToBounds:YES];
    im.layer.cornerRadius = cornerRadius;
    UIImageView* backgroundView = [[UIImageView alloc] initWithImage:background];
    UIView* printView = [[UIView alloc] initWithFrame:backgroundView.frame];
    [printView addSubview:backgroundView];
    [printView addSubview:im];
    UIGraphicsBeginImageContext(backgroundView.frame.size);
    [printView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    
    finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return finalImage;
}

@end
