//
//  localtionSearchCell.h
//  Tutu
//
//  Created by gexing on 15/4/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface localtionSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;


-(void)setFirstLabel:(NSString *)firstTitle andSubtitle:(NSString *)subtitle;

@end
