//
//  StretchableTableHeaderView.h
//  StretchableTableHeaderView
//

#import <Foundation/Foundation.h>

@class HFStretchableTableHeaderView;
typedef void(^StartLoadingBlock) ();

@interface HFStretchableTableHeaderView : NSObject

@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic,retain) UIView* view;

- (void)stretchHeaderForTableView:(UITableView*)tableView withView:(UIView*)view;
- (void)scrollViewDidScroll:(UIScrollView*)scrollView;
- (void)resizeView;

- (void)setStartBlock:(StartLoadingBlock) block;


- (void)startRefresh;
- (void)endLoading;

@end
