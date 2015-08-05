//
//  NoticeTools.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-24.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "NoticeTools.h"
#import "UIImageView+WebCache.h"
#import "UMSocial.h"
#import "UIImage+Category.h"
#import "UserInfoDB.h"

static NoticeTools *_instance=nil;

@implementation NoticeTools{
    UIView *noticeView;
}


+(NoticeTools *)getInstance{
    if(_instance==nil){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[NoticeTools alloc] init];
        });
    }
    return _instance;
}


-(void)showShareNotice:(TopicModel *)topicModel block:(NoticeCompleteBlock)finish{
    if(noticeView!=nil){
        [noticeView removeFromSuperview];
    }
    UIWindow *window=[[UIApplication sharedApplication]keyWindow];
    CGFloat w=window.frame.size.width;
    noticeView=[[UIView alloc] initWithFrame:CGRectMake(0, -62, w, 62)];
    [noticeView setBackgroundColor:UIColorFromRGB(NoticeBlockBgColor)];
    
    UIImageView *iv=[[UIImageView alloc] initWithFrame:CGRectMake(w/4, 14 , 34, 34)];
    if(topicModel.shareUrl!=nil){
        topicModel.sourcepath=topicModel.shareUrl;
    }
    if(topicModel!=nil && topicModel.sourcepath!=nil && ![topicModel.sourcepath hasPrefix:@"http://"]){
        UIImage* image = [UIImage imageWithContentsOfFile:getDocumentsFilePath(topicModel.sourcepath)];
        [iv setImage:image];
    }else{
        [iv sd_setImageWithURL:[NSURL URLWithString:topicModel.sourcepath]];
    }
    [noticeView addSubview:iv];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(w/4+34+14, 12, w-w/4-34-14, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setText:@"上传成功!"];
    [noticeView addSubview:label];
    
    
    NSString *detail=@"";
    switch (topicModel.shareType) {
        case 1:
            detail=@"立即同步至QQ空间";
            break;
        case 2:
            detail=@"立即同步至微信朋友圈";
            break;
        case 3:
            detail=@"立即同步至新浪微博";
            break;
        default:
            break;
    }
    
    UILabel *msgLabel=[[UILabel alloc] initWithFrame:CGRectMake(w/4+34+14, 32, w-w/4-34-14, 20)];
    [msgLabel setBackgroundColor:[UIColor clearColor]];
    [msgLabel setTextColor:UIColorFromRGB(TextGrayColor)];
    [msgLabel setFont:[UIFont systemFontOfSize:12]];
    [msgLabel setTextAlignment:NSTextAlignmentLeft];
    [msgLabel setText:detail];
    [noticeView addSubview:msgLabel];
    
    [[[UIApplication sharedApplication]keyWindow]addSubview:noticeView];
    [self animationShowNotice:noticeView share:topicModel block:finish];
}

-(void)animationShowNotice:(UIView *) view share:(TopicModel *) model block:(NoticeCompleteBlock) finish{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect cf=view.frame;
        cf.origin.y=0;
        view.frame=cf;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                CGRect cf1=view.frame;
                cf1.origin.y=-view.frame.size.height -StatusBarHeight;
                view.frame=cf1;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                if(finish){
                    finish();
                }
                
                if(model!=nil){
                    [self doShare:model];
                }
            }];
        });
    }];
}

-(void)doShare:(TopicModel *)model{
    NSString *shareText=@"95后、00后都在玩Tutu，快来围观吐槽吧！";
    NSString *shareURL=[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@",SHARE_TOPIC_HOST],model.topicid];
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = shareURL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareURL;
    [UMSocialData defaultData].extConfig.qqData.url = shareURL;
    [UMSocialData defaultData].extConfig.qzoneData.url = shareURL;
    [UMSocialData defaultData].extConfig.sinaData.urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeDefault url:shareURL];
    
    NSArray *types=@[UMShareToWechatSession];
    switch (model.shareType) {
        case 1:
            types=@[UMShareToQzone];
            [UMSocialData defaultData].extConfig.title = WebCopy_ShareZoneTitle;
            shareText = WebCopy_ShareZoneDesc;
            break;
        case 2:
            types=@[UMShareToWechatTimeline];
            [UMSocialData defaultData].extConfig.title = WebCopy_ShareWeixinTimelineTitle;
            shareText = WebCopy_ShareWeixinTimelineDesc;
            break;
        case 3:
            types=@[UMShareToSina];
            //添加视频地址
            if(model!=nil && model.type==5){
                [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:model.videourl];
            }else{
                [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:model.sourcepath];
            }
            [UMSocialData defaultData].extConfig.title = WebCopy_ShareZoneTitle;
            shareText = [NSString stringWithFormat:@"%@ %@",WebCopy_ShareSinaDesc,shareURL];
            break;
            
        default:
            break;
    }
    
    if(model!=nil && model.sourcepath!=nil && ![model.sourcepath hasPrefix:@"http://"]){
        UIImage* image = [UIImage imageWithContentsOfFile:getDocumentsFilePath(model.sourcepath)];
        
        UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:model.sourcepath];
        
        image = [image imageWithWaterMask:[UIImage imageNamed:@"watermark"] inRect:CGRectZero];
        
        UIViewController *controller = ApplicationDelegate.window.rootViewController;
        
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:image location:nil urlResource:resourece presentedController:controller completion:^(UMSocialResponseEntity *response){
            //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [SVProgressHUD showSuccessWithStatus:@"报告主人，分享传送成功！" duration:2];
            }else{
                // Todo
                [SVProgressHUD showSuccessWithStatus:@"报告主人，分享传送失败！" duration:2];
            }
            
        }];
    }else{
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        [manager downloadImageWithURL:[NSURL URLWithString:model.sourcepath] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            UMSocialUrlResource *resourece = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:model.sourcepath];
            image = [image imageWithWaterMask:[UIImage imageNamed:@"watermark"] inRect:CGRectZero];
            
            UIViewController *controller = ApplicationDelegate.window.rootViewController;
            
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:types content:shareText image:image location:nil urlResource:resourece presentedController:controller completion:^(UMSocialResponseEntity *response){
                //            WSLog(@"分享状态：%@，返回数据：%@",response.message,response.data);
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                    [SVProgressHUD showSuccessWithStatus:@"报告主人，分享传送成功！" duration:2];
                }else{
                    // Todo
                    [SVProgressHUD showSuccessWithStatus:@"报告主人，分享传送失败！" duration:2];
                }
                
            }];
            
        }];
    }
}


-(void)postAddFocus:(UserInfo *)info{
    if(info){
        UserInfoDB *db=[[UserInfoDB alloc] init];
        [db saveUser:info];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_ADDFRIEND object:info];
}

-(void)postdelFocus:(UserInfo *)info{
    if(info){
        UserInfoDB *db=[[UserInfoDB alloc] init];
        [db saveUser:info];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DELADDFRIEND object:info];
}

-(void)postClearMessageRead{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CleanMESSAGE object:nil];
}


-(void)postSendNewMessage{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_SendMESSAGE object:nil];
}

@end
