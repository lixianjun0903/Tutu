//
//  GlobalColor.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

//颜色取值方法
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COLORWithAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

//颜色定义
#define MenuTitleColor 0xFFFFFF

#define shareTextClolor 0xc9c9c9c
//字体颜色
#define TextBlackColor 0x333333
//字体颜色，灰色
#define TextGrayColor 0x999999

//添加好友，昵称颜色
#define TextGreenDColor 0x259d7d


#define TextCCCCCCColor 0xcccccc

//
#define TextSixColor 0x666666
#define TextSixAColor 0xAAAAAA

#define TextYellowColor 0xFFC43D
#define UserTextYellowBg 0xFFF8E3

//蒙层阴影
#define OverlayViewColor 0x1f2422

// 话题关注数背景
#define ButtonViewBgColor 0xF8F8F8


//私信，系统消息背景
#define ChatSysMessageBg 0xd9dade
#define ChatSysMessageBgHigh 0xcecfd2

//发布表情页面背景
#define EmotionCheckBg 0x353B39
#define EmotionListBg 0xF2F3F7
#define EmotionScrollViewBg 0x2d3331

#define ListLineColor 0xdedede
#define ItemLineColor 0xEEEEEE

// UserInfo
#define UserInfoBottomLineColor 0x3EA489

//图片背景
#define DragImageColor 0x4D5855

//混音滑块
#define SliderBgColor 0x2C3330

//提示层颜色
#define NoticeColor 0xF24C4C
#define NoticeBlockBgColor 0x000000

//系统薄荷绿背景色
#define SystemColor 0x53cbab
#define SystemColorHigh 0x87dbc4
#define UserInfoMenuHigh 0x8cdac3

// 系统音乐选中后的绿色
#define SystemMusicHigh 0xB6E6D7


//发送好友请求
#define SendFriendApply 0x1475e6


//录制背景颜色
#define BackgroundRecordColor 0x1F2422

//搜索高亮字体颜色
#define SearchHintColor 0XC9C9CE


//录制进度条背景色
#define ProgressBackColor 0x343635

//录音进度条背景色
#define ProgressVoiceBackColor 0xe3fff8

//选择音乐的蒙层
#define coverViewColor 0x000000

//录制的蒙层
#define CoverRecordColor 0x1f2422

//系统灰色背景颜色
#define SystemGrayColor 0xF2F3F7


//裁切视频视图背景
#define cutBackColor 0xF8F8F8

//首页黑色背景
#define HomeBlackColro 0x303231

//深绿色
#define DrakGreenNickNameColor 0x279d7d


//个人中心Button点击字体颜色
#define ButtonClickColor 0xc8c7cc

//性别、年龄背景
//#define GenderBoyColorBg 0x84b1ea
//#define GenderGirlColorBg 0xfe9092
#define GenderBoyColorBg 0x8FC4F0
#define GenderGirlColorBg  0xFAA7BB
#define HeaderGrayColor RGB(228, 228, 228)

//重新发送验证码字体颜色
#define TextGreenColor 0x4EC0A1
#define TextRegusterGrayColor 0xAAAAAA

//表情上方颜色图片
#define EmotionMenuColor 0x1F2422

//白色文字选中后颜色
#define ButtonHightWhiteColor 0xf68282


//私信列表头部到私信提醒背景
#define LetterListTopBgColor 0xEDFAF6
//私信列表头部到私信提醒文字
#define LetterListTopTextColor 0x68D0B3


