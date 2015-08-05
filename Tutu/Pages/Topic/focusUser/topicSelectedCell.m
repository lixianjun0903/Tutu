//
//  topicSelectedCell.m
//  Tutu
//
//  Created by gexing on 15/4/17.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "topicSelectedCell.h"
#import "UIImageView+WebCache.h"

@implementation topicSelectedCell

- (void)awakeFromNib {
    // Initialization code
    self.mainLabel.textColor=UIColorFromRGB(TextBlackColor);
    self.mainLabel.font=ListTitleFont;
    
    self.subLabel.textColor=UIColorFromRGB(TextSixAColor);
    self.subLabel.font=ListDetailFont;
    
    self.commentLabel.textColor=UIColorFromRGB(TextGrayColor);
    self.commentLabel.font=ListTimeFont;
    [self.commentLabel setTextAlignment:NSTextAlignmentRight];

}

-(void)cellLoadWith:(topicHotModel *)model
{
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:model.picurl]];
    self.userImage.layer.masksToBounds=YES;
    [self.userImage setContentMode:UIViewContentModeScaleAspectFill];
    self.mainLabel.text=[NSString stringWithFormat:@"#%@",model.httext];
    self.subLabel.text=model.httext;
    self.commentLabel.text=[NSString stringWithFormat:@"%@%@",model.joinusercount,TTLocalString(@"TT_comment_peoples")];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
