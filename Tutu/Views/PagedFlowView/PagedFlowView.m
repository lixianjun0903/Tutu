//
//  PagedFlowView.m
//  taobao4iphone
//
//  Created by Lu Kejin on 3/2/12.
//  Copyright (c) 2012 geeklu.com. All rights reserved.
//

#import "PagedFlowView.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabel+Additions.h"
#define  CommentCountWidth   0.0
#import "UIImage+GIF.h"

#define OriginX      100 * (ScreenWidth / 320.0)
#define LeftLoadViewX  65 * (ScreenWidth / 320.0)
@interface PagedFlowView ()
@property (nonatomic, assign, readwrite) NSInteger currentPageIndex;
@end

@implementation PagedFlowView
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize pageControl;
@synthesize minimumPageAlpha = _minimumPageAlpha;
@synthesize minimumPageScale = _minimumPageScale;
@synthesize orientation;
@synthesize currentPageIndex = _currentPageIndex;

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

//为了实现，头像的pagedingEnable效果，实际过程中，_scrollView的宽，是单个头像的宽度，而不是屏幕的宽度，
//因此_scrollView上的头像，除中间一个，其他的是不可点击的，所以，需要更加点击屏幕的位置来计算，需要点击的那个头像
-(void)handleTapGesture:(UIGestureRecognizer*)gestureRecognizer{
    NSInteger tappedIndex = 0;
    CGPoint locationInScrollView = [gestureRecognizer locationInView:self];
    CGFloat leftX = (self.mj_width - 50) / 2.0;
    CGFloat rightX = (self.mj_width + 50) / 2.0;
  // (CGRectContainsPoint(_scrollView.bounds, locationInScrollView))
    //当点击的是中间选中的头像时
    if (locationInScrollView.x >= leftX && locationInScrollView.x <= rightX) {
         tappedIndex = _currentPageIndex;
        if ([_delegate respondsToSelector:@selector(flowView:didTapSelectedPageAtIndex:)]) {
            [_delegate flowView:self didTapSelectedPageAtIndex:tappedIndex];
        }
    }else{
//        //当点击的是选择头像的左侧位置，
        if (locationInScrollView.x < _scrollView.mj_x) {
            WSLog(@"--%f",locationInScrollView.x);
            NSInteger count = ((NSInteger)(self.mj_width / 2.0 - locationInScrollView.x)) / 50;
            NSInteger count2 = count + 1;
           
            CGRect rect = CGRectMake(self.mj_width / 2.0 - 50 * count - 20, _scrollView.mj_y, 40, 40);
          // CGRect rect2 = CGRectMake(self.mj_width / 2.0 + 50 * count2 - 25, _scrollView.mj_y, 40, 40);
            
            if (CGRectContainsPoint(rect, locationInScrollView)) {
                tappedIndex = _currentPageIndex - count;
            }else{
                tappedIndex = _currentPageIndex - count2;
            }
            
            
            if (_delegate && [self.delegate respondsToSelector:@selector(flowView:didTapDisSelectedPageAtIndex:)]) {
                [_delegate flowView:self didTapDisSelectedPageAtIndex:tappedIndex];
            }
 
        }
        //点击的是当前选择头像的右侧的位置
        if (locationInScrollView.x > _scrollView.max_x) {
            NSInteger count = ((NSInteger)(locationInScrollView.x - self.mj_width / 2.0)) / 50;
            NSInteger count2 = count + 1;
            
            CGRect rect = CGRectMake(self.mj_width / 2.0 + 50 * count - 20, _scrollView.mj_y, 40, 40);
            // CGRect rect2 = CGRectMake(self.mj_width / 2.0 + 50 * count2 - 25, _scrollView.mj_y, 40, 40);
            
            if (CGRectContainsPoint(rect, locationInScrollView)) {
                tappedIndex = _currentPageIndex + count;
            }else{
                tappedIndex = _currentPageIndex + count2;
            }
            
            if (_delegate && [self.delegate respondsToSelector:@selector(flowView:didTapDisSelectedPageAtIndex:)]) {
                [_delegate flowView:self didTapDisSelectedPageAtIndex:tappedIndex];
            }
 
        }
       
    }
}

