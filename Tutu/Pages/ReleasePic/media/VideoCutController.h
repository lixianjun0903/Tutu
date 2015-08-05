//
//  VideoCutController.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-23.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "ChoosePickerController.h"




typedef enum :NSInteger {
    
    kCameraMoveDirectionNone,
    
    kCameraMoveDirectionUp,
    
    kCameraMoveDirectionDown,
    
    kCameraMoveDirectionRight,
    
    kCameraMoveDirectionLeft
    
} CameraMoveDirection;


@interface VideoCutController : BaseController<UIScrollViewDelegate>

@property(nonatomic,strong)NSMutableArray *videoArr;


@end
