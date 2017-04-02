//
//  LoginLogoutClass.h
//  ChatClass
//
//  Created by user on 2/9/16.
//  Copyright © 2016 BrainCake. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Quickblox/Quickblox.h>
#import <QuickbloxWebRTC/QuickbloxWebRTC.h>
#import "SlideNavigationController.h"

@protocol LoginDelegate<NSObject>
-(void)returnCurrentUser:(QBUUser*)user;
@end


@interface LoginLogoutClass : NSObject<QBChatDelegate,FBSDKLoginButtonDelegate>
@property (nonatomic,strong)QBUUser*currentUssser;
+ (LoginLogoutClass *)sharedInstance;

//create a new user  with all standard parameters. P.S. (the avatar need to be added manually)

-(void)signUpWithlogin:(NSString*)login password:(NSString*)password fullName:(NSString*)fullName country:(NSString*)country  gender:(NSString*)gender completition:(void(^)( QBUUser* rez))compl1;

//custom login with user and password

- (void)loginWithUser:(NSString*)loginU andPassword:(NSString*)passwordU completition:(void(^)( ))comp;

//get all users  in this app

- (void)retrieveAllUsersFromPage:(int)page;

//add facebookButton to an specific view it will automatically login or sign Up when user press it

-(void)addFBLoginButtonToView:(UIView*)view withCenterPoint:(CGPoint)point;

// login to chat when user is allready logged in to facebook

-(void)haveActiveFbSession;


@property (nonatomic, strong) id<LoginDelegate> delegate;
@end
