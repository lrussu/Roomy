//
//  LoginLogoutClass.m
//  ChatClass
//
//  Created by user on 2/9/16.
//  Copyright © 2016 BrainCake. All rights reserved.
//

#import "LoginLogoutClass.h"

@implementation LoginLogoutClass
{
    NSString*currentPassword;
    NSInteger userNumber;
}

+ (LoginLogoutClass *)sharedInstance
{
    static LoginLogoutClass* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LoginLogoutClass alloc] init];
        [QBChat.instance addDelegate:sharedInstance];
        sharedInstance->userNumber = 0;
        
    });
    return sharedInstance;
}



-(void)signUpWithlogin:(NSString*)login password:(NSString*)password fullName:(NSString*)fullName country:(NSString*)country  gender:(NSString*)gender completition:(void(^)( QBUUser* rez))compl1
{
    QBUUser*user = [QBUUser user];
    user.login = login;
    user.password = password;
    user.fullName = fullName;
    user.website = country;
    user.customData = gender;
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        _currentUssser = user;
        currentPassword = password;
        compl1(user);
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"\n Sign error \n%@ ",response);
    }];
    
    
}

#pragma mark facebook functional

-(void)addFBLoginButtonToView:(UIView*)view withCenterPoint:(CGPoint)point
{
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    loginButton.delegate = self;
    loginButton.center = point;
    [view addSubview:loginButton];
    
    loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends", @"user_location", @"user_photos"];
    
    [loginButton setBackgroundImage:nil forState:UIControlStateNormal];
    [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
    [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [loginButton setBackgroundImage:nil forState:UIControlStateDisabled];
    
    loginButton.backgroundColor = [UIColor clearColor];
    
    [loginButton setImage:nil forState:UIControlStateNormal];
    [loginButton setImage:nil forState:UIControlStateSelected];
    [loginButton setImage:nil forState:UIControlStateHighlighted];
    [loginButton setImage:nil forState:UIControlStateDisabled];
    
    for (id subview in loginButton.subviews){
        if ([subview isKindOfClass:[UILabel class]]){
            UILabel *lbl = subview;
            lbl.text = @"";
            lbl.alpha = 0;
            lbl.backgroundColor = [UIColor clearColor];
        }
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *img = subview;
            img.image = nil;
            img.alpha = 0;
            img.backgroundColor = [UIColor clearColor];
        }
        if ([subview isKindOfClass:[UIView class]]){
            UIView *v = subview;
            v.backgroundColor = [UIColor clearColor];
            v.alpha = 0;
        }
        if ([subview isKindOfClass:[UIButton class]]){
            UIButton *btn = subview;
            [btn setImage:nil forState:UIControlStateNormal];
            [btn setImage:nil forState:UIControlStateSelected];
            [btn setImage:nil forState:UIControlStateHighlighted];
            [btn setImage:nil forState:UIControlStateDisabled];
        }
    }
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SpecialLoadingStart2" object:nil];
    NSUserDefaults* u = [NSUserDefaults standardUserDefaults];
    NSLog(@"%@",result.token.tokenString);
    [self getFacebookDataWithCompletition:^(id rez) {
        NSLocale *locale = [NSLocale currentLocale];
        NSString *country = [locale displayNameForKey:NSLocaleIdentifier value:[locale localeIdentifier]];
        
        NSString *pass = [(NSString*)([rez objectForKey:@"id"]) substringToIndex:7];
        pass =  [pass stringByAppendingString:@"xy"];
        NSString *login = (NSString*)([rez objectForKey:@"id"]);
        
        [QBRequest usersWithLogins:[NSArray arrayWithObject:login]
                              page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:1]
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users)
         {
             if (users.count >0) {
                 [self loginWithUser:login andPassword:pass completition:^{
                     
                     [u setObject:login forKey:@"login"];
                     [u synchronize];
                 }];
                 
             }
             else
             {
                 [self signUpWithlogin:(NSString*)([rez objectForKey:@"id"]) password:pass fullName:[rez objectForKey:@"name"] country:country gender:[rez objectForKey:@"gender"] completition:^(QBUUser *rez)
                  {
                      [self loginWithUser:rez.login andPassword:currentPassword completition:^{
                          
                          [u setObject:login forKey:@"login"];
                          [u synchronize];
                      }];
                  }];
                 
                 
             }
             
         } errorBlock:^(QBResponse *response)
         {
             NSLog(@"error: %@", response);
             
             
         }];
        
        
    }];
    
    
    
}

