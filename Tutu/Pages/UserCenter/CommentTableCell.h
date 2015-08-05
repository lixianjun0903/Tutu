//
//  CommentTableCell.h
//  Tutu
//
//  Created by gexing on 1/12/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXActionSheet.h"
#import "TopicDelegate.h"
#import "TTExtendLabel.h"
#import "QBPopupMenu.h"
#import "UIImageViewAligned.h"
@interface CommentTableCell : UITableViewCell<LXActionSheetDelegate,TopicDelegate,QBPopupMenuDelegate>
@property(nonatomic,strong)UIImageView *avatarView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *stampLabel;
@property(nonatomic,strong)UILabel *likeCountLabel;
@property(nonatomic,strong)UIImageView *likeCountImageView;

@property(nonatomic,strong)UIButton *moreButton;
@property(nonatomic,strong)UIButton *likeButton;
@property(nonatomic,weak) id <TopicDelegate> topicDelegate;
//用来显示评论的内容
@property(nonatomic,strong)TTExtendLabel *commentLabel;
//用来显示评论的表情
@property(nonatomic,strong)UIView *commentImageViewBg;

@property(nonatomic,strong)UIImageView *commentImageView;
@property(nonatomic,strong)UIImageView *leftCommentImageView;

@property(nonatomic,strong)UIView *replyView;
@property(nonatomic,strong)UIImageView *replyBgView;
@property(nonatomic,strong)UILabel *replyNameLabel;
@property(nonatomic,strong)TTExtendLabel *replyContent;
@property(nonatomic,strong)UIImageView *replyImageView;
@property(nonatomic,strong)UIImageView *leftReplyImageView;

@property(nonatomic,strong)CommentModel *commentModel;
@property(nonatomic,strong)TopicModel *topicModel;

@property(nonatomic,strong)UIButton *coverButton;
@property(nonatomic,strong)UIView *moreView;

@property(nonatomic)NSInteger cellIndex;
@property(nonatomic,assign) NSInteger popviewType;//为1，是弹出评论popview，为2，是弹出被回复的评论的popview

- (void)loadCellWithModel:(CommentModel *)model;
+ (CGFloat)calculateCellHeight:(CommentModel *)model;
@end
