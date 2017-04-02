//
//  MCImageCache.m
//
//  Created by thelvis on 6/12/13.
//  Copyright (c) 2013 Indie. All rights reserved.
//

#import "MCImageCache.h"
// =============================================================================
// MCImageCache Private Interface
// =============================================================================
@interface MCImageCache ()
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSMutableDictionary *dictionary2;
@property (nonatomic, strong) NSString *cacheDirectory;
@end


// =============================================================================
// MCImageCache Implimantation
// =============================================================================
@implementation MCImageCache
+ (MCImageCache *)sharedCache {
    static dispatch_once_t pred;
    static MCImageCache *imageCache = nil;
    
    dispatch_once(&pred, ^{
        imageCache = [[self alloc] init];
    });
    
    return imageCache;
}


- (id)init {
    self = [super init];
    if (self != nil) {
        self.cacheDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Cache.plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.cacheDirectory]){
            _dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:self.cacheDirectory];
        }else{
            _dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
            [_dictionary writeToFile:self.cacheDirectory atomically:false];
        }
        _dictionary2 = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}


- (void)setObject:(id)anObject forKey:(id)aKey {
    if (anObject != nil){
        [self.dictionary setObject:anObject forKey:aKey];
        [self.dictionary writeToFile:self.cacheDirectory atomically:false];
    }
}


- (id)objectForKey:(id)aKey {
    UIImage * image = [self.dictionary2 objectForKey:aKey];
    if (image != nil){
        return image;
    }else{
        NSString *path = ([aKey containsString:@"vidlerr"]) ? [aKey lastPathComponent] : aKey;
        NSData *data = [self.dictionary objectForKey:path];
        if (data != nil){
            UIImage *img = [[UIImage alloc] initWithData:data];
            [self.dictionary2 setObject:img forKey:path];
            return img;
        }else{
            return nil;
        }
    }
}

- (void)loadImageWithURLPath:(NSString *)imagePath
                       index:(NSUInteger)index
             completionBlock:(void (^)(UIImage *image, NSUInteger returnIndex))completionBlock {
    UIImage *image = [self objectForKey:imagePath];
    if(nil != image){
        if (completionBlock != nil){
            completionBlock(image,index);
        }
        return;
    }
    dispatch_queue_t aQueue;
    aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        NSURL *url = [NSURL URLWithString:imagePath];
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (imageData == nil) {
            NSLog(@"Data is nil for imagepath %@",imagePath);
            url = [NSURL URLWithString:imagePath];
            imageData = [[NSData alloc] initWithContentsOfURL:url];
            image = [[UIImage alloc] initWithData:imageData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *path = ([imagePath containsString:@"vidlerr"]) ? [imagePath lastPathComponent] : imagePath;
            if (image != nil && imageData != nil){
                [self.dictionary2 setObject:image forKey:path];
                [self setObject:imageData forKey:path];
                if (completionBlock != nil){
                    completionBlock(image,index);
                }
            }else{
                if (completionBlock != nil){
                    NSLog(@"Image is nil %@",imagePath);
                    completionBlock([UIImage imageNamed:imagePath] ,index);
                }
            }
        });
    });
}

- (void)removeAllObjects {
    [self.dictionary removeAllObjects];
}

@end
