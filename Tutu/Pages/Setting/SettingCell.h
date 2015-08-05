//
//  SettingCell.h
//  Tutu
//
//  Created by gexing on 12/19/14.
//  Copyright (c) 2014 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SettingCellDelegate <NSObject>

- (void)switchValueChanged:(id)sender index:(NSIndexPath *)indexPath;

@end
@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *swithBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrow;
@property (nonatomic,strong) NSIndexPath *cellIndexPath;
@property(nonatomic,weak)id <SettingCellDelegate> delegate;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
- (IBAction)switchValueChange:(id)sender;
- (void)loadCellWithTitle:(NSString *)title info:(NSString *)info indexPaht:(NSIndexPath *)indexpath;
@end

