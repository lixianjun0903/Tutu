//
//  NavBaseController.h
//  Tutu
//
//  Created by zhangxinyao on 15-2-12.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface NavBaseController : BaseController


//设置系统导航栏的风格
// 搜索、webview使用
- (void)setNavigationBarStyle;
/**
 *  创建leftBarItem
 *
 *  @param select          按钮点击后调用的方法
 *  @param imageName       Normal下图片的名称
 *  @param heightImageName 点击下图片的名称
 */
- (void)createLeftBarItemSelect:(SEL)select imageName:(NSString *)imageName heightImageName:(NSString *)heightImageNam;
- (UIButton *)createRightBarItemSelect:(SEL)select imageName:(NSString *)imageName heightImageName:(NSString *)heightImageName;


@end
