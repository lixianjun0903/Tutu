//
//  FocusHeaderCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-14.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FocusHeaderCell.h"
#import "UIImageView+WebCache.h"

#define FocusCellIdentifier @"FocusCellIdentifier"


@implementation FocusHeaderCell{
    NSMutableArray *dataArray;
    EasyTableView *focusTable;
    
    UIButton *_focusButton;
    
    FocusTopicModel *model;
    
    UIButton *_lookButton;
    
    UIButton *_topicButton;
    
    
    UIButton *_hotButton;
    UIButton *_newsButton;
    UIImageView *_lineView;
    UIImageView *_itemLineView;

}

- (void)awakeFromNib {
    // Initialization code

}

-(void)initView:(CGFloat)width{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat w=width;
    
    dataArray=[[NSMutableArray alloc] init];
    focusTable=[[EasyTableView alloc] initWithFrame:CGRectZero numberOfColumns:0 ofWidth:44];
    focusTable.delegate=self;
    [focusTable setBackgroundColor:[UIColor clearColor]];
    [self addSubview:focusTable];
    [focusTable setFrame:CGRectMake(w/2-22, 10, 44, 44)];
    
    _focusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_focusButton setFrame:CGRectMake(10, 15, 44, 44)];
    _focusButton.layer.cornerRadius=22;
    _focusButton.tag=FocusClickTag;
    [_focusButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_focusButton];
    [_focusButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_itemLineView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    [_itemLineView setFrame:CGRectMake(10, 100, w-20, 1)];
    
    _lookButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_lookButton setImage:[UIImage imageNamed:@"look_num_tag"] forState:UIControlStateNormal];
    [_lookButton setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 6, 0)];
    [_lookButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_lookButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_lookButton setTitle:@" 0次浏览" forState:UIControlStateNormal];
    [_lookButton.titleLabel setFont:ListTimeFont];
    [_lookButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [_lookButton setFrame:CGRectMake(20, 75, 150, 22)];
    [self addSubview:_lookButton];
    
    _topicButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_topicButton setImage:[UIImage imageNamed:@"topic_list_tag"] forState:UIControlStateNormal];
    [_topicButton setImageEdgeInsets:UIEdgeInsetsMake(6, 0, 6, 0)];
    [_topicButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_topicButton setTitle:@" 0个主题" forState:UIControlStateNormal];
    [_topicButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_topicButton.titleLabel setFont:ListTimeFont];
    [_topicButton setTitleColor:UIColorFromRGB(TextGrayColor) forState:UIControlStateNormal];
    [_topicButton setFrame:CGRectMake(190, 75, w-190, 22)];
    [self addSubview:_topicButton];
    
    
    _hotButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_hotButton setTitle:TTLocalString(@"TT_hotest") forState:UIControlStateNormal];
    _hotButton.tag=HotTag;
    [_hotButton setFrame:CGRectMake(0, 100,width/2 , 40)];
    [self addSubview:_hotButton];
    
    
    _newsButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_newsButton setTitle:TTLocalString(@"TT_newest") forState:UIControlStateNormal];
    _newsButton.tag=NewsTag;
    [_newsButton setFrame:CGRectMake(width/2,100,width/2,40)];
    [self addSubview:_newsButton];
    
    
    [_hotButton.titleLabel setFont:ListTitleFont];
    [_newsButton.titleLabel setFont:ListTitleFont];
    
    
    _lineView = [[UIImageView alloc] init];
    [_lineView setFrame:CGRectMake(0, 138, width/2, 2)];
    [self addSubview:_lineView];
    [_lineView setBackgroundColor:UIColorFromRGB(SystemColor)];
    
    _itemLineView=[[UIImageView alloc] init];
    [_itemLineView setBackgroundColor:UIColorFromRGB(ItemLineColor)];
    [_itemLineView setFrame:CGRectMake(15, 100, w-30, 0.75)];
    [self addSubview:_itemLineView];
    
    UIImageView *vlineView=[[UIImageView alloc] initWithFrame:CGRectMake(w/2-0.5, 110, 1, 20)];
    [vlineView setBackgroundColor:UIColorFromRGB(ListLineColor)];
    [self addSubview:vlineView];
    
    [self checkMenuStyle:1];
    
    _hotButton.userInteractionEnabled=YES;
    [_hotButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    _newsButton.userInteractionEnabled=YES;
    [_newsButton addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dataToView:(FocusTopicModel *)focusmodel tableWidth:(CGFloat)width{
    [focusTable setFrame:CGRectMake(width/2-22, 10, 44, 44)];
    [_itemLineView setFrame:CGRectMake(15, 100, width-30, 0.75)];
    [dataArray removeAllObjects];
    
    if(focusmodel){
        model=focusmodel;
        
        NSString *lookText=[NSString stringWithFormat:@"%@%@",model.viewhumancount,TTLocalString(@"TT_browses")];
        [_lookButton setTitle:lookText forState:UIControlStateNormal];
        [_topicButton setTitle:[NSString stringWithFormat:@"%d%@",model.topiccount,TTLocalString(@"TT_topics")] forState:UIControlStateNormal];
        CGFloat lookWidth=[SysTools getWidthContain:lookText font:_lookButton.titleLabel.font Height:20];
        [_lookButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_topicButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        CGRect tf=_topicButton.frame;
        tf.origin.x=lookWidth+30+_lookButton.frame.origin.x;
        [_topicButton setFrame:tf];
        
        
        if(model.userlist==nil || model.userlist.count==0){
            model.userlist=[[NSMutableArray alloc] init];
            dataArray = [model.userlist mutableCopy];
            [focusTable reloadData];
            
            CGRect f=_focusButton.frame;
            f.origin.x=width/2-22;
            [_focusButton setFrame:f];
            
            
            [focusTable setFrame:CGRectZero];
            
        }else{
            dataArray = [model.userlist mutableCopy];
            [focusTable reloadData];
            
            CGRect f=_focusButton.frame;
            f.origin.x=10;
            [_focusButton setFrame:f];
            
            NSString *text=[NSString stringWithFormat:@"%d",model.usercount];
            CGFloat fontWidth=[SysTools getWidthContain:text font:ListDetailFont Height:20];
            if(fontWidth<35){
                fontWidth=35;
            }
            int count=(int)model.userlist.count;
            if(count>5){
                count=5;
            }
            CGFloat sw= 44*count+fontWidth+2;
            
            if(sw < focusTable.frame.size.width){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [focusTable setFrame:CGRectMake(width-sw-10, 15, sw, 44)];
                    
                });
            }else{
                [focusTable setFrame:CGRectMake(width-sw-10, 15, sw, 44)];
            }
            
        }
        
        
        if(focusmodel.isfollow){
            [_focusButton setBackgroundColor:UIColorFromRGB(ChatSysMessageBg)];
            [_focusButton setTitle:TTLocalString(@"TT_haved_follow") forState:UIControlStateNormal];
        }else{
            [_focusButton setBackgroundColor:UIColorFromRGB(SystemColor)];
            [_focusButton setTitle:TTLocalString(@"TT_follow") forState:UIControlStateNormal];
        }
    }
}

-(void)changeMenuClick:(UIButton *)button{
    if(button.tag<3){
        [self checkMenuStyle:(int)button.tag];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemClick:)]){
        [self.delegate itemClick:button.tag];
    }
}

