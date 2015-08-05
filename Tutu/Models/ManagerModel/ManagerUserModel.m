//
//  ManagerUserModel.m
//  Tutu
//
//  Created by 刘大治 on 14-10-26.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ManagerUserModel.h"

@implementation ManagerUserModel
-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        _title = CheckNilValue([dictionary objectForKey:@"title"]);
        switch ([[dictionary objectForKey:@"type"] integerValue]) {
            case 0:
            {
                _type = ManagerCellTypeEmpty;
                break;
            }
            case 1:
            {
                _type = ManagerCellTypeImage;
                _avatarUrl =CheckNilValue([dictionary objectForKey:@"image"]);
                break;
            }
            case 2:
            {
                _type = ManagerCellTypeDetail;
                _detail = CheckNilValue([dictionary objectForKey:@"detail"]);
                break;
            }
            case 3:
            {
                _type = ManagerCellTypeTuTuNum;
                _detail = CheckNilValue([dictionary objectForKey:@"detail"]);
                break;
            }
            default:
                break;
        }
        
    }
    return self;
}
@end
