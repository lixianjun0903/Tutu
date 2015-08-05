//
//  TopicCollectionViewCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-4-16.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "TopicCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation TopicCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}


-(void)dataToView:(TopicModel *)topicModel width:(CGFloat)collonWidth{
    [self.tagView setHidden:YES];
    if(topicModel){
        CGRect f=CGRectMake(0, 0, collonWidth, collonWidth);
        
        [self.imageView setFrame:f];
        if(topicModel.topicid==nil || [@"" isEqual:topicModel.topicid]){
            UIImage* image = [UIImage imageWithContentsOfFile:getDocumentsFilePath(topicModel.sourcepath)];
            [self.imageView setImage:image];
        }else{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:topicModel.smallcontent]];
        }
        [self.imageView setBackgroundColor:[UIColor whiteColor]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        self.imageView.layer.masksToBounds=YES;
        
        if(topicModel.type==5){
            [self.tagView setHidden:NO];
        }
    }
}

@end
