//
//  WebCopyDefines.h
//  Tutu
//
//  Created by gexing on 1/14/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#define WebCopy_NoNewComment        @"已经是最新的了"
#define WebCopy_NewComment(x)       [NSString stringWithFormat:@"更新了%d条评论",x]


#define WebCopy_ShareTitle(nickname) [NSString stringWithFormat:@"分享【%@】的主题",nickname]

#define WebCopy_ShareTuFriendTitle  @"这图片也是醉了"
#define WebCopy_ShareTuFriendDesc   @"看完我整个人都不好了，分享给你一起乐呵一下！"

#define WebCopy_ShareQQTitle        @"快来看，Tutu上这张图"
#define WebCopy_ShareQQDesc         @"分享给你一张图片，快安装Tutu帮我点个赞！"

#define WebCopy_ShareZoneTitle      @"我在Tutu交到了好多朋友~"
#define WebCopy_ShareZoneDesc       @"我在Tutu要火了！你们确定不来玩吗？"


#define WebCopy_ShareWeixinFriendTitle   @"快来看，Tutu上这张图"
//#define WebCopy_ShareWeixinFriendDesc    @"Tutu - 95后、00后图片视频交友软件-xxx发布的图片"
#define WebCopy_ShareWeixinFriendDesc(x)  [NSString stringWithFormat:@"Tutu - 95后、00后图片视频交友软件-%@发布的图片",x]

#define WebCopy_ShareWeixinTimelineTitle  @"在Tutu看到这图，真是醉了"
#define WebCopy_ShareWeixinTimelineDesc   @"特效评论，最炫表情，最近好友们都在玩Tutu！"


#define WebCopy_ShareSinaTitle           @"在Tutu看到这图，真是醉了！"
#define WebCopy_ShareSinaDesc            @"95后、00后都在玩 #Tutu#,快来围观吐槽吧！@Tutu弹幕交友"

//分享个人主页给好友
#define WebCopy_ShareProfleToFridenTitle        @"邀请你加入Tutu"
#define WebCopy_ShareProfleToFridenDesc(x)      [NSString stringWithFormat:@"我在Tutu，我的Tutu号是%@。95后、00后都在玩！快来加入吧！",x]

//收藏成功
#define WebCopy_Collect_Success      @"收藏成功，请在个人主页查看收藏！"
//取消收藏
#define WebCopy_Cancel_Collect       @"主人，都收藏了这么久，您确定要取消收藏吗？"

//屏蔽他（她）的内容
#define WebCopy_Block_Somebody_topic        @"屏蔽成功，可以在设置中解除屏蔽！"
//屏蔽他（她）的私信
#define WebCopy_Block_Somebody_message      @"屏蔽成功，你将不再接收对方消息。"
//屏蔽内容列表为空
#define WebCopy_Block_topic_none            @"善良的你还没有屏蔽任何内容哦~"
//屏蔽私信列表为空
#define WebCopy_Block_message_none          @"还没有讨厌的人存在哦~"
//没有发布任何主题
#define WebCopy_Release_my_topic_none       @"主人！不发照片是没有小伙伴处友滴~"
//他人没有发布主题
#define WebCopy_Release_other_topic_none    @"这位小伙伴有点懒，还没有发照片！"
//没有收藏任何内容
#define WebCopy_Collect_topic_none          @"主人！这里什么都米有！快去收藏喜欢的内容把！"
//无任何好友
#define WebCopy_None_friend                 @"一个Tu友都没有感觉心塞塞的..."
//无任何私信
#define WebCopy_None_message                 @"还没有私信，先去跟其他Tu友搭讪吧~"

//有需要导入的数据时，头部需要显示的文案
#define WebCopy_HadExport_message @"有历史聊天记录！请到“设置->隐私->聊天记录下载”中下载之前的聊天记录。"

//改变好友到关注粉丝提醒
#define WebCopy_FriendToFocus_message @"温馨提醒：新版Tutu好友转换成粉丝和关注，之前好友全部为互粉好友~~"

//确定删除该好友？
#define WebCopy_Delete_Friend                 @"确定删除该好友？"
//删除私信
#define WebCopy_Delete_message                @""

//主题发布中
#define WebCopy_Post_Topic_Start    @"主题正在发布，请稍候..."

//用户被封杀
#define WebCopy_BeKill_message @"你已经被封号，回火星老家种田去吧"
//个人页查询用户不存在
#define WebCopy_User_NotFound @"该用户不存在"


//没有任何动态

#define WebCopy_None_dynamic                  @"还没有新的动态哦~"

//删除图片

#define WebCopy_Delete_topic                @"主人，你真的不要我了吗？"

//发布主题,无网络
#define Error_NetMessage @"啊哦，网络好像不给力哦~"

//举报不良图片
#define WebCopy_Report_topic                         @"举报成功！管理员会及时处理！"
//查看被封号的主页

#define WebCopy_User_Disabled                        @"Ta发了不良内容，被封号了！"
//好友发布照片,推送

#define WebCopy_Friend_Release_topic(x)              [NSString stringWithFormat:@"你的好友%@刚刚发布了一张照片快去看看吧",x]




