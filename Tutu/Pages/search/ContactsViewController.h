//
//  ContactsViewController.h
//  Tutu
//
//  Created by zhangxinyao on 14-12-13.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

#import "AddressFriendCell.h"
#import <MessageUI/MessageUI.h>
@interface ContactsViewController : BaseController<AddressFriendCellDelegate,MFMessageComposeViewControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>


@property(nonatomic,strong)NSArray *modelsArray;
@property(nonatomic,strong)NSMutableArray *letterArray;
@property(nonatomic,strong)NSMutableArray *friendsArray;
@property(nonatomic,strong)NSMutableArray *searchArray;
@property(nonatomic,strong)NSMutableDictionary *searchDic;


@end
