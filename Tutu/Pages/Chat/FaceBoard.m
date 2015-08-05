//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"


#define FACE_COUNT_ALL  81

#define FACE_COUNT_ROW  4

#define FACE_ICON_SIZE  44



@implementation FaceBoard

@synthesize delegate;


-(id)init:(CGFloat)width h:(CGFloat)height{
    self = [super initWithFrame:CGRectMake(0, height, width, FaceViewHeight)];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];

        _faceMap = [[NSDictionary dictionaryWithContentsOfFile:
                         [[NSBundle mainBundle] pathForResource:@"_expression_cn"
                                                         ofType:@"plist"]] retain];

        int FACE_COUNT_CLU=width/44;
        int FACE_COUNT_PAGE=FACE_COUNT_ROW * FACE_COUNT_CLU;
        //表情盘
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, 190)];
        faceView.pagingEnabled = YES;
        faceView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * width, 190);
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        faceView.delegate = self;
        
        for (int i = 1; i <= FACE_COUNT_ALL; i++) {
            NSString *face=[NSString stringWithFormat:@"face%03d", i];
            FaceButton *faceButton = [FaceButton buttonWithType:UIButtonTypeCustom];
            faceButton.buttonIndex = i;
            faceButton.faceTag=face;
            faceButton.faceString=[_faceMap objectForKey:face];
            
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + ((i - 1) / FACE_COUNT_PAGE * width);
            CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
            faceButton.frame = CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
            [faceButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
            [faceButton setImage:[UIImage imageNamed:face]
                        forState:UIControlStateNormal];

            [faceView addSubview:faceButton];
        }
        
        //添加PageControl
        facePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(width/2-50, 190, 100, 20)];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        facePageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        facePageControl.currentPageIndicatorTintColor=[UIColor darkGrayColor];
        facePageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        //添加键盘View
        [self addSubview:faceView];
        
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:TTLocalString(@"TT_delete") forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake((FACE_COUNT_CLU-1)*44+10, 182, 38, 28);
        [self addSubview:back];
    }

    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [facePageControl setCurrentPage:faceView.contentOffset.x / 320];
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {

    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * 320, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {

    FaceButton *btn = (FaceButton*)sender;
    
    if(self.delegate){
        [self.delegate onItemClick:btn.faceTag faceName:btn.faceString index:btn.buttonIndex];
    }
}

- (void)backFace{
    if(self.delegate){
        [self.delegate delItem];
    }
}

- (void)dealloc {
    
    [_faceMap release];
    [faceView release];
    [facePageControl release];
    
    [super dealloc];
}

@end
