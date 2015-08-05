//
//  MusicSelectController.m
//  Tutu
//
//  Created by zhangxinyao on 15/5/15.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "MusicSelectController.h"
#import "MusicTools.h"
#import <AVFoundation/AVFoundation.h>
#import "RCCaptureSessionManager.h"

#define TableCellIdentifier @"SystemMusicCell"

@interface MusicSelectController (){
    NSMutableArray *dataArray;
    UITableView *listTable;
    
    CGFloat w;
    NSIndexPath *selectIndex;
    BOOL isOpen;
    
    AVAudioPlayer *audioPlayer;
    NSTimer *audioTimer;
    NSTimeInterval startDuration;
}

@end

@implementation MusicSelectController


// 隐藏状态栏 for ios 7
- (BOOL)prefersStatusBarHidden{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    // for ios 6
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self stopAudio];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColorFromRGB(BackgroundRecordColor)];
    
    
    w=self.view.frame.size.width;
    dataArray=[[NSMutableArray alloc] init];
    isOpen=NO;
    self.videoDuration=50;
    
    [self createView];
}

//创建视图
-(void)createView{
    UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundColor:[UIColor clearColor]];
    backBtn.tag=BACK_BUTTON;
    [backBtn setFrame:CGRectMake(0, 0, 45, 45)];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(13, 16, 13, 16)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"backc_light"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *commitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [commitBtn setBackgroundColor:[UIColor clearColor]];
    commitBtn.tag=RIGHT_BUTTON;
    [commitBtn setFrame:CGRectMake(SCREEN_WIDTH-60, 0, 50,45)];
    [commitBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commitBtn setTitle:@"完成" forState:UIControlStateNormal];
    [commitBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [commitBtn setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
    [commitBtn.titleLabel setFont:TitleFont];
    [self.view addSubview:commitBtn];
    
    
    listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 45, self.view.mj_width, self.view.mj_height-45)];
    [self.view addSubview:listTable];
    listTable.delegate=self;
    listTable.dataSource=self;
    [listTable registerNib:[UINib nibWithNibName:TableCellIdentifier bundle:nil] forCellReuseIdentifier:TableCellIdentifier];
    [listTable setBackgroundColor:[UIColor whiteColor]];
    [listTable setSeparatorColor:UIColorFromRGB(ListLineColor)];
