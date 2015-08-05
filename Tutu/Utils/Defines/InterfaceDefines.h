//
//  InterfaceDefines.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-24.
//  Copyright (c) 2014年 zxy. All rights reserved.
//


#define HttpTimeOutSecond 5
#define HttpPostTimeOutSecond 30


//#define API_HOST @"http://223.6.253.158"
//#define API_HOST @"http://121.41.60.175"
#define API_HOST @"http://api.tutuim.com"

// 分享主题
#define SHARE_TOPIC_HOST @"http://www.tutuim.com/topicdetail/"
//分享
#define SHAREURL @"http://www.tutuim.com/invite/"
//头像url
#define AVATARURL @"http://a.tutuim.com/avatar/"

//功能介绍
#define API_Function_About @"http://api.tutuim.com/static/feature.php"

//表情、输入框URL
#define EMOTIONURL @"http://www.tutuim.com/download/commentbox/"

//话题广场
#define URL_HuaTi_GuangChang      @"http://www.tutuim.com/hd/hothuatih5.php"

//首页热门列表

#define API_index_hot_list(starttopicid,endtopicid,len,direction) [NSString stringWithFormat:@"%@/topic/indexhotlist.php?starttopicid=%@&endtopicid=%@&len=%d&direction=%@",API_HOST,starttopicid,endtopicid,len,direction]

//首页朋友列表
#define API_index_friend_list(starttopicid,endtopicid,len,direction)  [NSString stringWithFormat:@"%@/topic/indexfriendlist.php?starttopicid=%@&endtopicid=%@&len=%d&direction=%@",API_HOST,starttopicid,endtopicid,len,direction]

//给主题点赞
#define API_TOPIC_LIKE [NSString stringWithFormat:@"%@%@",API_HOST,@"/digg/liketopic.php"]
//给主题取消赞
#define API_TOPIC_UNLIKE [NSString stringWithFormat:@"%@%@",API_HOST,@"/digg/disliketopic.php"]
//主题详情
#define API_TOPIC_DETAIL(topicid,startcommentid)  [NSString stringWithFormat:@"%@/topic/topic.php?topicid=%@&commentid=%@",API_HOST,topicid,startcommentid]
//主题评论列表

#define API_TOPIC_COMMENT_LIST [NSString stringWithFormat:@"%@%@",API_HOST,@"/comment/commonlist.php"]
//发布主题
#define API_ADD_TOPIC [NSString stringWithFormat:@"%@%@",API_HOST,@"/topic/addtopic.php"]

#define API_ADD_TOPIC_v2 [NSString stringWithFormat:@"%@%@",API_HOST,@"/topic/addtopicv2.php"]

//获得好友列表
#define API_MY_FRIENDS_GET  [NSString stringWithFormat:@"%@%@",API_HOST,@"/friend/getfriendlist.php"]
//删去好友
#define API_MY_FRIEND_DELETE  [NSString stringWithFormat:@"%@%@",API_HOST,@"/friend/delfriend.php"]
//添加好友

#define API_MY_FRIEND_ADD  [NSString stringWithFormat:@"%@%@",API_HOST,@"/friend/addfriend.php"]
//屏蔽好友
#define API_MY_FRIEND_BLICK  [NSString stringWithFormat:@"%@%@",API_HOST,@"/message/block.php"]
//取消屏蔽
#define API_MY_FRIEND_UNBLOCK   [NSString stringWithFormat:@"%@%@",API_HOST,@"/message/unblock.php"]
//删去主题

#define API_TOPIC_DELETE   [NSString stringWithFormat:@"%@%@",API_HOST,@"/topic/deltopic.php"]

//获得首页的消息数

#define API_Get_Usernewinfo   [NSString stringWithFormat:@"%@%@",API_HOST,@"/userinfo/getusernewinfo.php"]

//发布主题联想接口
#define API_RELEASE_HOT_TOPIC(searchtxt,len) [NSString stringWithFormat:@"%@%@?searchtxt=%@&len=%@",API_HOST,@"/topic/searchhuatiforpublish.php",searchtxt,len]

