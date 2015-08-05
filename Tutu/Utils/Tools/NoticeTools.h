//
//  NoticeTools.h
//  Tutu
//
//  Created by zhangxinyao on 15-4-24.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NoticeCompleteBlock) ();

@interface NoticeTools : NSObject

+(NoticeTools *) getInstance;

-(void)showShareNotice:(TopicModel *)topicModel block:(NoticeCompleteBlock)finish;

//发送关注通知
-(void)postAddFocus:(UserInfo *) info;

//取消关注通知
-(void)postdelFocus:(UserInfo *) info;


-(void)postClearMessageRead;

-(void)postSendNewMessage;

@end
