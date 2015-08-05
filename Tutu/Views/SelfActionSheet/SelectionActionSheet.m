//
//  SelectionActionSheet.m
//  Tutu
//
//  Created by 刘大治 on 14-11-3.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "SelectionActionSheet.h"

@implementation SelectionActionSheet
{
    NSInteger * buttonCount;
}
-(id)init
{
    self = [super initWithFrame:[UIScreen mainScreen].applicationFrame];
    if (self) {
        self.backgroundColor= [UIColor blackColor];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedCancel)];
        [self addGestureRecognizer:tapGesture];

    }
    return self;
    
}


-(void)setWithButtons:(UIButton*)cancelButton, ...
{
    va_list arrays;
    va_start(arrays, cancelButton);
    
    UIButton * eachButton;
    va_list arguementList;
    
    NSMutableArray * allButtons = [[NSMutableArray alloc] init];
    
    if (cancelButton) {
        [allButtons addObject:cancelButton];
        while ((eachButton  = va_arg(arguementList, id))) {
            [self addSubview:eachButton];
        }
    }
    va_end(arguementList);
    NSLog(@"%@",allButtons);
}



-(void)tapedCancel
{
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width,0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

-(void)showInView:(UIView*)view
{
    [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:view];
}

-(void)doCancel
{
    [self tapedCancel];
}


-(void)clickAtIndex:(UIButton*)sender
{
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
