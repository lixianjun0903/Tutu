//
//  StretchableTableHeaderView.m
//  StretchableTableHeaderView
//

#import "HFStretchableTableHeaderView.h"

@interface HFStretchableTableHeaderView()
{
    CGRect initialFrame;
    CGFloat defaultViewHeight;
    CGFloat dFoffsetY;
    
    StartLoadingBlock block;
    BOOL loading;
    BOOL startLoading;
}
@end


@implementation HFStretchableTableHeaderView

@synthesize tableView = _tableView;
@synthesize view = _view;

- (void)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view
{
    _tableView = tableView;
    _view = view;
    
    
    initialFrame       = _view.frame;
    defaultViewHeight  = tableView.frame.size.width;
    dFoffsetY= 250-defaultViewHeight;
    
//    UIView* emptyTableHeaderView = [[UIView alloc] initWithFrame:initialFrame];
//    _tableView.tableHeaderView = emptyTableHeaderView;    
//    [_tableView addSubview:_view];
    
    loading = NO;
    startLoading = NO;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    CGRect f = _view.frame;
    f.size.width = _tableView.frame.size.width;
    _view.frame = f;
    
    
    if(scrollView.contentOffset.y < dFoffsetY) {
        CGFloat offsetY = (scrollView.contentOffset.y + scrollView.contentInset.top) * -1;
        CGFloat offsetW = (offsetY+dFoffsetY);
        
        
        initialFrame.origin.y = offsetY * -1;
        initialFrame.size.height = defaultViewHeight + ABS(offsetW);
        
        _view.frame = initialFrame;
        
        if(offsetY > 64 && !loading){
            loading=YES;
        }
    }
}

- (void)resizeView
{
    initialFrame.size.width = _tableView.frame.size.width;
    initialFrame.origin.y=dFoffsetY;
    initialFrame.size.height =_tableView.frame.size.width;
    initialFrame.origin.x=0;
    _view.frame = initialFrame;
}


- (void)setStartBlock:(StartLoadingBlock) startblock{
    block=startblock;
}

- (void) startRefresh{
    if(loading && block && !startLoading){
        block();
        startLoading=YES;
    }
}

- (void)endLoading{
    loading=NO;
    startLoading=NO;
}


@end
