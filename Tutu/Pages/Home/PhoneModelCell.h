//
//  PhoneModelCell.h
//  dfas
//
//  Created by gexing on 5/14/15.
//  Copyright (c) 2015 youmi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneModel.h"

@protocol PhoneModelCellDelegate <NSObject>

- (void)phoneNameClick:(PhoneModel *)phoneModel index:(NSInteger)index;

@end
@interface PhoneModelCell : UITableViewCell
@property(nonatomic,strong)UIButton *leftButton;
@property(nonatomic,strong)UIButton *rightButton;
@property(nonatomic,strong)PhoneModel *leftModel;
@property(nonatomic,strong)PhoneModel *rightModel;
@property(nonatomic)NSInteger index;
@property(nonatomic,weak) id <PhoneModelCellDelegate> delegate;

- (void)relaodWith:(PhoneModel *)leftModel right:(PhoneModel *)rightModel;

@end