//发布评论
#define API_ADD_COMMENT [NSString stringWithFormat:@"%@%@",API_HOST,@"/comment/addcomment.php"]

//上传视频的观看次数
#define API_UPLOAD_VEDIO_VIEWS    [NSString stringWithFormat:@"%@/topic/viewtopic.php?",API_HOST]

//获取时间新排序评论

#define API_NEW_COMMENT_LIST(topicid,startcommentid,len,direction)    [NSString stringWithFormat:@"%@/comment/newcommentlist.php?topicid=%@&startcommentid=%@&len=%d&direction=%@",API_HOST,topicid,startcommentid,len,direction]
//获取HOT评论
#define API_HOT_COMMENT_LIST(topicid,startcommentid,len,direction)    [NSString stringWithFormat:@"%@/comment/hotcommentlist.php?topicid=%@&startcommentid=%@&len=%lu&direction=%@",API_HOST,topicid,startcommentid,len,direction]

//赞一个评论
#define API_ZAN_COMMENT(commentid)    [NSString stringWithFormat:@"%@/digg/likecomment.php?commentid=%@",API_HOST,commentid]

//取消赞一个评论
#define API_ZAN_CANCEL_COMMENT(commentid)    [NSString stringWithFormat:@"%@/digg/dislikecomment.php?commentid=%@",API_HOST,commentid]

//举报一个评论

#define API_COMMENT_REPORT(commentid)    [NSString stringWithFormat:@"%@/comment/reportcomment.php?commentid=%@",API_HOST,commentid]

//十六    设置用户资料
#define API_ADD_SETUSERINFO(type,string) [NSString stringWithFormat:@"%@%@?%@=%@",API_HOST,@"/userinfo/setuserinfo.php",type,string]
#define API_ADD_SETUSERINFOS(sth) [NSString stringWithFormat:@"%@%@?%@",API_HOST,@"/userinfo/setuserinfo.php",sth]
#define API_ADD_SETUSERAVATAR [NSString stringWithFormat:@"%@%@",API_HOST,@"/userinfo/setavatar.php"]



//检测昵称重复
#define API_CHECKRENAME(nickname) [NSString stringWithFormat:@"%@%@?nickname=%@",API_HOST,@"/sso/checknicknameexist.php",nickname]

//注册获取验证码
#define API_REGIST_GET_REGVERIFY_CODE(phoneNum) [NSString stringWithFormat:@"%@%@?phonenumber=%@",API_HOST,@"/sso/getregverifycode.php",phoneNum]

//注册校验验证码
#define API_REGIST_CHECK_REGVERIFY_CODE(phoneNum,code) [NSString stringWithFormat:@"%@%@?phonenumber=%@&vcode=%@",API_HOST,@"/sso/checkregverifycode.php",phoneNum,code]

//注册
#define API_REGIST_SETINFO(phonenumber,password,nickname) [NSString stringWithFormat:@"%@%@?phonenumber=%@&password=%@&nickname=%@",API_HOST,@"/sso/reg.php",phonenumber,password,nickname]





//十七+ 登陆接口
#define API_ADD_LOGIN(num,password) [NSString stringWithFormat:@"%@%@?phonenumber=%@&password=%@",API_HOST,@"/sso/phonelogin.php",num,password]

//十七++  登陆状态下的修改密码
#define APP_CHANGEPASSWORD_LOGIN(phonenumber) [NSString stringWithFormat:@"%@%@?phonenumber=%@",API_HOST,@"/sso/resetpassword.php",phonenumber]



//二十、重置密码获取验证码      忘记密码获取验证码
#define APP_CHECKNUM_LOGIN(phonenumber) [NSString stringWithFormat:@"%@%@?phonenumber=%@",API_HOST,@"/sso/getresetpasswordverifycode.php",phonenumber]

