//
//  ManagerCell.m
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ManagerCell.h"
#import "UIImageView+WebCache.h"

@implementation ManagerCell

-(void)setWithModel:(ManagerUserModel*)model
{
    UserInfo * usemodel = [[LoginManager getInstance]getLoginInfo];
    _titlenameLabel.text = model.title;
    _titlenameLabel.textColor = UIColorFromRGB(TextBlackColor);
//    _titlenameLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:15.0];
    [_detailArrowImage setImage:[UIImage imageNamed:@"p_right.png"]];
    _detailInfoLabel.textColor = UIColorFromRGB(TextGrayColor);
    _detailInfoLabel.numberOfLines = 0;
    _detailInfoLabel.delegate = self;
    
    if (model.type == ManagerCellTypeImage) {
        [_detailInfoLabel setHidden:YES];
        _avatarImage.layer.cornerRadius = _avatarImage.frame.size.width/2;
        _avatarImage.layer.masksToBounds= YES;
        
        if(self.imagePath!=nil && checkFileIsExsis(self.imagePath)){
            [_avatarImage setImage:[UIImage imageWithContentsOfFile:self.imagePath]];
        }else{
            [_avatarImage sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:usemodel.uid time:usemodel.avatartime]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        }
//        WSLog(@"%@",[NSURL URLWithString:[SysTools getHeaderImageURL:usemodel.uid time:usemodel.avatartime]]);
        self.frame = CGRectMake(0, 0,self.superview.frame.size.width, 70);

    }
    else if(model.type == ManagerCellTypeDetail)
    {
        [_avatarImage setHidden:YES];
        if([@"签名" isEqual:model.title]){

            _detailInfoLabel.adjustsFontSizeToFitWidth = NO;
            [_detailInfoLabel setBackgroundColor:[UIColor clearColor]];
            [_detailInfoLabel setTextAlignment:NSTextAlignmentLeft];

        }else{
            [_detailInfoLabel setTextAlignment:NSTextAlignmentRight];
        }
        _detailInfoLabel.text = model.detail;

        
        
    }
    else if(model.type == ManagerCellTypeTuTuNum)
    {
        [_avatarImage setHidden:YES];
        [_detailArrowImage setHidden:YES];
        _detailInfoLabel.text = model.detail;
        _detailInfoLabel.textAlignment = NSTextAlignmentRight;

    }
    else
    {
        [_avatarImage setHidden:YES];
        [_detailInfoLabel setHighlighted:YES];
    }
    
    CGRect rect = _lineView.frame;
    [_lineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    _lineView.frame = CGRectMake(rect.origin.x, self.frame.size.height-1, rect.size.width,1);

//    [_detailInfoLabel setHighlightedTextColor:[UIColor whiteColor]];
//    [_detailInfoLabel setBackgroundColor:[UIColor cyanColor]];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)setLineHidden
{
    [_lineView setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)label:(TCCopyableLabel *)copyableLabel didCopyText:(NSString *)copiedText{
    if (_delegate && [_delegate respondsToSelector:@selector(label:didCopyText:)]) {
        [_delegate label:copyableLabel didCopyText:copiedText];
    }

}
@end
