//
//  FaceBoard.h
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import <UIKit/UIKit.h>

#import "FaceButton.h"

#import "GrayPageControl.h"
#define FaceViewHeight 216


@protocol FaceBoardDelegate <NSObject>

@optional

-(void)onItemClick:(NSString *) faceTag faceName:(NSString *) name index:(int)itemId;

-(void)delItem;

@end


@interface FaceBoard : UIView<UIScrollViewDelegate>{

    UIScrollView *faceView;

    UIPageControl *facePageControl;

    NSDictionary *_faceMap;
}


@property (nonatomic, assign) id<FaceBoardDelegate> delegate;


-(id)init:(CGFloat) width h:(CGFloat) height;


@end
