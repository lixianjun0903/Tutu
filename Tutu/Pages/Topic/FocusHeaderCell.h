//
//  FocusHeaderCell.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FocusTopicModel.h"
#import "EasyTableView.h"
typedef NS_ENUM(NSInteger,FocusTypeTag){
    HotTag=1,
    NewsTag=2,
    FocusClickTag=3,
    FocusNumClickTag=4,
    FocusUserAvatarClickTag=5,
};

@protocol FocusHeaderDelegate <NSObject>

-(void)itemClick:(FocusTypeTag) tag;

-(void)itemUserClick:(UserInfo *)model;

@end

@interface FocusHeaderCell : UIView<EasyTableViewDelegate>

@property (nonatomic, strong) id<FocusHeaderDelegate> delegate;


// 初始化UI，主要设在默认值，颜色等
-(void)initView:(CGFloat) width;

// 填充数据
-(void)dataToView:(FocusTopicModel *) model tableWidth:(CGFloat )width;

// 切换menu样式，由于有2个入口，所以需要同步
-(void)checkMenuStyle:(int)showType;

@end
