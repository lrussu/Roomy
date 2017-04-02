//
//  videoChatClass.m
//  ChatClass
//
//  Created by user on 2/16/16.
//  Copyright © 2016 BrainCake. All rights reserved.
//

#import "videoChatClass.h"
#import "SlideNavigationController.h"
#import "BannerReviewClass.h"
@implementation videoChatClass
{
    AVPlayer* pl;
    BOOL selfHangUp;
    
}
+ (videoChatClass *)sharedInstance
{
    static videoChatClass* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[videoChatClass alloc] init];
        sharedInstance.frame = kScreen;
        sharedInstance->selfHangUp = true;
        sharedInstance.hidden = YES;
        [QBChat.instance addDelegate:sharedInstance];
        [QBRTCClient initializeRTC];
        [QBRTCClient.instance addDelegate:sharedInstance];
        [sharedInstance setUserInteractionEnabled:NO];
        sharedInstance.backgroundColor = [UIColor blackColor];
        // ************************ init remote video View *************************
        
        CGRect frm = CGRectMake(0, 0, kScreen.size.width * 1.3333, 0);
        frm.size.height = isIpad ? (kScreen.size.height * (1024 / 768)) : kScreen.size.height + 4;
        frm.origin = CGPointMake(0, -((frm.size.height - kScreen.size.height) / 2));
        
        sharedInstance.opponentVideoView = [[QBRTCRemoteVideoView alloc] initWithFrame:frm];
        sharedInstance.opponentVideoView.backgroundColor = [UIColor blackColor];
        sharedInstance.opponentVideoView.center = sharedInstance.center;
        [sharedInstance addSubview:sharedInstance.opponentVideoView];
        sharedInstance->pl = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"]]];
        
        CGFloat smallVideoWidth = (isIpad) ? 232 : 119;
        //************************* init and Configure local video view **************
        sharedInstance.localVideoView = [[UIView alloc] init];
        sharedInstance.localVideoView.backgroundColor = [UIColor yellowColor];
        sharedInstance.localVideoView.clipsToBounds = YES;
        sharedInstance.localVideoView.frame = CGRectMake(0, 0, smallVideoWidth, smallVideoWidth * 1.775);
        
        UIView *localView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, smallVideoWidth, smallVideoWidth)];
        localView.backgroundColor = [UIColor clearColor];
        localView.clipsToBounds = true;
        localView.layer.masksToBounds = true;
        localView.layer.cornerRadius = localView.frame.size.width / 2;
        sharedInstance.localVideoView.center = CGPointMake(localView.frame.size.width / 2, localView.frame.size.width / 2);
        
        UIImage *imageBorder = [UIImage imageNamed:@"2_my_image_border"];
        UIImageView *myImageBorder = [[UIImageView alloc] initWithImage:imageBorder];
//        myImageBorder.contentMode = UIViewContentModeScaleAspectFit;
        CGRect imgBorderFrame = CGRectMake(0, 0, localView.frame.size.width, localView.frame.size.width);//myImageBorder.frame;
        imgBorderFrame.size = CGSizeMake(localView.frame.size.width + ((isIpad) ? 10 : 6), localView.frame.size.width + ((isIpad) ? 10 : 6));//imageBorder.size;
        imgBorderFrame.origin = CGPointMake((isIpad) ? 20 : 10, kScreen.size.height - localView.frame.size.height - ((isIpad) ? 20 : 10));
        myImageBorder.frame = imgBorderFrame;
        myImageBorder.backgroundColor = [UIColor clearColor];
        
        CGRect lvFrame = localView.frame;
        lvFrame.origin = isIpad ? CGPointMake(5, 5) : CGPointMake(3, 3);
        localView.frame = lvFrame;
        
//        myImageBorder.frame = CGRectMake(imgBorderFrame.origin.x, imgBorderFrame.origin.y, lvFrame.size.width, lvFrame.size.height);
        [localView addSubview:sharedInstance.localVideoView];
        [myImageBorder addSubview:localView];
        [sharedInstance addSubview:myImageBorder];
        
        
        QBRTCVideoFormat *videoFormat = [[QBRTCVideoFormat alloc] init];
        videoFormat.frameRate = 30;
        videoFormat.pixelFormat = QBRTCPixelFormat420f;
        videoFormat.width = kScreen.size.width;
        videoFormat.height = kScreen.size.height;
        sharedInstance.videoCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront]; // or AVCaptureDevicePositionBack
        sharedInstance.videoCapture.previewLayer.frame = sharedInstance.localVideoView.bounds;
        [sharedInstance.videoCapture startSession];
        [sharedInstance.localVideoView.layer insertSublayer:sharedInstance.videoCapture.previewLayer atIndex:0];
        [QBRTCSoundRouter.instance initialize];
    });
    return sharedInstance;
}
-(void)callUsersWithIDs:(NSArray*)IDs
{
    QBRTCSession *newSession = [QBRTCClient.instance createNewSessionWithOpponents:IDs
                                                                withConferenceType:QBRTCConferenceTypeVideo];
    // userInfo - the custom user information dictionary for the call. May be nil.
    [newSession startCall:nil];
}

