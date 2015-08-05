//
//  AddressListViewController.h
//  Tutu
//
//  Created by 刘大治 on 14/12/8.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "NavBaseController.h"
#import "AddressFriendCell.h"
#import <MessageUI/MessageUI.h>
@interface AddressListViewController :NavBaseController<AddressFriendCellDelegate,MFMessageComposeViewControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic)IBOutlet UITableView *mainTable;
@property(nonatomic,strong)NSArray *modelsArray;
@property(nonatomic,strong)NSMutableArray *letterArray;
@property(nonatomic,strong)NSMutableArray *friendsArray;
@property(nonatomic,strong)NSMutableArray *searchArray;
@property(nonatomic,strong)NSMutableDictionary *searchDic;
@end
