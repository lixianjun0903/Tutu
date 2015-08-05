//
//  UserInfo.m
//  Tutu
//
//  Created by gaoyong on 14-10-19.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

-(UserInfo *)initWithMyDict:(NSDictionary *)dict{
    self=[super init];
    if (self && dict!=nil) {
        @try {
            _uid=CheckNilValue([dict objectForKey:@"uid"]);
            _nickname=CheckNilValue([dict objectForKey:@"nickname"]);
            _avatartime=CheckNilValue([dict objectForKey:@"avatartime"]);
            _newmessagecount=CheckNilValue([dict objectForKey:@"newmessagecount"]);
            _newtipscount=CheckNilValue([dict objectForKey:@"newtipscount"]);
            _gender=CheckNilValue([dict objectForKey:@"gender"]);
            _birthday=CheckNilValue([dict objectForKey:@"birthday"]);
            _province=CheckNilValue([dict objectForKey:@"province"]);
            _city=CheckNilValue([dict objectForKey:@"city"]);
            _area=CheckNilValue([dict objectForKey:@"area"]);
            _sign=CheckNilValue([dict objectForKey:@"sign"]);
            _age = CheckNilValue([dict objectForKey:@"age"]);
            _addtime=CheckNilValue([dict objectForKey:@"addtime"]);
            _relation = CheckNilValue(dict[@"relation"]);
            _isBlock = [CheckNilValue(dict[@"isblock"]) boolValue];
            
            _distance = CheckNilValue(dict[@"distance"]);
            
            _lasttime=CheckNilValue(dict[@"lasttime"]);
            
            _topicblock=[CheckNilValue(dict[@"topicblock"]) boolValue];
            _isblockme=[CheckNilValue(dict[@"isblockme"]) boolValue];
            
            _constellation=CheckNilValue([dict objectForKey:@"constellation"]);
            _userhonorlevel=[CheckNilValue([dict objectForKey:@"userhonorlevel"]) intValue];
            _isliked=[CheckNilValue([dict objectForKey:@"isliked"]) intValue];
            _likenum=[CheckNilValue([dict objectForKey:@"likenum"]) intValue];
            _homecoverurl=CheckNilValue([dict objectForKey:@"homecoverurl"]);
            
            
            _status=[CheckNilValue([dict objectForKey:@"status"]) intValue];
            _topicnum=[CheckNilValue([dict objectForKey:@"topicnum"]) intValue];
            _favnum=[CheckNilValue([dict objectForKey:@"favnum"]) intValue];
            
            
            
            
            
            _isQQLogin=CheckNilValue([dict objectForKey:@"isqqlogin"]);
            
            _logintype=CheckNilValue([dict objectForKey:@"logintype"]);
            _isbind_phone=CheckNilValue([dict objectForKey:@"isbind_phone"]);
            _isbind_qq=CheckNilValue([dict objectForKey:@"isbind_qq"]);
            _isbind_weibo=CheckNilValue([dict objectForKey:@"isbind_weibo"]);
            _token=CheckNilValue([dict objectForKey:@"token"]);
            
            _locationstatus = CheckNilValue(dict [@"locationstatus"]);
            
            
            _remarkname = CheckNilValue(dict [@"remarkname"]);
            _cansendmessage = CheckNilValue(dict [@"cansendmessage"]);
            _errormsg = CheckNilValue(dict [@"errormsg"]);
            _applymsg = CheckNilValue(dict[@"applymsg"]);
            _applytime = CheckNilValue(dict[@"applytime"]);
            _applystatus = CheckNilValue(dict[@"applystatus"]);
            
            
            _canchat = [CheckNilValue(dict[@"canchat"]) boolValue];
            
            _follownum=[CheckNilValue(dict[@"follownum"]) intValue];
            _fansnum=[CheckNilValue(dict[@"fansnum"]) intValue];
         
            _isauth = [CheckNilValue(dict[@"isauth"]) boolValue];
            _authreason = CheckNilValue(dict[@"authreason"]);
            
            _realname=_nickname;
            if(_remarkname!=nil && ![@"" isEqual:_remarkname]){
                _nickname=_remarkname;
            }
            _descinfo=CheckNilValue([dict objectForKey:@"descinfo"]);
            _followtime=CheckNilValue([dict objectForKey:@"followtime"]);
            
            if([SysTools getApp].checkUserAge){
                if([_age intValue]<18){
                    _age=[NSString stringWithFormat:@"%d",(18-[_age intValue])+[_age intValue]+arc4random()%10];
                }
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            if((NSNull *)_nickname==[NSNull null]){
                _nickname=@"";
            }
            if((NSNull *)_avatartime==[NSNull null]){
                _avatartime=@"";
            }
            if((NSNull *)_birthday==[NSNull null]){
                _birthday=@"";
            }
            if((NSNull *)_province==[NSNull null]){
                _province=@"";
            }
            if((NSNull *)_city==[NSNull null]){
                _city=@"";
            }
            if((NSNull *)_area==[NSNull null]){
                _area=@"";
            }
            if((NSNull *)_sign==[NSNull null]){
                _sign=@"";
            }
            if((NSNull *)_addtime==[NSNull null]){
                _addtime=@"";
            }
        }
    }
    return self;
}

@end
