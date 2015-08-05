//
//  HomeController.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

typedef NS_ENUM(NSInteger, HomePageContentType) {
    HomePageContentTypeTopicView,
    HomePageContentTypeUserCenter
};
#import "BaseController.h"
#import "CameraActionSheet.h"
#import "SendTopicDelegate.h"
#import "LXActionSheet.h"
#import "TopicCell.h"
#import "HomePageCollectionCell.h"
#import "ThemeCell.h"
#import "TopicCell.h"
#import "TopicViewController.h"

@interface HomeController : BaseController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LXActionSheetDelegate,SendTopicDelegate,TopicDelegate>
@property(nonatomic)CGFloat previousScrollViewYOffset;
@property(nonatomic)HomePageContentType contentTyep;
@property(nonatomic,strong)UIImageView *focusDotView;
- (void)hidenSegmentViewAndFootView;
- (void)showSegmentViewAndFootView;
@end
