//
//  UserModel.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseModel.h"
#import "UserInfo.h"


@interface UserModel : BaseModel<NSCoding , NSCopying>

@property (nonatomic , retain) NSString *addtime;
@property (nonatomic , retain) NSString *age;
@property (nonatomic , retain) NSString *area;
@property (nonatomic , retain) NSString *avatartime;
@property (nonatomic , retain) NSString *birthday;
@property (nonatomic , retain) NSString *city;
@property (nonatomic , retain) NSString *gender;
@property (nonatomic , retain) NSString *isblock;
@property (nonatomic , retain) NSString *nickname;
@property (nonatomic , retain) NSString *province;
@property (nonatomic , retain) NSString *relation;
@property (nonatomic , retain) NSString *sign;
@property (nonatomic , retain) NSString *uid;
@property (nonatomic , retain) NSString *isQQLogin;

// 1.6.3 新增字段
@property (nonatomic , retain) NSString *logintype;
@property (nonatomic , retain) NSString *isbind_qq;
@property (nonatomic , retain) NSString *isbind_weibo;
@property (nonatomic , retain) NSString *isbind_phone;

@property (nonatomic , retain) NSString *token;

@property (nonatomic,strong)NSString *locationstatus;


+(UserModel *) shareUserModel;


//获取本地序列化对象
+(UserInfo *) getFromLocal;


//重置所有属性
-(void) removeUser;

//保存对象到NSUserDefaults中,每次修改内容，均调用此方法
-(void) saveToLocal;

-(void)logout;

@end
