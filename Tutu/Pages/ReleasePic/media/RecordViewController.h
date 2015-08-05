//
//  RecordViewController.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-5.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "RCCaptureSessionManager.h"
#import "LXActionSheet.h"
#import "PhotoAlbumController.h"

@interface RecordViewController : BaseController<LXActionSheetDelegate>

@property(nonatomic,strong) UIView *cameraShowView;
@property(nonatomic,strong) RCCaptureSessionManager *rcManager;

@end
