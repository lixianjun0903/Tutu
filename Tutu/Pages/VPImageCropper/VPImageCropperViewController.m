//
//  VPImageCropperViewController.m
//  VPolor
//
//  Created by Vinson.D.Warm on 12/30/13.
//  Copyright (c) 2013 Huang Vinson. All rights reserved.



#import "VPImageCropperViewController.h"
#import "ReleasePicViewController.h"
#import "releaseCommentViewController.h"

#define SCALE_FRAME_Y 100.0f
#define BOUNDCE_DURATION 0.3f
#define MaxRatio 3.0f
#define MinRatio 1.0f
#define BottomMenu 50.0f

@interface VPImageCropperViewController ()

@property (nonatomic, retain) UIImage *originalImage;
@property (nonatomic, retain) UIImage *editedImage;

@property (nonatomic, retain) UIImageView *showImgView;
@property (nonatomic, retain) UIView *overlayView;
@property (nonatomic, retain) UIView *ratioView;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect largeFrame;


//@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation VPImageCropperViewController
{
    UIButton *_rotateButton;
    CGRect cropFrame;
    
    int w;
    int h;
    
    int imageW;
    int imageH;
    
    
    BOOL isRotated;
    
    BOOL allowRotate;
    //BOOL isGrayColor;
    BOOL isCropAll;
    
    //当前是可拖动状态，YES,可拖动
    BOOL isPan;
    
    //当前是否横屏
    BOOL isV;
    
    CGFloat currentScale;
    
    UIImageView *borderView;
}

- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.editedImage = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}

- (id)initWithImage:(UIImage *)originalImage{
    self = [super init];
    if (self) {
        self.originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    w=self.view.frame.size.width;
    h=self.view.frame.size.height;
    
    
    
    cropFrame = CGRectMake(0,(h-BottomMenu-w)/2, w, w);
    isCropAll=YES;
    isPan=YES;
    isV=NO;
    
    imageW=self.originalImage.size.width;
    imageH=self.originalImage.size.height;
    
    
    [self initView];
    
    [self initControlBtn];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

- (void)initView {
    //覆盖层
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:cropFrame];
    [bgView setBackgroundColor:[UIColor whiteColor]];
    bgView.tag=1;
    [self.view addSubview:bgView];
    
    
    
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    
    [self fitToScreen];
    
    [self addGestureRecognizers];
    
    [self.view addSubview:self.showImgView];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //覆盖层
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.alpha =0.7f;
    self.overlayView.backgroundColor =UIColorFromRGB(CoverRecordColor);
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    
    
    //裁剪框
    self.ratioView = [[UIView alloc] initWithFrame:cropFrame];
    self.ratioView.layer.borderColor = UIColorFromRGB(SystemColor).CGColor;
    self.ratioView.layer.borderWidth = 0.5f;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
    
    [self overlayClipping];
    
    borderView=[[UIImageView alloc]initWithFrame:cropFrame];
    borderView.image=[UIImage imageNamed:@"crop_border"];
    [self.view addSubview:borderView];
}

#pragma mark -初始化按钮
-(void)initControlBtn {
    
    UIView  *buttonView=[[UIView alloc]initWithFrame:CGRectMake(0, h-45,w,45)];
    buttonView.backgroundColor=UIColorFromRGB(BackgroundRecordColor);
    //    buttonView.alpha=0.6;
    [self.view addSubview:buttonView];
    UIButton *cancelBtn2 = [[UIButton alloc] initWithFrame:CGRectMake(15,0, 45, 45)];
    [cancelBtn2 setImageEdgeInsets:UIEdgeInsetsMake((45-19)/2, (45-19)/2, (45-19)/2, (45-19)/2)];
    //    cancelBtn2.backgroundColor = [UIColor blackColor];
    cancelBtn2.titleLabel.textColor = [UIColor whiteColor];
    
    [cancelBtn2 setImage:[UIImage imageNamed:@"record_close_nor"] forState:UIControlStateNormal];
    [cancelBtn2 setImage:[UIImage imageNamed:@"record_close"] forState:UIControlStateHighlighted];
    [cancelBtn2 addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:cancelBtn2];
    
    
    _rotateButton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 45)];
    _rotateButton.center=CGPointMake(w/2-25, 45/2);
    [_rotateButton setImageEdgeInsets:UIEdgeInsetsMake((45-23)/2, (45-26)/2, (45-23)/2, (45-26)/2)];
    [_rotateButton setImage:[UIImage imageNamed:@"rato_nor"] forState:UIControlStateNormal];
    [_rotateButton setImage:[UIImage imageNamed:@"rato"] forState:UIControlStateSelected];
    _rotateButton.tag=101;
    
    [_rotateButton addTarget:self action:@selector(rotated:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:_rotateButton];
    
    UIButton *showAllButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0, 45, 45)];
    showAllButton.center=CGPointMake(w/2+25, 45/2);
    [showAllButton setImageEdgeInsets:UIEdgeInsetsMake((45-22)/2, (45-22)/2, (45-22)/2, (45-22)/2)];
    [showAllButton setImage:[UIImage imageNamed:@"crop_screen_nor"] forState:UIControlStateNormal];
    showAllButton.tag=100;
    [showAllButton addTarget:self action:@selector(showAll:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:showAllButton];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(w-60,0, 45, 45)];
    [confirmBtn setImageEdgeInsets:UIEdgeInsetsMake((45-17)/2, (45-24)/2, (45-17)/2, (45-24)/2)];
    [confirmBtn setImage:[UIImage imageNamed:@"crop_comfirm_nor"] forState:UIControlStateNormal];
    [confirmBtn setImage:[UIImage imageNamed:@"crop_comfirm"] forState:UIControlStateHighlighted];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:confirmBtn];
}

