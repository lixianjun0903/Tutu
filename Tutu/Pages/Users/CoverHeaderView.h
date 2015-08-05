//
//  CoverHeaderView.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-27.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverHeaderView : UICollectionReusableView


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)setTitle:(NSString *)title;

@end
