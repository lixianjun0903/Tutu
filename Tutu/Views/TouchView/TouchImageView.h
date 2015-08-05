//
//  TouchImageView.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-7.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCMessage.h"
#import "RCLetterCell.h"

@protocol TouchImageView;
typedef void(^BeginTouch)(BOOL isSelf,UIImageView * imageView);
typedef void(^EndTouch)(BOOL isSelf,UIImageView * imageView);

typedef void(^DelBlock)(RCMessage * message);


@interface TouchImageView : UIImageView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


-(void)addTouchChanged:(BOOL) isMyself beginTouch:(BeginTouch) beginTouch endTouch:(EndTouch) endTouch;

-(void)showMenuController:(BOOL) addCopy;

-(void)addLongPress:(RCMessage *)msg delegate:(id<RCLetterItemClickDelegate>) delgate;

@end