//二十+、检查重置密码验证码是否正确     检查重置验证码
#define APP_RESETPASSWORD_LOGIN(phonenumber,vcode) [NSString stringWithFormat:@"%@%@?phonenumber=%@&vcode=%@",API_HOST,@"/sso/checkresetpasswordverifycode.php",phonenumber,vcode]

//二十一、重置密码第二步输入验证码重新设置验证码       重置密码
#define APP_RESTPASSWORD_RESET(phonenumber,newpassword) [NSString stringWithFormat:@"%@%@?phonenumber=%@&newpassword=%@",API_HOST,@"/sso/resetpasswordverifycode.php",phonenumber,newpassword]


//

//修改密码
#define API_CHANGEPASSWORD_LOGIN(old,new) [NSString stringWithFormat:@"%@%@?oldpassword=%@&newpassword=%@",API_HOST,@"/sso/resetpassword.php",old,new]

//http://223.6.253.158/sso/resetpassword.php?oldpassword=aaaaaa&newpassword=bbbbbb

//二十一   退出登陆
#define API_ADD_SIGNOUT [NSString stringWithFormat:@"%@%@",API_HOST,@"/sso/logout.php"]


//举报主题
#define API_REPORTTOPIC(topicid) [NSString stringWithFormat:@"%@%@?topicid=%@",API_HOST,@"/topic/reporttopic.php",topicid]



///////////////////////////////////////////////
// 个人信息相关
#define API_GET_USERINFO(userid) [NSString stringWithFormat:@"%@%@?uid=%@",API_HOST,@"/userinfo/getuserinfo.php",userid]

//获取自己的用户信息
#define API_GET_SELFINFO [NSString stringWithFormat:@"%@%@",API_HOST,@"/userinfo/syncselfinfo.php"]

//获取用户发布主题列表
#define API_GET_USER_TOPIC(uid,starttopicid,len) [NSString stringWithFormat:@"%@%@?uid=%@&starttopicid=%@&len=%@",API_HOST,@"/topic/usertopiclist.php",uid,starttopicid,len]

//缓存同步接口
#define API_GET_SelfUSER_TOPIC(localnewtime,locallasttime,localupdatetime,locallisttype) [NSString stringWithFormat:@"%@%@?localnewtime=%@&locallasttime=%@&localupdatetime=%@&locallisttype=%@",API_HOST,@"/userinfo/syncusertopiclist.php",localnewtime,locallasttime,localupdatetime,locallisttype]


//三十、用户搜索接口
#define API_SEARCH_USER(keyword,startuid,len,direction) [NSString stringWithFormat:@"%@%@?keyword=%@&startuid=%@&len=%@&direction=%@",API_HOST,@"/userinfo/searchuser.php",keyword,startuid,len,direction]

///////////////////////////////////////////////
//十四+、删除会话
#define API_DEL_SESSION(touid) [NSString stringWithFormat:@"%@%@?touid=%@",API_HOST,@"/message/delsession.php",touid]

//屏蔽私信
#define API_BLOCK(blockuid) [NSString stringWithFormat:@"%@%@?blockuid=%@",API_HOST,@"/message/block.php",blockuid]

//解除屏蔽私信
#define API_UNBLOCK(blockuid) [NSString stringWithFormat:@"%@%@?blockuid=%@",API_HOST,@"/message/unblock.php",blockuid]


//获取动态列表
#define API_GET_FEEDS(starttipid,len,direction) [NSString stringWithFormat:@"%@%@?starttipid=%@&len=%@&direction=%@",API_HOST,@"/tip/tiplist.php",starttipid,len,direction]

//删除动态
#define API_DEL_FEEDS(tipid) [NSString stringWithFormat:@"%@%@?tipid=%@",API_HOST,@"/tip/deltip.php",tipid]

//清楚未读记录
#define API_DEL_FEEDS_Read(tipid) [NSString stringWithFormat:@"%@%@?tipid=%@",API_HOST,@"/tip/readtip.php",tipid]


//十四：最新聊天会话列表
#define API_GET_SESSIONLIST(page,len) [NSString stringWithFormat:@"%@%@?page=%@&len=%@",API_HOST,@"/message/sessionlist.php",page,len]

