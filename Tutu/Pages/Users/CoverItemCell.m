//
//  CoverItemCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-27.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "CoverItemCell.h"

@implementation CoverItemCell

- (void)awakeFromNib {
    // Initialization code
    
}


- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
    if(selected)
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(0.97, 0.97);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
                [imageView setImage:[UIImage imageNamed:@"user_report_sel"]];
                [self.itemImageView addSubview:imageView];
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(1.03, 1.03);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                for (UIView *iv in self.itemImageView.subviews) {
                    [iv removeFromSuperview];
                }
            }];
        }];
        
    }
}


@end
