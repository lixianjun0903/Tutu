//
//  SystemMusicCell.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemMusiceModel.h"

@protocol MusiceCellDelegate <NSObject>

-(void)itemClick:(SystemMusiceModel *)model;
-(void)musicPlayer:(SystemMusiceModel *) model startDuration:(double) duration;

@end


@interface SystemMusicCell : UITableViewCell


@property (weak, nonatomic) id<MusiceCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *musicNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *dragView;
@property (weak, nonatomic) IBOutlet UIImageView *durationView;
@property (weak, nonatomic) IBOutlet UIImageView *videoDurationView;
@property (weak, nonatomic) IBOutlet UIImageView *canPlayView;
@property (weak, nonatomic) IBOutlet UIImageView *leftTagView;
@property (weak, nonatomic) IBOutlet UIImageView *rightTagView;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;


-(void)dataToView:(SystemMusiceModel *) model open:(BOOL)isOpen videoDuration:(double) duration tw:(CGFloat )w;

/**
 * 更新播放状态
 * cutDuration 播放的了多久
 **/
-(void)updateProgress:(NSTimeInterval) cutDuration;

/**
 * 获取开始位置，切割视频使用
 */
-(NSTimeInterval)getCurDuration;

@end