-(void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo
{
    if (self.session) {
        [session rejectCall:nil];
        return;
    }
    NSNumber *userID = session.initiatorID;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(heCallMe:)]){
        [self.delegate heCallMe:userID];
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud boolForKey:@"exitActionBool"]){
        self.session = session;
        [self acceptCall];
    }else{
        [ud setBool:false forKey:@"exitActionBool"];
        [session rejectCall:nil];
        [self.session rejectCall:nil];
        self.session = nil;
    }
}

-(void)acceptCall
{
    [self.session acceptCall:nil];
}

- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo
{
    self.hidden = NO;
    if (self.session){
        [self.session rejectCall:nil];
        self.session = nil;
    }
    self.session = session;
}
- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    // NSLog(@"Initialized local media stream %@", mediaStream);
    mediaStream.videoTrack.videoCapture = self.videoCapture;
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    self.hidden = NO;
}

-(UIViewController*)ret
{
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    return (UIViewController *)responder;
}
- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
    NSLog(@"User %@ did not respond to your call within timeout", userID);
    [self hangUp];
}
- (void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)userID {
      NSLog(@"Connection has failed with user %@", userID);
}

-(void)session:(QBRTCSession *)session connectionClosedForUser:(NSNumber *)userID{
    NSLog(@"connectionClosedForUser: %@", userID);
//    [self hangUp];
}

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    [self.opponentVideoView setVideoTrack:videoTrack];
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoTrackBegin)]){
        [self.delegate videoTrackBegin];
    }
}


- (void)sendData:(NSString *)data completion:(void(^)(NSDictionary *responce))comp{
    NSString *urlString = @"http://vidlerr.com";
    NSURL *baseURL = [NSURL URLWithString:urlString];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *id_ready = [defaults objectForKey:@"id_ready"];
    if (!id_ready){
        id_ready = @"";
    }
    
    [manager POST:@"/applications/roomy/data.php"
       parameters:@{
                    @"type": @"search",
                    @"data": data,
                    @"id_ready" : id_ready
                    }
         progress: nil
          success:^(NSURLSessionDataTask *operation, id responseObject) {
              if (responseObject != nil){
                  NSDictionary *resp = (NSDictionary *)responseObject;
                  if ([resp objectForKey:@"add"] != nil){
                      NSString *id_ready_new = [resp objectForKey:@"id_ready"];
                      if (id_ready_new != nil){
                          [defaults setObject:id_ready_new forKey:@"id_ready"];
                      }
                  }
                  comp(resp);
              }else{
                  comp(@{@"error": @"Server error"});
              }
          }
          failure:^(NSURLSessionDataTask *operation, NSError *error) {
              [defaults removeObjectForKey:@"id_ready"];
              comp(@{@"error": @"Connect to the internet"});
          }];
}


-(void)hangUp
{
    self->selfHangUp = true;
    [self.session hangUp:nil];
    self.session = nil;
    [self removeFromSuperview];
    [[messagingClass sharedInstance] leaveDialog];
    if (self.delegate && [self.delegate respondsToSelector:@selector(BeginNewSearch)])
    {
        [_delegate BeginNewSearch];
    }
    
}
- (void)exit{
    [self.session hangUp:nil];
    self.session = nil;
    [[messagingClass sharedInstance] leaveDialog];
    [self removeFromSuperview];
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo
{
    self->selfHangUp = true;
    [self removeFromSuperview];
    [[messagingClass sharedInstance] leaveDialog];
    if (self.delegate && [self.delegate respondsToSelector:@selector(BeginNewSearch)])
    {
        [_delegate BeginNewSearch];
    }
}



- (void)sessionDidClose:(QBRTCSession *)session
{
    // release session instance
    self.session = nil;
    if (!self->selfHangUp){
        [self hangUp];
    }
    self->selfHangUp = false;
    
}

-(void)BeginNewSearch
{
    
}
@end
