//
//  SearchController.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-31.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"

@interface SearchController : BaseController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIGestureRecognizerDelegate>{
    UISearchBar *mySearchBar;
    UISearchDisplayController *searchDisplayController;
}

@end