-(void)checkMenuStyle:(int)showType{
    if(showType==1){
        CGRect lineF=_lineView.frame;
        lineF.origin.x=0;
        _lineView.frame=lineF;
        
        [_hotButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [_newsButton setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
        
    }else if(showType==2){
        CGRect lineF=_lineView.frame;
        lineF.origin.x=lineF.size.width;
        _lineView.frame=lineF;
        
        [_newsButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
        [_hotButton setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
    }
}

#pragma mark-easyTableViewDelegate


-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForFooterInSection:(NSInteger)section{
    if(model!=nil && model.usercount>0){
        NSString *text=[NSString stringWithFormat:@"%d",model.usercount];
        CGFloat fontWidth=[SysTools getWidthContain:text font:ListDetailFont Height:20];
        if(fontWidth<35){
            fontWidth=35;
        }
        
        UIView *footerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, fontWidth+2, 44)];
        [footerView setBackgroundColor:[UIColor clearColor]];
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(2, 12, fontWidth, 20)];
        btn.layer.cornerRadius=10;
        btn.layer.masksToBounds=YES;
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setBackgroundColor:UIColorFromRGB(ButtonViewBgColor)];
        btn.tag=FocusNumClickTag;
        [btn.titleLabel setFont:ListDetailFont];
        [btn setTitleColor:UIColorFromRGB(TextSixColor) forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btn];
        return footerView;
    }else{
        return nil;
    }
}

