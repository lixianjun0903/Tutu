//
//  CommentCollectionCell.m
//  LineLayout
//
//  Created by gexing on 1/8/15.
//
//

#import "CommentCollectionCell.h"
#import "LineLayout.h"
#import "UIImageView+WebCache.h"
@implementation CommentCollectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 41, 41)];
        _avatarView.center = CGPointMake(ITEM_SIZE / 2.0f, ITEM_SIZE / 2.0f);
        _avatarView.layer.masksToBounds = YES;
        [_avatarView.layer setCornerRadius:_avatarView.mj_width / 2.0f];
        [self.contentView addSubview:_avatarView];
        
        _selectedView = [[UIImageView alloc]initWithFrame:CGRectMake((ITEM_SIZE - 41.6) / 2.0f,0, 41.6, 46)];
        _selectedView.image = [UIImage imageNamed:@"comment_selected_avatar"];
        [_selectedView setHidden:YES];
        [self.contentView addSubview:_selectedView];
    }
    return self;
}
- (void)loadCellWithModel:(CommentModel *)commendModel{
    _commentModel = commendModel;
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:[SysTools getHeaderImageURL:_commentModel.uid time:_commentModel.avatar]] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    [_selectedView setHidden:YES];
}
- (void)hidenSelectedView{
    [self.selectedView setHidden:YES];
}
- (void)showSelectedView{
    [self.selectedView setHidden:NO];

}
@end
