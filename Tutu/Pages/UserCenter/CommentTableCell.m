//
//  CommentTableCell.m
//  Tutu
//
//  Created by gexing on 1/12/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "CommentTableCell.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Additions.h"
#import "ReleasePicViewController.h"
#import "UserDetailController.h"

#define EmotionWidth      70

#define CommentLabelWidth    (ScreenWidth - 80)
#define ReplyLabelWith       (ScreenWidth - 90)

#define TOP_COMMENT_GAP                          58   //顶部到评论的高度

#define ReplyBg_Comment_GAP                      9     //评论到评论背景

#define Comment_bg_width                        (ScreenWidth - 40)


#define ReplyName_CommentBg_GAP                  19    //回复的昵称到评论背景的距离

#define ReplyComment_CommentBgButtom_GAP         12  //回复到评论背景的底部

#define CommentBg_Buttom_GAP                17     //评论背景到底部距离

#define Comment_Buttom                           15  //评论到底部的距离。

@implementation CommentTableCell

- (void)awakeFromNib {
    _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(12, 12, 35, 35)];
    _avatarView.layer.masksToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [_avatarView.layer setCornerRadius:_avatarView.mj_height / 2.0f];
    [self.contentView addSubview:_avatarView];
    
    UITapGestureRecognizer *avatarTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [_avatarView addGestureRecognizer:avatarTap];
    
    _nameLabel = [UILabel labelWithSystemFont:14 textColor:HEXCOLOR(DrakGreenNickNameColor)];
    _nameLabel.numberOfLines = 1;
    _nameLabel.frame = CGRectMake(_avatarView.max_x + 10, 17, ScreenWidth * 0.6, 15);
    [self.contentView addSubview:_nameLabel];
    _nameLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [_nameLabel addGestureRecognizer:nameTap];
    
    UIImageView *timeIcon = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.mj_x, _nameLabel.max_y + 5, 10, 10)];
    timeIcon.image = [UIImage imageNamed:@"topic_time_icon"];
    [self.contentView addSubview:timeIcon];
    
    _stampLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextGrayColor)];
    _stampLabel.frame = CGRectMake(timeIcon.max_x + 4, timeIcon.mj_y -1,40, 12);
    _stampLabel.numberOfLines = 1;
    _stampLabel.text = @"2015-09-12";
    [self.contentView addSubview:_stampLabel];
    
    _likeCountImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comment_zan_icon"]];
    _likeCountImageView.frame = CGRectMake(_stampLabel.max_x + 10, timeIcon.mj_y, 10, 10);
    [self.contentView addSubview:_likeCountImageView];
    
    _likeCountLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(TextGrayColor)];
    _likeCountLabel.frame = CGRectMake(_likeCountImageView.max_x + 4, _stampLabel.mj_y, 80, 11);
    _likeCountLabel.text = @"9999";
    [self.contentView addSubview:_likeCountLabel];
    
    _commentLabel = [[TTExtendLabel alloc]init];
    _commentLabel.font = [UIFont systemFontOfSize:13];
    _commentLabel.frame = CGRectMake(_nameLabel.mj_x, _avatarView.max_y + 10, ScreenWidth - _nameLabel.mj_x - 12, 14);
    [self.contentView addSubview:_commentLabel];
   
    //给评论内容加手势
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(commentlongPress:)];
    [_commentLabel addGestureRecognizer:longpress];
    _commentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_nameLabel.mj_x, _avatarView.max_y + 10, CommentLabelWidth, EmotionWidth)];
    _commentImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_commentImageView];
    _leftCommentImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, EmotionWidth, EmotionWidth)];
    [_commentImageView addSubview:_leftCommentImageView];
    
    UILongPressGestureRecognizer *longpress1 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(commentlongPress:)];
    [_commentImageView addGestureRecognizer:longpress1];
   
    //创建下面的回复信息视图
    
    _replyView = [[UIView alloc]initWithFrame:CGRectMake(_nameLabel.mj_x, _commentLabel.max_y + 5, ScreenWidth - 12 - _nameLabel.mj_x, 47)];
    _replyView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_replyView];
    
    _replyBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _replyView.mj_width, _replyView.mj_height)];
    [_replyView addSubview:_replyBgView];
    _replyNameLabel = [[UILabel alloc]init];
    _replyNameLabel.backgroundColor = [UIColor clearColor];
    _replyNameLabel.font = [UIFont systemFontOfSize:13];
    [_replyView addSubview:_replyNameLabel];
    
    _replyContent = [[TTExtendLabel alloc]init];
    _replyContent.font = [UIFont systemFontOfSize:13];
    [_replyContent setTextColor:HEXCOLOR(0x999999)];
    [_replyView addSubview:_replyContent];
    
    UILongPressGestureRecognizer *longpress2 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(replylongPress:)];
    [_replyContent addGestureRecognizer:longpress2];
    
    
    _replyImageView = [[UIImageViewAligned alloc]init];
    _replyImageView.userInteractionEnabled = YES;
    _replyImageView.frame = CGRectMake(0, 0, ReplyLabelWith, EmotionWidth);
    [_replyImageView setBackgroundColor:[UIColor clearColor]];
    [_replyView addSubview:_replyImageView];
    
    _leftReplyImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, EmotionWidth, EmotionWidth)];
    [_leftReplyImageView setBackgroundColor:[UIColor clearColor]];
    [_replyImageView addSubview:_leftReplyImageView];
    
    UILongPressGestureRecognizer *longpress3 = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(replylongPress:)];
    [_replyImageView addGestureRecognizer:longpress3];
    //创建喜欢点击按钮
    
    _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_likeButton addTarget:self action:@selector(likeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle"] forState:UIControlStateNormal];
    [_likeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _likeButton.frame = CGRectMake(ScreenWidth - 14 - 37, 11, 37, 37);
    [self.contentView addSubview:_likeButton];
    
    //创建更多按钮
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    [_moreButton setImage:[UIImage imageNamed:@"comment_more"] forState:UIControlStateNormal];
    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 5)];
    _moreButton.frame = CGRectMake(_likeButton.mj_x - 32, _likeButton.mj_y, 32, 37);
    [self.contentView addSubview:_moreButton];
 
}
- (void)copyAction:(id)sender{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_popviewType == 1) {
        pasteboard.string = _commentModel.comment;
    }else{
        pasteboard.string = _commentModel.replyContent;
    }
    [SVProgressHUD showSuccessWithStatus:@"复制成功"];
    
}
- (void)popupMenuWillDisappear:(QBPopupMenu *)popupMenu{
    [self setBackgoundClear];
}
- (void)setBackgoundClear{
    [_commentLabel setBackgroundColor:[UIColor clearColor]];
    _commentImageView.backgroundColor = [UIColor clearColor];
    _replyContent.backgroundColor = [UIColor clearColor];
    _replyImageView.backgroundColor = [UIColor clearColor];
}
- (void)setBackgroundGray{
    if (_popviewType == 1) {
        if (_commentModel.comment.length > 0) {
            [_commentLabel setBackgroundColor:HEXCOLOR(0xF2F3F7)];
        }else{
            _commentImageView.backgroundColor = HEXCOLOR(0xF2F3F7);
        }
    }else{
        if (_commentModel.replyContent.length > 0) {
            _replyContent.backgroundColor = HEXCOLOR(0xF2F3F7);
        }else{
            _replyImageView.backgroundColor = HEXCOLOR(0xF2F3F7);
        }
    }

}
- (void)deleteAction:(id)sender{
    if (_popviewType == 1) {
        [self didClickOnButtonIndex:0 tag:0];
    }else{
        [[RequestTools getInstance]get:API_COMMENT_DELETE(_commentModel.replyCommentid,_topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
            if ([dict[@"code"]intValue] == 10000) {
                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_delete_success")];
                [NOTIFICATION_CENTER postNotificationName:Notification_Delete_Reply_Comment object:_commentModel];
            }
        } failure:^(ASIHTTPRequest *request, NSString *message) {
            
        } finished:^(ASIHTTPRequest *request) {
            
        }];
    }
    
    
}
- (void)reportAction:(id)sender{
    NSString *commendid = @"";
    if (_popviewType == 1) {
        commendid = _commentModel.commentid;

    }else{
        commendid = _commentModel.replyCommentid;
    }
    [[RequestTools getInstance]get:API_COMMENT_REPORT(commendid) isCache:NO completion:^(NSDictionary *dict) {
        if ([dict[@"code"]intValue] == 10000) {
            [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_report_success") duration:1.0];
        }
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

//评论长按弹出菜单

- (void)commentlongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSMutableArray *items = [@[]mutableCopy];
        
        //用户主题下的所有评论都可以删除
        if (_commentModel.comment.length > 0) {
            QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_coyp") target:self action:@selector(copyAction:)];
            [items addObject:item4];
        }
        if ([_topicModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
            QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_delete") target:self action:@selector(deleteAction:)];
            [items addObject:item2];
            if (![_commentModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
                QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_report") target:self action:@selector(reportAction:)];
                [items addObject:item3];
            }
        }else{
            if ([_commentModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
                QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_delete") target:self action:@selector(deleteAction:)];
                [items addObject:item2];
            }else{
                QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_report") target:self action:@selector(reportAction:)];
                [items addObject:item2];
                
            }
        }
        
        QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
        popupMenu.delegate = self;
        popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
        CGRect rect = [recognizer.view convertRect:recognizer.view.frame toView:[UIApplication sharedApplication].keyWindow];
        rect.origin.x = rect.origin.x - 50;
        rect.origin.y = rect.origin.y - 60;
        [popupMenu showInView:[UIApplication sharedApplication].keyWindow targetRect:rect animated:YES];
        _popviewType = 1;
        
    }
    
    [self setBackgroundGray];
    
}

//下部的回复内容长按弹出菜单。

- (void)replylongPress:(UIGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSMutableArray *items = [@[]mutableCopy];
        if (_commentModel.replyContent.length > 0) {
            QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_coyp") target:self action:@selector(copyAction:)];
            [items addObject:item4];
        }
        if ([_topicModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {

            QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_delete") target:self action:@selector(deleteAction:)];
            [items addObject:item2];
            if (![_commentModel.uid isEqualToString:[[LoginManager getInstance]getUid]]) {
                QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_report") target:self action:@selector(reportAction:)];
                [items addObject:item3];
            }
        }else{
            if ([_commentModel.replyUid isEqualToString:[[LoginManager getInstance]getUid]]) {
                QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_delete") target:self action:@selector(deleteAction:)];
                [items addObject:item2];
            }else{
                QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:TTLocalString(@"TT_report") target:self action:@selector(reportAction:)];
                [items addObject:item2];
            }
        }
        
        QBPopupMenu *popupMenu = [[QBPopupMenu alloc] initWithItems:items];
        popupMenu.delegate = self;
        popupMenu.highlightedColor = [[UIColor colorWithRed:0 green:0.478 blue:1.0 alpha:1.0] colorWithAlphaComponent:0.8];
        CGRect rect = [recognizer.view convertRect:recognizer.view.frame toView:[UIApplication sharedApplication].keyWindow];
        rect.origin.x = rect.origin.x - 50;
        rect.origin.y = rect.origin.y - 45;
        [popupMenu showInView:[UIApplication sharedApplication].keyWindow targetRect:rect animated:YES];
        _popviewType = 2;
        
    }
   [self setBackgroundGray];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentAvatarClick:)]) {
        [_topicDelegate topicCommentAvatarClick:_commentModel];
    }
}
- (void)addAnimationToView:(UIView *)targetView{
    [targetView setHidden:NO];
    [UIView animateWithDuration:0.15 animations:^{
        targetView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            targetView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                targetView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            } completion:^(BOOL finished) {
            }];
        }];
    }];
}
- (void)showMore:(id)sender{
    if (_coverButton) {
        [_coverButton removeFromSuperview];
        _coverButton = nil;
    }
    _coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _coverButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [_coverButton addTarget:self action:@selector(dismissCoverButton:) forControlEvents:UIControlEventTouchUpInside];
    [ApplicationDelegate.window addSubview:_coverButton];
    
    [_moreButton setImage:[UIImage imageNamed:@"comment_more_hl"] forState:UIControlStateNormal];
    
    CGPoint point = [self.contentView convertPoint:CGPointMake(ScreenWidth - 80,11) toView:_coverButton];
    
    _moreView = [[UIView alloc]initWithFrame:CGRectMake(point.x, point.y,0, 37)];
    _moreView.clipsToBounds = YES;
    [_coverButton addSubview:_moreView];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 37)];
    [_moreView addSubview:bgView];
    bgView.backgroundColor = HEXCOLOR(0x222222);
    bgView.layer.masksToBounds = YES;
    [bgView.layer setCornerRadius:8.0f];
    [_moreView addSubview:bgView];
    UIImageView *pointImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"comment_more_sanjiao"]];
    pointImageView.frame = CGRectMake(150, 13, 7, 11);
    [_moreView addSubview:pointImageView];
    NSArray *images = nil;
    NSArray *titles = nil;
    BOOL isMine = [_commentModel.uid isEqualToString:[LoginManager getInstance].getUid];
    if (isMine) {
        images = @[@"topic_comment_delete",@"topic_comment_review"];
        titles = @[TTLocalString(@"TT_delete"),TTLocalString(@"TT_reply")];
    }else{
        images = @[@"topic_comment_report",@"topic_comment_review"];
        titles = @[TTLocalString(@"TT_report"),TTLocalString(@"TT_reply")];
    }
    
    for (int i = 0; i < 2; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(75 * i,0, 75, 37);
        btn.tag = i;
        [btn setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:HEXCOLOR(0x919191) forState:UIControlStateHighlighted];
        [_moreView addSubview:btn];
        if (i == 0) {
            if (!isMine) {
                [btn setImageEdgeInsets:UIEdgeInsetsMake(10, 16, 11, 45)];
            }else{
                [btn setImageEdgeInsets:UIEdgeInsetsMake(11, 16, 11, 48)];
            }
            
        }else{
            [btn setImageEdgeInsets:UIEdgeInsetsMake(12, 16, 10, 45)];
        }
    }
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(75, 8, 1, 20)];
    lineView.backgroundColor = HEXCOLOR(0xa5a5a5);
    [_moreView addSubview:lineView];
    
    [UIView animateWithDuration:0.2 animations:^{
        _moreView.frame = CGRectMake(point.x - 160, point.y, 157, 37);
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)didClickOnButtonIndex:(NSInteger)buttonIndex tag:(NSInteger)tag{
    if (buttonIndex == 0) {
        //发送删除请求
            [[RequestTools getInstance]get:API_COMMENT_DELETE(_commentModel.commentid, _topicModel.topicid) isCache:NO completion:^(NSDictionary *dict) {
                if ([dict[@"code"]intValue] == 10000) {
                    [SVProgressHUD showSuccessWithStatus:TTLocalString(@"TT_delete_success")];
                    [NOTIFICATION_CENTER postNotificationName:Notification_Delete_Comment object:_commentModel];
                }
            } failure:^(ASIHTTPRequest *request, NSString *message) {

            } finished:^(ASIHTTPRequest *request) {
                
            }];
    }else{
    
    }
}
- (void)moreButtonClick:(UIButton *)button{
    [self dismissCoverButton:nil];
    if (button.tag == 1) {
        [[SDWebImageDownloader sharedDownloader]downloadImageWithURL:StrToUrl(_topicModel.sourcepath) options:SDWebImageDownloaderUseNSURLCache progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
                    [_topicDelegate topicCommentContentClick:_commentModel topicModel:_topicModel image:image duration:0 type:2 point:CGPointZero];
                }
            });
        }];

    }else{
        BOOL isMine = [_commentModel.uid isEqualToString:[LoginManager getInstance].getUid];
        if (isMine) {
         //弹出删除确认
            LXActionSheet *sheet = [[LXActionSheet alloc]initWithTitle:TTLocalString(@"TT_confirm_delete_comment?") delegate:self otherButton:@[TTLocalString(@"TT_make_sure"),] cancelButton:TTLocalString(@"TT_cancel")];
            [sheet showInView:nil];
        }else{
         //发送举报请求
            [[RequestTools getInstance]get:API_COMMENT_REPORT(_commentModel.commentid) isCache:NO completion:^(NSDictionary *dict) {
                [SVProgressHUD showSuccessWithStatus:TTLocalString(@"topic_report_success") duration:1.0];
            } failure:^(ASIHTTPRequest *request, NSString *message) {
                
            } finished:^(ASIHTTPRequest *request) {
                
            }];
        }
    }
}
- (void)dismissCoverButton:(UIButton *)sender{
    CGPoint point = [self.contentView convertPoint:CGPointMake(ScreenWidth - 80,11) toView:_coverButton];
    [_moreButton setImage:[UIImage imageNamed:@"comment_more"] forState:UIControlStateNormal];
      _moreView = [[UIView alloc]initWithFrame:CGRectMake(point.x, point.y,0, 37)];
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
       [_coverButton removeFromSuperview];
        _coverButton = nil;
    }];
}
- (void)likeButtonClick:(UIButton *)sender{
 
    sender.userInteractionEnabled = NO;
   __block NSInteger count = _commentModel.likenum;
    if (_commentModel.islike == 1) {
        [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle"] forState:UIControlStateNormal];
        count --;
        [self addAnimationToView:sender];
        if (count == 0) {
            [_likeCountImageView setHidden:YES];
            [_likeCountLabel setHidden:YES];
        }
        _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_icon"];
        _likeCountLabel.text = [@(count) stringValue];
        [[RequestTools getInstance]get:API_ZAN_CANCEL_COMMENT(_commentModel.commentid) isCache:NO completion:^(NSDictionary *dict) {
            _commentModel.likenum = count;
            _commentModel.islike = 0;
            [_topicModel.newcommentlist replaceObjectAtIndex:_cellIndex withObject:_commentModel];

        } failure:^(ASIHTTPRequest *request, NSString *message) {
            count ++;
            _likeCountLabel.text = [@(count) stringValue];
            _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_middle_hl"];
            [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle_hl"] forState:UIControlStateNormal];
        } finished:^(ASIHTTPRequest *request) {
            sender.userInteractionEnabled = YES;
        }];
    }else{
        [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle_hl"] forState:UIControlStateNormal];
        _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_middle_hl"];
        count ++;
        if (count > 0) {
            [_likeCountImageView setHidden:NO];
            [_likeCountLabel setHidden:NO];
        }
        [self addAnimationToView:sender];
        _likeCountLabel.text = [@(count) stringValue];
        
        [[RequestTools getInstance]get:API_ZAN_COMMENT(_commentModel.commentid) isCache:NO completion:^(NSDictionary *dict) {
           _commentModel.likenum = count;
            _commentModel.islike = 1;
            [_topicModel.newcommentlist replaceObjectAtIndex:_cellIndex withObject:_commentModel];

        } failure:^(ASIHTTPRequest *request, NSString *message) {
            count --;
            _likeCountLabel.text = [@(count) stringValue];
            [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle"] forState:UIControlStateNormal];
            _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_icon"];
        } finished:^(ASIHTTPRequest *request) {
            sender.userInteractionEnabled = YES;
        }];

    }

}
- (void)loadCellWithModel:(CommentModel *)model{
    _replyNameLabel.text = @"";
    [_commentLabel setExtendText:@""];
    [_replyContent setExtendText:@""];
    _commentModel = model;
    if (_commentModel.replyName.length > 0) {
        [_replyView setHidden:NO];
    }else{
        [_replyView setHidden:YES];
    }
    _nameLabel.text = _commentModel.nickname;
    _stampLabel.text = _commentModel.formataddtime;
    _likeCountLabel.text = [@(_commentModel.likenum) stringValue];
    if (_commentModel.likenum == 0 ) {
        [_likeCountImageView setHidden:YES];
        _likeCountLabel.hidden = YES;
    }else{
        
        [_likeCountImageView setHidden:NO];
        _likeCountLabel.hidden = NO;
    }
    
    if (_commentModel.islike == 1) {
        _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_middle_hl"];
    }else{
        _likeCountImageView.image = [UIImage imageNamed:@"comment_zan_icon"];
    }
    
    [_avatarView sd_setImageWithURL:StrToUrl([SysTools getHeaderImageURL:_commentModel.uid time:_commentModel.avatar]) placeholderImage:[UIImage imageNamed:@"avatar_default"]];
  
    [self reloadSubViews];
    
    if (_commentModel.islike == 1) {
        [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle_hl"] forState:UIControlStateNormal];
    }else{
        [_likeButton setImage:[UIImage imageNamed:@"comment_zan_middle"] forState:UIControlStateNormal];
    }
    
}
- (void)reloadSubViews{
    
__weak CommentTableCell *weakSelf = self;
    
    [_replyImageView setHidden:YES];
    if (_commentModel.comment.length > 0) {
        [_commentImageView setHidden:YES];
        _commentLabel.frame = CGRectMake(58, TOP_COMMENT_GAP, CommentLabelWidth, 0);
        [_commentLabel setExtendText:_commentModel.comment];
        _commentLabel.frame = CGRectMake(58, TOP_COMMENT_GAP, CommentLabelWidth, _commentLabel.contentHeight);
        
        
        [_commentLabel setExntedBlock:^(NSString *linkedString,TTExtendLabelLinkType type){
            if (type == TTExtendLabelLinkTypeAt) {
                if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
                    [weakSelf.topicDelegate topicAtClick:linkedString topicModel:weakSelf.topicModel];
                }
            }else if(type == TTExtendLabelLinkTypePoundSign){
                if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
                    [weakSelf.topicDelegate topicPoundSignClick:linkedString topicModel:weakSelf.topicModel];
                }
            }
        }];
        
        
        if (_commentModel.replyName.length > 0) {
            [_replyBgView setHidden:NO];
            NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:FormatString(@"%@ %@:", _commentModel.replyName,TTLocalString(@"TT_reply"))];
            
            UIColor *nameColor = HEXCOLOR(DrakGreenNickNameColor);
            UIColor *contentColor = HEXCOLOR(0xA8A8A8);
            [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0,_commentModel.replyName.length +1)];
            [mStr addAttribute:NSForegroundColorAttributeName value:nameColor range:NSMakeRange(0, _commentModel.replyName.length + 1 )];
            [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(_commentModel.replyName.length +1,3)];
            [mStr addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(_commentModel.replyName.length + 1,3)];
            _replyNameLabel.attributedText = mStr;
            _replyNameLabel.frame = CGRectMake(12, ReplyName_CommentBg_GAP,ReplyLabelWith, 15);
            
            if (_commentModel.replyContent.length > 0) {
                _replyContent.frame = CGRectMake(12, _replyNameLabel.max_y + 7, ReplyLabelWith, 0);
                [_replyContent setExtendText:_commentModel.replyContent];
                _replyContent.frame = CGRectMake(_replyContent.mj_x, _replyContent.mj_y, ReplyLabelWith, _replyContent.contentHeight);
                [_replyContent setExntedBlock:^(NSString *linkedString,TTExtendLabelLinkType type){
                    if (type == TTExtendLabelLinkTypeAt) {
                        if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
                            [weakSelf.topicDelegate topicAtClick:linkedString topicModel:weakSelf.topicModel];
                        }
                    }else if(type == TTExtendLabelLinkTypePoundSign){
                        if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
                            [weakSelf.topicDelegate topicPoundSignClick:linkedString topicModel:weakSelf.topicModel];
                        }
                    }
                }];
                _replyView.frame = CGRectMake(58, _commentLabel.max_y + ReplyBg_Comment_GAP, ReplyLabelWith + 24, _replyContent.contentHeight + 20 + ReplyName_CommentBg_GAP + ReplyComment_CommentBgButtom_GAP);
            }else{//回复是图片
                [_replyImageView setHidden:NO];
                 [SysTools getEmotionImage:_commentModel.replyTxtframe imageView:_leftReplyImageView];
                _replyImageView.frame = CGRectMake(12, _replyNameLabel.max_y + 7, ReplyLabelWith, EmotionWidth);
                _replyView.frame = CGRectMake(58, _commentLabel.max_y + ReplyBg_Comment_GAP, ReplyLabelWith + 24,  EmotionWidth + 20 + ReplyName_CommentBg_GAP + ReplyComment_CommentBgButtom_GAP);
            }
            
            _replyBgView.frame = CGRectMake(0, 0, _replyView.mj_width, _replyView.mj_height);
            UIImage *bgImage = [UIImage imageNamed:@"topic_comment_kuang"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5,20,1,1)];
            _replyBgView.image = bgImage;
        }else{
            [_replyView setHidden:YES];
        }
        
    }else{
        _commentImageView.frame = CGRectMake(58, TOP_COMMENT_GAP, CommentLabelWidth, EmotionWidth);
        [_commentImageView setHidden:NO];
       [SysTools getEmotionImage:_commentModel.commentbg imageView:_leftCommentImageView];
        if (_commentModel.replyName.length > 0) {
            [_replyBgView setHidden:NO];
            _replyNameLabel.frame = CGRectMake(12, ReplyName_CommentBg_GAP,ReplyLabelWith, 15);
            NSMutableAttributedString *mStr = [[NSMutableAttributedString alloc] initWithString:FormatString(@"%@ %@:", _commentModel.replyName,TTLocalString(@"TT_reply"))];
            UIColor *nameColor = HEXCOLOR(0x6CBEA6);
            UIColor *contentColor = HEXCOLOR(0xA8A8A8);
            [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0,_commentModel.replyName.length +1)];
            [mStr addAttribute:NSForegroundColorAttributeName value:nameColor range:NSMakeRange(0, _commentModel.replyName.length + 1 )];
            [mStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(_commentModel.replyName.length +1,3)];
            [mStr addAttribute:NSForegroundColorAttributeName value:contentColor range:NSMakeRange(_commentModel.replyName.length + 1,3)];
            _replyNameLabel.attributedText = mStr;
            _replyNameLabel.frame = CGRectMake(12, ReplyName_CommentBg_GAP,ReplyLabelWith, 15);
            if (_commentModel.replyContent.length > 0) {
                _replyContent.frame = CGRectMake(12, _replyNameLabel.max_y + 7, ReplyLabelWith, 0);
                [_replyContent setExtendText:_commentModel.replyContent];
                [_replyContent setExntedBlock:^(NSString *linkedString,TTExtendLabelLinkType type){
                    if (type == TTExtendLabelLinkTypeAt) {
                        if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
                            [weakSelf.topicDelegate topicAtClick:linkedString topicModel:weakSelf.topicModel];
                        }
                    }else if(type == TTExtendLabelLinkTypePoundSign){
                        if (weakSelf.topicDelegate && [weakSelf.topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
                            [weakSelf.topicDelegate topicPoundSignClick:linkedString topicModel:weakSelf.topicModel];
                        }
                    }
                }];
                _replyContent.frame = CGRectMake(_replyContent.mj_x, _replyContent.mj_y, ReplyLabelWith, _replyContent.contentHeight);
                _replyView.frame = CGRectMake(58, _commentImageView.max_y + ReplyBg_Comment_GAP, ReplyLabelWith + 24, _replyContent.contentHeight + 20 + ReplyName_CommentBg_GAP + ReplyComment_CommentBgButtom_GAP);
            }else{//回复是图片
                [_replyImageView setHidden:NO];
                [SysTools getEmotionImage:_commentModel.replyTxtframe imageView:_leftReplyImageView];
                _replyImageView.frame = CGRectMake(12, _replyNameLabel.max_y + 7, ReplyLabelWith, EmotionWidth);
                _replyView.frame = CGRectMake(58, _commentImageView.max_y + ReplyBg_Comment_GAP, ReplyLabelWith + 24,  EmotionWidth + 20 + ReplyName_CommentBg_GAP + ReplyComment_CommentBgButtom_GAP);
            }
            _replyBgView.frame = CGRectMake(0, 0, _replyView.mj_width, _replyView.mj_height);
            UIImage *bgImage = [UIImage imageNamed:@"topic_comment_kuang"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5,20,1,1)];
            _replyBgView.image = bgImage;
        }else{
            [_replyView setHidden:YES];
        }
    }
    
    
    
    //计算子view的frame。
  
    
    CGSize stampLabelSize = [_stampLabel getLineLabelSize];
    _stampLabel.frame = CGRectMake(_stampLabel.mj_x, _stampLabel.mj_y, stampLabelSize.width, stampLabelSize.height);
    _likeCountImageView.frame = CGRectMake(_stampLabel.max_x + 10, _likeCountImageView.mj_y, _likeCountImageView.mj_width, _likeCountImageView.mj_height);
    _likeCountLabel.frame = CGRectMake(_likeCountImageView.max_x + 4, _likeCountLabel.mj_y, _likeCountLabel.mj_width, _likeCountLabel.mj_height);
    
}
+ (CGFloat)calculateCellHeight:(CommentModel *)model{
    CGFloat cellHeight = 0;
    if (model.comment.length > 0) {//评论是文字
        TTExtendLabel *label = [[TTExtendLabel alloc] initWithFrame:CGRectMake(0, 0, CommentLabelWidth, 0)];
        [label setExtendText:model.comment];
        
        CGFloat height = label.contentHeight;
        
        cellHeight = TOP_COMMENT_GAP + height;
        
        if (model.replyName.length > 0) {
            if (model.replyContent.length > 0) {//回复是文字
                TTExtendLabel *reply = [[TTExtendLabel alloc] initWithFrame:CGRectMake(0, 0, ReplyLabelWith, 0)];
                [reply setExtendText:model.replyContent];
                cellHeight = cellHeight + reply.contentHeight + 20 + ReplyName_CommentBg_GAP + ReplyBg_Comment_GAP;
                
                return cellHeight + ReplyComment_CommentBgButtom_GAP + CommentBg_Buttom_GAP;
                
            }else{//回复是图片
                
                cellHeight = cellHeight + EmotionWidth + 20 + ReplyName_CommentBg_GAP + ReplyBg_Comment_GAP;
                
                cellHeight = cellHeight + ReplyComment_CommentBgButtom_GAP + CommentBg_Buttom_GAP;
                
                return cellHeight;
                
            }
        }else{
        
            return cellHeight + Comment_Buttom;
        }
        
    }else{//评论是图像
       cellHeight = TOP_COMMENT_GAP + EmotionWidth;
        if (model.replyName.length > 0) {
            
            if (model.replyContent.length > 0) {//回复是文字
                
                TTExtendLabel *reply = [[TTExtendLabel alloc] initWithFrame:CGRectMake(0, 0, ReplyLabelWith, 0)];
                [reply setExtendText:model.replyContent];
                cellHeight = cellHeight + reply.contentHeight + 20 + ReplyName_CommentBg_GAP + ReplyBg_Comment_GAP;
                
                return cellHeight + ReplyComment_CommentBgButtom_GAP + CommentBg_Buttom_GAP;
            }else{//回复是图片
                cellHeight = cellHeight + EmotionWidth + 20 + ReplyName_CommentBg_GAP + ReplyBg_Comment_GAP;
                
                cellHeight = cellHeight + ReplyComment_CommentBgButtom_GAP + CommentBg_Buttom_GAP;
                
                return cellHeight;
                
            }
        }else{
            return cellHeight + Comment_Buttom;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