- (void)initialize{
    self.clipsToBounds = YES;
    
    _needsReload = YES;
    _pageSize = self.bounds.size;
    _pageCount = 0;
    _currentPageIndex = 0;
    
    _minimumPageAlpha = 1.0;
    _minimumPageScale = 1.0;
    
    _visibleRange = NSMakeRange(0, 0);
    
    _reusableCells = [[NSMutableArray alloc] initWithCapacity:0];
    _cells = [[NSMutableArray alloc] initWithCapacity:0];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 10, self.mj_width, self.mj_height - 10)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    
    

    
    
    /*由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews
    这里为了避免scrollview滚动带来自己layoutSubviews的调用,所以给scrollView加了一层父View
     */
    UIView *superViewOfScrollView = [[UIView alloc] initWithFrame:self.bounds];
    [superViewOfScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [superViewOfScrollView setBackgroundColor:[UIColor clearColor]];
    [superViewOfScrollView addSubview:_scrollView];
    [self addSubview:superViewOfScrollView];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapRecognizer];
    self.backgroundColor = [UIColor clearColor];
    
   //创建评论数View,上面有两个View，_commentImageV放评论图标，_commentLabel放评论数。
    _commentView = [[UIView alloc]initWithFrame:CGRectMake(0, 5,28, self.mj_height - 10)];
    _commentView.backgroundColor = [UIColor clearColor];
    [superViewOfScrollView addSubview:_commentView];
    
    _commentImageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"homePage_comment_count"]];
    _commentImageV.frame = CGRectMake(5, 15, 18, 19);
    
    [_commentView addSubview:_commentImageV];
   
    _commentView.frame = CGRectMake(OriginX - _scrollView.contentOffset.x, 10, self.mj_height, self.mj_height);
    
    _commentLabel = [UILabel labelWithSystemFont:11 textColor:HEXCOLOR(SystemColor)];
    
    _commentLabel.frame = CGRectMake(0,_commentImageV.max_y + 4, 28, 12);
    _commentLabel.textAlignment = NSTextAlignmentCenter;
    
    [_commentView addSubview:_commentLabel];
    
    //创建两个loading图，左边一个用来加载前面的评论，右边一个用来加载后面的评论。
    
    _rightLoadingView = [[UIImageView alloc]init];
    _rightLoadingView.image = [UIImage sd_animatedGIFNamed:@"comment_loading"];
    _rightLoadingView.frame = CGRectMake(LeftLoadViewX - _scrollView.contentOffset.x + 88 + _scrollView.contentSize.width, self.mj_height - 35, 28, 10);
    [_rightLoadingView setHidden:YES];
    [self addSubview:_rightLoadingView];
    
    _leftLoadingView = [[UIImageView alloc]init];
    _leftLoadingView.image = [UIImage sd_animatedGIFNamed:@"comment_loading"];
    _leftLoadingView.frame = CGRectMake(LeftLoadViewX - _scrollView.contentOffset.x, self.mj_height - 35, 28, 10);
    [_leftLoadingView setHidden:YES];
    [self addSubview:_leftLoadingView];

    
}
//_leftLoadingView.frame = CGRectMake(LeftLoadViewX - _scrollView.contentOffset.x, _leftLoadingView.mj_y, _leftLoadingView.mj_width, _leftLoadingView.mj_height);
//_rightLoadingView.frame = CGRectMake(_leftLoadingView.max_x + _scrollView.contentSize.width + 60, _rightLoadingView.mj_y, _rightLoadingView.mj_width, _rightLoadingView.mj_height);
- (void)showRightLoadingView{
    _rightLoadingView.frame = CGRectMake(LeftLoadViewX - _scrollView.contentOffset.x + 88 + _scrollView.contentSize.width, self.mj_height - 35, 28, 10);
    [_rightLoadingView setHidden:NO];
}
- (void)hidenRightLoadingView{
    [_rightLoadingView setHidden:YES];
}
- (void)showLeftLoadingView{
    _leftLoadingView.frame = CGRectMake(LeftLoadViewX - _scrollView.contentOffset.x, self.mj_height - 35, 28, 10);
    [_leftLoadingView setHidden:NO];
}
- (void)hidenLeftLoadingView{
    [_leftLoadingView setHidden:YES];
}
- (void)dealloc{
    _scrollView.delegate = nil;
}

- (void)queueReusableCell:(UIView *)cell{
    [_reusableCells addObject:cell];
}