-(void)haveActiveFbSession
{
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpecialLoadingStart2" object:nil];
        [self getFacebookDataWithCompletition:^(id rez)
         {
             NSString *pass = [(NSString*)([rez objectForKey:@"id"]) substringToIndex:7];
             pass =  [pass stringByAppendingString:@"xy"];
             NSString *login = (NSString*)([rez objectForKey:@"id"]);
             [self loginWithUser:login andPassword:pass completition:^
              {
                  NSLog(@"loged in");
              }];
             
         }];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SpecialLoadingStop2" object:nil];
    }
}

- (void)getFacebookDataWithCompletition:(void(^)( id rez))compl{
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             
             compl(result);
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
    
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    [[QBChat instance] disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
            // Successful logout
        } errorBlock:^(QBResponse *response) {
            // Handle error
        }];
        
    }];
}


- (void)loginWithUser:(NSString*)loginU andPassword:(NSString*)passwordU completition:(void(^)( ))comp
{
    // Authenticate user
    currentPassword = passwordU;
    [QBRequest logInWithUserLogin:loginU password:passwordU
                     successBlock:[self successBlock] errorBlock:[self errorBlock]];
    comp();
}



- (void (^)(QBResponse *response, QBUUser *user))successBlock
{
    return ^(QBResponse *response, QBUUser *user) {
        QBUUser*tmp = user;
        tmp.password =currentPassword;
        NSLog(@" \n\n\n\n\n succes  Loged in \n\n\n\n\n");
        NSLog(@"userLogin%@  ,   user Password%@,   userID %lu",user.login,user.password,(unsigned long)user.ID);
        [[QBChat instance] connectWithUser:tmp completion:^(NSError * _Nullable error) {
            NSLog(@"%@",error);
            [self checkIfImOnlineNow:tmp];
        }];
    };
}

-(void)checkIfImOnlineNow:(QBUUser*)user1
{
    NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSInteger userLastRequestAtTimeInterval   = [[user1 lastRequestAt] timeIntervalSince1970];
    
    // if user didn't do anything last 1 minute (60 seconds)
    if((currentTimeInterval - userLastRequestAtTimeInterval) > 60){
        
    } else {
        // [self createANewDialogWithMe:user1 andOponent:reciver];
        if (self.delegate && [self.delegate respondsToSelector:@selector(returnCurrentUser:)]) {
            [self.delegate returnCurrentUser:user1];
            NSLog(@"\n\n\n\n\n\n\n\n\n\n     aaaaaaaaaaaaaaaaaaaaa\n\n\n\n\n\n\n\n\n\n\n");
        }
    }
}


- (void)retrieveAllUsersFromPage:(int)page
{
    
    [QBRequest usersForPage:[QBGeneralResponsePage responsePageWithCurrentPage:page perPage:4] successBlock:^(QBResponse *response, QBGeneralResponsePage *pageInformation, NSArray *users) {
        userNumber += users.count;
        NSLog(@"%@",users);
        if (pageInformation.totalEntries > userNumber) {
            [self retrieveAllUsersFromPage:page + 1];
        }
    } errorBlock:^(QBResponse *response) {
        // Handle error
    }];
}

-(BOOL)UsersWiThlogins:(NSArray*)logins FromPage:(int)page
{
    __block BOOL y;
    [QBRequest usersWithLogins:logins page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:1]
                  successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users)
     {
         y=YES;
     } errorBlock:^(QBResponse *response)
     {
         y=NO;
     }];
    return y;
}

- (QBRequestErrorBlock)errorBlock
{
    return ^(QBResponse *response) {
        // Handle error
    };
}

@end
