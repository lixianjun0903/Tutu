//
//  RCLetterCell.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMessage.h"
#import "RCTextMessage.h"
#import "RCIMClientHeader.h"
#import "RCUserInfo.h"


#import "XHImageViewer.h"


typedef NS_ENUM(NSInteger, RCMessageClickType) {
    RCContentClick=1,
    RCButtonClick=2,
};


@protocol RCLetterItemClickDelegate <NSObject>


// 头像点击
-(void)IconOnClick:(RCMessage *) item view:(UIImageView *)avatarView;

// 富媒体点击
-(void)activeOnClick:(RCMessage *) item type:(RCMessageClickType) clickType;

//点击播放声音，在controller中播放，方便关闭
-(void)voiceClick:(RCMessage *) item view:(UIImageView *) imageView;


-(void)copyText:(NSString *) text;

-(void)delCellItem:(RCMessage *) item;

//重新发送
-(void)resendMessage:(RCMessage *) item;


//申请好友
-(void)goUserInfoApplyFriend;



//查看大图
-(void)showBigImageView:(RCMessage *)item;

-(void)refreshRow:(UITableViewCell *) cell;

@end

@interface RCLetterCell : UITableViewCell<XHImageViewerDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<RCLetterItemClickDelegate> delegate;

@property (strong, nonatomic) NSString *targetId;
@property (strong, nonatomic) NSString *lastTime;
@property (strong, nonatomic) RCMessage *msg;


-(int)initViewData:(RCMessage *)model time:(NSString *)time width:(int) width;

@end