#pragma mark 屏幕适配


-(void)fitToScreen
{
    isPan=YES;
    float iw=self.originalImage.size.width;
    float ih=self.originalImage.size.height;
    if(isV){
        iw=self.originalImage.size.height;
        ih=self.originalImage.size.width;
    }
    
    // scale to fit the screen大小适配屏幕
    CGFloat aspect=ih/iw;
    if (aspect>1.0f) {
        CGFloat oriHeight = ih* (w / iw);
        CGFloat oriX = 0;
        CGFloat oriY = 0;
        if(oriHeight>(cropFrame.size.height+cropFrame.origin.y)){
            oriY=0;
        }else{
            oriY=cropFrame.size.height+cropFrame.origin.y-oriHeight;
        }
        self.oldFrame = CGRectMake(oriX, oriY, w, oriHeight);
        [self.showImgView setFrame:self.oldFrame];
    }
    else
    {
        CGFloat oriHeight = w;
        CGFloat oriWidth = iw* w / ih;
        CGFloat oriX = 0;
        CGFloat oriY = cropFrame.origin.y + (cropFrame.size.height - oriHeight) / 2;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        [self.showImgView setFrame:self.oldFrame];
    }
//    self.largeFrame = CGRectMake(0, 0, MaxRatio * self.oldFrame.size.width, MaxRatio * self.oldFrame.size.height);
    
}

//拉伸还原
-(void)fitToScreenWithPan
{
    float iw=imageW;
    float ih=imageH;
    if(isV){
        iw=imageH;
        ih=imageW;
    }
    
    // scale to fit the screen大小适配屏幕
    CGFloat aspect=ih/iw;
    if (aspect>1.0f) {
        CGFloat oriHeight = ih* (w / iw);
        CGFloat oriX = 0.0f;
        CGFloat oriY = 0.0f;
        if(oriHeight>(cropFrame.size.height+cropFrame.origin.y)){
            oriY=0.0f;
        }else{
            oriY=cropFrame.size.height+cropFrame.origin.y-oriHeight;
        }
        self.oldFrame = CGRectMake(oriX, oriY, w, oriHeight);
        [self.showImgView setFrame:self.oldFrame];
    }
    else
    {
        CGFloat oriWidth = iw* w / ih;
        CGFloat oriX = 0;
        CGFloat oriY = cropFrame.origin.y + (cropFrame.size.height - w) / 2;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, w);
        [self.showImgView setFrame:self.oldFrame];
    }
//    self.largeFrame = CGRectMake(0, 0, MaxRatio * self.oldFrame.size.width, MaxRatio * self.oldFrame.size.height);
    
}



