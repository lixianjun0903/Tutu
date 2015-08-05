//
//  ApplyLeaveDB.m
//  Tutu
//
//  Created by zhangxinyao on 15-3-26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "ApplyLeaveDB.h"

@implementation ApplyLeaveDB

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
                       (frienduid INTEGER PRIMARY KEY NOT NULL, \
                       relation INTEGER, \
                       nickname VARCHAR, \
                       avatartime VARCHAR, \
                       gender VARCHAR, \
                       sign VARCHAR, \
                       isblock INTEGER, \
                       age VARCHAR, \
                       userhonorlevel INTEGER, \
                       topicblock INTEGER, \
                       applymsg VARCHAR, \
                       applystatus INTEGER, \
                       applytype INTEGER, \
                       applytime VARCHAR, \
                       isSelected INTEGER, \
                       inputText VARCHAR, \
                       isDel INTEGER, \
                       uptime VARCHAR, \
                       isread INTEGER)",TutuApplyTable];
        
    
    // TODO: 插入新的数据库
    NSString * sql2 = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ \
                       (uid INTEGER NOT NULL, \
                       frienduid INTEGER, \
                       applymsg VARCHAR(50), \
                       isme VARCHAR,  \
                       addtime VARCHAR)",TutuApplyLeaveTable];
    //        BOOL res = [_db executeUpdate:sql];
    [_db executeUpdate:sql1];
    [_db executeUpdate:sql2];
}

