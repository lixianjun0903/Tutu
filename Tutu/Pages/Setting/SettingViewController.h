//
//  SettingViewController.h
//  Tutu
//
//  Created by gaoyong on 14-10-17.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "SettingCell.h"
#import "LXActionSheet.h"
@interface SettingViewController : BaseController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SettingCellDelegate,LXActionSheetDelegate> {

}
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property(nonatomic,strong)NSMutableArray *dataArray;

@end


