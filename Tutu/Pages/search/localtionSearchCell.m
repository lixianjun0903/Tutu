//
//  localtionSearchCell.m
//  Tutu
//
//  Created by gexing on 15/4/9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "localtionSearchCell.h"

@implementation localtionSearchCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setFirstLabel:(NSString *)firstTitle andSubtitle:(NSString *)subtitle
{
    self.firstLabel.text=firstTitle;
    self.firstLabel.textColor=UIColorFromRGB(TextBlackColor);
    [self.firstLabel setFont:ListTitleFont];
    
    self.subtitleLabel.text=subtitle;
    self.subtitleLabel.textColor=UIColorFromRGB(TextGrayColor);
    [self.subtitleLabel setFont:ListDetailFont];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