-(void)showImageAll
{
    isPan=NO;
    float iw=self.originalImage.size.width;
    float ih=self.originalImage.size.height;
    if(isV){
        iw=self.originalImage.size.height;
        ih=self.originalImage.size.width;
    }
    
    CGFloat aspect=ih/iw;
    
    if (aspect>1.0f) {
        isCropAll=YES;
        CGFloat oriHeight = cropFrame.size.height;
        CGFloat oriWidth = w * iw / ih;
        CGFloat oriX = (w - oriWidth) / 2;
        CGFloat oriY = cropFrame.origin.y;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        
        self.showImgView.frame = self.oldFrame;
        
        
    }
    else
    {
        CGFloat oriWidth=w;
        CGFloat oriHeight = w * ih / iw;
        CGFloat oriX = 0;
        CGFloat oriY = cropFrame.origin.y + (w - oriHeight) / 2;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        self.showImgView.frame = self.oldFrame;
    }
    
    
    self.largeFrame = CGRectMake(0, 0, MaxRatio * self.oldFrame.size.width, MaxRatio * self.oldFrame.size.height);
}


//缩放还原
-(void)showImageAllWithPan{
    float iw=imageW;
    float ih=imageH;
    if(isV){
        iw=imageH;
        ih=imageW;
    }
    
    CGFloat aspect=ih/iw;
    
    if (aspect>1.0f) {
        CGFloat oriHeight = cropFrame.size.height;
        CGFloat oriWidth = w * iw / ih;
        CGFloat oriX = (w - oriWidth) / 2;
        CGFloat oriY = cropFrame.origin.y;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        
        self.showImgView.frame = self.oldFrame;
    }
    else
    {
        CGFloat oriWidth=w;
        CGFloat oriHeight = w * ih / iw;
        CGFloat oriX = 0;
        CGFloat oriY = cropFrame.origin.y + (1.0f)*(w - oriHeight) / 2;
        self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
        self.showImgView.frame = self.oldFrame;
    }
    
}


#pragma mark 按钮点击函数
- (void)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm:(id)sender {
//    [self cropAll];
    
    releaseCommentViewController *rc=[[releaseCommentViewController alloc]init];
    rc.passUserImage=[self cropAll];
    rc.pageType=PhotoType;
    [self.navigationController pushViewController:rc  animated:YES];

}
- (void)showAll:(id)sender {
    UIButton *btn=(UIButton *)sender;
    if(isPan){
        
        [btn setImage:[UIImage imageNamed:@"crop_party_nor"] forState:UIControlStateNormal];
        [self showImageAll];
    }else{
        [btn setImage:[UIImage imageNamed:@"crop_screen_nor"] forState:UIControlStateNormal];
        [self fitToScreen];
    }
}
- (void)rotated:(id)sender {
    [self rotation];
}
-(void)rotation
{
    isV=!isV;
    
    CGFloat x=self.showImgView.bounds.size.width/2;
    CGFloat y=self.showImgView.bounds.size.height/2;
    
    CGPoint rotationCenter=CGPointMake(x,y);
    CGFloat deltaX = rotationCenter.x-self.showImgView.bounds.size.width/2;
    CGFloat deltaY = rotationCenter.y-self.showImgView.bounds.size.height/2;
    CGAffineTransform transform =  CGAffineTransformTranslate(self.showImgView.transform,deltaX,deltaY);
    transform = CGAffineTransformRotate(transform, M_PI_2);
    transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);
    self.showImgView.transform = transform;
    
    UIView *view = self.showImgView;
    
    view.transform =transform;
    
    
    if(isPan){
        [self fitToScreen];
    }else{
        [self showImageAll];
    }
}
#pragma mark-裁剪全图
- (UIImage *)clipImage:(UIImage *)image imageoritation:(UIImageOrientation)oritation withRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *clipImage = [UIImage imageWithCGImage:imageRef scale:image.scale orientation:oritation];//UIImageOrientationLeft
    CGImageRelease(imageRef);
    return clipImage;
}

#pragma mark -旋转时控制截图方向
-(UIImage *)cropAll
{
    UIImage *image=self.originalImage;
    
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    int minWidth=rect_screen.size.width*scale_screen;
    
    if(image){
        image = [SysTools scaleToSize:image size:CGSizeMake(minWidth, image.size.height*minWidth/image.size.width)];
        
    }
    
    CGFloat imageScale=self.showImgView.frame.size.width/cropFrame.size.width;
    image=[SysTools scaleToSize:image size:CGSizeMake(image.size.width*imageScale, image.size.height*imageScale)];
    

    CGFloat scale=minWidth/w;
    
    int cropy=(cropFrame.origin.y-self.showImgView.frame.origin.y)*scale;
    int cropx=(cropFrame.origin.x-self.showImgView.frame.origin.x)*scale;
    
    CGRect cf=CGRectMake(cropx, cropy, minWidth, minWidth);
    
    
    return [self clipImage:image imageoritation:image.imageOrientation withRect:cf];
}



