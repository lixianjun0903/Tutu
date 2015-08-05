//
//  PageScrollView.h
//  fnews.gui.iphone
//
//  Created by Yu Qiang on 10-10-23.
//  Copyright 2010 Thu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageScrollView : UIView <UIScrollViewDelegate> {
	
    UIScrollView *scrollView;
    UIPageControl *pageControl;
	
    CGRect _pageRegion, _controlRegion;
	
    NSArray *_pages;
    id _delegate;
}
-(void)layoutViews;
-(void) notifyPageChange;
-(CGRect) getPageRegion;

@property(nonatomic,retain, setter = setPages:, getter = getPages) NSArray * pages;
@property(nonatomic,assign, setter = setCurrentPage:, getter = getCurrentPage) int currentPage;
@property(nonatomic,retain, setter = setDelegate:, getter = getDelegate) id  delegate;

@end


@protocol PageScrollViewDelegate<NSObject>

@optional

-(void) pageScrollViewDidChangeCurrentPage:
			(PageScrollView *)pageScrollView currentPage:(int)currentPage;
@end