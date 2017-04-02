//
//  MCImageCache.h
//
//  Created by thelvis on 6/12/13.
//  Copyright (c) 2013 Indie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCImageCache : NSObject
+ (MCImageCache *)sharedCache;
- (void)loadImageWithURLPath:(NSString *)imagePath
                       index:(NSUInteger)index
             completionBlock:(void (^)(UIImage *image, NSUInteger returnIndex))completionBlock;
- (void)removeAllObjects;
@end
