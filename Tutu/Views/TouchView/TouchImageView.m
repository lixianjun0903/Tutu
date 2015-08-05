//
//  TouchImageView.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-7.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TouchImageView.h"

@implementation TouchImageView{
    BeginTouch bTouch;
    EndTouch eTouch;
    
    BOOL isSelf;
    RCMessage *message;
    
    id<RCLetterItemClickDelegate> delegate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)addTouchChanged:(BOOL)isMyself beginTouch:(BeginTouch)beginTouch endTouch:(EndTouch)endTouch{
    bTouch=beginTouch;
    eTouch=endTouch;
    isSelf=isMyself;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if(bTouch && ![RCImageMessageTypeIdentifier isEqual:message.objectName]){
        bTouch(isSelf,self);
    }
    
//    [self setBackgroundColor:[UIColor colorWithRed:227/255.0 green:227/255.0 blue:227/255.0 alpha:1.0]];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if(eTouch && ![RCImageMessageTypeIdentifier isEqual:message.objectName]){
        eTouch(isSelf,self);
    }
//    [self setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if(eTouch && ![RCImageMessageTypeIdentifier isEqual:message.objectName]){
        eTouch(isSelf,self);
    }
//    [self setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
}



-(BOOL) canBecomeFirstResponder{
    return YES;
}


-(void)showMenuController:(BOOL) addCopy{
    WSLog(@"我顶级了啊");
    [self becomeFirstResponder];
    
    UIMenuController *popMenu = [UIMenuController sharedMenuController];
    UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyClick:)];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(delClick:)];
    
    NSArray *menuItems =nil;
    if(addCopy)
    {
        menuItems = [NSArray arrayWithObjects:item1,item2,nil];
    }else{
        menuItems = [NSArray arrayWithObjects:item2,nil];
    }
    [popMenu setMenuItems:menuItems];
    [popMenu setTargetRect:self.frame inView:self.superview];
    [popMenu setMenuVisible:YES animated:NO];
}

-(void)addLongPress:(RCMessage *)msg delegate:(id<RCLetterItemClickDelegate>) idelgate{
    self.userInteractionEnabled=YES;
    message=msg;
    delegate=idelgate;
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:longPress];
}

-(void)delClick:(UIMenuController *) sender{
    [sender setMenuVisible:NO];
    [self removeFromSuperview];
    //删除
    if(delegate && [delegate respondsToSelector:@selector(delCellItem:)]){
        [delegate delCellItem:message];
    }
}
    
-(void)copyClick:(UIMenuController *) sender{
    [sender setMenuVisible:NO];
    //复制
    if(delegate && [delegate respondsToSelector:@selector(copyText:)]){
        RCTextMessage *tmsg=(RCTextMessage *)message.content;
        [delegate copyText:tmsg.content];
    }
}


-(void)handleTap:(UIGestureRecognizer*) recognizer{
    WSLog(@"你到底显示不系那是啊");
    if([RCTextMessageTypeIdentifier isEqual:message.objectName]){
        [self showMenuController:YES];
    }else{
        [self showMenuController:NO];
    }
}

@end
