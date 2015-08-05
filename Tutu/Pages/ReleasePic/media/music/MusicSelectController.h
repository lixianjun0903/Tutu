//
//  MusicSelectController.h
//  Tutu
//
//  Created by zhangxinyao on 15/5/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "SystemMusicCell.h"

@protocol MusicSelectDelegate <NSObject>

-(void)checkedMusic:(NSString *)audioPath;

@end

@interface MusicSelectController : BaseController<UITableViewDataSource,UITableViewDelegate,MusiceCellDelegate>

@property(nonatomic,strong) id<MusicSelectDelegate> delegate;

@property(nonatomic,assign) NSTimeInterval videoDuration;

@end
