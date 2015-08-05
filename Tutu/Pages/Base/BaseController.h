//
//  BaseController.h
//  Tutu
//  基础类，作用
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//
//  修改日期
//  修改人
//  原因

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MenuButtonTag) {
    BACK_BUTTON=1,
    RIGHT_BUTTON=2,
    OTHER_BUTTON=3,
    DOWN_BTNTAG1=4,
    DOWN_BTNTAG2=5,
    DOWN_BTNTAG3=6,
};

//提示层颜色
typedef NS_ENUM(NSInteger, TopNoticeBackColor) {
    TopNotice_Red_Color=1,
    TopNotice_Block_Color=2,
};


typedef void(^NoticeComplete)();


//*********************属性说明**********************************
//如果用的是自定义的View当做NavigationBar，创建的是上面的menuLeftButton，
//如何是在系统的原生的导航栏上自定义，用的是下面的leftBarItem
@interface BaseController : UIViewController

@property(nonatomic,retain)UIView *titleMenu;

@property(nonatomic,retain)UIButton *menuTitleButton;
@property(nonatomic,retain)UIButton *menuLeftButton;
@property(nonatomic,retain)UIButton *menuRightButton;
@property(nonatomic,retain)UIButton *otherButton;



//当页面的list数据为空时，给它一个带提示的占位图。
@property(nonatomic,strong)UIView *placeholderView;


// 是否登录
-(BOOL)isLogin;

// 登录
-(void)doLogin;

// 获取用户UID
-(NSString *)getUID;
-(UserInfo *)getLoginUser;


/**
 *  当页面的list数据为空时，需要创建一个占位视图
 *
 *  @param center 占位视图的center
 *  @param message 占位视图上面的提示文字
 *  @param superView 显示在那个view上，如果nil，就显示在self.view
 */

- (void)createPlaceholderView:(CGPoint)center message:(NSString *)message withView:(UIView *)superView;

/**
 *  移除占位视图
 */
- (void)removePlaceholderView;

/**
 * 打开nav，并传递声音
 */
-(IBAction)openNavWithSound:(UIViewController *) controller;

/**
 * 打开新的页面
 * soundName，声音名字，如果open.m4a,传递open
 */
-(IBAction)openNav:(UIViewController *) controller sound:(NSString *)soundName;


/**
 * 播放声音
 * soundName，声音名字，如果open.m4a,传递open
 */
-(void)playerSoundWith:(NSString *)soundName;

/**
 * 返回上一页
 */
-(IBAction)goBack:(id)sender;

/**
 *  加载数据方法
 */
-(void)refreshData;
-(void)loadMoreData;

// 检查用户是否被封杀，
// YES被封杀
- (BOOL)checkBeKill;


/**
 * 创建顶部导航
 * menuTitleButton; 中间标题
 * menuLeftButton;  左边返回
 * menuRightButton; 右边按钮
 * otherButton;     右边按钮
 *
 */
-(void)createTitleMenu;

//////////////////////////////////////////////////////////////////
//获取顶层Controller
- (UIViewController *)getCurrentVC;


//////////////////////////////////////////////////////////////////

/**
 * button 点击
 * MenuButtonTag tag 枚举值
 */
-(IBAction)buttonClick:(id)sender;

/**
 * 下滑提示框
 *  title，提示的标题
 *  detail 如果没有，直接传nil
 * 枚举直接选择
 */
-(UIView *)showNoticeWithMessage:(NSString *)title message:(NSString *) detail bgColor:(TopNoticeBackColor) colorEnum;
-(UIView *)showNoticeWithMessage:(NSString *)title message:(NSString *) detail bgColor:(TopNoticeBackColor) colorEnum block:(NoticeComplete) finish;

//接收到新消息
-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object;

// 重新连接成功
-(void)connectRCSuccess:(NSString *) userId;
-(void)connectRCError:(NSString *) errorMsg;

//屏蔽或者解除屏蔽私信
-(void)pushBlockNotice:(NSString *) action uid:(NSString *)userid;




@end
