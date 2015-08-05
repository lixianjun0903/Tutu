//
//  LoginManager.h
//  Tutu
//  用户登录管理，使用此类，替换UserModel相关操作
//  Created by zhangxinyao on 15-3-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "XGPush.h"
#import "LXActionSheet.h"

@interface LoginManager : NSObject<LXActionSheetDelegate>{
    
}

+(LoginManager *) getInstance;


/**
 * 解析登录用户的信息
 * 保存的数据库，并做登录操作
 * dict  服务器返回的json用户数据
 */
-(UserInfo *)doLoginWidthDict:(NSDictionary *)dict;
/**
 * 解析dict数据位UserInfo
 * 并且保存dict数据到数据库中
 */
-(UserInfo *)parseDictData:(NSDictionary *)dict;

/**
 * 保存用户信息到数据库
 */
-(void)saveInfoToDB:(UserInfo *) info;

/**
 * 获取登录用户信息
 */
-(UserInfo *)getLoginInfo;


/**
 * 获取登录用户UID
 */
-(NSString *)getUid;

/**
 * 判断用户是否登录
 */
-(BOOL)isLogin;

/**
 * 退出登录
 */
-(void)loginOut;

- (void)showLoginView:(id ) target;

@end
