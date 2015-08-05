//
//  NewFriendViewController.h
//  Tutu
//
//  Created by gexing on 3/16/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//


typedef void(^BackBlock)(id backInfo);

#import "NewFriendTableCell.h"
#import "BaseController.h"
#import "MyFriendViewController.h"
@protocol FoodDeleteViewDelegate <NSObject>
- (void)footButtonClick:(UIButton *)sender;

@end
@interface FoodDeleteView : UIView
@property(nonatomic)UIButton *selectButton;
@property(nonatomic)UIButton *deleteButton;
@property(nonatomic,weak)id <FoodDeleteViewDelegate> delegate;
@end


@interface NewFriendViewController : BaseController<UITableViewDataSource,UITableViewDelegate,NewFriendTableCellDelegate,FoodDeleteViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong)UITableView *mainTable;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UIView *inputView;
@property(nonatomic,strong)UITextField *fieldView;
@property(nonatomic,strong)NSIndexPath *currentIndexPath;
@property(nonatomic,strong)UIButton *overButton;
@property(nonatomic,strong)UIButton *sendButton;
@property(nonatomic,strong)UpdateFriendListBlock updateBlock;

@end
