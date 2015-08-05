//
//  LinkManModel.m
//  Tutu
//
//  Created by 刘大治 on 14/12/9.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "LinkManModel.h"

@implementation LinkManModel
-(id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        @try {
            self.local_id = CheckNilValue([dictionary objectForKey:@"local_id"]);
            self.phonenumber = CheckNilValue([dictionary objectForKey:@"phonenumber"]);
            self.relation = [CheckNilValue([dictionary objectForKey:@"relation"]) integerValue];
            self.tutuid = CheckNilValue([dictionary objectForKey:@"tutu_uid"]);
            self.mytutuid= [LoginManager getInstance].getUid;
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    return self;
}
@end