// 十三、获取私聊列表
// newmessage 1：获得新信息，0：获得老信息
#define API_GET_MESSAGELIST(touid,messageid,len,direction) [NSString stringWithFormat:@"%@%@?touid=%@&messageid=%@&len=%@&direction=%@",API_HOST,@"/message/messagelist.php",touid,messageid,len,direction]

//十二、发送私聊
#define API_SEND_MESSAGE(message,touid) [NSString stringWithFormat:@"%@%@?message=%@&touid=%@",API_HOST,@"/message/addmessage.php",message,touid]

//QQ登陆接口
#define API_QQLOGIN(accessToken,openId) [NSString stringWithFormat:@"%@%@?accessToken=%@&openId=%@",API_HOST,@"/sso/qqlogin.php",accessToken,openId]
#define API_QQFISTREGIST(accessToken,openid,nickname) [NSString stringWithFormat:@"%@%@?accessToken=%@&openId=%@&nickName=%@",API_HOST,@"/sso/qqloginreg.php",accessToken,openid,nickname]

//添加备注
#define API_UPDATE_REMARD_NICK(frienduid,remark)[NSString stringWithFormat:@"%@%@?frienduid=%@&remark=%@",API_HOST,@"/friend/setremark.php",frienduid,remark]


//查询同城好友
#define API_Find_SameCity(startuid,len,direction)[NSString stringWithFormat:@"%@%@?startuid=%@&len=%@&direction=%@",API_HOST,@"/userinfo/getlocaluser.php",startuid,len,direction]



//屏蔽用户主题
#define API_BLOCK_USER_FEED(blockuid)[NSString stringWithFormat:@"%@%@?blockuid=%@",API_HOST,@"/userinfo/blockusertopic.php",blockuid]
//解除屏蔽用户主题
#define API_UNBLOCK_USER_FEED(blockuid)[NSString stringWithFormat:@"%@%@?blockuid=%@",API_HOST,@"/userinfo/unblockusertopic.php",blockuid]


//清空聊天数量
#define API_CLEAR_MESSAGE(touid) [NSString stringWithFormat:@"%@%@?touid=%@",API_HOST,@"/message/clearsessionnews.php",touid]

//上传位置坐标
#define API_LOCATION(latitude,longitude,radius,addr,operationers)[NSString stringWithFormat:@"%@%@?latitude=%@&longitude=%@&radius=%@&addr=%@&operationers=%@",API_HOST,@"/userinfo/location.php",latitude,longitude,radius,addr,operationers]


//获得屏蔽私信的用户列表
#define API_BLOCK_USER_MESSAGE_LIST  [NSString stringWithFormat:@"%@%@?",API_HOST,@"/message/blockusermessagelist.php"]

//屏蔽用户的topic

#define API_BLOCK_USER_TOPIC  [NSString stringWithFormat:@"%@%@?",API_HOST,@"/userinfo/blockusertopic.php"]

//获得被屏蔽主题的用户
#define API_BLOCK_USER_TOPIC_LIST     [NSString stringWithFormat:@"%@%@?",API_HOST,@"/userinfo/blockusertopiclist.php"]

//收藏topic
#define API_TOPIC_FAVORITE_ADD(X)          [NSString stringWithFormat:@"%@/favorite/addfavorite.php?topicid=%@",API_HOST,X]

//取消收藏topic
#define API_TOPIC_FAVORITE_DELETE(X)          [NSString stringWithFormat:@"%@/favorite/delfavorite.php?topicid=%@",API_HOST,X]


//我的topic收藏列表
#define API_TOPIC_FAVORITE_LIST(len,direction,starttopicid)     [NSString stringWithFormat:@"%@/favorite/getfavoritelist.php?len=%d&direction=%@&starttopicid=%@",API_HOST,len,direction,starttopicid]

//上传通讯录接口
#define API_COMMITADDRESSLIST [NSString stringWithFormat:@"%@/contacts/uploadcontacts.php",API_HOST]
//



