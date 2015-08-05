//
//  ThemeCell.m
//  Tutu
//
//  Created by gexing on 4/8/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#define HuaTiCell_Height   (44 + ScreenWidth + 10)

#import "ThemeCell.h"
#import "UILabel+Additions.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
@implementation ThemeCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = HEXCOLOR(0xF2F3F7);
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _headView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_headView];
    _middleView = [[UIView alloc]initWithFrame:CGRectMake(0, _headView.max_y, ScreenWidth, ScreenWidth - 5)];
    _middleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_middleView];
   
    _titleLabel = [UILabel labelWithSystemFont:15 textColor:HEXCOLOR(0x333333)];
    _titleLabel.frame = CGRectMake(8, 14, 300, 16);
    _titleLabel.text = TTLocalString(@"home_page_hot_huati");
    [self.contentView addSubview:_titleLabel];
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moreButton.frame = CGRectMake(ScreenWidth - 66, 0, 66, 44);
    [_moreButton setTitle:TTLocalString(@"topic_more") forState:UIControlStateNormal];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_moreButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
    [_moreButton setTitleColor:HEXCOLOR(0xcccccc) forState:UIControlStateHighlighted];
    _moreButton.titleLabel.font = [UIFont systemFontOfSize:14];
    UIImageView *moreImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"photo_to_right"]];
    moreImageView.frame = CGRectMake(ScreenWidth - 16, 0, 7, 11);
    moreImageView.center = CGPointMake(moreImageView.center.x, _moreButton.center.y);
    [_headView addSubview:moreImageView];
    [_moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_moreButton];
    
    _imageArray = [[NSMutableArray alloc]init];
    _labelArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 6; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //btn.backgroundColor = [UIColor redColor];
        [btn addTarget:self action:@selector(picButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *image = [[UIImageView alloc] init];
        [_middleView addSubview:btn];
        [_middleView addSubview:image];
        
        CGFloat buttonWidth = (ScreenWidth - 20) / 3.f;
        switch (i) {
            case 0:
                btn.frame = CGRectMake(5,0, buttonWidth, buttonWidth);
                btn.tag = 1;
                break;
            case 1:
                btn.frame = CGRectMake(buttonWidth + 10,0, buttonWidth * 2 + 5, buttonWidth * 2 + 5);
                btn.tag = 0;
                break;
            case 2:
                btn.frame = CGRectMake(5,buttonWidth + 5, buttonWidth, buttonWidth);
                btn.tag = 2;
                break;
            case 3:
                btn.frame = CGRectMake(5,buttonWidth * 2 + 10, buttonWidth, buttonWidth);
                btn.tag = 3;
                break;
            case 4:
                btn.frame = CGRectMake(buttonWidth + 10,buttonWidth * 2 + 10, buttonWidth, buttonWidth);
                btn.tag = 4;
                break;
            case 5:
                btn.frame = CGRectMake(buttonWidth * 2 + 15,buttonWidth * 2 + 10, buttonWidth, buttonWidth);
                btn.tag = 5;
                break;
                
            default:
                break;
        }
        
        image.tag = btn.tag;
        image.frame = btn.frame;
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.layer.masksToBounds = YES;
        UIView *textBgView = [[UIView alloc]initWithFrame:CGRectMake(0, btn.mj_height - 20, btn.mj_width, 20)];
        textBgView.backgroundColor = [UIColor blackColor];
        textBgView.alpha = 0.5f;
        [image addSubview:textBgView];
        
        UILabel *textLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(0xffffff)];
        textLabel.frame = CGRectMake(0, btn.mj_height - 18, btn.mj_width, 14);
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.tag = btn.tag;
        [image addSubview:textLabel];
        [_imageArray addObject:image];
        [_labelArray addObject:textLabel];
        
    }
    
}
- (void)reloadCellWithModel:(TopicModel *)topicModel{
    _topicModel = topicModel;
    [_imageArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *image = (UIImageView *)obj;
        if (topicModel.huatilist.count > image.tag) {
            HuaTiModel *model = _topicModel.huatilist[image.tag];
            [image sd_setImageWithURL:StrToUrl(model.content) placeholderImage:nil];
        }
    }];
    [_labelArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *label = (UILabel *)obj;
        if (topicModel.huatilist.count > label.tag) {
            HuaTiModel *model = _topicModel.huatilist[label.tag];
            label.text = model.huatitext;
        }
    }];
}
- (void)picButtonClick:(UIButton *)sender{
    if (sender.tag < _topicModel.huatilist.count) {
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiClick:index:)]) {
            [_topicDelegate topicHuaTiClick:_topicModel index:sender.tag];
        }
    }
}
- (void)moreButtonClick:(UIButton *)sender{

    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiMoreClick:)]) {
        [_topicDelegate topicHuaTiMoreClick:_topicModel];
    }
}
- (void)playVideo{
    [[AWEasyVideoPlayer sharePlayer]stop];
}
- (void)stopVideo{
    [[AWEasyVideoPlayer sharePlayer]stop];
}
+ (CGFloat)getCellHeight{
    return HuaTiCell_Height;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
