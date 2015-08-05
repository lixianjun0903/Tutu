//
//  UserInfo.h
//  Tutu
//
//  Created by gaoyong on 14-10-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic , retain) NSString *uid;
@property (nonatomic , retain) NSString *nickname;
@property (nonatomic,  retain) NSString *pinyin;//把名称转换成大写的拼音字母，便于作A-Z分组。
@property (nonatomic , retain) NSString *avatartime;

@property (nonatomic , retain) NSString *newmessagecount;
@property (nonatomic , retain) NSString *newtipscount;
//0：未定义  1：男  2：女
@property (nonatomic , retain) NSString *gender;
@property (nonatomic,retain)  NSString *age;
@property (nonatomic , retain) NSString *birthday;
@property (nonatomic , retain) NSString *province;
@property (nonatomic , retain) NSString *city;
@property (nonatomic , retain) NSString *area;
@property (nonatomic , retain) NSString *sign;
@property (nonatomic,strong) NSString *applymsg;
@property (nonatomic,strong) NSString *applystatus;
@property (nonatomic,strong) NSString *applytime;
//"frienduid": "10125",
//"relation": 0,
//"nickname": "凸凸",
//"avatartime": 1415774757,
//"gender": "1",
//"sign": "",
//"isblock": 0,
//"age": 0,
//"userhonorlevel": 0,
//"topicblock": 0,
//"applymsg": "你好，想加你为好友!!",
//"applystatus": "0",
//"applytime": "2015-03-12 18:54:36"

//0:没有关系 1：对方添加我未好友 2：我添加对方为好友 3:互为好友 4：我自己
//5,对方删除我了 6我删除对方，对方还不知道
@property (nonatomic ,retain) NSString *relation;

@property (nonatomic , retain) NSString *addtime;
@property (nonatomic)BOOL isBlock;

//星座
@property (nonatomic,retain) NSString *constellation;
//等级
@property (nonatomic,assign) int userhonorlevel;
@property (nonatomic,assign) int isliked;
@property (nonatomic,assign) int likenum;

//封面
@property (nonatomic,retain) NSString *homecoverurl;


@property (nonatomic,assign)BOOL topicblock;
@property (nonatomic,assign)BOOL isblockme;

//附近时，距离后面的时间
@property (nonatomic , retain) NSString *lasttime;

//距离，查询同城好友时使用
@property (nonatomic , retain) NSString *distance;


//用户状态，-2为已封杀
@property (nonatomic , assign) int status;

@property (nonatomic , assign) int topicnum;
@property (nonatomic , assign) int favnum;


// 服务端修改用户匹配时间戳
@property (nonatomic , retain) NSString *updatetime;
// 本地修改数据(被评论、聊天)，用于查找好友顶部常用联系人显示
@property (nonatomic , retain) NSString *changetime;


@property (nonatomic , retain) NSString *isQQLogin;

// 1.6.3 新增字段
@property (nonatomic , retain) NSString *logintype;
@property (nonatomic , retain) NSString *isbind_qq;
@property (nonatomic , retain) NSString *isbind_weibo;
@property (nonatomic , retain) NSString *isbind_phone;

@property (nonatomic , retain) NSString *token;
//可见范围，默认对好友可见
@property (nonatomic,strong)NSString *locationstatus;


//用户备注
@property (nonatomic,strong)NSString *remarkname;
// 是否能发送私信
@property (nonatomic,strong)NSString *cansendmessage;
// 不能发送私信提示
@property (nonatomic,strong)NSString *errormsg;

//是否可以与对方聊天
@property (nonatomic,assign)BOOL canchat;


// 个人主页，关注数量
@property (nonatomic , assign) int follownum;

// 粉丝数
@property (nonatomic , assign) int fansnum;

@property (nonatomic , assign) BOOL isauth;
@property (nonatomic , strong) NSString * authreason;


//临时使用，显示的昵称
@property (nonatomic , strong) NSString * realname;

//临时使用，存储用户拼音
@property (nonatomic , strong) NSString * pinYin;
//临时使用，感兴趣的人
@property (nonatomic ,strong) NSArray *topicList;
@property (nonatomic ,strong) NSString *descinfo;
@property (nonatomic ,strong) NSString *followtime;


-(UserInfo *)initWithMyDict:(NSDictionary *)dict;



@end