///////////////////////////////////////////////
// 绑定相关
//////////
//检查绑定并发短信
#define API_CHECK_PHONEBIND(phonenumber) [NSString stringWithFormat:@"%@/userinfo/checkphonecanbind.php?phonenumber=%@",API_HOST,phonenumber]

//重复发送短信
#define API_RE_SendCode(phonenumber) [NSString stringWithFormat:@"%@/userinfo/getphonebindverifycode.php?phonenumber=%@",API_HOST,phonenumber]

//检查验证码
#define API_Check_Code(phonenumber,vcode) [NSString stringWithFormat:@"%@/userinfo/checkphonebindverifycode.php?phonenumber=%@&vcode=%@",API_HOST,phonenumber,vcode]

//绑定手机
#define API_BIND_PHONE(phonenumber,password) [NSString stringWithFormat:@"%@/userinfo/confirmbindphone.php?phonenumber=%@&password=%@",API_HOST,phonenumber,password]
//绑定相关结束

//分享主题至Tutu好友私信
#define API_SHARE_TO_TUTU_FRIEND(toUid,topicId,title,content,message)    [NSString stringWithFormat:@"%@/share/topictomessage.php?touid=%@&topicid=%@&title=%@&content=%@&message=%@",API_HOST,toUid,topicId,title,content,message]
///////////////////////////////////////////////

//退出出登录关闭消息通知
#define API_SSO_LOGOUT             [NSString stringWithFormat:@"%@/sso/logout.php?",API_HOST]


//删除评论
#define API_COMMENT_DELETE(commentid,topicid)      [NSString stringWithFormat:@"%@/comment/delcomment.php?commentid=%@&topicid=%@",API_HOST,commentid,topicid]

//设置用户的位置可见性
#define API_SET_USER_INFO(locationstatus)     [NSString stringWithFormat:@"%@/userinfo/setuserinfo.php?locationstatus=%@",API_HOST,locationstatus]

//获得用户Token
#define API_GET_TOKEN [NSString stringWithFormat:@"%@/message/gettoken.php",API_HOST]

//导入数据
#define API_GET_UserOldMESSAGE [NSString stringWithFormat:@"%@/userinfo/exportmsgdata.php",API_HOST]

//获取融云用户与本地用户关系
#define API_GET_RCUserRelationInfo(userids) [NSString stringWithFormat:@"%@/message/messagerelation.php?uidlist=%@",API_HOST,userids]

// 检测用户是否存在历史聊天数据
#define API_Check_ExportHistroy(senduid,getuid,sendtime) [NSString stringWithFormat:@"%@/userinfo/havemsgdata.php?senduid=%@&getuid=%@&sendtime=%@",API_HOST,senduid,getuid,sendtime]




//举报用户
#define API_GET_REPORT_USER(uid,type,text,isreport)[NSString stringWithFormat:@"%@//report/user.php?reportuid=%@&reasontype=%@&userinput=%@&isuploadmesage=%d",API_HOST,uid,type,text,isreport]

//上传封面
#define API_POST_COVER [NSString stringWithFormat:@"%@/userhomecover/updateuserhomecover.php",API_HOST]

//获取封面信息
#define API_GET_COVER_LIST [NSString stringWithFormat:@"%@/userhomecover/getsyscoverlist.php",API_HOST]


//用户点赞
#define API_ADD_Liker(uid) [NSString stringWithFormat:@"%@/digg/likeuser.php?uid=%@",API_HOST,uid]


//通知服务器，私信数据下载完成
#define API_DownLoad_Success(fileName) [NSString stringWithFormat:@"%@/userinfo/endexportmsgstatus.php?fileName=%@",API_HOST,fileName]

//申请好友
#define API_Apply_Friend(frienduid,applymsg,nameremark) [NSString stringWithFormat:@"%@/friend/addfriend.php?frienduid=%@&applymsg=%@&nameremark=%@",API_HOST,frienduid,applymsg,nameremark]