//    if([SysTools getSystemVerson] >= 7){
//        [listTable setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
//    }
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    
    dataArray=[[MusicTools getInstance] querySystemMusic];
    [listTable reloadData];
    
    [self checkDataNull];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SystemMusicCell *cell = (SystemMusicCell*)[tableView dequeueReusableCellWithIdentifier:TableCellIdentifier];
    if (cell == nil) {
        cell = [[SystemMusicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableCellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    SystemMusiceModel *model=[dataArray objectAtIndex:indexPath.row];
    if(selectIndex!=nil && isOpen && selectIndex.row==indexPath.row){
        [cell dataToView:model open:YES videoDuration:self.videoDuration tw:w];
    }else{
        [cell dataToView:model open:NO videoDuration:self.videoDuration tw:w];
    }
    cell.delegate=self;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self stopAudio];
    NSArray *indexPaths=[NSArray arrayWithObject:indexPath];
    if(selectIndex!=nil && selectIndex.row==indexPath.row){
        indexPaths=[NSArray arrayWithObjects:indexPath,selectIndex, nil];
        isOpen=!isOpen;
    }else if(selectIndex!=nil && selectIndex.row!=indexPath.row){
        indexPaths=[NSArray arrayWithObjects:selectIndex,indexPath, nil];
        
        isOpen=YES;
    }else if(selectIndex==nil){
        isOpen=YES;
    }
    selectIndex=indexPath;
    
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark table cell 代理事件
-(void)itemClick:(SystemMusiceModel *)model{
    
}

-(void)musicPlayer:(SystemMusiceModel *)model startDuration:(double)duration{
    startDuration=duration;
    if(audioPlayer!=nil && audioPlayer.isPlaying && [audioPlayer.url isEqual:model.url]){
        [self stopAudio];
        return;
    }
    
    if(audioPlayer!=nil && audioPlayer.playing){
        [self stopAudio];
    }
    
    
    NSError *error;
    audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:model.url
                                                      error:&error];
    [audioPlayer setCurrentTime:duration];
    
    [audioPlayer prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
    [audioPlayer play];//播放
    
    audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
}

-(void)stopAudio{
    if(audioTimer!=nil){
        [audioTimer invalidate];
    }
    if(audioPlayer!=nil){
        [audioPlayer stop];
        audioPlayer=nil;
    }
}


//动态显示时间
-(void)timerDiscount{
    if(audioPlayer==nil){
        [audioTimer invalidate];
        return;
    }
    double duration=audioPlayer.currentTime;
    if(selectIndex!=nil && audioPlayer.isPlaying){
        SystemMusicCell *cell=(SystemMusicCell*)[listTable cellForRowAtIndexPath:selectIndex];
        [cell updateProgress:duration-startDuration];
    }
    //大于60秒，停止录音
    if(duration>=(startDuration+self.videoDuration)){
        [self stopAudio];
    }
}
#pragma mark 本页点击事件
-(IBAction)buttonClick:(UIButton *)sender{
    if(sender.tag==BACK_BUTTON){
        [self goBack:nil];
    }
    
    if(sender.tag==RIGHT_BUTTON){
        if(selectIndex==nil){
            return;
        }
        SystemMusiceModel *model=[dataArray objectAtIndex:selectIndex.row];
        
        SystemMusicCell *cell=(SystemMusicCell *)[listTable cellForRowAtIndexPath:selectIndex];
        double starttime=[cell getCurDuration];
        
        [SVProgressHUD showSuccessWithStatus:@"音频截取中..."];
        NSString *exportPath=getDocumentsFilePath(@"cutTempAudio.m4a");
        
        //即使不需要切割，也需要运行，否则不能合并，因为系统文件不允许操作
        [[[RCCaptureSessionManager alloc] init] cutAudio:model.url export:exportPath start:starttime length:self.videoDuration succes:^(NSURL *fileURL, CGFloat duration, NSError *error) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(checkedMusic:)]){
                [self.delegate checkedMusic:exportPath];
                [self goBack:nil];
                [SVProgressHUD dismiss];
            }
        } fail:^(NSURL *fileURL, NSError *error) {
            
            [SVProgressHUD dismissWithError:@"音频截取发送错误！"];
        }];
        
//        [[[RCCaptureSessionManager alloc] init] videoToTempFile:model.url finish:^(NSString *filePath) {
//            
//        } fail:^(NSString *filePath, NSError *error) {
//            
//        }];
        
        
    }
}


#pragma mark 空数据UI展示
-(void)checkDataNull{
    if(dataArray==nil || dataArray.count==0){
        
        [self removePlaceholderView];
        self.placeholderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 195, 100)];
        self.placeholderView.center = CGPointMake(self.view.center.x, self.view.center.y-40);
        [listTable addSubview:self.placeholderView];
        
        UILabel *placeTitleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 195, 20)];
        [placeTitleLabel setText:@"未检测到本地音乐！"];
        [placeTitleLabel setTextColor:UIColorFromRGB(TextBlackColor)];
        [placeTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.placeholderView addSubview:placeTitleLabel];
        
        UILabel *placeDescLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 195, 30)];
        [placeDescLabel setText:@"你可以从iTunes Store下载音乐"];
        [placeDescLabel setFont:ListDetailFont];
        [placeDescLabel setTextColor:UIColorFromRGB(TextGrayColor)];
        [placeDescLabel setTextAlignment:NSTextAlignmentCenter];
        [self.placeholderView addSubview:placeDescLabel];
        
//        UIButton *placeButton=[UIButton buttonWithType:UIButtonTypeCustom];
//        [placeButton setFrame:CGRectMake(195/2-125/2, 50, 125, 36)];
//        placeButton.layer.cornerRadius=18;
//        placeButton.layer.borderColor=UIColorFromRGB(SystemColor).CGColor;
//        placeButton.layer.borderWidth=1.0f;
//        [placeButton setTitle:@"话题广场" forState:UIControlStateNormal];
//        [placeButton setTitleColor:UIColorFromRGB(SystemColor) forState:UIControlStateNormal];
//        [placeButton setTitleColor:UIColorFromRGB(SystemColorHigh) forState:UIControlStateHighlighted];
//        placeButton.tag=5;
//        [placeButton.titleLabel setFont:ListDetailFont];
//        [placeButton addTarget:self action:@selector(changePageClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.placeholderView addSubview:placeButton];
    }else{
        [self removePlaceholderView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
