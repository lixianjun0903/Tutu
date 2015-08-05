//
//  TopicCollectionCell.m
//  Tutu
//
//  Created by feng on 14-10-22.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "TopicCollectionCell.h"
#import "TopicDetailController.h"
@implementation TopicCollectionCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}
- (void)loadCellWithModel:(TopicModel *)model{
    if (_topicController) {
        [_topicController.view removeFromSuperview];
        _topicController = nil;
    }
    _topicController = [[TopicDetailController alloc]init];
    _topicModel = model;
    _topicController.topicModel = self.topicModel;
    _topicController.isTopicDetailListView = YES;
    _topicController.topicDelegate = self;
    _topicController.indexRow = _cellIndexPathRow;
    [self.contentView addSubview:_topicController.view];
}

#pragma mark TopicDelegate
- (void)topicPhoneNameClick:(id)sender{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPhoneNameClick:)]) {
        [_topicDelegate topicPhoneNameClick:sender];
    }
}
- (void)topicAvatarOrNicknameClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAvatarOrNicknameClick:topicModel];
    }
}
- (void)topicAtClick:(NSString *)name topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicAtClick:topicModel:)]) {
        [_topicDelegate topicAtClick:name topicModel:topicModel];
    }
}
- (void)topicPoundSignClick:(NSString *)string topicModel:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicPoundSignClick:topicModel:)]) {
        [_topicDelegate topicPoundSignClick:string topicModel:topicModel];
    }
}

- (void)topicDetailClick:(TopicModel *)topicModel index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicDetailClick: index:)]) {
        [_topicDelegate topicDetailClick:topicModel index:index];
    }
}
- (void)topicCommentCountClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentCountClick:)]) {
        [_topicDelegate topicCommentCountClick:topicModel];
    }
}
//- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex{
//    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicUpdateModel:index:tableIndex:)]) {
//        [_topicDelegate topicUpdateModel:model index:index tableIndex:tabelIndex];
//    }
//}
//- (void)topicUpdateModel:(TopicModel *)model index:(NSInteger)index tableIndex:(NSInteger)tabelIndex isReload:(BOOL)isReload{
//    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicUpdateModel:index:tableIndex:isReload:)]) {
//        [_topicDelegate topicUpdateModel:model index:index tableIndex:tabelIndex isReload:isReload];
//    }
//}
- (void)topicCommentAvatarClick:(CommentModel *)commentModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentAvatarClick:)]) {
        [_topicDelegate topicCommentAvatarClick:commentModel];
    }
}
- (void)topicCommentContentClick:(CommentModel *)commentModel topicModel:(TopicModel *)topicModel image:(UIImage *)image duration:(CGFloat)duration type:(NSInteger)type point:(CGPoint)commentPoint{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicCommentContentClick:topicModel:image:duration:type:point:)]) {
        [_topicDelegate topicCommentContentClick:commentModel topicModel:topicModel image:image duration:duration type:type point:commentPoint];
    }
}
//转发的用户名称点击
- (void)topicReportUserNameClick:(NSString *)userID nickName:(NSString *)name{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicReportUserNameClick:nickName:)]) {
        [_topicDelegate topicReportUserNameClick:userID nickName:name];
    }
}

- (void)topicLoctionClick:(NSString *)location topic:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicLoctionClick:topic:)]) {
        [_topicDelegate topicLoctionClick:location topic:topicModel];
    }
}
//分享类型的按钮点击
- (void)topicShareButtonClick:(TopicModel *)topicModel type:(ActionSheetType)type index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicShareButtonClick:type:index:)]) {
        [_topicDelegate topicShareButtonClick:topicModel type:type index:index];
    }
}
//话题的更多点击
- (void)topicHuaTiMoreClick:(TopicModel *)topicModel{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiMoreClick:)]) {
        [_topicDelegate topicHuaTiMoreClick:topicModel];
    }
}
//莫个话题点击
- (void)topicHuaTiClick:(TopicModel *)topicModel index:(NSInteger)index{
    if (_topicDelegate && [_topicDelegate respondsToSelector:@selector(topicHuaTiClick:index:)]) {
        [_topicDelegate topicHuaTiClick:topicModel index:index];
    }
}



@end