// 添加好友
#define API_ADD_FRIEND(frienduid) [NSString stringWithFormat:@"%@/friend/addfriend.php?frienduid=%@",API_HOST,frienduid]

//获取申请列表
#define API_Get_friend_applylis(localnewtime,locallasttimen)    [NSString stringWithFormat:@"%@/friend/syncfriendapplylist.php?localnewtime=%@&locallasttime=%@",API_HOST,localnewtime,locallasttimen]
//同意好友
#define API_friend_agreeapply(frienduid)   [NSString stringWithFormat:@"%@/friend/agreeapply.php?frienduid=%@",API_HOST,frienduid]
//获取新增好友申请数量

#define API_friend_getnewapplycount   [NSString stringWithFormat:@"%@/friend/getnewapplycount.php",API_HOST]

//回复好友申请
#define API_friend_reply_apply(frienduid,applymsg)      [NSString stringWithFormat:@"%@/friend/addapplymsg.php?frienduid=%@&applymsg=%@",API_HOST,frienduid,applymsg]

#define API_friend_apply_delete    [NSString stringWithFormat:@"%@//friend/delfriendapply.php?",API_HOST]

//好友同步

#define API_Sync_My_Friend(localnewtime,locallasttime,localupdatetime)   [NSString stringWithFormat:@"%@/userinfo/syncfriendlist.php?localnewtime=%@&locallasttime=%@&localupdatetime=%@",API_HOST,localnewtime,locallasttime,localupdatetime]

//设置好友申请已读

#define API_Set_apply_read   [NSString stringWithFormat:@"%@/friend/setapplyread.php?",API_HOST]

//根据话题获取话题列表
#define API_GET_TOPIC_LIST(huati,sorttype,starttopicid,len,direction) [NSString stringWithFormat:@"%@/topic/huatitopiclist.php?huati=%@&sorttype=%@&starttopicid=%@&len=%@&direction=%@",API_HOST,huati,sorttype,starttopicid,len,direction]

//位置下主题列表
#define API_GET_POI_TOPIC_LIST(poiid,sorttype,starttopicid,len,direction) [NSString stringWithFormat:@"%@/topic/poitopiclist.php?poiid=%@&sorttype=%@&starttopicid=%@&len=%@&direction=%@",API_HOST,poiid,sorttype,starttopicid,len,direction]

//关注话题
#define API_ADD_TOPIC_FOCUS(htid) [NSString stringWithFormat:@"%@/topic/addhuatifollow.php?htid=%@",API_HOST,htid]

//取消话题关注
#define API_DEL_TOPIC_FOCUS(htid) [NSString stringWithFormat:@"%@/topic/delhuatifollow.php?htid=%@",API_HOST,htid]

//添加位置关注
#define API_ADD_POI_FOCUS(poiid) [NSString stringWithFormat:@"%@/topic/addpoifollow.php?poiid=%@",API_HOST,poiid]

//取消位置关注
#define API_DEL_POI_FOCUS(poiid) [NSString stringWithFormat:@"%@/topic/delpoifollow.php?poiid=%@",API_HOST,poiid]

//用户关注列表
#define API_GetUserFocus_List(uid,direction,startfid,len) [NSString stringWithFormat:@"%@/topic/userfollowlist.php?uid=%@&direction=%@&startfid=%@&len=%@",API_HOST,uid,direction,startfid,len]

//获取话题关注用户列表
#define API_GET_TopicFOCUS_USER_LIST(htid,len) [NSString stringWithFormat:@"%@/topic/huatiuserlist.php?htid=%@&len=%@&startfid=",API_HOST,htid,len]

// 获取位置关注用户列表
#define API_GET_PoiFOCUS_USER_LIST(poiid,len) [NSString stringWithFormat:@"%@/topic/poiuserlist.php?poiid=%@&len=%@&&startfid=",API_HOST,poiid,len]


// 搜索用户
#define API_Publish_SearchUserList(searchtext)[NSString stringWithFormat:@"%@/topic/searchuserforpublish.php?searchtxt=%@&len=100",API_HOST,searchtext]


