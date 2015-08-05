//
//  UserInfoCell.m
//  Tutu
//
//  Created by zhangxinyao on 15-1-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserInfoCell.h"
#import "UIImageView+WebCache.h"

@implementation UserInfoCell{
    
    //间隔
    int xw;
    
    int w;
    
    //列宽
    int cw;
    
    NSMutableArray *list;
    int index;
    int row;
    
    UIImageView *iv1;
    UIImageView *iv2;
    UIImageView *iv3;

}

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        // 2、创建头像
        iv1 = [[UIImageView alloc] init];
        [iv1 setBackgroundColor:[UIColor whiteColor]];
        iv1.layer.masksToBounds=YES;
        iv1.userInteractionEnabled=YES;
        [iv1 setHidden:YES];
        iv1.tag=0;
        [self.contentView addSubview:iv1];
        
        
        
        iv2 = [[UIImageView alloc] init];
        [iv2 setBackgroundColor:[UIColor whiteColor]];
        iv2.layer.masksToBounds=YES;
        iv2.userInteractionEnabled=YES;
        [iv2 setHidden:YES];
        iv2.tag=1;
        [self.contentView addSubview:iv2];
        
        
        iv3 = [[UIImageView alloc] init];
        [iv3 setBackgroundColor:[UIColor whiteColor]];
        iv3.layer.masksToBounds=YES;
        iv3.userInteractionEnabled=YES;
        [iv3 setHidden:YES];
        iv3.tag=2;
        [self.contentView addSubview:iv3];
    }
    return self;
}

-(void)dataToView:(NSMutableArray *)arr column:(int)column row:(int)indexRow width:(int)tableWidth{
    row=indexRow;
    list=arr;
    
    w=tableWidth;
    self.backgroundColor=[UIColor clearColor];
    //间隔
    xw=5;
    
    //列宽
    cw=(w-(column+1)*xw)/column;
    
    [iv1 setImage:nil];
    [iv2 setImage:nil];
    [iv3 setImage:nil];
    [iv1 setBackgroundColor:[UIColor clearColor]];
    [iv2 setBackgroundColor:[UIColor clearColor]];
    [iv3 setBackgroundColor:[UIColor clearColor]];
    iv1.hidden=YES;
    iv2.hidden=YES;
    iv3.hidden=YES;
    
    
    UIGestureRecognizer *tap1=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    iv1.userInteractionEnabled=YES;
    [iv1 addGestureRecognizer:tap1];
    
    
    UIGestureRecognizer *tap2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    iv2.userInteractionEnabled=YES;
    [iv2 addGestureRecognizer:tap2];
    
    
    UIGestureRecognizer *tap3=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
    iv3.userInteractionEnabled=YES;
    [iv3 addGestureRecognizer:tap3];
    
    
    for (int i=0;i<arr.count;i++) {
        TopicModel *topicModel=[arr objectAtIndex:i];
        if(i==0){
            iv1.hidden=NO;
            [self setData:iv1 model:topicModel index:i];
        }else if(i==1){
            iv2.hidden=NO;
            [self setData:iv2 model:topicModel index:i];
        }else{
            iv3.hidden=NO;
            [self setData:iv3 model:topicModel index:i];
        }
    }
    
    [self setFrame:CGRectMake(0, 0, w, cw+xw)];
}

-(void)setData:(UIImageView *)imageView model:(TopicModel *) topicModel index:(int) i{
    CGRect f=CGRectMake(xw*(i+1)+cw*i, xw, cw, cw);
    
    [imageView setFrame:f];
    imageView.hidden=NO;
    if(topicModel.topicid==nil || [@"" isEqual:topicModel.topicid]){
        UIImage* image = [UIImage imageWithContentsOfFile:getDocumentsFilePath(topicModel.sourcepath)];
        [imageView setImage:image];
    }else{
        [imageView sd_setImageWithURL:[NSURL URLWithString:topicModel.smallcontent]];
    }
    [imageView setBackgroundColor:[UIColor whiteColor]];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    imageView.layer.masksToBounds=YES;
    
    int fx=cw-21;
    if(topicModel.type==5){
        UIImageView *tagView=[[UIImageView alloc] initWithFrame:CGRectMake(cw-21, 8, 16, 11.5)];
        [tagView setImage:[UIImage imageNamed:@"user_video_icon"]];
        tagView.tag=11;
        [imageView addSubview:tagView];
        
        fx=cw-21-20;
    }else{
        UIImageView *iv=(UIImageView *)[imageView viewWithTag:11];
        if(iv){
            [iv removeFromSuperview];
        }
    }
    
    if(topicModel.fromrepost){
        UIImageView *tagView=[[UIImageView alloc] initWithFrame:CGRectMake(fx, 7, 14.5, 12.5)];
        [tagView setImage:[UIImage imageNamed:@"userinfo_forward"]];
        tagView.tag=12;
        [imageView addSubview:tagView];
    }else{
        UIImageView *iv=(UIImageView *)[imageView viewWithTag:12];
        if(iv){
            [iv removeFromSuperview];
        }
    }
}

-(void)click:(UITapGestureRecognizer *)tap{
    int tag=(int)tap.view.tag;
    WSLog(@"点击的tag%d",tag);
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:index:)]){
        [self.delegate cellItemClick:[list objectAtIndex:tag] index:row*3+tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// cell 划出屏幕外了，可能被重用
-(void)prepareForReuse{
    [super prepareForReuse];
    
    // 清空所有数据
    [iv1 setImage:nil];
    [iv2 setImage:nil];
    [iv3 setImage:nil];
    [iv1 setBackgroundColor:[UIColor clearColor]];
    [iv2 setBackgroundColor:[UIColor clearColor]];
    [iv3 setBackgroundColor:[UIColor clearColor]];
    iv1.hidden=YES;
    iv2.hidden=YES;
    iv3.hidden=YES;
}
@end
