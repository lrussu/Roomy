//
//  messagingClass.h
//  
//
//  Created by user on 2/11/16.
//
//

#import <UIKit/UIKit.h>
@protocol MessagingDelegate<NSObject>
-(void)haveMessage:(NSString*)message senderID:(NSUInteger)senderID;
-(void)didOpenDialog;
-(void)didNotOpenDialog;
-(void)messageSendError:(NSString *)message;
@end


@interface messagingClass : UIView<QBChatDelegate>
@property (nonatomic, strong) QBChatDialog *chatDialog;
+ (messagingClass *)sharedInstance;
-(void)leaveDialog;
-(void)createANewDialogWithMe:(QBUUser*)me andOponent:(QBUUser*)oponent;
-(void)sendMesage:(NSString*)messagestr;
@property (nonatomic, strong) id<MessagingDelegate> delegate;
@end
