// RDVTabBarController.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import <objc/runtime.h>

#import "HomeController.h"
#import "RCLetterListController.h"
#import "SameCityController.h"
#import "FeedsController.h"
#import "UserDetailController.h"
#import "UIView+Border.h"
#import "MobClick.h"

@interface UIViewController (RDVTabBarControllerItemInternal)

- (void)rdv_setTabBarController:(RDVTabBarController *)tabBarController;

@end

@interface RDVTabBarController () {
    UIView *_contentView;
}

@property (nonatomic, readwrite) RDVTabBar *tabBar;

@end

@implementation RDVTabBarController


#pragma mark - 初始化数据
- (void)customizeTabBarForController {
    UIViewController *firstViewController = [[HomeController alloc] init];
//    UINavigationController *firstNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:firstViewController];
    
    SameCityController *secondViewController = [[SameCityController alloc] init];
    ((UserDetailController *)secondViewController).fromRoot=YES;
//    UINavigationController *secondNavigationController = [[UINavigationController alloc]
//                                                    initWithRootViewController:secondViewController];
    
    RCLetterListController *thirdViewController = [[RCLetterListController alloc] init];
    ((RCLetterListController *)thirdViewController).fromRoot=YES;
//    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:thirdViewController];
    
    UIViewController *fourViewController = [[FeedsController alloc] init];
    ((FeedsController *)fourViewController).fromRoot=YES;
    
    
    UIViewController *fiveViewController = [[UserDetailController alloc] init];
    ((UserDetailController *)fiveViewController).uid=[[LoginManager getInstance] getUid];
    ((UserDetailController *)fiveViewController).fromRoot=YES;
    
    [self setViewControllers:@[firstViewController,secondViewController,thirdViewController,fourViewController,fiveViewController]];
    
    
    UIImage *finishedImage = nil;//[UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = nil;//[UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemTitles = @[@"首页", @"附近",@"聊天",@"动态",@"我"];
    NSArray *tabBarImteImages = @[@"root_menu1",@"root_menu2",@"root_menu3",@"root_menu4",@"root_menu5"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                      [tabBarImteImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_nor",
                                                        [tabBarImteImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        [item setSelectedTitleAttributes:@{NSFontAttributeName: ListTimeFont,
                                           NSForegroundColorAttributeName:UIColorFromRGB(SystemColor)}];
        [item setUnselectedTitleAttributes:@{NSFontAttributeName:ListTimeFont,NSForegroundColorAttributeName: UIColorFromRGB(TextBlackColor)}];
//        [item setBadgeValue:@"3"];
        index++;
    }
    
    [self getUserMessageCount];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    if(iOS7){
        self.automaticallyAdjustsScrollViewInsets=NO;
    }

    
    [self customizeTabBarForController];
    
    [self.view addSubview:[self contentView]];
    [self.view addSubview:[self tabBar]];
    
    
    // 暂时不监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkNewcount) name:NOTICE_RECEIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNewcount) name:NOTICE_CleanMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNewcount) name:Login_Exit object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setSelectedIndex:[self selectedIndex]];
    
    [self setTabBarHidden:self.isTabBarHidden animated:NO];
}

- (NSUInteger)supportedInterfaceOrientations {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskAll;
    for (UIViewController *viewController in [self viewControllers]) {
        if (![viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            return UIInterfaceOrientationMaskPortrait;
        }
        
        UIInterfaceOrientationMask supportedOrientations = [viewController supportedInterfaceOrientations];
        
        if (orientationMask > supportedOrientations) {
            orientationMask = supportedOrientations;
        }
    }
    
    return orientationMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    for (UIViewController *viewCotroller in [self viewControllers]) {
        if (![viewCotroller respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ||
            ![viewCotroller shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Methods

- (UIViewController *)selectedViewController {
    return [[self viewControllers] objectAtIndex:[self selectedIndex]];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.viewControllers.count) {
        return;
    }
    
    if ([self selectedViewController]) {
        [[self selectedViewController] willMoveToParentViewController:nil];
        [[[self selectedViewController] view] removeFromSuperview];
        [[self selectedViewController] removeFromParentViewController];
    }
    
    _selectedIndex = selectedIndex;
    [[self tabBar] setSelectedItem:[[self tabBar] items][selectedIndex]];
    
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:selectedIndex]];
    [self addChildViewController:[self selectedViewController]];
    [[[self selectedViewController] view] setFrame:[[self contentView] bounds]];
    [[self contentView] addSubview:[[self selectedViewController] view]];
    [[self selectedViewController] didMoveToParentViewController:self];
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers && [viewControllers isKindOfClass:[NSArray class]]) {
        _viewControllers = [viewControllers copy];
        
        NSMutableArray *tabBarItems = [[NSMutableArray alloc] init];
        
        for (UIViewController *viewController in viewControllers) {
            RDVTabBarItem *tabBarItem = [[RDVTabBarItem alloc] init];
            [tabBarItem setTitle:viewController.title];
            [tabBarItems addObject:tabBarItem];
            [viewController rdv_setTabBarController:self];
        }
        
        [[self tabBar] setItems:tabBarItems];
    } else {
        for (UIViewController *viewController in _viewControllers) {
            [viewController rdv_setTabBarController:nil];
        }
        
        _viewControllers = nil;
    }
}

- (NSInteger)indexForViewController:(UIViewController *)viewController {
    UIViewController *searchedController = viewController;
    if ([searchedController navigationController]) {
        searchedController = [searchedController navigationController];
    }
    return [[self viewControllers] indexOfObject:searchedController];
}

- (RDVTabBar *)tabBar {
    if (!_tabBar) {
        _tabBar = [[RDVTabBar alloc] init];
        [_tabBar setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                      UIViewAutoresizingFlexibleTopMargin|
                                      UIViewAutoresizingFlexibleLeftMargin|
                                      UIViewAutoresizingFlexibleRightMargin|
                                      UIViewAutoresizingFlexibleBottomMargin)];
        [_tabBar setDelegate:self];
    }
    return _tabBar;
}




- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        [_contentView setBackgroundColor:[UIColor clearColor]];
        [_contentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|
                                           UIViewAutoresizingFlexibleHeight)];
    }
    return _contentView;
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    _tabBarHidden = hidden;
    
    __weak RDVTabBarController *weakSelf = self;
    
    void (^block)() = ^{
        CGSize viewSize = weakSelf.view.bounds.size;
        CGFloat tabBarStartingY = viewSize.height;
        CGFloat contentViewHeight = viewSize.height;
        CGFloat tabBarHeight = CGRectGetHeight([[weakSelf tabBar] frame]);
        
        if (!tabBarHeight) {
            tabBarHeight = 49;
        }
        
        if (!hidden) {
            tabBarStartingY = viewSize.height - tabBarHeight;
            //始终要减少，不然不正确啊
//            if (![[weakSelf tabBar] isTranslucent]) {
                contentViewHeight -= ([[weakSelf tabBar] minimumContentHeight] ?: tabBarHeight);
//            }
            [[weakSelf tabBar] setHidden:NO];
        }
        
        [[weakSelf tabBar] setFrame:CGRectMake(0, tabBarStartingY, viewSize.width, tabBarHeight)];
        [[weakSelf contentView] setFrame:CGRectMake(0, 0, viewSize.width, contentViewHeight)];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished){
        if (hidden) {
            [[weakSelf tabBar] setHidden:YES];
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:0.24 animations:block completion:completion];
    } else {
        block();
        completion(YES);
    }
}

