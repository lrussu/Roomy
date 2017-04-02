//
//  messagingClass.m
//
//
//  Created by user on 2/11/16.
//
//

#import "messagingClass.h"

@implementation messagingClass

{
    QBUUser* localUser,*reciver;
    AVPlayer*pl;
    BOOL iCreate;
}
@synthesize chatDialog;
+ (messagingClass *)sharedInstance
{
    static messagingClass* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[messagingClass alloc] init];
        sharedInstance->iCreate = false;
        [QBChat.instance addDelegate:sharedInstance];
        sharedInstance->reciver = [QBUUser user];
        sharedInstance->pl = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"]]];
    });
    return sharedInstance;
}



-(void)createANewDialogWithMe:(QBUUser*)me andOponent:(QBUUser*)oponent
{
    iCreate = true;
    chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(oponent.ID),@(me.ID)];
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        for (NSString *occupantID in chatDialog.occupantIDs) {
            
            QBChatMessage *inviteMessage = [self createChatNotificationForGroupChatCreation:chatDialog];
            
            NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
            inviteMessage.customParameters[@"date_sent"] = @(timestamp);
            
            // send notification
            //
            inviteMessage.recipientID = [occupantID integerValue];
            //[pl play];
            [[QBChat instance] sendSystemMessage:inviteMessage completion:^(NSError * _Nullable error) {
                //NSLog(@"%@",error);
            }];
        }
    } errorBlock:^(QBResponse *response) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didNotOpenDialog)]){
            [self.delegate didNotOpenDialog];
        }
    }];
}


- (QBChatMessage *)createChatNotificationForGroupChatCreation:(QBChatDialog *)dialog
{
    // create message:
    QBChatMessage *inviteMessage = [QBChatMessage message];
    inviteMessage.text = [NSString stringWithFormat:@"%lu",(unsigned long)localUser.ID];
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[@"xmpp_room_jid"] = dialog.roomJID;
    customParams[@"name"] = dialog.name;
    customParams[@"_id"] = dialog.ID;
    customParams[@"type"] = @(dialog.type);
    customParams[@"occupants_ids"] = [dialog.occupantIDs componentsJoinedByString:@","];
    
    // Add notification_type=1 to extra params when you created a group chat
    //
    customParams[@"notification_type"] = @"1";
    
    inviteMessage.customParameters = customParams;
    
    return inviteMessage;
}



- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message
{
    [pl seekToTime:kCMTimeZero];
    [pl play];
    if (!iCreate){
        chatDialog = [[QBChatDialog alloc] initWithDialogID:message.dialogID type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = [self getIDsFromString:[message.customParameters objectForKey:@"occupants_ids"]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didOpenDialog)])
    {
        NSArray* firstId = chatDialog.occupantIDs;//[self getIDsFromString:[message.customParameters objectForKey:@"occupants_ids"]];
        
//        if ([[firstId objectAtIndex:1] isEqualToString:[NSString stringWithFormat:@"%lu",[[QBChat instance] currentUser].ID]] ) {
        if ([[firstId objectAtIndex:1] isEqual:@([[QBChat instance] currentUser].ID)]){
            [_delegate didOpenDialog];
        }
        
    }
    @try {
        [chatDialog joinWithCompletionBlock:^(NSError * _Nullable error){
            NSLog(@"%@",error);
        }];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
}

-(void)chatDidNotConnectWithError:(NSError *)error{
    NSLog(@"error connection: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpecialLoadingStop2" object:nil];
    [[videoChatClass sharedInstance] exit];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
}

-(void )leaveDialog
{
    @try {
        [chatDialog leaveWithCompletionBlock:^(NSError * _Nullable error){
            NSLog(@"%@",error);
        }];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

-(void)chatDidAccidentallyDisconnect{
    NSLog(@"chat disconnected");
}

-(void)chatDidConnect{
    NSLog(@"chat didconnect");
}

-(void)chatDidFailWithStreamError:(NSError *)error{
    NSLog(@"didfaild with error: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpecialLoadingStart2" object:nil];
}

-(void)chatDidReconnect{
    NSLog(@"didreconnect");
}

-(NSArray*)getIDsFromString:(NSString*)str
{
    NSMutableArray* tmp = [NSMutableArray arrayWithArray:[str componentsSeparatedByString:@","]];
//    for (int i=0; i<[tmp count]; i++) {
//        
//        [tmp replaceObjectAtIndex:i withObject:(NSNumber*)[tmp objectAtIndex:i] ];
//    }
    return @[@([[tmp objectAtIndex:0] intValue]), @([[tmp objectAtIndex:1] intValue])];
}
-(void)sendMesage:(NSString*)messagestr
{
    QBChatMessage *message = [QBChatMessage message];
    
    [message setText:messagestr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @(1);
    [message setCustomParameters:params];
    //
    @try {
        [chatDialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
            if (error != nil && self.delegate != nil && [self.delegate respondsToSelector:@selector(messageSendError:)]){
                [self.delegate messageSendError:messagestr];
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}
- (void)chatDidReceiveMessage:(QBChatMessage *)message
{

    if (self.delegate && [self.delegate respondsToSelector:@selector(haveMessage:senderID:)])
    {
        [_delegate haveMessage:message.text senderID:message.senderID];
    }
    [pl seekToTime:kCMTimeZero];
    [pl play];
}
-(void)haveMessage:(NSString*)message
{
    
}
-(void)didOpenDialog
{
    
}

@end