- (void)removeCellAtIndex:(NSInteger)index{
    UIView *cell = [_cells objectAtIndex:index];
    if ((NSObject *)cell == [NSNull null]) {
        return;
    }
    
    [self queueReusableCell:cell];
    
    if (cell.superview) {
        cell.layer.transform = CATransform3DIdentity;
        [cell removeFromSuperview];
    }
    
    [_cells replaceObjectAtIndex:index withObject:[NSNull null]];
}

- (void)refreshVisibleCellAppearance{
    
    if (_minimumPageAlpha == 1.0 && _minimumPageScale == 1.0) {
        return;//无需更新
    }
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:{
            CGFloat offset = _scrollView.contentOffset.x;
            
            for (int i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {

                UIView *cell = [_cells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.x;
                CGFloat delta = fabs(origin - offset);
                if (![cell isKindOfClass:[NSNull class]]) {
                    UIImageView *bgImageView = (UIImageView *)[cell viewWithTag:200];
                    [bgImageView setHidden:YES];
                }
                [UIView beginAnimations:@"CellAnimation" context:nil];
                if (delta < _pageSize.width) {
                    //当处于被选中状态，把它前面背景剪头隐藏，让它的背景显示，
                    if (_cells.count > i - 1) {
                        UIView *cell1 = [_cells objectAtIndex:i - 1];
                        if (![cell1 isKindOfClass:[NSNull class]]) {
                            UIImageView *bgImageView1 = (UIImageView *)[cell1 viewWithTag:200];
                            [bgImageView1 setHidden:YES];

                        }
                    }
                    cell.alpha = 1 - (delta / _pageSize.width) * (1 - _minimumPageAlpha);
                    CGFloat pageScale = 1 - (delta / _pageSize.width) * (1 - _minimumPageScale);
                    cell.layer.transform = CATransform3DMakeScale(pageScale, pageScale, 1);
                    if (![cell isKindOfClass:[NSNull class]]) {
                        UIImageView *bgImageView = (UIImageView *)[cell viewWithTag:200];
                        [bgImageView setHidden:NO];
                    }
                    
                } else {
                    cell.alpha = _minimumPageAlpha;
                    cell.layer.transform = CATransform3DMakeScale(_minimumPageScale, _minimumPageScale, 1);
                }

                [UIView commitAnimations];
            }
            break;   
        }
        case PagedFlowViewOrientationVertical:{
            CGFloat offset = _scrollView.contentOffset.y;
            
            for (int i = _visibleRange.location; i < _visibleRange.location + _visibleRange.length; i++) {
                UIView *cell = [_cells objectAtIndex:i];
                CGFloat origin = cell.frame.origin.y;
                CGFloat delta = fabs(origin - offset);
                                
                [UIView beginAnimations:@"CellAnimation" context:nil];
                if (delta < _pageSize.height) {
                    cell.alpha = 1 - (delta / _pageSize.height) * (1 - _minimumPageAlpha);
                    
                    CGFloat pageScale = 1 - (delta / _pageSize.height) * (1 - _minimumPageScale);
                    cell.layer.transform = CATransform3DMakeScale(pageScale, pageScale, 1);
                } else {
                    cell.alpha = _minimumPageAlpha;
                    cell.layer.transform = CATransform3DMakeScale(_minimumPageScale, _minimumPageScale, 1);
                }
                [UIView commitAnimations];
            }
        }
        default:
            break;
    }

}

- (void)setPageAtIndex:(NSInteger)pageIndex{
    NSParameterAssert(pageIndex >= 0 && pageIndex < [_cells count]);
    
    UIView *cell = [_cells objectAtIndex:pageIndex];
    
    if ((NSObject *)cell == [NSNull null]) {
        cell = [_dataSource flowView:self cellForPageAtIndex:pageIndex];
        NSAssert(cell!=nil, @"datasource must not return nil");
        [_cells replaceObjectAtIndex:pageIndex withObject:cell];
        
        
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal:
                cell.frame = CGRectMake(_pageSize.width * pageIndex + CommentCountWidth, 0, _pageSize.width, _pageSize.height);
                break;
            case PagedFlowViewOrientationVertical:
                cell.frame = CGRectMake(0, _pageSize.height * pageIndex, _pageSize.width, _pageSize.height);
                break;
            default:
                break;
        }
        
        if (!cell.superview) {
            [_scrollView addSubview:cell];
        }
    }
}


