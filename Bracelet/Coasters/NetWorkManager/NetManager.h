//
//  Engine.h
//  WuLiuNoProblem
//
//  Created by yyh on 15/1/6.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface NetManager : NSObject
{
}
@property (nonatomic, assign) AFNetworkReachabilityStatus netStatus;

@property (nonatomic, copy) void (^responseSuccessDic) (NSDictionary *dic  );
@property (nonatomic, copy) void (^requestFailError  ) (NSError *     error);

+(void)observeNet;                                                                              // 监视网络

+(void)DF_requestWithAction:(void(^)(NetManager *net))action success:(void(^)(NSDictionary *dic))success failError:(void(^)(NSError *erro))failError inView:(UIView *)inView isShowError:(BOOL)isShowError;

// ----------------------------------------------------------------------
// -----------------------------------------------------    新的登陆流程接口
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------// 邮箱注册
-(void)registerByEmail:(NSString *)email
              password:(NSString *)password;


// ----------------------------------------------------------------------// 邮箱找回密码
-(void)findPasswordByEmail:(NSString *)email;

// ----------------------------------------------------------------------// 登陆
-(void)login:(NSString *)account
          type:(int)type
      password:(NSString *)password;

// ----------------------------------------------------------------------// 邮箱修改密码
-(void)updatePasswordByEmail:(NSString *)email
                           old:(NSString *)old
                           new:(NSString *)neW;

// ----------------------------------------------------------------------// 手机号注册
-(void)registerByPhone:(NSString *)phone
                areaCode:(NSString *)areaCode
                authCode:(NSString *)authCode
                password:(NSString *)password;

// ----------------------------------------------------------------------// 手机号密码重置
-(void)updatePasswordByPhone:(NSString *)phone
                      areaCode:(NSString *)areaCode
                      authCode:(NSString *)authCode
                      password:(NSString *)password;

// ----------------------------------------------------------------------// 第三方平台登录
-(void)loginByThird:(NSString *)typeID
                 type:(int)type;

// ----------------------------------------------------------------------// 验证手机号是否已经注册
-(void)authPhoneExist:(NSString *)phone
               areaCode:(NSString *)areaCode;


// ----------------------------------------------------------------------
// -----------------------------------------------------    新的增加流程接口
// ----------------------------------------------------------------------


// ----------------------------------------------------------------------// 上传运动数据
-(void)updateSportData:(NSString *)access
            sport_data:(NSString *)sport_data;

// ----------------------------------------------------------------------// 上传运动数据
-(void)getSportData:(NSString *)access
            user_id:(NSString *)user_id
        k_date_from:(NSString *)k_date_from
          k_date_to:(NSString *)k_date_to;


// ----------------------------------------------------------------------// 更新用户个人信息
-(void)updateUserInfo:(NSDictionary *)dic;

// ----------------------------------------------------------------------// 获取用户个人信息
-(void)getUserInfo:(NSString *)access;

// ----------------------------------------------------------------------// 申请加好友
-(void)applyFriend:(NSString *)access
      friend_account:(NSString *)friend_account
 friend_account_type:(NSString *)friend_account_type
        push_content:(NSString *)push_content;

// ----------------------------------------------------------------------//获取好友申请列表
-(void)getFriendApplyList:(NSString *)access;

// ----------------------------------------------------------------------// 接受或者拒绝好友申请
-(void)updateFriendship:(NSString *)access
                friend_id:(NSString *)friend_id
              ship_status:(NSString *)ship_status;

// ----------------------------------------------------------------------// 提醒好友运动，回复提醒接口
-(void)pushHintInfo:(NSString *)access
               type:(NSString *)type
          friend_id:(NSString *)friend_id
       hint_content:(NSString *)hint_content;

// ----------------------------------------------------------------------// 点赞接口
-(void)pushLikeInfo:(NSString *)access
               type:(int)type
          friend_id:(NSString *)friend_id
    today_real_date:(NSString *)today_real_date;

// ----------------------------------------------------------------------// 获取好友列表信息
-(void)getFriendsInfo:(NSString *)access
      today_real_date:(NSString *)today_real_date;

// ----------------------------------------------------------------------// 获取今日全球排行榜
-(void)getTodayGlobalRank:(NSString *)access
          today_real_date:(NSString *)today_real_date;



// ----------------------------------------------------------------------// 更新系统设置
-(void)updateSysSetting:(NSString *)access
               sys_unit:(BOOL)sys_unit
      sys_notify_status:(BOOL)sys_notify_status;

// ----------------------------------------------------------------------// 获取系统设置
-(void)getUserSys:(NSString *)access;



// ----------------------------------------------------------------------//获取推送消息列表
-(void)getPushInfoList:(NSString *)access
                  time:(long long)time;

// ----------------------------------------------------------------------// 意见反馈
-(void)updateFeedback:(NSString *)access
              content:(NSString *)content;

// ----------------------------------------------------------------------// token-distribute-server
-(void)getToken_distribute_server:(NSString *)access;


// ----------------------------------------------------------------------// 获取用户token值
-(void)getUserToken:(NSString *)access;




//-(void)updatePushInfo:(NSString *)access                                                        // 推送channelId上传
//              channelID:(NSString *)channelID;













@end

