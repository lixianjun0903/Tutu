//
//  UserInfoDB.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-10.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "UserInfoDB.h"

@implementation UserInfoDB

- (id) init {
    self = [super init];
    if (self) {
        //========== 首先查看有没有建立message的数据库，如果未建立，则建立数据库=========
        _db = [TutuDBManager defaultDBManager].dataBase;
    }
    [self createDataBase];
    return self;
}


/**
 * @brief 创建数据库
 */
- (void) createDataBase {
    NSString * sql1 = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ \
                       (uid INTEGER PRIMARY KEY NOT NULL, \
                       nickname VARCHAR, \
                       avatartime VARCHAR, \
                       newmessagecount VARCHAR, \
                       newtipscount VARCHAR, \
                       gender VARCHAR, \
                       age VARCHAR, \
                       birthday VARCHAR, \
                       province VARCHAR, \
                       city VARCHAR, \
                       area VARCHAR, \
                       sign VARCHAR, \
                       relation VARCHAR, \
                       addtime VARCHAR, \
                       isBlock BOOL, \
                       constellation VARCHAR, \
                       userhonorlevel VARCHAR, \
                       isliked VARCHAR, \
                       likenum VARCHAR, \
                       homecoverurl VARCHAR, \
                       topicblock VARCHAR, \
                       isblockme VARCHAR, \
                       lasttime VARCHAR, \
                       distance VARCHAR, \
                       status VARCHAR, \
                       topicnum VARCHAR, \
                       favnum VARCHAR, \
                       changetime VARCHAR, \
                       updatetime VARCHAR,\
                       isQQLogin VARCHAR, \
                       logintype VARCHAR, \
                       isbind_qq VARCHAR, \
                       isbind_weibo VARCHAR, \
                       isbind_phone VARCHAR, \
                       token VARCHAR, \
                       canchat INTEGER, \
                       locationstatus VARCHAR, \
                       remarkname VARCHAR, \
                       cansendmessage VARCHAR, \
                       errormsg VARCHAR)",TutuUserInfo];
    [_db executeUpdate:sql1];
    
    
    
    //添加列
    // 判断列不存在
    if(![self checkColumnName:TutuUserInfo columnName:@"follownum"]){
        NSString *addColumnSql1 = [NSString stringWithFormat:
                                   @"ALTER TABLE %@ ADD COLUMN follownum INTEGER",TutuUserInfo];
        [_db executeUpdate:addColumnSql1];
    }
    
    if(![self checkColumnName:TutuUserInfo columnName:@"fansnum"]){
        NSString *addColumnSql1 = [NSString stringWithFormat:
                                   @"ALTER TABLE %@ ADD COLUMN fansnum INTEGER",TutuUserInfo];
        [_db executeUpdate:addColumnSql1];
    }
    
    
    if(![self checkColumnName:TutuUserInfo columnName:@"followtime"]){
        NSString *addColumnSql1 = [NSString stringWithFormat:
                                   @"ALTER TABLE %@ ADD COLUMN followtime VARCHAR",TutuUserInfo];
        NSString *addColumnSql2 = [NSString stringWithFormat:
                                   @"ALTER TABLE %@ ADD COLUMN isauth INTEGER",TutuUserInfo];
        
        [_db executeUpdate:addColumnSql1];
        [_db executeUpdate:addColumnSql2];
    }
}