- (void)setPagesAtContentOffset:(CGPoint)offset{
    if ([_cells count] == 0)
        return;
    //计算_visibleRange
    CGPoint startPoint = CGPointMake(offset.x - _scrollView.frame.origin.x, offset.y - _scrollView.frame.origin.y);
    CGPoint endPoint = CGPointMake(MAX(0, startPoint.x) + self.bounds.size.width, MAX(0, startPoint.y) + self.bounds.size.height);
    
    
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:{
            NSInteger startIndex = 0;
            for (int i =0; i < [_cells count]; i++) {
                if (_pageSize.width * (i +1) > startPoint.x) {
                    startIndex = i;
                    break;
                }
            }
            
            NSInteger endIndex = startIndex;
            for (int i = startIndex; i < [_cells count]; i++) {
                //如果都不超过则取最后一个
                if ((_pageSize.width * (i + 1) < endPoint.x && _pageSize.width * (i + 2) >= endPoint.x) || i+ 2 == [_cells count]) {
                    endIndex = i + 1;//i+2 是以个数，所以其index需要减去1
                    break;
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, [_cells count] - 1);
            
            if (_visibleRange.location == startIndex && _visibleRange.length == (endIndex - startIndex + 1)) {
                return;
            }
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            for (int i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (int i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (int i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        case PagedFlowViewOrientationVertical:{
            NSInteger startIndex = 0;
            for (int i =0; i < [_cells count]; i++) {
                if (_pageSize.height * (i +1) > startPoint.y) {
                    startIndex = i;
                    break;
                }
            }
            
            NSInteger endIndex = startIndex;
            for (int i = startIndex; i < [_cells count]; i++) {
                //如果都不超过则取最后一个
                if ((_pageSize.height * (i + 1) < endPoint.y && _pageSize.height * (i + 2) >= endPoint.y) || i+ 2 == [_cells count]) {
                    endIndex = i + 1;//i+2 是以个数，所以其index需要减去1
                    break;
                }
            }
            
            //可见页分别向前向后扩展一个，提高效率
            startIndex = MAX(startIndex - 1, 0);
            endIndex = MIN(endIndex + 1, [_cells count] - 1);
            
            if (_visibleRange.location == startIndex && _visibleRange.length == (endIndex - startIndex + 1)) {
                return;
            }
            
            _visibleRange.location = startIndex;
            _visibleRange.length = endIndex - startIndex + 1;
            
            for (int i = startIndex; i <= endIndex; i++) {
                [self setPageAtIndex:i];
            }
            
            for (int i = 0; i < startIndex; i ++) {
                [self removeCellAtIndex:i];
            }
            
            for (int i = endIndex + 1; i < [_cells count]; i ++) {
                [self removeCellAtIndex:i];
            }
            break;
        }
        default:
            break;
    }
    
    
    
}




////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Override Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (_needsReload) {
        //如果需要重新加载数据，则需要清空相关数据全部重新加载
        
        
        //重置pageCount
        if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInFlowView:)]) {
            _pageCount = [_dataSource numberOfPagesInFlowView:self];
            
            if (pageControl && [pageControl respondsToSelector:@selector(setNumberOfPages:)]) {
                [pageControl setNumberOfPages:_pageCount];
            }
        }
        
        //重置pageWidth
        if (_delegate && [_delegate respondsToSelector:@selector(sizeForPageInFlowView:)]) {
            _pageSize = [_delegate sizeForPageInFlowView:self];
        }
        
        [_reusableCells removeAllObjects];
        _visibleRange = NSMakeRange(0, 0);
        
        //从supperView上移除cell
        for (NSInteger i=0; i<[_cells count]; i++) {
            [self removeCellAtIndex:i];
        }
        
        //填充cells数组
        [_cells removeAllObjects];
        for (NSInteger index=0; index<_pageCount; index++)
        {
            [_cells addObject:[NSNull null]];
        }
        
        // 重置_scrollView的contentSize
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal://横向
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width * _pageCount + CommentCountWidth,_pageSize.height);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                break;
            case PagedFlowViewOrientationVertical:{
                _scrollView.frame = CGRectMake(0, 0, _pageSize.width, _pageSize.height);
                _scrollView.contentSize = CGSizeMake(_pageSize.width ,_pageSize.height * _pageCount);
                CGPoint theCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                _scrollView.center = theCenter;
                break;
            }
            default:
                break;
        }
    }
    

    [self setPagesAtContentOffset:_scrollView.contentOffset];//根据当前scrollView的offset设置cell
    
    [self refreshVisibleCellAppearance];//更新各个可见Cell的显示外貌
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView API