- (void)setTabBarHidden:(BOOL)hidden {
    [self setTabBarHidden:hidden animated:NO];
}

#pragma mark - RDVTabBarDelegate

- (BOOL)tabBar:(RDVTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index {
    if ([[self delegate] respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![[self delegate] tabBarController:self shouldSelectViewController:[self viewControllers][index]]) {
            return NO;
        }
    }
    
    if ([self selectedViewController] == [self viewControllers][index]) {
        if ([[self selectedViewController] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *selectedController = (UINavigationController *)[self selectedViewController];
            
            if ([selectedController topViewController] != [selectedController viewControllers][0]) {
                [selectedController popToRootViewControllerAnimated:NO];
            }
        }
        
        return NO;
    }
    
    return YES;
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index {
    if (index < 0 || index >= [[self viewControllers] count]) {
        return;
    }
    if(index>1 && ![[LoginManager getInstance] isLogin]){
        [[LoginManager getInstance] showLoginView:self];
        return;
    }
    
    if(index==0){
        [MobClick event:@"click_home"];
    }
    if(index==1){
        [MobClick event:@"click_near"];
    }
    if(index==2){
        [MobClick event:@"click_chat"];
    }
    if(index==3){
        [MobClick event:@"click_tips"];
    }
    if(index==4){
        [MobClick event:@"click_personal"];
    }
    
    [self setSelectedIndex:index];
    
    if ([[self delegate] respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [[self delegate] tabBarController:self didSelectViewController:[self viewControllers][index]];
    }
    if(index==0){
        _homenum=[[RequestTools getInstance] getNewfollowtopiccount];
    }else if(index==2){
        _chatnum=[[RequestTools getInstance] getMessagesNum];
    }else if(index==3){
        _feednum=[[RequestTools getInstance] getTipsNum];
    }else if(index==4){
        _menum=[[RequestTools getInstance] getNewfollowhtcount]+[[RequestTools getInstance] getNewfanscount]+[[RequestTools getInstance] getNewfollowpoicount];
    }
    
    [[[self tabBar].items objectAtIndex:index] setBadgeValue:@""];
}


/**
 *  获得用户的消息数
 */
- (void)getUserMessageCount{
    [[RequestTools getInstance]get:API_Get_Usernewinfo isCache:NO completion:^(NSDictionary *dict) {
        [[RequestTools getInstance] setNewsCountWithDict:[dict objectForKey:@"data"]];
        [self checkNewcount];
    } failure:^(ASIHTTPRequest *request, NSString *message) {
        
    } finished:^(ASIHTTPRequest *request) {
        
    }];
}

-(void)checkNewcount{
    if(![[LoginManager getInstance] isLogin]){
        [[RequestTools getInstance] doCleanMessageNum];
    }
    
    if([[RequestTools getInstance] getNewfollowtopiccount]>0 && _selectedIndex>0 && [[RequestTools getInstance] getNewfollowtopiccount]!=_homenum){
        [[[self tabBar].items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getNewfollowtopiccount]]];
    }else{
        [[[self tabBar].items objectAtIndex:0] setBadgeValue:@""];
    }
    
    if([[RequestTools getInstance] getMessagesNum]>0 && [[RequestTools getInstance] getMessagesNum]!=_chatnum){
        [[[self tabBar].items objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getMessagesNum]]];
    }else{
        [[[self tabBar].items objectAtIndex:2] setBadgeValue:@""];
    }
    
    if([[RequestTools getInstance] getTipsNum]>0 && [[RequestTools getInstance] getTipsNum]!=_feednum){
        [[[self tabBar].items objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getTipsNum]]];
    }else{
        [[[self tabBar].items objectAtIndex:3] setBadgeValue:@""];
    }
    
    if([[RequestTools getInstance] getNewfollowhtcount]>0 ||[[RequestTools getInstance] getNewfanscount]>0 || [[RequestTools getInstance] getNewfollowpoicount]>0){
        if(([[RequestTools getInstance] getNewfollowhtcount]+[[RequestTools getInstance] getNewfanscount]+[[RequestTools getInstance] getNewfollowpoicount])==_menum){
            [[[self tabBar].items objectAtIndex:4] setBadgeValue:@""];
            return;
        }
        [[[self tabBar].items objectAtIndex:4] setBadgeValue:[NSString stringWithFormat:@"%d",[[RequestTools getInstance] getNewfollowhtcount]+[[RequestTools getInstance] getNewfanscount]+[[RequestTools getInstance] getNewfollowpoicount]]];
    }else{
        [[[self tabBar].items objectAtIndex:4] setBadgeValue:@""];
    }
}

#pragma mark  监听消息数变化
-(void)reciveRCMessage:(RCMessage *)message num:(int)nleft object:(id)object{
    [self checkNewcount];
}

@end

#pragma mark - UIViewController+RDVTabBarControllerItem

@implementation UIViewController (RDVTabBarControllerItemInternal)

- (void)rdv_setTabBarController:(RDVTabBarController *)tabBarController {
    objc_setAssociatedObject(self, @selector(rdv_tabBarController), tabBarController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@implementation UIViewController (RDVTabBarControllerItem)

- (RDVTabBarController *)rdv_tabBarController {
    RDVTabBarController *tabBarController = objc_getAssociatedObject(self, @selector(rdv_tabBarController));
    
    if (!tabBarController && self.parentViewController) {
        tabBarController = [self.parentViewController rdv_tabBarController];
    }
    
    return tabBarController;
}

- (RDVTabBarItem *)rdv_tabBarItem {
    RDVTabBarController *tabBarController = [self rdv_tabBarController];
    NSInteger index = [tabBarController indexForViewController:self];
    return [[[tabBarController tabBar] items] objectAtIndex:index];
}

- (void)rdv_setTabBarItem:(RDVTabBarItem *)tabBarItem {
    RDVTabBarController *tabBarController = [self rdv_tabBarController];
    
    if (!tabBarController) {
        return;
    }
    
    RDVTabBar *tabBar = [tabBarController tabBar];
    NSInteger index = [tabBarController indexForViewController:self];
    
    NSMutableArray *tabBarItems = [[NSMutableArray alloc] initWithArray:[tabBar items]];
    [tabBarItems replaceObjectAtIndex:index withObject:tabBarItem];
    [tabBar setItems:tabBarItems];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
