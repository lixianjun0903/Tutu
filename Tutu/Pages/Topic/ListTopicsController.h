//
//  ListTopicsController.h
//  Tutu
//  话题列表,点击话题跳转页面
//  Created by zhangxinyao on 15-4-13.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "FocusHeaderCell.h"
#import "TopicsGeneralController.h"
#import "ShareActonSheet.h"


@interface ListTopicsController : BaseController<FocusHeaderDelegate,GeneralScrollDelegate,ShareActonSheetDelegate>

// 话题或位置名称，用于话题搜索和标题展示
@property(nonatomic,strong) NSString * topicString;

// 用于位置搜索
@property(nonatomic,strong) NSString * poiid;

// 判断使用哪个搜索
@property(nonatomic,assign) TopicWithTypePage pageType;
@property(nonatomic,strong) NSString * startid;


@property(nonatomic)NSInteger comefrom;

@end
