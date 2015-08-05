//
//  ApplyFriendsController.h
//  Tutu
//
//  Created by zhangxinyao on 15-3-17.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "NewFriendViewController.h"
@interface ApplyFriendsController : BaseController<UITextViewDelegate>

@property(nonatomic,strong) NSString *uid;

@property(nonatomic,strong) BackBlock backBlock;

@end
