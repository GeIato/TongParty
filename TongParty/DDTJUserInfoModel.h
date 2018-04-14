//
//  DDTJUserInfoModel.h
//  TongParty
//
//  Created by 方冬冬 on 2017/9/14.
//  Copyright © 2017年 桐聚. All rights reserved.
//

#import "DDBaseModel.h"

@interface DDTJUserInfoModel : DDBaseModel
@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, assign) NSInteger create_time;
@property (nonatomic, assign) NSInteger repin_count;
@property (nonatomic, assign) NSInteger new_followers;
@property (nonatomic, assign) BOOL user_verified;
@property (nonatomic, assign) NSInteger notification_count;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger point;
@property (nonatomic, assign) NSInteger ugc_count;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, copy) NSString *large_avatar_url;
@property (nonatomic, assign) NSInteger subscribe_count;
@property (nonatomic, assign) NSInteger followers;
@property (nonatomic, assign) NSInteger gender;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, assign) NSInteger followings;
@property (nonatomic, assign) BOOL is_following;
@property (nonatomic, assign) NSInteger comment_count;
@property (nonatomic, copy) NSString *desc;
@end
