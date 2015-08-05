//
//  CommentCollectionCell.h
//  LineLayout
//
//  Created by gexing on 1/8/15.
//
//

#import <UIKit/UIKit.h>

@interface CommentCollectionCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView *avatarView;
@property(nonatomic,strong)UIImageView *selectedView;

@property(nonatomic,strong)CommentModel *commentModel;
- (void)loadCellWithModel:(CommentModel *)commendModel;
- (void)hidenSelectedView;
- (void)showSelectedView;
@end
