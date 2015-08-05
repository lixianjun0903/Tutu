//
//  ParamsDefines.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#ifndef Tutu_ParamsDefines_h
#define Tutu_ParamsDefines_h

#define Login_Exit @"LoginExit"
#define Login_Sucess @"Login_Sucess"


#define Timer_Should_Stop      @"Timer_Should_Stop"
#define Timer_Should_Fire      @"Timer_Should_Fire"

//当前用户的名称发生了变化
#define User_Name_Changed      @"User_Name_Changed"
//好友的名称发生了变化，一般用于修改备注后
#define Friend_Name_Changed    @"Friend_Name_Changed"

#define PostTopic @"PostTopic"
#define PostComment @"PostComment"
#define PostTopicFail @"PostTopicFail"

#define TOPIC_DELETE  @"TOPIC_DELETE"
#define TencentOpenAPI @"1103429136"

//#define SinaAPPKEY @"3900335850"
//#define SinaAPPSECRET @"b0839f402c1b48623d5f3a29eb359495"


#define Load_UP @"up"
#define Load_MORE @"down"


//缓存首页热门列表Key
#define UserDefaults_Index_Hot_List       @"UserDefaults_Index_Hot_List"

//缓存首页朋友列表Key
#define UserDefaults_Index_Friend_List    @"UserDefaults_Index_Friend_List"

#define UserDefaults_Home_Default_Display @"UserDefaults_Home_Default"

#define AllowStrangerMessage_KEY [NSString stringWithFormat:@"AllowStrangerMessage%@",[[LoginManager getInstance] getUid]]

//Wifi下自动播放
#define UserDefaults_is_Close_AutoPlay_Under_Wifi    [NSString stringWithFormat:@"UserDefaults_Is_AutoPlay_Under_Wifi%@",[[LoginManager getInstance] getUid]]


#define UserDefaults_PhoneName_Key          [NSString stringWithFormat:@"UserDefaults_PhoneName_Key%@",[[LoginManager getInstance] getUid]]


//获取点赞的次数。

#define UserDefaults_Topic_Zan_Count            @"UserDefaults_Zan_Count"

//储存我的好友列表
#define MY_FRIEND_LIST_CACHE   @"MY_FRIEND_LIST_CACHE"
#define ANIMATIONDURATION 0.3

#define AppToken @"AppToken"
#define COOKIE_KEY @"COOKIE_KEY"

#define LoginUID @"LoginUID"

//最大视频时间
#define MaxCMtime 16

//提交通讯录时间
#define SYSContactsTime_KEY [NSString stringWithFormat:@"TutuContacts%@",[[LoginManager getInstance] getUid]]

//首页评论的背景的透明度

#define TOPIC_COMMENT_BG_ALPHA   0.6

#define MaxFontSize 26.0
#define MinFontSize 8.0

#define TitleFont [UIFont fontWithName:@"Helvetica Neue" size:18.0]
#define SignFont [UIFont fontWithName:@"Helvetica Neue" size:16.0]

#define ListTitleFont [UIFont fontWithName:@"Helvetica Neue" size:16.0]
#define ListDetailFont [UIFont fontWithName:@"Helvetica Neue" size:14.0]
#define ListTimeFont [UIFont fontWithName:@"Helvetica Neue" size:12.0]
#define FONT_CHAT    [UIFont fontWithName:@"Helvetica Neue" size:14.0]

#define REGISTSUCCESS @"RegistSuccess"


#define XG_TYPE_ZAN @"like"
#define XG_TYPE_ADD_FRIENDS @"friend"
#define XG_TYPE_COMMENT @"comment"
#define XG_TYPE_MESSAGE @"message"
#define XG_TYPE_ADD_FOLLOW @"follow"


//发主题，关注了你
#define XG_TYPE_ATUSER @"topicatuser"
//发评论，关注了你
#define XG_TYPE_COMMENTATUSER @"commentatuser"

//赞评论
#define XG_TYPE_ZAN_COMMENT @"likecomment"
//赞人
#define XG_TYPE_ZAN_USER @"likeuser"


#define XG_TYPE_TOPIC_DETAIL @"systopicdetail"
#define XG_TYPE_SYSHTTP @"syshttp"

//屏蔽与取消屏蔽
#define XG_TYPE_BLOCK @"block"
#define XG_TYPE_UNBLOCK @"unblock"


//////////////////////////////////
// 1.7.1 新增类型
// start
// 转发了你的主题
#define XG_TYPE_Reposttopic @"reposttopic"
// 系统推送--》个人主页
#define XG_TYPE_Sysuserhomepage @"sysuserhomepage"
// 系统推送--》话题
#define XG_TYPE_Syshuati @"syshuati"
// 系统推送--》位置
#define XG_TYPE_Syspoi @"syspoi"
// 系统推送--》附近
#define XG_TYPE_Sysnear @"sysnear"
// end
//////////////////////////////////


//用户更新通知
#define CHANGEUSERINFO @"refreshuserinfo"


//更改封面
#define NOTICE_UPDATE_COVER @"NOTICE_UPDATE_COVER"

