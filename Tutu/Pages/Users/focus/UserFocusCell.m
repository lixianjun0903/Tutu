//
//  UserFocusCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserFocusCell.h"
#import "UIImageView+WebCache.h"

@implementation UserFocusCell{
    UserFocusModel *umodel;
    
    NSMutableArray *dataArray;
    EasyTableView *_easyTable;
}

- (void)awakeFromNib {
    // Initialization code
    [self.dotImageView setHidden:YES];
    self.dotImageView.layer.cornerRadius=3;
    self.dotImageView.layer.masksToBounds=YES;
    [self.dotImageView setBackgroundColor:[UIColor redColor]];
    
}

-(void)dataToView:(UserFocusModel *)model width:(CGFloat)w{
    UIImage *img=[SysTools createImageWithColor:UIColorFromRGB(SystemGrayColor)];
    [_topBg setImage:img];
    umodel=model;
    if(_easyTable!=nil){
        [_easyTable removeFromSuperview];
    }
    
    _easyTable=[[EasyTableView alloc] initWithFrame:CGRectMake(10, 60, w-10, 83) numberOfColumns:0 ofWidth:88];
    [_easyTable setBackgroundColor:[UIColor clearColor]];
    _easyTable.delegate=self;
    [self addSubview:_easyTable];
    
    if(dataArray==nil){
        dataArray=[[NSMutableArray alloc] init];
    }else{
        [dataArray removeAllObjects];
    }
    
//    _easyTable.delegate=self;
    
    if(model){
        if([model.restype intValue]==1){
            [_locationImage setHidden:YES];
            [_lblTitle setText:[NSString stringWithFormat:@"%@",model.title]];
        }else{
            [_lblTitle setText:[NSString stringWithFormat:@"   %@",model.title]];
            [_locationImage setHidden:NO];
            [_locationImage setHighlightedImage:[UIImage imageNamed:@"addLocaltion_click"]];
        }
        [_lblTitle setTextColor:UIColorFromRGB(DrakGreenNickNameColor)];
        [_lblTitle setFont:ListTitleFont];
        [_lblTitle setTextAlignment:NSTextAlignmentLeft];
        [_lblNum setTextColor:UIColorFromRGB(TextBlackColor)];
        [_lblNum setFont:ListDetailFont];
        
        [_btnFocus.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_btnFocus addTarget:self action:@selector(buttonClickItem:) forControlEvents:UIControlEventTouchUpInside];
        
        if(model.isfollow){
            [_btnFocus setTitle:TTLocalString(@"TT_haved_follow") forState:UIControlStateNormal];
            [_btnFocus setTitleColor:UIColorFromRGB(TextCCCCCCColor) forState:UIControlStateNormal];
            [_btnFocus setTitleColor:UIColorFromRGB(TextCCCCCCColor) forState:UIControlStateHighlighted];
            _btnFocus.layer.borderColor=UIColorFromRGB(TextCCCCCCColor).CGColor;
            _btnFocus.layer.borderWidth=.75f;
            _btnFocus.layer.cornerRadius=12.5f;
            _btnFocus.layer.masksToBounds=YES;
        }else{
            [_btnFocus setTitle:TTLocalString(@"TT_follow") forState:UIControlStateNormal];
            [_btnFocus setTitleColor:UIColorFromRGB(DrakGreenNickNameColor) forState:UIControlStateNormal];
            [_btnFocus setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
            _btnFocus.layer.borderColor=UIColorFromRGB(DrakGreenNickNameColor).CGColor;
            _btnFocus.layer.borderWidth=.75f;
            _btnFocus.layer.cornerRadius=12.5f;
            _btnFocus.layer.masksToBounds=YES;
        }
        if(model.topiclist!=nil && model.topiclist.count>0){
            [dataArray addObjectsFromArray:model.topiclist];
            [_easyTable reloadData];
        }
        
        if([model.isread intValue]==0){
            [self.dotImageView setHidden:NO];
            [self.lblTitle sizeToFit];
            
            CGRect tf=self.lblTitle.frame;
            tf.size.height=44;
            tf.origin.x=12;
            [self.lblTitle setFrame:tf];
            
            
            CGRect dotF=self.dotImageView.frame;
            dotF.origin.x=self.lblTitle.frame.origin.x+self.lblTitle.frame.size.width+2;
            [self.dotImageView setFrame:dotF];
        }else{
            [self.dotImageView setHidden:YES];
        }
        
        [_lblNum setText:[NSString stringWithFormat:@"%@%@ · %@%@ · %@%@",model.topiccount,TTLocalString(@"TT_topics"),model.viewhumancount,TTLocalString(@"TT_browses"),model.usercount,TTLocalString(@"TT_follows")]];
    }
}



-(void)buttonClickItem:(UIButton *)button{
    WSLog(@"%@",umodel.resid);
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemFocusClick:)]){
        [self.delegate itemFocusClick:umodel];
    }
}




#pragma mark-easyTableViewDelegate
-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    return dataArray.count;
}

-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect
{
    rect=CGRectMake(0, 0, 83, 83);
    UIImageView *test=[[UIImageView alloc]initWithFrame:rect];
    test.layer.masksToBounds=YES;
    test.contentMode=UIViewContentModeScaleAspectFill;
    test.layer.borderColor=UIColorFromRGB(SystemGrayColor).CGColor;
    test.layer.borderWidth=0.75;
    return test;
}

-(void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath
{
    UserFocusTopicModel *info=[dataArray objectAtIndex:indexPath.row];
    UIImageView *v=(UIImageView *)view;
    [v sd_setImageWithURL:[NSURL URLWithString:info.content]];
}

-(void)easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset
{
}

-(void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView{
    UserFocusTopicModel *info=[dataArray objectAtIndex:indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemTopicOnClick:focus:)]){
        [self.delegate itemTopicOnClick:info focus:umodel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