//遮盖层
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}



// 添加所有手势
- (void) addGestureRecognizers
{
    
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// 捏合手势处理
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
//    WSLog(@"缩放");
    if (isPan) {
        UIView *view = self.showImgView;
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
            pinchGestureRecognizer.scale =1;
            
        }
        else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            pinchGestureRecognizer.scale =1;
//            WSLog(@"缩放比例：%f",[self calculatorScale]);
            
            //缩放比例的限制
            if([self calculatorScale]<MinRatio){
                [self showImageAllWithPan];

                // To do 不重新设置，第一次不居中
                [self.showImgView setFrame:self.oldFrame];
            }
            if([self calculatorScale]>MaxRatio){
                [self fitToScreenWithPan];

                
                // To do 不重新设置，第一次不居中
                [self.showImgView setFrame:self.oldFrame];
            }
        }
    }
}

//计算缩放比例
-(CGFloat)calculatorScale
{
//    WSLog(@"%@",NSStringFromCGRect(self.showImgView.frame));
    if (!isV) {
        return    currentScale = self.showImgView.frame.size.height/w;
    }
    
    else     //横屏状态下的比例
    {
        return   currentScale = self.showImgView.frame.size.width/w;
        
    }
}
// 拖动
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    WSLog(@"拖动");
    if (isPan) {
        UIView *view = self.showImgView;
        if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            // 加速   计算
            CGFloat absCenterX = cropFrame.origin.x + cropFrame.size.width / 2;
            CGFloat absCenterY = cropFrame.origin.y + cropFrame.size.height / 2;
            CGFloat scaleRatio = self.showImgView.frame.size.width / cropFrame.size.width;
            CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
            CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
            CGPoint translation = [panGestureRecognizer translationInView:view.superview];
            [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
            [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
        }
        else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            // 回弹到起始frame
            CGRect newFrame = self.showImgView.frame;
            newFrame = [self handleBorderOverflow:newFrame];
            [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
                self.showImgView.frame = newFrame;
                //                self.latestFrame = newFrame;
            }];
        }
        //        NSLog(@"lastFrame%f,%f,%f,%f",self.latestFrame.origin.x,self.latestFrame.origin.y,self.latestFrame.size.width,self.latestFrame.size.height);
        //        NSLog(@"------cropFrame%f,%f,%f,%f",cropFrame.origin.x,cropFrame.origin.y,cropFrame.size.width,cropFrame.size.height);
    }else
    {
        NSLog(@"不可拖动");
    }
    
}


//设置不超出裁剪边框
- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    
    // horizontally
    if (newFrame.origin.x > cropFrame.origin.x) newFrame.origin.x = cropFrame.origin.x;
    
    if (CGRectGetMaxX(newFrame) < cropFrame.size.width){
        //在水平方向裁剪框出现的情况下， 宽度大于裁剪框
        if (self.showImgView.frame.size.width>cropFrame.size.width) {
            newFrame.origin.x = cropFrame.size.width - newFrame.size.width;
        }
        
        else
        {
            //设置在中间
            newFrame.origin.x=(w-self.showImgView.frame.size.width)/2;
            
        }
    }
    
    if (newFrame.origin.y > cropFrame.origin.y) newFrame.origin.y = cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < cropFrame.origin.y + cropFrame.size.height) {
        newFrame.origin.y = cropFrame.origin.y + cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= cropFrame.size.height) {
        newFrame.origin.y = cropFrame.origin.y + (cropFrame.size.height - newFrame.size.height) / 2;
    }
    
    if(self.showImgView.frame.size.width<=cropFrame.size.width && self.showImgView.frame.size.height<=cropFrame.size.height){
        newFrame.origin.y=cropFrame.origin.y+(cropFrame.size.height-self.showImgView.frame.size.height)/2;
        newFrame.origin.x=(w-self.showImgView.frame.size.width)/2;
    }
    
    return newFrame;
}



- (UIImage *)takeScreenshot {
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    //    CGSize imageSize = [self bounds].size;// [[UIScreen mainScreen] bounds].size;
    borderView.hidden=YES;
    
    if(!iOS7){
        self.overlayView.hidden=YES;
    }
    
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    //    if (NULL != UIGraphicsBeginImageContextWithOptions)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    //    else
    //        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width *[[window layer] anchorPoint].x,
                                  -[window bounds].size.height *[[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    borderView.hidden=NO;
    return image;
}


@end