-(BOOL)saveUser:(UserInfo *)item{
    if(item==nil || item.uid==nil){
        return NO;
    }
    if([self findWidthUID:item.uid])
    {
        return [self updateUser:item];
    }
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuUserInfo];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:30];
    if (item.uid) {
        [keys appendString:@"uid,"];
        [values appendString:@"?,"];
        [arguments addObject:item.uid];
    }else {
        return NO;
    }
    
    [keys appendString:@"nickname,"];
    [values appendString:@"?,"];
    [arguments addObject:item.nickname];
    
    [keys appendString:@"avatartime,"];
    [values appendString:@"?,"];
    [arguments addObject:item.avatartime];
    
    [keys appendString:@"newmessagecount,"];
    [values appendString:@"?,"];
    [arguments addObject:[@"" isEqual:CheckNilValue(item.newmessagecount)]?@"0":CheckNilValue(item.newmessagecount)];
    
    [keys appendString:@"newtipscount,"];
    [values appendString:@"?,"];
    [arguments addObject:[@"" isEqual:CheckNilValue(item.newtipscount)]?@"0":CheckNilValue(item.newtipscount)];
    
    [keys appendString:@"gender,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.gender)];
    
    [keys appendString:@"age,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.age)];
    
    [keys appendString:@"birthday,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.birthday)];
    
    [keys appendString:@"province,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.province)];
    
    [keys appendString:@"city,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.city)];
    
    [keys appendString:@"area,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.area)];
    
    [keys appendString:@"sign,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.sign)];
    
    [keys appendString:@"relation,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.relation)];
    
    [keys appendString:@"addtime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.addtime)];
    
    [keys appendString:@"isBlock,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isBlock]];
    
    [keys appendString:@"constellation,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.constellation)];
    
    [keys appendString:@"userhonorlevel,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.userhonorlevel]];

    [keys appendString:@"isliked,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isliked]];

    [keys appendString:@"likenum,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.likenum]];

    [keys appendString:@"homecoverurl,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.homecoverurl)];

    [keys appendString:@"topicblock,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.topicblock]];

    [keys appendString:@"isblockme,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isblockme]];

    [keys appendString:@"lasttime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.lasttime)];
    
    [keys appendString:@"distance,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.distance)];
    
    [keys appendString:@"status,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.status]];
    
    [keys appendString:@"topicnum,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.topicnum]];
    
    [keys appendString:@"favnum,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.favnum]];
    
    [keys appendString:@"changetime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.changetime)];
    
    [keys appendString:@"updatetime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.updatetime)];
    
    [keys appendString:@"isQQLogin,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.isQQLogin)];
    
    [keys appendString:@"logintype,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.logintype)];
    
    [keys appendString:@"isbind_qq,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.isbind_qq)];
    
    [keys appendString:@"isbind_weibo,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.isbind_weibo)];
    
    [keys appendString:@"isbind_phone,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.isbind_phone)];
    
    [keys appendString:@"token,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.token)];
    
    [keys appendString:@"locationstatus,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.locationstatus)];
    
    
    [keys appendString:@"remarkname,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.remarkname)];
    
    
    [keys appendString:@"cansendmessage,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.cansendmessage)];
    
    
    [keys appendString:@"errormsg,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.errormsg)];
    
    
    [keys appendString:@"canchat,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.canchat]];
    
    
    [keys appendString:@"follownum,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.follownum]];
    
    [keys appendString:@"fansnum,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.fansnum]];
    
    
    [keys appendString:@"followtime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.followtime)];
    
    [keys appendString:@"isauth,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isauth]];
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
    [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
    [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
//    WSLog(@"%@",query);
//    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}


-(BOOL)saveUserInfoWithArr:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (UserInfo *info in arr) {
           if(![[[LoginManager getInstance] getUid] isEqual:info.uid]){
               info.nickname=info.realname;
               [self saveUser:info];
//               WSLog(@"插入好友数据：%d--%@",isOK,info.nickname);
           }
        }
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [_db rollback];
    }
    @finally {
        if (!isRollBack) {
            [_db commit];
        }else{
            [_db rollback];
        }
    }
    
    return !isRollBack;
}

-(BOOL)deleteUserInfoByUID:(NSString *)uid{
    if(!uid){
        return NO;
    }
    if([uid isEqual:[[LoginManager getInstance] getUid]]){
        return NO;
    }
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uid in (%@)",TutuUserInfo,uid];
//    WSLog(@"%@",query);
    return [_db executeUpdate:query];
}


-(BOOL)updateUser:(UserInfo *)item{
    NSMutableString * query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",TutuUserInfo];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (!item.uid){
        return NO;
    }
    
    if(CheckNilValue(item.nickname)!=nil){
        [query appendString:@"nickname=?,"];
        [arguments addObject:item.nickname];
    }
    if(item.avatartime!=nil){
        [query appendString:@"avatartime=?,"];
        [arguments addObject:item.avatartime];
    }
    
    if(item.newmessagecount!=nil){
        [query appendString:@"newmessagecount=?,"];
        [arguments addObject:item.newmessagecount];
    }
    
    if(item.newtipscount!=nil){
        [query appendString:@"newtipscount=?,"];
        [arguments addObject:item.newtipscount];
    }
    
    if(item.gender!=nil){
        [query appendString:@"gender=?,"];
        [arguments addObject:item.gender];
    }
    
    if(item.age!=nil){
        [query appendString:@"age=?,"];
        [arguments addObject:item.age];
    }
    
    if(item.birthday!=nil){
        [query appendString:@"birthday=?,"];
        [arguments addObject:item.birthday];
    }
    if(item.province!=nil){
        [query appendString:@"province=?,"];
        [arguments addObject:item.province];
    }
    if(item.city!=nil){
        [query appendString:@"city=?,"];
        [arguments addObject:item.city];
    }
    if(item.area!=nil){
        [query appendString:@"area=?,"];
        [arguments addObject:item.area];
    }
    if(item.sign!=nil){
        [query appendString:@"sign=?,"];
        [arguments addObject:item.sign];
    }
    if(item.relation!=nil){
        [query appendString:@"relation=?,"];
        [arguments addObject:item.relation];
    }
    if(item.addtime!=nil){
        [query appendString:@"addtime=?,"];
        [arguments addObject:item.addtime];
    }
    
    [query appendString:@"isBlock=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isBlock]];
    
    if(item.constellation!=nil){
        [query appendString:@"constellation=?,"];
        [arguments addObject:item.constellation];
    }
    
    [query appendString:@"userhonorlevel=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.userhonorlevel]];

    
    [query appendString:@"isliked=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isliked]];


    [query appendString:@"likenum=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.likenum]];

    if(item.homecoverurl!=nil){
        [query appendString:@"homecoverurl=?,"];
        [arguments addObject:item.homecoverurl];
    }
 
    [query appendString:@"topicblock=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.topicblock]];

    [query appendString:@"isblockme=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isblockme]];
 
    if(item.lasttime!=nil){
        [query appendString:@"lasttime=?,"];
        [arguments addObject:item.lasttime];
    }
    if(item.distance!=nil){
        [query appendString:@"distance=?,"];
        [arguments addObject:item.distance];
    }
    
    [query appendString:@"status=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.status]];
    
    [query appendString:@"topicnum=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.topicnum]];

    [query appendString:@"favnum=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.favnum]];

    if(item.changetime!=nil){
        [query appendString:@"changetime=?,"];
        [arguments addObject:item.changetime];
    }
    if(item.updatetime!=nil){
        [query appendString:@"updatetime=?,"];
        [arguments addObject:item.updatetime];
    }
    
    if(item.isQQLogin!=nil){
        [query appendString:@"isQQLogin=?,"];
        [arguments addObject:item.isQQLogin];
    }
    if(item.logintype!=nil){
        [query appendString:@"logintype=?,"];
        [arguments addObject:item.logintype];
    }
    
    if(item.isbind_qq!=nil){
        [query appendString:@"isbind_qq=?,"];
        [arguments addObject:item.isbind_qq];
    }
    
    if(item.isbind_weibo!=nil){
        [query appendString:@"isbind_weibo=?,"];
        [arguments addObject:item.isbind_weibo];
    }
    
    if(item.isbind_phone!=nil){
        [query appendString:@"isbind_phone=?,"];
        [arguments addObject:item.isbind_phone];
    }
    
    if(item.token!=nil){
        [query appendString:@"token=?,"];
        [arguments addObject:item.token];
    }
    
    if(item.locationstatus!=nil){
        [query appendString:@"locationstatus=?,"];
        [arguments addObject:item.locationstatus];
    }
    
    if(item.remarkname!=nil){
        [query appendString:@"remarkname=?,"];
        [arguments addObject:item.remarkname];
    }
    if(item.cansendmessage!=nil){
        [query appendString:@"cansendmessage=?,"];
        [arguments addObject:item.cansendmessage];
    }
    if(item.errormsg!=nil){
        [query appendString:@"errormsg=?,"];
        [arguments addObject:item.errormsg];
    }
    
    [query appendString:@"canchat=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.canchat]];
    
    
    [query appendString:@"follownum=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.follownum]];
    
    [query appendString:@"fansnum=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.fansnum]];
    
    if(item.followtime!=nil){
        [query appendString:@"followtime=?,"];
        [arguments addObject:item.followtime];
    }
    
    [query appendString:@"isauth=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isauth]];
    
    [query appendString:@")"];
    if([query hasSuffix:@",)"]){
        [query replaceCharactersInRange:NSMakeRange(query.length-2, 2) withString:@" "];
        [query stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
//    WSLog(@"%@",query);
    [query appendFormat:@" where uid =%@ ",item.uid];
    
//    WSLog(@"修改用户信息：%@",query);
//    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}

-(UserInfo *)findWidthUID:(NSString *)uid{
    UserInfo *userinfo=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" where uid='%@' ",uid];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        userinfo=[self parseResultSet:rs];
    }
    [rs close];
    return userinfo;
}

-(NSMutableDictionary *)findAllRelationDict{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" where 1=1 "];
    //    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        UserInfo *info=[self parseResultSet:rs];
        if(info!=nil && info.uid!=nil){
            [dict setObject:info forKey:info.uid];
        }
    }
    [rs close];
    return dict;
}


-(UserInfo *)findNewUserInfo{
    UserInfo *userinfo=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT  * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" order by addtime desc limit 1 "];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        userinfo=[self parseResultSet:rs];
    }
    [rs close];
    return userinfo;
}

-(UserInfo *)findOldUserInfo{
    UserInfo *userinfo=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" order by addtime asc limit 1 "];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        userinfo=[self parseResultSet:rs];
    }
    [rs close];
    return userinfo;
}


-(NSMutableArray *)findMyFriends{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" where (relation=3 or relation=5 or relation=2) and uid!=%@ order by followtime desc,addtime desc ",[[LoginManager getInstance] getUid]];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [arr addObject:[self parseResultSet:rs]];
    }
    [rs close];
    return arr;
}

-(NSMutableArray *)findMyFriends:(NSString *)queryString{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuUserInfo];
    query = [query stringByAppendingFormat:@" where uid='%@' or nickname like '%@%%'",queryString,queryString];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [arr addObject:[self parseResultSet:rs]];
    }
    [rs close];
    return arr;
}



//////////////////////////////////////////////////////////////////////////

-(UserInfo *)parseResultSet:(FMResultSet *)rs{
    UserInfo *item=[UserInfo new];
    @try {
        item.uid=CheckNilValue([rs stringForColumn:@"uid"]);
        item.nickname=CheckNilValue([rs stringForColumn:@"nickname"]);
        item.avatartime=CheckNilValue([rs stringForColumn:@"avatartime"]);
        item.newmessagecount= CheckNilValue([rs stringForColumn:@"newmessagecount"]);
        item.newtipscount=CheckNilValue([rs stringForColumn:@"newtipscount"]);
        item.gender=CheckNilValue([rs stringForColumn:@"gender"]);
        item.age=CheckNilValue([rs stringForColumn:@"age"]);
        item.birthday=CheckNilValue([rs stringForColumn:@"birthday"]);
        item.province=CheckNilValue([rs stringForColumn:@"province"]);
        item.city=CheckNilValue([rs stringForColumn:@"city"]);
        item.area=CheckNilValue([rs stringForColumn:@"area"]);
        item.sign=CheckNilValue([rs stringForColumn:@"sign"]);
        item.relation=CheckNilValue([rs stringForColumn:@"relation"]);
        item.addtime=CheckNilValue([rs stringForColumn:@"addtime"]);
        item.isBlock=[CheckNilValue([rs stringForColumn:@"isBlock"]) boolValue];
        item.constellation=CheckNilValue([rs stringForColumn:@"constellation"]);
        item.userhonorlevel=[CheckNilValue([rs stringForColumn:@"userhonorlevel"]) intValue];
        item.isliked=[CheckNilValue([rs stringForColumn:@"isliked"]) intValue];
        item.likenum=[CheckNilValue([rs stringForColumn:@"likenum"]) intValue];
        item.homecoverurl=CheckNilValue([rs stringForColumn:@"homecoverurl"]);
        item.topicblock=[CheckNilValue([rs stringForColumn:@"topicblock"]) intValue];
        item.isblockme=[CheckNilValue([rs stringForColumn:@"isblockme"]) boolValue];
        item.lasttime=CheckNilValue([rs stringForColumn:@"lasttime"]);
        item.distance=CheckNilValue([rs stringForColumn:@"distance"]);
        item.status=[CheckNilValue([rs stringForColumn:@"status"]) intValue];
        item.topicnum=[CheckNilValue([rs stringForColumn:@"topicnum"]) intValue];
        item.favnum=[CheckNilValue([rs stringForColumn:@"favnum"]) intValue];
        item.changetime=CheckNilValue([rs stringForColumn:@"changetime"]);
        item.updatetime=CheckNilValue([rs stringForColumn:@"updatetime"]);
        
        
        item.isQQLogin=CheckNilValue([rs stringForColumn:@"isQQLogin"]);
        item.logintype=CheckNilValue([rs stringForColumn:@"logintype"]);
        item.isbind_qq=CheckNilValue([rs stringForColumn:@"isbind_qq"]);
        item.isbind_phone=CheckNilValue([rs stringForColumn:@"isbind_phone"]);
        item.token=CheckNilValue([rs stringForColumn:@"token"]);
        item.locationstatus=CheckNilValue([rs stringForColumn:@"locationstatus"]);
        
        item.realname=item.nickname;
        item.remarkname=CheckNilValue([rs stringForColumn:@"remarkname"]);
        if(item.remarkname!=nil && ! [@"" isEqual:item.remarkname]){
            item.nickname=item.remarkname;
        }
        
        item.cansendmessage=CheckNilValue([rs stringForColumn:@"cansendmessage"]);
        item.errormsg=CheckNilValue([rs stringForColumn:@"errormsg"]);
        item.canchat=[[rs stringForColumn:@"canchat"] boolValue];
        
        item.follownum=[[rs stringForColumn:@"follownum"] intValue];
        
        item.fansnum=[[rs stringForColumn:@"fansnum"] intValue];
        
        item.followtime=CheckNilValue([rs stringForColumn:@"followtime"]);
        item.isauth=[[rs stringForColumn:@"isauth"] intValue];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


//////////////////////////////////////////////////////////////////////////

//检查列是否存在
-(BOOL) checkColumnName:(NSString *) tableName columnName:(NSString *) column{
    BOOL isExists=NO;
    NSString * query = [NSString stringWithFormat:@"select * from %@ limit 0",tableName];
    @try {
        FMResultSet * rs = [_db executeQuery:query];
        [rs intForColumn:column];
        NSMutableDictionary *dict=[rs columnNameToIndexMap];
        if(dict!=nil && [dict objectForKey:column]!=nil){
            isExists=YES;
        }
        [rs close];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return isExists;
}


//////////////////////////////////////////////////////////////////////////
-(BOOL) clearTable{
    NSString * query = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = '%@'",TutuUserInfo,TutuUserInfo];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    BOOL isOK=[_db executeUpdate:query];
    return isOK;
}


@end