///////////////////////////
//通知,更新消息数量
#define NOTICE_RECEIVE @"NOTICE_RECEIVE"
#define NOTICE_MESSAGE @"NOTICE_MESSAGE"
//清理消息数
#define NOTICE_CleanMESSAGE @"NOTICE_CleanMESSAGE"
//发送新消息
#define NOTICE_SendMESSAGE @"NOTICE_SendMESSAGE"

// 添加关注，或者添加好友
#define NOTICE_ADDFRIEND @"NOTICE_ADDFRIEND"
// 取消关注，或者删除好友
#define NOTICE_DELADDFRIEND @"NOTICE_DELADDFRIEND"
#define NOTICE_ADDCOMMENT @"NOTICE_ADDCOMMENT"
#define NOTICE_ADDZAN @"NOTICE_ADDZAN"


//发送好友申请的通知
#define NOTICE_SEND_FRIEND_APPLY    @"NOTICE_SEND_FRIEND_APPLY"



//屏蔽或者解除屏蔽
#define NOTICE_BLOCKORUN @"NOTICE_BLOCKORUN"

#define NOTICE_UPDATE_UserInfo  @"NOTICE_UPDATE_UserInfo"
#define NOTICE_DOWNLOAD_IMDATA_SUCCESS  @"NOTICE_DOWNLOAD_IMDATA_SUCCESS"

#define NOTIFICATION_BLOCK_USER_TOPIC    @"NOTIFICATION_BLOCK_USER_TOPIC"
#define NOTIFICATION_BLOCK_USER_MESSAGE   @"NOTIFICATION_BLOCK_USER_MESSAGE"

#define NOTIFICATION_FAVORITE_DELETE     @"NOTIFICATION_FAVORITE_DELETE"
#define NOTIFICATION_FAVORITE_ADD        @"NOTIFICATION_FAVORITE_ADD"
//主题的收藏状态发生改变
#define NOTIFICATON_FAVORITE_STATUS_CHANGE   @"NOTIFICATON_FAVORITE_STATUS_CHANGE"

//获取到新消息
#define NOTICE_RC_RECICEMESSAGE @"NOTICE_RC_RECICEMESSAGE"
//连接融云成功
#define NOTICE_RC_CONNECT @"NOTICE_RC_CONNECT"
#define NOTICE_RC_CONNECT_ERROR @"NOTICE_RC_CONNECT_ERROR"



#define NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS  @"NOTIFICATION_VEDIO_DOWNLOAD_SUCCESS"

#define Comment_Scroll_BeginDragging       @"Comment_Scroll_BeginDragging"

#define NOTIFICATION_Timer_stop             @"NOTIFICATION_Timer_stop"
#define NOTIFICATION_Timer_fire              @"NOTIFICATION_Timer_fire"

//绑定手机号成功
#define NOTICE_BINDPHONE_SUCCESS @"NOTICE_BINDPHONE_SUCCESS"

//Alert
#define ALERTSIGNOUT 4001
#define NEARBYGENDER @"nearbyGender"

#define Video_Message @"正在处理中，请稍候"

//UMeng
//是否显示QQ登陆
#define SHOWQQLOGIN @"showQQLogin"
//检测无QQ登陆是否显示QQ登陆
#define SHOWQQEXIST @"checkQQExistShow"
#define UMobClickAPI @"544f704ffd98c5a651002b48"

//融云Key
#define RCKey @"x4vkb1qpv62gk"
//测试
//#define RCKey @"x18ywvqf8dn5c"


////////////////////////////////////////////////////
// 判断Key定义
////////////////////////////////////////////////////
//聊天列表
#define KeyShowExportNotice @"KeyShowExportNotice"
#define KeyShowExportNoticeTimes @"KeyShowExportNoticeTimes"

//好友更换为关注的提醒
#define KeyShowFriendChangeToFollow @"KeyShowFriendChangeToFollow"


////////////////////////////////////////////////////
// 数据库表名称定义
////////////////////////////////////////////////////

// 联系人表
#define TutuContast @"TutuContanstTable"

// 主题表
#define TutuTopic @"TopicTable"

// 评论表
#define TutuTopicComment @"CommentTable"

// 用户表
#define TutuUserInfo @"UserInfoTable"

// 同步时间表
#define TutuSynchMark @"SynchMarkTable"

//申请表
#define TutuApplyTable @"ApplyTable"

//申请留言表
#define TutuApplyLeaveTable @"ApplyLeaveTable"



// 缓存用户信息
#define UserInfoCacheKey(uid) [NSString stringWithFormat:@"UserInfoCacheKey%@",uid]



////////////////////////////////////////////////////
// 数据判断定义
////////////////////////////////////////////////////
// 表情或输入框，是否有更新
#define CheckInputUpdate [NSString stringWithFormat:@"CheckInputUpdate%@",[[LoginManager getInstance] getUid]]
#define CheckFaceUpdate [NSString stringWithFormat:@"CheckFaceUpdate%@",[[LoginManager getInstance] getUid]]


#endif
