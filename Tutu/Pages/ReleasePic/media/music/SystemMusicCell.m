//
//  SystemMusicCell.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "SystemMusicCell.h"

@implementation SystemMusicCell{
    SystemMusiceModel *musicModel;
    CGFloat videoDuration;
    CGFloat tw;
    
    BOOL isPlay;
}

- (void)awakeFromNib {
    // Initialization code
    [self.musicNameLabel setTextColor:UIColorFromRGB(TextBlackColor)];
    [self.musicNameLabel setFont:ListTitleFont];
    
    [self.authorTimeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [self.authorTimeLabel setFont:ListDetailFont];
    
    [self.startTimeLabel setFont:ListDetailFont];
    [self.startTimeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    
    [self.endTimeLabel setFont:ListDetailFont];
    [self.endTimeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    
    [self.durationView setBackgroundColor:UIColorFromRGB(SystemGrayColor)];
    [self.videoDurationView setBackgroundColor:UIColorFromRGB(SystemColor)];
    [self.canPlayView setBackgroundColor:UIColorFromRGB(BackgroundRecordColor)];
    
    [self.dragView setBackgroundColor:[UIColor clearColor]];
    [self.playerView setBackgroundColor:[UIColor clearColor]];
    [self.dragView setBackgroundColor:[UIColor clearColor]];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handlePan:)];
    [self.dragView addGestureRecognizer:panGestureRecognizer];
    
    [self.playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dataToView:(SystemMusiceModel *)model open:(BOOL)isOpen videoDuration:(double)duration tw:(CGFloat)tableWidth{
    CGFloat w=tableWidth;
    videoDuration=duration;
    tw=w;
    if(model){
        musicModel=model;
        
        [self.musicNameLabel setText:model.name];
        [self.authorTimeLabel setText:[NSString stringWithFormat:@"%@ %@",@"未知",[self getTimeStringOfTimeInterval:model.duration]]];
        [self.startTimeLabel setText:@"00:00"];
        [self.endTimeLabel setText:[self getTimeStringOfTimeInterval:model.duration]];
        
        
        if(isOpen){
            [self.musicNameLabel setTextColor:UIColorFromRGB(SystemColor)];
            [self.authorTimeLabel setTextColor:UIColorFromRGB(SystemMusicHigh)];
            
            CGFloat durationWith=self.durationView.frame.size.width;
            CGFloat dragWidth=durationWith*duration/model.duration;
            if(model.duration<duration){
                dragWidth=w-30;
            }
            CGFloat dragY=self.dragView.frame.origin.y;
            [self.dragView setFrame:CGRectMake(0, dragY, dragWidth, 20)];
            
            CGRect rigthF = self.rightTagView.frame;
            rigthF.origin.x=dragWidth-5;
            [self.rightTagView setFrame:rigthF];
            
            CGRect vf = self.videoDurationView.frame;
            vf.size.width=dragWidth-5;
            vf.origin.x=2.5f;
            [self.videoDurationView setFrame:vf];
            
            
            [self.playButton setHidden:NO];
            
            self.playerView.hidden=NO;
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, 110)];
            
        }else{
            [self.musicNameLabel setTextColor:UIColorFromRGB(TextBlackColor)];
            [self.authorTimeLabel setTextColor:UIColorFromRGB(TextGrayColor)];
            
            [self.playButton setHidden:YES];
            
            self.playerView.hidden=YES;
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
        }
    }
}

-(void)updateProgress:(NSTimeInterval)cutDuration{
    CGFloat x= 2+self.videoDurationView.frame.size.width * cutDuration/videoDuration;
    CGRect f=self.canPlayView.frame;
    f.origin.x=x;
    [self.canPlayView setFrame:f];
}

-(NSTimeInterval) getCurDuration{
    double duration=musicModel.duration*(self.dragView.frame.origin.x/self.durationView.frame.size.width);
    return duration;
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint translation = [recognizer translationInView:self.playerView];
    CGPoint center=CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y);
    CGFloat dw=self.dragView.frame.size.width;
    if((center.x-dw/2)<0){
        center.x=dw/2;
    }else if(center.x>(self.durationView.frame.size.width-dw/2)){
        center.x=self.durationView.frame.size.width-dw/2;
    }
    
    recognizer.view.center = center;
    [recognizer setTranslation:CGPointZero inView:self.playerView];
    
}

-(void)actionPlay:(UIButton *)btn{
    if(!isPlay){
        [self.playButton setImage:[UIImage imageNamed:@"music_pause_nor"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"music_pause_nor"] forState:UIControlStateHighlighted];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"music_play_nor"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"music_play_nor"] forState:UIControlStateHighlighted];
    }
    isPlay=!isPlay;
    if(self.delegate && [self.delegate respondsToSelector:@selector(musicPlayer:startDuration:)]){
        double duration=musicModel.duration*(self.dragView.frame.origin.x/self.durationView.frame.size.width);
        [self.delegate musicPlayer:musicModel startDuration:duration];
    }
}



- (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags =
    NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit |
    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    
    NSDateComponents *components = [calendar components:uFlags
                                               fromDate:dateRef
                                                 toDate:dateNow
                                                options:0];
    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
