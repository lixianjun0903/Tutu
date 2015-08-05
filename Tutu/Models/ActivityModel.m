//
//  ActivityModel.m
//  Tutu
//
//  Created by gexing on 14/12/9.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel
+(ActivityModel *)initWithDic:(NSDictionary *)dic
{
    ActivityModel *model = [[ActivityModel alloc]init];
    model.gotourl = CheckNilValue(dic[@"gotourl"]);
    model.displaystyle = [CheckNilValue(dic[@"displaystyle"]) integerValue];
    NSArray *buttonlist = (NSArray *)dic[@"buttonlist"];
    model.buttonCount = buttonlist.count;
    for (int i = 0; i < buttonlist.count; i ++) {
        if (i == 0) {
            model.btnOneTitle = CheckNilValue(buttonlist[0][@"buttontxt"]);
            model.btnOneUrl = CheckNilValue(buttonlist[0][@"gotourl"]);
        }else{
            model.btnTwoTitle = CheckNilValue(buttonlist[1][@"buttontxt"]);
            model.btnTwoUrl = CheckNilValue(buttonlist[1][@"gotourl"]);
        }
    }
    return model;
}
@end