// 举报话题
#define API_Report_POIORHT(type,ids)[NSString stringWithFormat:@"%@/topic/reporthtpoi.php?type=%@&ids=%@",API_HOST,type,ids]


///////////////////////////////////////////////
// 1.7.0新增接口
///////////////////////////////////////////////

//获取首页关注列表
#define API_Index_Follow_List(starttopicid,endtopicid,len,direction)  [NSString stringWithFormat:@"%@/topic/indexfollowlist.php?starttopicid=%@&endtopicid=%@&len=%d&direction=%@",API_HOST,starttopicid,endtopicid,len,direction]

//获取用户粉丝
#define API_GET_FansList(uid,direction,len,startuid)[NSString stringWithFormat:@"%@/friend/getfanslist.php?uid=%@&direction=%@&len=%d&startuid=%@",API_HOST,uid,direction,len,startuid]

//获取用户关注人列表
#define API_GET_FollowUserList(uid,direction,len,startuid)[NSString stringWithFormat:@"%@/friend/getfollowlist.php?uid=%@&direction=%@&len=%d&startuid=%@",API_HOST,uid,direction,len,startuid]

//搜索好友，感兴趣的人
#define API_Get_RecommendMore(direction,len,startuid) [NSString stringWithFormat:@"%@/friend/getrecommendmore.php?datatype=user&withtopic=withtopic&direction=%@&len=%d&startid=%@",API_HOST,direction,len,startuid]


// 关注用户
#define API_ADD_Follow_User(uid) [NSString stringWithFormat:@"%@/friend/addfollow.php?frienduid=%@",API_HOST,uid]

// 取消用户关注
#define API_DEL_Follow_User(uid) [NSString stringWithFormat:@"%@/friend/delfollow.php?frienduid=%@",API_HOST,uid]

//删除粉丝
#define API_DEL_UserFans(uid) [NSString stringWithFormat:@"%@/friend/delfans.php?frienduid=%@",API_HOST,uid]

//转发主题
#define API_Repost_Topic(topicid)  [NSString stringWithFormat:@"%@/topic/reposttopic.php?reposttopicid=%@",API_HOST,topicid]
//取消主题转发
#define API_DEL_Repost_Topic(topicid)  [NSString stringWithFormat:@"%@/topic/delreposttopic.php?reposttopicid=%@",API_HOST,topicid]

//手机标识列表
#define API_PhoneNameList    [NSString stringWithFormat:@"%@/userinfo/listphonename.php?",API_HOST]

//新浪微博登录授权回调
#define API_LOGIN_SinaBack(wbuid,accesstoken,expiresin) [NSString stringWithFormat:@"%@%@?wbuid=%@&accesstoken=%@&expiresin=%d",API_HOST,@"/sso/wblogin.php",wbuid,accesstoken,expiresin]
//新浪微博注册
#define API_LOGIN_SinaReg(wbuid,accesstoken,expiresin,nickname) [NSString stringWithFormat:@"%@%@?wbuid=%@&accesstoken=%@&expiresin=%d&nickname=%@",API_HOST,@"/sso/wbreg.php",wbuid,accesstoken,expiresin,nickname]

//首页，位置，主题推荐/friend/getrecommendlist.php

#define API_Friend_RecommendList(latitude,longitude)  [NSString stringWithFormat:@"%@/friend/getrecommendlist.php?latitude=%f&longitude=%f",API_HOST,latitude,longitude]


//设置用户手机标识
#define API_Set_Phone_Name(typeid)  [NSString stringWithFormat:@"%@/userinfo/setphonename.php?typeid=%d",API_HOST,typeid]


//获取线上评论输入框
#define API_Get_InputList [NSString stringWithFormat:@"%@/userinfo/loadcommentinputbox.php",API_HOST]
//获取线上表情
#define API_Get_FaceList [NSString stringWithFormat:@"%@/userinfo/loadcommentemotionbox.php",API_HOST]


