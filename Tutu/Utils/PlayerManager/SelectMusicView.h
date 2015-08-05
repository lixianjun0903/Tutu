//
//  selectMusicView.h
//  tttttest
//
//  Created by gexing on 15/1/13.
//  Copyright (c) 2015年 gexing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol clickDelegate <NSObject>

//按钮点击事件的代理方法
-(void)clickButton:(int)buttonTag andState:(int)state ;

@end

@interface SelectMusicView : UIView
@property(nonatomic,assign)id<clickDelegate> clickDelegata;

//数组给的是图片名称
-(id)initWithFrame:(CGRect)rect musicArray:(NSArray *)photoArray delegate:(id<clickDelegate>)delegata;

-(void)loclMusicChecked:(int)tag;

@end
