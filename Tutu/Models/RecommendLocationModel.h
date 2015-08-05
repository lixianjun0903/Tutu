//
//  RecommendLocationModel.h
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "JSONModel.h"

@interface RecommendLocationModel : JSONModel
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *ids;
@property(nonatomic,strong)NSString *idstext;
@property(nonatomic)       int       joinusercount;
@property(nonatomic)       int       isfollow;
@end