//-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForHeaderInSection:(NSInteger)section{
//    if(model==nil || !model.isfollow){
//        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(0, 0, 44, 44)];
//        btn.layer.cornerRadius=22;
//        btn.layer.masksToBounds=YES;
//        [btn setBackgroundColor:UIColorFromRGB(SystemColor)];
//        [btn setTitle:@"关注" forState:UIControlStateNormal];
//        [btn.titleLabel setFont:ListDetailFont];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btn.tag=FocusClickTag;
//        [btn addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
//        return btn;
//    } else if(model!=nil && model.isfollow){
//        
//        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(0, 0, 44, 44)];
//        btn.layer.cornerRadius=22;
//        btn.layer.masksToBounds=YES;
//        [btn setBackgroundColor:UIColorFromRGB(ChatSysMessageBg)];
//        [btn setTitle:@"已关注" forState:UIControlStateNormal];
//        [btn.titleLabel setFont:ListDetailFont];
//        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        btn.tag=FocusClickTag;
//        [btn addTarget:self action:@selector(changeMenuClick:) forControlEvents:UIControlEventTouchUpInside];
//        return btn;
//    }
//    return nil;
//}

-(NSUInteger)numberOfCellsForEasyTableView:(EasyTableView *)view inSection:(NSInteger)section
{
    if(dataArray.count>5){
        return 5;
    }
    return dataArray.count;
}

-(UIView *)easyTableView:(EasyTableView *)easyTableView viewForRect:(CGRect)rect
{
    UIImageView *test=[[UIImageView alloc]init];
    test.contentMode=UIViewContentModeScaleAspectFill;
    [test setFrame:CGRectMake(5.5, 5.5, 35, 35)];
    test.layer.masksToBounds=YES;
    return test;
}

-(void)easyTableView:(EasyTableView *)easyTableView setDataForView:(UIView *)view forIndexPath:(NSIndexPath *)indexPath
{
    UserInfo *info=[dataArray objectAtIndex:indexPath.row];
    NSString *avataURL=[SysTools getHeaderImageURL:info.uid time:info.avatartime];
    UIImageView *v=(UIImageView *)view;
    v.layer.cornerRadius=17.5;
    if(v.frame.size.width>35){
        [v setFrame:CGRectMake(5.5, 5.5, 35, 35)];
    }
//    WSLog(@"%@",NSStringFromCGRect(v.frame));
    [v sd_setImageWithURL:[NSURL URLWithString:avataURL] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
}

-(void)easyTableView:(EasyTableView *)easyTableView selectedView:(UIView *)selectedView atIndexPath:(NSIndexPath *)indexPath deselectedView:(UIView *)deselectedView{
    UserInfo *info=[dataArray objectAtIndex:indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemUserClick:)]){
        [self.delegate itemUserClick:info];
    }
}

-(void)easyTableView:(EasyTableView *)easyTableView scrolledToOffset:(CGPoint)contentOffset
{
    
}
@end
