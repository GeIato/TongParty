//
//  UserManager.m
//  MiAiApp
//
//  Created by Apple on 2017/8/22.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "UserManager.h"
#import <UMSocialCore/UMSocialCore.h>
#import "DDResponseModel.h"

@implementation UserManager

+ (instancetype)sharedUserManager {
    static UserManager *sharedUserManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserManager = [[self alloc] init];
    });
    return sharedUserManager;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        //被踢下线
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onKick)
                                                     name:KNotificationOnKick
                                                   object:nil];
    }
    return self;
}

#pragma mark ————— 三方登录 —————
-(void)login:(UserLoginType )loginType completion:(loginBlock)completion{
    [self login:loginType params:nil completion:completion];
}

#pragma mark ————— 带参数登录 —————
-(void)login:(UserLoginType )loginType params:(NSDictionary *)params completion:(loginBlock)completion{
//    友盟登录类型
    UMSocialPlatformType platFormType;
    NSString *act = @"wx";

    if (loginType == kUserLoginTypeQQ) {
        platFormType = UMSocialPlatformType_QQ;
        act = @"qq";
    }else if (loginType == kUserLoginTypeWeChat) {
        platFormType = UMSocialPlatformType_WechatSession;
        act = @"wx";
    }else if (loginType == kUserLoginTypeWeibo) {
        platFormType = UMSocialPlatformType_Sina;
        act = @"wb";
    }
//    第三方登录
    if (loginType != kUserLoginTypeAccount) {
        [MBProgressHUD showMessage:@"授权中..."];
        [[UMSocialManager defaultManager] getUserInfoWithPlatform:platFormType currentViewController:nil completion:^(id result, NSError *error) {
            if (error) {
                [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
                if (completion) {
                    completion(NO,error.localizedDescription);
                }
            } else {

                UMSocialUserInfoResponse *resp = result;

//                // 授权信息
//                RLog(@"QQ uid: %@", resp.uid);
//                RLog(@"QQ openid: %@", resp.openid);
//                RLog(@"QQ accessToken: %@", resp.accessToken);
//                RLog(@"QQ expiration: %@", resp.expiration);
//
//                // 用户信息
//                RLog(@"QQ name: %@", resp.name);
//                RLog(@"QQ iconurl: %@", resp.iconurl);
//                RLog(@"QQ gender: %@", resp.unionGender);
//
//                // 第三方平台SDK源数据
//                RLog(@"QQ originalResponse: %@", resp.originalResponse);

                //登录参数
//                NSDictionary *params = @{@"openid":resp.openid, @"nickname":resp.name, @"photo":resp.iconurl, @"sex":[resp.unionGender isEqualToString:@"男"]?@1:@2, @"cityname":resp.originalResponse[@"city"], @"fr":@(loginType)};
//
//                self.loginType = loginType;
//                //登录到服务器
//                [self loginToServer:params completion:completion];
                NSString *open_id = @"";
                if (loginType == kUserLoginTypeQQ) {
                    open_id = resp.openid;
                }else if (loginType == kUserLoginTypeWeChat) {
                    open_id = resp.openid;
                }else if (loginType == kUserLoginTypeWeibo) {
                    open_id = resp.uid;
                }
                
                [MBProgressHUD showLoading:@"登录中..." toView:KEY_WINDOW];
                [DDResponseBaseHttp getWithAction:kTJOtherLogin params:@{@"open_id":open_id, @"act":act, @"image_url":resp.iconurl} type:kDDHttpResponseTypeJson block:^(DDResponseModel *result) {
                    [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
                    if ([result.status isEqualToString:@"success"]) {
                        [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
                        [self LoginSuccess:result completion:completion];
                    }
                    [MBProgressHUD showMessage:result.msg_cn toView:KEY_WINDOW];
                } failure:^{
                    [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
                }];
            }
        }];
    } else {
        // 账号登录
        [MBProgressHUD showLoading:KEY_WINDOW];
        [DDResponseBaseHttp getWithAction:kTJUserLoginAPI params:params type:kDDHttpResponseTypeJson block:^(DDResponseModel *result) {
            [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
            [self LoginSuccess:result completion:completion];
        } failure:^{
            completion(NO,@"请求失败");
            [MBProgressHUD hideAllHUDsInView:KEY_WINDOW];
        }];

     }
}

#pragma mark ————— 手动登录到服务器 —————
-(void)loginToServer:(NSDictionary *)params completion:(loginBlock)completion{
    [MBProgressHUD showMessage:@"登录中..."];
    
    
    
//    [PPNetworkHelper POST:NSStringFormat(@"%@%@",kTJHostAPI,kTJUserLoginAPI) parameters:params success:^(id responseObject) {
//        [self LoginSuccess:responseObject completion:completion];
//
//    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
//        if (completion) {
//            completion(NO,error.localizedDescription);
//        }
//    }];
}

#pragma mark ————— 自动登录到服务器 —————
-(void)autoLoginToServer:(loginBlock)completion{
//    [PPNetworkHelper POST:NSStringFormat(@"%@%@",kTJHostAPI,kUrlUserAutoLogin) parameters:nil success:^(id responseObject) {
//        [self LoginSuccess:responseObject completion:completion];
//        
//    } failure:^(NSError *error) {
//        if (completion) {
//            completion(NO,error.localizedDescription);
//        }
//    }];
}

#pragma mark ————— 登录成功处理 —————
-(void)LoginSuccess:(DDResponseModel *)responseObject completion:(loginBlock)completion{
    if ([responseObject.status isEqualToString:@"success"]) {
        NSDictionary *dic = responseObject.data;
        self.curUserInfo = [DDUserSingleton mj_objectWithKeyValues:dic];
        [self saveUserInfo];
        self.isLogined = true;
        if (completion) {
            completion(true, responseObject.msg_cn);
        }
        KPostNotification(KNotificationLoginStateChange, @YES);
    } else {
        completion(NO,responseObject.msg_cn);
        KPostNotification(KNotificationLoginStateChange, @NO);
    }

//        if (ValidDict(responseObject)) {
//            if ([responseObject[@"result"] isEqualToString:@"01"]) {// 成功
//                NSDictionary *userInfo = responseObject[@"pd"];
//                self.curUserInfo = [UserInfo modelWithDictionary:userInfo];
//                [self saveUserInfo];
//                self.isLogined = true;
//                if (completion) {
//                    completion(true, nil);
//                }
//                KPostNotification(KNotificationLoginStateChange, @YES);
//            } else {
//                if (completion) {
//                    completion(false, @"登录失败");
//                }
////                RLog(@"result=%@", responseObject[@"result"]);
////                KPostNotification(KNotificationLoginStateChange, @NO);
//            }
//        } else {
//            if (completion) {
//                completion(NO,@"登录返回数据异常");
//            }
//            KPostNotification(KNotificationLoginStateChange, @NO);
//        }
}
#pragma mark ————— 储存用户信息 —————
-(void)saveUserInfo{
    if (self.curUserInfo) {
        YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
        NSDictionary *dic = [self.curUserInfo mj_keyValues];
        [cache setObject:dic forKey:KUserModelCache];
    }
    
}
#pragma mark ————— 加载缓存的用户信息 —————
-(BOOL)loadUserInfo{
    YYCache *cache = [[YYCache alloc] initWithName:KUserCacheName];
    NSDictionary * userDic = (NSDictionary *)[cache objectForKey:KUserModelCache];
    if (userDic) {
        self.curUserInfo = [DDUserSingleton mj_objectWithKeyValues:userDic];
        self.isLogined = true;
        return YES;
    }
    return NO;
}
#pragma mark ————— 被踢下线 —————
-(void)onKick{
    [self logout:nil];
}
#pragma mark ————— 退出登录 —————
- (void)logout:(void (^)(BOOL, NSString *))completion{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationLogout object:nil];//被踢下线通知用户退出直播间
    
//    [[IMManager sharedIMManager] IMLogout];
    
    self.curUserInfo = nil;
    self.isLogined = NO;

//    //移除缓存
    YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
    [cache removeAllObjectsWithBlock:^{
        if (completion) {
            completion(YES,nil);
        }
    }];
    
    KPostNotification(KNotificationLoginStateChange, @NO);
}
@end
