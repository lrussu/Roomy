//
//  videoChatClass.h
//  ChatClass
//
//  Created by user on 2/16/16.
//  Copyright © 2016 BrainCake. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
@protocol videoDelegate<NSObject>
-(void)BeginNewSearch;
-(void)videoTrackBegin;
-(void)heCallMe:(NSNumber *)userID;
@end

@interface videoChatClass : UIView<QBChatDelegate,QBRTCClientDelegate>
@property (nonatomic,strong) QBRTCSession *session;
//@property (nonatomic, strong) QBRTCVideoCapture*capture;
@property (nonatomic, strong) id<videoDelegate> delegate;
@property (nonatomic,strong)  QBRTCRemoteVideoView* opponentVideoView;
@property (strong, nonatomic)  UIView *localVideoView;
@property (strong, nonatomic) QBRTCCameraCapture *videoCapture;
@property (strong, nonatomic) UIView *globalView;
- (void)sendData:(NSString *)data completion:(void(^)(NSDictionary *responce))comp;
+ (videoChatClass *)sharedInstance;
-(void)callUsersWithIDs:(NSArray*)IDs;
-(void)hangUp;
-(void)acceptCall;
- (void)exit;
@end
