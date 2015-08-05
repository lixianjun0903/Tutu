//
//  CompleteInfoController.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-25.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "TSLocateView.h"
#import "ASIFormDataRequest.h"
#import "LXActionSheet.h"
#import "ManagerCell.h"

@interface CompleteInfoController : BaseController<UIActionSheetDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ASIHTTPRequestDelegate,UITableViewDataSource,UITableViewDelegate,ManagerCellDelegate,LXActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *myTitle;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *infoListView;
@property (weak, nonatomic) IBOutlet UITextField *hideTextField;
@property (strong,nonatomic) UIButton * signOut;
@property (strong, nonatomic) UIView * dateAnimationView;
@property (strong, nonatomic) TSLocateView *locateView;
@property (strong, nonatomic) UIAlertController * alertController;
@end
