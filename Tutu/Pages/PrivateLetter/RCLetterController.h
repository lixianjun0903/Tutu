//
//  RCLetterController.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-16.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "FaceBoard.h"
#import "UserInfo.h"
#import "RCLetterCell.h"
#import "UserDetailController.h"
#import "RCIMClient.h"
#import "RCIMClientHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ListMenuView.h"
#import "RCSessionModel.h"
#import "XHImageViewer.h"


@interface RCLetterController : BaseController<UITableViewDelegate,UITableViewDataSource,FaceBoardDelegate,UITextViewDelegate,RCLetterItemClickDelegate,RCSendMessageDelegate,AVAudioRecorderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioPlayerDelegate,ListMenuDelegate,LXActionSheetDelegate,XHImageViewerDelegate>


@property (retain, nonatomic) NSString *userid;
@property (retain, nonatomic) RCSessionModel *sessionModel;
@property (retain, nonatomic) NSString * lastTime;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UIView *footView;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *faceButton;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property(nonatomic)NSInteger comefrom;


@end