- (void)reloadData
{
    _needsReload = YES;
    
    [self setNeedsLayout];
    
}


- (UIView *)dequeueReusableCell{
    UIView *cell = [_reusableCells lastObject];
    if (cell)
    {
        [_reusableCells removeLastObject];
    }
    
    return cell;
}

- (void)scrollToPage:(NSUInteger)pageNumber {
    
    if (pageNumber < _pageCount) {
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal:
                [_scrollView setContentOffset:CGPointMake(_pageSize.width * pageNumber + CommentCountWidth, 0) animated:YES];
                break;
            case PagedFlowViewOrientationVertical:
                [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * pageNumber) animated:YES];
                break;
        }
        [self setPagesAtContentOffset:_scrollView.contentOffset];
        [self refreshVisibleCellAppearance];

        _currentPageIndex = pageNumber;
        
        [self bk_performBlock:^(id obj) {
        [self getCurrentPageIndex:_currentPageIndex];
        } afterDelay:0.5];
        
    }
}
- (void)scrollToPageNoAnimation:(NSUInteger)pageNumber{
    
    if (pageNumber < _pageCount) {
        switch (orientation) {
            case PagedFlowViewOrientationHorizontal:
                [_scrollView setContentOffset:CGPointMake(_pageSize.width * pageNumber + CommentCountWidth, 0) animated:NO];
                break;
            case PagedFlowViewOrientationVertical:
                [_scrollView setContentOffset:CGPointMake(0, _pageSize.height * pageNumber) animated:NO];
                break;
        }
        [self setPagesAtContentOffset:_scrollView.contentOffset];
        [self refreshVisibleCellAppearance];
        _currentPageIndex = pageNumber;
    }
      [self getCurrentPageIndex:pageNumber];
}
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = CGPointZero;
        newPoint.x = point.x - _scrollView.frame.origin.x + _scrollView.contentOffset.x;
        newPoint.y = point.y - _scrollView.frame.origin.y + _scrollView.contentOffset.y;
        if ([_scrollView pointInside:newPoint withEvent:event]) {
            return [_scrollView hitTest:newPoint withEvent:event];
        }
        
        return _scrollView;
    }
    
    return nil;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self setPagesAtContentOffset:scrollView.contentOffset];
    [self refreshVisibleCellAppearance];
    _commentView.frame = CGRectMake( OriginX - _scrollView.contentOffset.x, _commentView.mj_y, self.mj_height, self.mj_height);

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[NSNotificationCenter defaultCenter]postNotificationName:Comment_Scroll_BeginDragging object:nil];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //如果有PageControl，计算出当前页码，并对pageControl进行更新
    
    NSInteger pageIndex;
    
    switch (orientation) {
        case PagedFlowViewOrientationHorizontal:
            pageIndex = floor(_scrollView.contentOffset.x / _pageSize.width);
            break;
        case PagedFlowViewOrientationVertical:
            pageIndex = floor(_scrollView.contentOffset.y / _pageSize.height);
            break;
        default:
            break;
    }
    
    if (pageControl && [pageControl respondsToSelector:@selector(setCurrentPage:)]) {
        [pageControl setCurrentPage:pageIndex];
    }
    
    if ([_delegate respondsToSelector:@selector(flowView:didScrollToPageAtIndex:)] && _currentPageIndex != pageIndex) {
        [_delegate flowView:self didScrollToPageAtIndex:pageIndex];
        [self getCurrentPageIndex:pageIndex];
    }
    
    _currentPageIndex = pageIndex;
}
- (void)getCurrentPageIndex:(NSInteger)index{

    if (index == _cells.count - 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(beginLoadMoreComment)]) {
            [_delegate beginLoadMoreComment];
            
        }
        
    }
    if (index == 0 && _cells.count != 1) {
        if (_delegate && [_delegate respondsToSelector:@selector(beginRefreshComment)]) {
            [_delegate beginRefreshComment];
            
        }
        
    }
}
@end