-(BOOL)saveApplyToDB:(ApplyFriendModel *)item{
    if([self findModelWidthUID:item.frienduid])
    {
        return [self updateApplyToDB:item];
    }
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuApplyTable];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:30];
    if (item && item.frienduid) {
        [keys appendString:@"frienduid,"];
        [values appendString:@"?,"];
        [arguments addObject:item.frienduid];
    }else {
        return NO;
    }
    
    [keys appendString:@"relation,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.relation ]];
    
    [keys appendString:@"nickname,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.nickname)];
    
    [keys appendString:@"avatartime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.avatartime)];
    
    [keys appendString:@"gender,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.gender)];
    
    [keys appendString:@"sign,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.sign)];
    
    [keys appendString:@"isblock,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isblock]];
    
    [keys appendString:@"age,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.age]];
    
    [keys appendString:@"userhonorlevel,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.userhonorlevel]];
    
    [keys appendString:@"topicblock,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.topicblock]];
    
    [keys appendString:@"applymsg,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.applymsg)];
    
    [keys appendString:@"applystatus,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.applystatus]];
    
    [keys appendString:@"applytype,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.applytype]];
    
    [keys appendString:@"topicblock,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.applytime)];
    
    [keys appendString:@"isSelected,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isSelected]];
    
    [keys appendString:@"inputText,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.inputText)];
    
    
    [keys appendString:@"isDel,"];
    [values appendString:@"?,"];
    [arguments addObject:@"0"];
    
    
    [keys appendString:@"uptime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.uptime)];
    
    [keys appendString:@"isread,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isread]];
    
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
    //    WSLog(@"%@",query);
    //    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    if(isOK && item.applymsglist!=nil && item.applymsglist.count>0){
       
        [self delApplyLeaveDB:item.frienduid];
        
        for (ApplyModel *cm in item.applymsglist) {
            [self saveApplyLeaveToDB:cm frienduid:item.frienduid];
        }
        
    }
    return isOK;
}


-(BOOL)saveApplyWithArr:(NSArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (ApplyFriendModel *info in arr) {
            [self saveApplyToDB:info];
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

-(BOOL)saveApplyLeaveToDB:(ApplyModel *)item frienduid:(NSString *)uid{
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuApplyLeaveTable];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:30];
    if (item && item.uid) {
        [keys appendString:@"uid,"];
        [values appendString:@"?,"];
        [arguments addObject:CheckNilValue(item.uid)];
    }else {
        return NO;
    }
    
    
    [keys appendString:@"frienduid,"];
    [values appendString:@"?,"];
    [arguments addObject:uid];
    
    
    [keys appendString:@"applymsg,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.applymsg)];
    
    [keys appendString:@"isme,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isme]];
    
    [keys appendString:@"addtime,"];
    [values appendString:@"?,"];
    [arguments addObject:[CheckNilValue(item.addtime) isEqual:@""]?@"xxxx":item.addtime];
    
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES %@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
    //    WSLog(@"%@",query);
    //    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
//    WSLog(@"保存：%d",isOK);
    return isOK;
}

-(BOOL)updateApplyToDB:(ApplyFriendModel *)item{
    NSMutableString * query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",TutuApplyTable];
    
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (!item.frienduid){
        return NO;
    }
    
    
    [query appendString:@"relation=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.relation]];
    
    if(item.nickname!=nil){
        [query appendString:@"nickname=?,"];
        [arguments addObject:item.nickname];
    }
    
    if(item.avatartime!=nil){
        [query appendString:@"avatartime=?,"];
        [arguments addObject:item.avatartime];
    }
    
    if(item.gender!=nil){
        [query appendString:@"gender=?,"];
        [arguments addObject:item.gender];
    }
    
    if(item.sign!=nil){
        [query appendString:@"sign=?,"];
        [arguments addObject:item.sign];
    }
    
    
    [query appendString:@"isblock=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isblock]];
    
    [query appendString:@"age=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.age]];
    
    
    [query appendString:@"userhonorlevel=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.userhonorlevel]];
    
    [query appendString:@"topicblock=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.topicblock]];
    
    
    if(item.applymsg!=nil){
        [query appendString:@"applymsg=?,"];
        [arguments addObject:item.applymsg];
    }
    
    
    [query appendString:@"applystatus=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.applystatus]];
    
    [query appendString:@"applytype=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.applytype]];
    
    [query appendString:@"isSelected=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isSelected]];
    
    if(item.inputText!=nil){
        [query appendString:@"inputText=?,"];
        [arguments addObject:item.inputText];
    }
    
    [query appendString:@"isDel=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isDel]];
    
    
    if(item.uptime!=nil){
        [query appendString:@"uptime=?,"];
        [arguments addObject:item.uptime];
    }
    
    
    [query appendString:@"isread=?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.isread]];
    
    
    [query appendString:@")"];
    if([query hasSuffix:@",)"]){
        [query replaceCharactersInRange:NSMakeRange(query.length-2, 2) withString:@" "];
        [query stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
    //    WSLog(@"%@",query);
    [query appendFormat:@" where frienduid =%@ ",item.frienduid];
    
    //    WSLog(@"修改用户信息：%@",query);
    //    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    
    if(isOK && item.applymsglist!=nil && item.applymsglist.count>0){
        [self delApplyLeaveDB:item.frienduid];
        for (ApplyModel *cm in item.applymsglist) {
            [self saveApplyLeaveToDB:cm frienduid:item.frienduid];
        }

    }
    
    
    return isOK;
}


-(BOOL)delApplyDBWidthArray:(NSMutableArray *)items{
    if(!items || items.count<1){
        return NO;
    }
    int i=0;
    for (ApplyFriendModel *item in items) {
        item.applymsglist=nil;
        item.isDel=1;
        BOOL isUp=[self updateApplyToDB:item];
        if(isUp){
            i=i+1;
        }
        
        // 直接删除评论
        [self delApplyLeaveDB:item.frienduid];
    }
    if(i==items.count){
        return YES;
    }
    return NO;
}

-(BOOL)delApplyDB:(NSString *)uid{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE frienduid = '%@'",TutuApplyTable,uid];
    
    //删除任务中的题目
    query=[query stringByAppendingFormat:@";DELETE from %@ where uid = '%@'",TutuApplyLeaveTable,uid];
//    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    
    BOOL re = [_db executeUpdate:query];
    return re;
}

-(BOOL)delApplyLeaveDB:(NSString *)uid{
    //删除任务中的题目
    NSString *query=[NSString stringWithFormat:@"DELETE from %@ where frienduid = %@",TutuApplyLeaveTable,uid];
//    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    return [_db executeUpdate:query];
}

-(BOOL)delAllIsDelApplyDB{
    //删除任务中的题目
    NSString *query=[NSString stringWithFormat:@"DELETE from %@ where isDel=1",TutuApplyTable];
//    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    BOOL rs = [_db executeUpdate:query];

    return rs;
}

-(ApplyFriendModel *)findNewModel{
    ApplyFriendModel *afModel=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    query = [query stringByAppendingFormat:@" order by uptime desc  limit 1  "];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        // 不包含评论数据
        afModel=[self parseAFModel:rs];
    }
    [rs close];
    return afModel;
}


-(ApplyFriendModel *)findOldModel{
    ApplyFriendModel *afModel=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    query = [query stringByAppendingFormat:@" order by uptime asc limit 1 "];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        // 不包含评论数据
        afModel=[self parseAFModel:rs];
    }
    [rs close];
    return afModel;
}


-(ApplyFriendModel *)findModelWidthUID:(NSString *)friendUID{
    ApplyFriendModel *afModel=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    query = [query stringByAppendingFormat:@" where frienduid=%@ order by uptime desc ",friendUID];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        // 不包含评论数据
        afModel=[self parseAFModel:rs];
    }
    [rs close];
    return afModel;
}

-(NSMutableDictionary *)findAllApplyLeaves{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyLeaveTable];
    query = [query stringByAppendingFormat:@" order by addtime desc "];
    //    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        ApplyModel *item=[self parseApplyModelRs:rs];
        NSMutableArray *itemArr = [dict objectForKey:item.frienduid];
        if(itemArr==nil){
            itemArr=[[NSMutableArray alloc] init];
        }
        [itemArr addObject:item];
        [dict setObject:itemArr forKey:item.frienduid];
    }
    [rs close];
    return dict;
}

-(NSMutableArray *)findAppModelWidthUID:(NSString *)friendUid{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyLeaveTable];
    query = [query stringByAppendingFormat:@" where frienduid=%@ order by addtime desc ",friendUid];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
       [array addObject:[self parseApplyModelRs:rs]];
    }
    [rs close];
    return array;
}

-(NSMutableArray *)findAllApplyWithDel{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    query = [query stringByAppendingFormat:@" where isDel=1 "];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        // 不包含评论数据
        [array addObject:[self parseApplyModelRs:rs]];
    }
    [rs close];
    return array;
}


-(NSMutableArray *)findAllApplyWithIsRead:(BOOL)isread{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    query = [query stringByAppendingFormat:@" where isread=%d ",isread];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        // 不包含评论数据
        [array addObject:[self parseAFModel:rs]];
    }
    [rs close];
    
    
    
    return array;
}


-(BOOL)updateReadStatus:(NSMutableArray *)items{
    if(!items || items.count<1){
        return NO;
    }
    NSMutableString *friendID = [[NSMutableString alloc] init];
    // 拼接uid
    for (ApplyFriendModel *item in items) {
        [friendID appendFormat:@"%@,",item.frienduid];
    }
    
    [friendID appendString:@")"];
    if([friendID hasSuffix:@",)"]){
        [friendID replaceCharactersInRange:NSMakeRange(friendID.length-2, 2) withString:@""];
        [friendID stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",TutuApplyTable];
    
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    
    [query appendString:@"isread=? "];
    [arguments addObject:@"1"];
    
    //    WSLog(@"%@",query);
    [query appendFormat:@" where frienduid in(%@)",friendID];
    
//        WSLog(@"修改信息：%@",query);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}


-(NSMutableArray *)findAllWithPage:(int)page len:(int)length{
    if(page==0){
        page=1;
    }
//    WSLog(@"开始查询：%@",dateTransformString(@"yyyy-MM-dd HH:mm:ss.SSS",[NSDate date]));
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    
    query = [query stringByAppendingFormat:@" where isDel=0 ORDER BY uptime DESC limit %d offset %d ",length,(page-1)*length];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        // 不包含评论数据
        [array addObject:[self parseAFModel:rs]];
    }
    [rs close];
    
    
    [self addApplyLeaveModelToApply:array];
    
//    WSLog(@"结束查询：%@",dateTransformString(@"yyyy-MM-dd HH:mm:ss.SSS",[NSDate date]));
    return array;
}
- (NSMutableArray *)findAllApplyModel{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuApplyTable];
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        ApplyFriendModel *item=[self parseAFModel:rs];
        [array addObject:item];
    }
    [rs close];
    [self addApplyLeaveModelToApply:array];
    return array;
    
}
-(ApplyFriendModel *)parseAFModel:(FMResultSet *)rs{
   ApplyFriendModel *item=[ApplyFriendModel new];
   @try {
       item.frienduid=CheckNilValue([rs stringForColumn:@"frienduid"]);
       item.relation=[CheckNilValue([rs stringForColumn:@"relation"]) intValue];
       item.nickname=CheckNilValue([rs stringForColumn:@"nickname"]);
       item.avatartime=CheckNilValue([rs stringForColumn:@"avatartime"]);
       item.gender=CheckNilValue([rs stringForColumn:@"gender"]);
       item.sign=CheckNilValue([rs stringForColumn:@"sign"]);
       item.isblock=[CheckNilValue([rs stringForColumn:@"isblock"]) intValue];
       item.age=[CheckNilValue([rs stringForColumn:@"age"]) intValue];
       item.userhonorlevel=[CheckNilValue([rs stringForColumn:@"userhonorlevel"]) intValue];
       item.topicblock=[CheckNilValue([rs stringForColumn:@"topicblock"]) intValue];
       item.applymsg=CheckNilValue([rs stringForColumn:@"applymsg"]);
       item.applystatus=[CheckNilValue([rs stringForColumn:@"applystatus"]) intValue];
       item.applytype=[CheckNilValue([rs stringForColumn:@"applytype"]) intValue];
       item.applytime=CheckNilValue([rs stringForColumn:@"applytime"]);
       item.isSelected=[CheckNilValue([rs stringForColumn:@"isSelected"]) intValue];
       item.inputText=CheckNilValue([rs stringForColumn:@"inputText"]);
       item.uptime=CheckNilValue([rs stringForColumn:@"uptime"]);
       item.isDel=[CheckNilValue([rs stringForColumn:@"isDel"]) boolValue];
       item.isread=[CheckNilValue([rs stringForColumn:@"isread"]) boolValue];
   }
   @catch (NSException *exception) {
       
   }
   @finally {
       
   }
   return item;
}



-(ApplyModel *)parseApplyModelRs:(FMResultSet *)rs{
    ApplyModel *item=[ApplyModel new];
    @try {
        item.uid=[rs stringForColumn:@"uid"];
        item.frienduid=[rs stringForColumn:@"frienduid"];
        item.applymsg=[rs stringForColumn:@"applymsg"];
        item.isme=[[rs stringForColumn:@"isme"] boolValue];
        item.addtime=[rs stringForColumn:@"addtime"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


-(NSMutableArray *) addApplyLeaveModelToApply:(NSMutableArray *) arr{
    NSMutableDictionary *dicts=[self findAllApplyLeaves];
    for (ApplyFriendModel *item in arr) {
        item.applymsglist=[dicts objectForKey:item.frienduid];
    }
    return arr;
}


//////////////////////////////////////////////////////////////////////////
-(BOOL) clearTable{
    NSString * query = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = '%@'",TutuApplyTable,TutuApplyTable];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    NSString * query1 = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = '%@'",TutuApplyLeaveTable,TutuApplyLeaveTable];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    [_db executeUpdate:query];
    
    BOOL isOK=[_db executeUpdate:query1];
    return isOK;
}
@end
