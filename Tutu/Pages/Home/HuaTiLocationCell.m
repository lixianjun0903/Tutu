//
//  HuaTiLocationCell.m
//  Tutu
//
//  Created by gexing on 5/20/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//


#import "HuaTiLocationCell.h"
#import "UILabel+Additions.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "HuaTiLocationCollectionCell.h"

@implementation HuaTiLocationCell
static NSString *huaTiLocationCollectionCell = @"HuaTiLocationCollectionCell";
- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = HEXCOLOR(0xF2F3F7);
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    _headView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_headView];
    _middleView = [[UIView alloc]initWithFrame:CGRectMake(0, _headView.max_y, ScreenWidth,PIC_ITEM_WIDTH * 2 + 15 )];
    _middleView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_middleView];
    
    _titleLabel = [UILabel labelWithSystemFont:16 textColor:HEXCOLOR(DrakGreenNickNameColor)];
    _titleLabel.frame = CGRectMake(10, 14, 300, 17);
    _titleLabel.text = TTLocalString(@"topic_hot_huati");
    _titleLabel.userInteractionEnabled = YES;
    [_headView addSubview:_titleLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locationOrTitleClick:)];
    [_titleLabel addGestureRecognizer:tap];
    
    _locationIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 13, 13, 18)];
    _locationIcon.image = [UIImage imageNamed:@"topic_location_icon"];
    [_headView addSubview:_locationIcon];
    
    _descLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(TextBlackColor)];
    _descLabel.frame = CGRectMake(0, 14, 15, 15);
    [_headView addSubview:_descLabel];
    
    
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.itemSize = CGSizeMake(PIC_ITEM_WIDTH, PIC_ITEM_WIDTH);
    layOut.minimumLineSpacing = 5;
    layOut.minimumInteritemSpacing = 5;
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, PIC_ITEM_WIDTH * 2 + 5) collectionViewLayout:layOut];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:huaTiLocationCollectionCell bundle:nil] forCellWithReuseIdentifier:huaTiLocationCollectionCell];
    _collectionView.contentInset = UIEdgeInsetsMake(0,10, 0, 10);
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
    [_middleView addSubview:_collectionView];
    
}
- (void)locationOrTitleClick:(id)sender{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicThemeTitleOrLocationClick:)]) {
        [_topicDelegate topicThemeTitleOrLocationClick:_topicModel];
    }
}
- (UILabel *)createDescLabel:(int)totalCount{
    NSString *desc = FormatString(@"%@%d%@",TTLocalString(@"TT_have"), totalCount,TTLocalString(@"TT_new_post"));
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:desc];
    [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(TextBlackColor),NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, 1)];
    [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(DrakGreenNickNameColor),NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(1, IntToString(totalCount).length)];
    [string addAttributes:@{NSForegroundColorAttributeName:HEXCOLOR(TextBlackColor),NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(IntToString(totalCount).length + 1,6)];
    _descLabel.attributedText = string;
    CGSize size = [desc sizeWithFont:_descLabel.font];
    _descLabel.frame = CGRectMake(0, _descLabel.mj_y, size.width, size.height);
    return _descLabel;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HuaTiModel *model = _topicModel.topiclist[indexPath.row];
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLocationAndHuaTiClick:)]) {
        [_topicDelegate topicLocationAndHuaTiClick:model.topicid];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _topicModel.topiclist.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HuaTiLocationCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:huaTiLocationCollectionCell forIndexPath:indexPath];
    HuaTiModel *model = _topicModel.topiclist[indexPath.row];
    [cell reloadCellWithModel:model];
    return cell;
}
- (void)reloadCellWithModel:(TopicModel *)topicModel{
    _topicModel = topicModel;
    if (_cellType == CellTypeLocation) {
        [_locationIcon setHidden:NO];
        _titleLabel.text = _topicModel.idtext;
        CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
        _titleLabel.frame = CGRectMake(_locationIcon.max_x + 5, _titleLabel.mj_y, size.width, _titleLabel.mj_height);
    }else{
        _titleLabel.text = FormatString(@"#%@", _topicModel.idtext);
        CGSize size = [_titleLabel.text sizeWithFont:_titleLabel.font];
        _titleLabel.frame = CGRectMake(10, _titleLabel.mj_y, size.width, _titleLabel.mj_height);
        [_locationIcon setHidden:YES];
    }
    
    _descLabel = [self createDescLabel:_topicModel.newcount];
    _descLabel.frame = CGRectMake(_titleLabel.max_x + 15, _descLabel.mj_y, _descLabel.mj_width, _descLabel.mj_height);
    
    [_collectionView reloadData];
    _collectionView.contentInset = UIEdgeInsetsMake(0,10, 0, 10);
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}
- (void)picButtonClick:(UIButton *)sender{
    if (sender.tag < _topicModel.huatilist.count) {
        if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiClick:index:)]) {
            [_topicDelegate topicHuaTiClick:_topicModel index:sender.tag];
        }
    }
}

+ (CGFloat)getCellHeight{
    return PIC_ITEM_WIDTH * 2 + 44 + 30;
}

@end
