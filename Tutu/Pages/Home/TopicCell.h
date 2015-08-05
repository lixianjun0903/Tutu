//
//  TopicCell.h
//  Tutu
//
//  Created by gexing on 1/6/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#define TOPIC_CELL_HEIGTH   190 + ScreenWidth
#define HOME_CELL_HEIGHT    (ScreenWidth + 120)
#define TIMER_INTERVAL      1.5f
#define TIMER_INTERVAL2     4.0f
#import <UIKit/UIKit.h>
#import "LXActionSheet.h"
#import "TTplayView.h"
#import "TCBlobDownload.h"
#import "SendTopicDelegate.h"
#import "ShareActonSheet.h"
#import "TTExtendLabel.h"
#import "TopicDelegate.h"
#import "AWEasyVideoPlayer.h"
@class M13ProgressViewRing;
@class M13ProgressViewBar;
@interface TopicCell : UITableViewCell<LXActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,ShareActonSheetDelegate>
@property(nonatomic,weak)id <TopicDelegate>topicDelegate;
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UIView *headerView;
@property(nonatomic,strong)UIView *middleView;
@property(nonatomic,strong)UIView *footerView;

@property(nonatomic,strong)UIButton *avatarBtn;
@property(nonatomic,strong)UIButton *addFollowBtn;//添加关注按钮
@property(nonatomic,strong)UIImageView *levelImageView;//用户等级
@property(nonatomic,strong)UIImageView *vipImageView;//用户vip图标
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *stampLabel;
@property(nonatomic,strong)UIImageView *locationFlag;
@property(nonatomic,strong)UIImageView *phoneFlag;
@property(nonatomic,strong)UILabel *phoneName;
@property(nonatomic,strong)UILabel *addressLabel;
@property(nonatomic,strong)UILabel *watchCount;

@property(nonatomic,strong)TTExtendLabel *titleLabel;
@property(nonatomic,strong)UIButton *detailBtn;

@property(nonatomic)BOOL isShowAddFollow;
@property(nonatomic)BOOL isFollowCell;//是否是关注页面cell.
@property(nonatomic)BOOL isShowReportView;//是否显示顶部的转发view

@property(nonatomic)BOOL isDetail;//是否是详情页

@property(nonatomic,strong)UIImageView *topicPicView;
@property(nonatomic,strong)M13ProgressViewRing *picProgress;
@property(nonatomic,strong)M13ProgressViewBar *videoProgress;
@property(nonatomic)CGFloat progressValue;
@property(nonatomic)CGFloat picProgressValue;

@property(nonatomic)BOOL isTargetCell;

@property(nonatomic,strong)UIButton *reUploadBtn;
@property(nonatomic,strong)UILabel *reUploadLabel;//重新上传视频的文字。

@property(nonatomic,strong)UIButton *footMoreBtn;

@property(nonatomic,strong)UIButton *reloadButton;
@property(nonatomic,strong)UIImageView *videoIcon;
@property(nonatomic,strong)UIImageView *commentBgView;
@property(nonatomic,strong)TTExtendLabel *commentLabel;
@property(nonatomic,strong)UIImageView *rateAnimationView;

@property(nonatomic,strong)UIImageView *addZanView;
@property(nonatomic,strong)UIImageView *cancelZanView;

@property(nonatomic,strong)UIView *commentDefaultView;
@property(nonatomic,strong)UILabel *wonderfulLabel;
@property(nonatomic,strong)UILabel *commentDefaultLabel;
@property(nonatomic,strong)UIImageView *commentDefaultIcon;

@property(nonatomic,strong)UIView *collectionViewbg;
@property(nonatomic,strong)UICollectionView *commentCollectionView;
@property(nonatomic,strong)UIButton *playButton;

@property(nonatomic)BOOL isShowComment;
@property(nonatomic,strong)UIButton *commentControl;
@property(nonatomic,strong)UILabel *commentCountLabel;
@property(nonatomic,strong)UIButton *likeCountBtn;
@property(nonatomic,strong)UILabel *likeCountLabel;
@property(nonatomic,strong)UILabel *reportLabel;//转发label;
@property(nonatomic,strong)UIButton *reportBtn;//转发按钮;
@property(nonatomic,strong)TopicModel *topicModel;
@property(nonatomic)NSInteger currentCommetnIndex;

@property(nonatomic)NSInteger cellIndex;
@property(nonatomic)NSInteger tabelIndex;

@property(nonatomic)BOOL isVedioSuccess;//视频是否下载完成
@property(nonatomic)BOOL isPicSuccess;//主题图片是否下载完成


@property(nonatomic)BOOL isCanScroll;
@property(nonatomic,strong)UIView *hotFlag;

@property(nonatomic,strong)NSString *startcommentid;
@property(nonatomic,strong)NSString *direction;
@property(nonatomic)NSInteger length;
@property(nonatomic)BOOL isVisibled;
@property(nonatomic,strong)UserInfo *currentUserInfo;

@property(nonatomic,strong)UIButton *overButton;

@property(nonatomic) BOOL isAutoPlay;



//用来显示动态的评论
@property(nonatomic,strong)UICollectionView *collectionView;
- (void)loadCellWithModel:(TopicModel *)topicModel;

- (void)scrollAvatarAndComment;
- (void)insertCommentWithTopicModel:(TopicModel *)topicModel;

- (void)playVideo;
- (void)stopVideo;
//下载然后播放
- (void)startDownVedio;
//计算cell的高度
+ (CGFloat)getCellHeight:(TopicModel *)model isDetail:(BOOL)isDetail;
@end

