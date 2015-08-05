//
//  UserInfoCell.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserInfoCellItemDelegate <NSObject>

-(void)cellItemClick:(TopicModel *)model index:(int)indexPath;

@end

@interface UserInfoCell : UITableViewCell

@property(nonatomic,strong) id<UserInfoCellItemDelegate> delegate;


-(void)dataToView:(NSMutableArray *) arr column:(int) column row:(int) indexRow width:(int)w;

@end
