//
//  TopicCacheDB.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-4.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "TopicCacheDB.h"

@implementation TopicCacheDB


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
                       (autoid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, \
                       topicid VARCHAR(50), \
                       sourcepath VARCHAR, \
                       smallcontent VARCHAR, \
                       commentnum VARCHAR, \
                       time VARCHAR, \
                       formattime VARCHAR, \
                       zan VARCHAR, \
                       uid VARCHAR, \
                       views VARCHAR, \
                       location VARCHAR, \
                       type VARCHAR, \
                       videourl VARCHAR, \
                       times VARCHAR, \
                       width VARCHAR, \
                       height VARCHAR, \
                       isLike VARCHAR, \
                       emptyCommentText VARCHAR, \
                       favorite VARCHAR, \
                       nickname VARCHAR, \
                       avatar VARCHAR,\
                       localid VARCHAR, \
                       topicType VARCHAR, \
                       topicStatus VARCHAR, \
                       showtype INTEGER)",TutuTopic];
    //        BOOL res = [_db executeUpdate:sql];
    
    
    // TODO: 插入新的数据库
    NSString * sql2 = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ \
                       (autoid INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, \
                       commentid VARCHAR(50), \
                       topicid VARCHAR, \
                       uid VARCHAR, \
                       type VARCHAR, \
                       comment VARCHAR, \
                       commentbg VARCHAR, \
                       time VARCHAR, \
                       pid VARCHAR, \
                       pointX VARCHAR, \
                       pointY VARCHAR, \
                       nickname VARCHAR, \
                       avatar VARCHAR(100),\
                       localtopicid VARCHAR,\
                       localid VARCHAR)",TutuTopicComment];
    //        BOOL res = [_db executeUpdate:sql];
    [_db executeUpdate:sql1];
    [_db executeUpdate:sql2];
    
    
    
    //添加列,一个版本只用判断一次就可以了
    //检查是否有状态字段
    if(![self checkColumnName:TutuTopic columnName:@"topicDesc"]){
        NSString *addColumnSql=[NSString stringWithFormat:
                             @"ALTER TABLE %@ ADD COLUMN topicDesc VARCHAR ",TutuTopic];
        [_db executeUpdate:addColumnSql];
       
        
        NSString *addColumnSql2=[NSString stringWithFormat:
                                @"ALTER TABLE %@ ADD COLUMN shareType INTEGER ",TutuTopic];
        [_db executeUpdate:addColumnSql2];
    }
    
    if(![self checkColumnName:TutuTopic columnName:@"createtime"]){
        NSString *addColumnSql1=[NSString stringWithFormat:
                                @"ALTER TABLE %@ ADD COLUMN createtime VARCHAR ",TutuTopic];
        NSString *addColumnSql2=[NSString stringWithFormat:
                                @"ALTER TABLE %@ ADD COLUMN reposttopicid VARCHAR ",TutuTopic];
        NSString *addColumnSql3=[NSString stringWithFormat:
                                @"ALTER TABLE %@ ADD COLUMN roottopicid VARCHAR ",TutuTopic];
        NSString *addColumnSql4=[NSString stringWithFormat:
                                @"ALTER TABLE %@ ADD COLUMN fromrepost VARCHAR ",TutuTopic];
        
        NSString *addColumnSql5=[NSString stringWithFormat:
                                 @"ALTER TABLE %@ ADD COLUMN userisrepost VARCHAR ",TutuTopic];
        
        [_db executeUpdate:addColumnSql1];
        [_db executeUpdate:addColumnSql2];
        [_db executeUpdate:addColumnSql3];
        [_db executeUpdate:addColumnSql4];
        [_db executeUpdate:addColumnSql5];
    }
}

-(BOOL)saveTopic:(TopicModel *)item{
    if(item.topicid!=nil){
        TopicModel *checkModel=[self checkTopicModel:item.topicid topicStatus:[item.topicStatus intValue]];
        if(checkModel!=nil && checkModel.topicid!=nil){
            return NO;
        }
    }
    if(item.localid!=nil){
        TopicModel *checkModel=[self checkTopicModelWithLocalId:item.localid topicStatus:[item.topicStatus intValue]];
        if(checkModel!=nil && checkModel.topicid!=nil){
            return NO;
        }
    }
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuTopic];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if (item.topicid) {
        [keys appendString:@"topicid,"];
        [values appendString:@"?,"];
        [arguments addObject:item.topicid];
    }else {
        return NO;
    }
    
    
    [keys appendString:@"sourcepath,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.sourcepath)];

    [keys appendString:@"smallcontent,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.smallcontent)];

    
    [keys appendString:@"commentnum,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.commentnum)];
    
    [keys appendString:@"time,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.time)];
    
    [keys appendString:@"formattime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.formattime)];
    
    [keys appendString:@"zan,"];
    [values appendString:@"?,"];
    [arguments addObject:item.zan==nil?@"0":item.zan];
    
    [keys appendString:@"uid,"];
    [values appendString:@"?,"];
    [arguments addObject:item.uid];
    
    [keys appendString:@"views,"];
    [values appendString:@"?,"];
    int views = item.views == 0 ? 0:item.views;
    [arguments addObject:@(views)];
    
    [keys appendString:@"location,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.location)];
    
    [keys appendString:@"type,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.type]];
    
    [keys appendString:@"videourl,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.videourl)];
    
    [keys appendString:@"times,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%f",item.times]];
    
    [keys appendString:@"width,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%f",item.width]];
    
    [keys appendString:@"height,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%f",item.height]];
    
    [keys appendString:@"isLike,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.isLike]];
    
    [keys appendString:@"emptyCommentText,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.emptyCommentText)];
    
    [keys appendString:@"favorite,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",item.favorite]];
    
    [keys appendString:@"nickname,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.nickname)];
    
    
    [keys appendString:@"avatar,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.avatar)];
    
    [keys appendString:@"localid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.localid)];
    
    [keys appendString:@"topicType,"];
    [values appendString:@"?,"];
    [arguments addObject:item.topicType==nil?@"0":item.topicType];
    
    [keys appendString:@"topicStatus,"];
    [values appendString:@"?,"];
    [arguments addObject:item.topicStatus==nil?@"0":item.topicStatus];
    
    [keys appendString:@"topicDesc,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.topicDesc)];
    
    
    [keys appendString:@"shareType,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.shareType]];
    
    
    [keys appendString:@"showtype,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.showtype]];
    
    
    [keys appendString:@"createtime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.createtime)];
    
    [keys appendString:@"reposttopicid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.reposttopicid)];
    
    [keys appendString:@"roottopicid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.roottopicid)];
    
    [keys appendString:@"fromrepost,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.fromrepost]];
    
    
    [keys appendString:@"userisrepost,"];
    [values appendString:@"?,"];
    [arguments addObject:[NSString stringWithFormat:@"%d",(int)item.userisrepost]];
    
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
//        NSLog(@"%@",query);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    if(item.commentList!=nil && item.commentList.count>0){
        for (CommentModel *cm in item.commentList) {
            [self saveTopicComment:cm];
        }
    }
    
    return isOK;
}

-(BOOL)saveTopicComment:(CommentModel *)item{
    
    NSMutableString * query = [NSMutableString stringWithFormat:@"INSERT INTO %@ ",TutuTopicComment];
    NSMutableString * keys = [NSMutableString stringWithFormat:@" ("];
    NSMutableString * values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    
    if (item.commentid) {
        [keys appendString:@"commentid,"];
        [values appendString:@"?,"];
        [arguments addObject:item.commentid];
    }else {
        return NO;
    }
    
    if (item.topicid) {
        [keys appendString:@"topicid,"];
        [values appendString:@"?,"];
        [arguments addObject:item.topicid];
    }else {
        return NO;
    }
    
    [keys appendString:@"uid,"];
    [values appendString:@"?,"];
    [arguments addObject:item.uid];
    
    [keys appendString:@"type,"];
    [values appendString:@"?,"];
    [arguments addObject:item.type];
    
    
    [keys appendString:@"comment,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.comment)];
    
    
    [keys appendString:@"commentbg,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.commentbg)];
    
    
    [keys appendString:@"time,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.time)];
    
    
    [keys appendString:@"pid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.pid)];
    
    
    [keys appendString:@"pointX,"];
    [values appendString:@"?,"];
    [arguments addObject:item.pointX];
    
    
    [keys appendString:@"pointY,"];
    [values appendString:@"?,"];
    [arguments addObject:item.pointY];
    
    
    [keys appendString:@"nickname,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.nickname)];
    
    
    [keys appendString:@"avatar,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.avatar)];
    
    
    [keys appendString:@"localtopicid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.localtopicid)];
    
    [keys appendString:@"localid,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.localid)];
    
    
    [keys appendString:@"invideotime,"];
    [values appendString:@"?,"];
    [arguments addObject:CheckNilValue(item.invideotime)];
    
    
    [keys appendString:@")"];
    [values appendString:@")"];
    [query appendFormat:@" %@ VALUES%@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    
    //    NSLog(@"%@",query);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    return isOK;
}

-(BOOL)updateTopicNickName:(NSString *)uid nickName:(NSString *)nickname{
    NSMutableString * query = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",TutuTopic];
    NSMutableArray * arguments = [NSMutableArray arrayWithCapacity:5];
    if ([@"" isEqual:CheckNilValue(uid)]){
        return NO;
    }
    
    if(CheckNilValue(nickname)!=nil){
        [query appendString:@"nickname=?,"];
        [arguments addObject:nickname];
    }

    [query appendString:@")"];
    if([query hasSuffix:@",)"]){
        [query replaceCharactersInRange:NSMakeRange(query.length-2, 2) withString:@" "];
        [query stringByReplacingOccurrencesOfString:@",)" withString:@""];
    }
    //    WSLog(@"%@",query);
    [query appendFormat:@" where uid =%@ ",uid];
    
    //    WSLog(@"修改用户信息：%@",query);
    //    WSLog(@"%@",[arguments componentsJoinedByString:@","]);
    BOOL isOK=[_db executeUpdate:query withArgumentsInArray:arguments];
    
    return isOK;
}


/***
 * 删除题目
 **/
-(BOOL)deleteTopicByTopicID:(NSString *)topicID{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE topicid = '%@'",TutuTopic,topicID];
    
    //删除任务中的题目
    query=[query stringByAppendingFormat:@";DELETE from %@ where topicId = '%@'",TutuTopicComment,topicID];
    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    return [_db executeUpdate:query];
}

-(BOOL)deleteTopicByTopicID:(NSString *)topicID withType:(TopicStatusValue)type{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE topicid = '%@' and topicStatus=%d ",TutuTopic,topicID,(int)type];
    
    //删除任务中的题目
    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    return [_db executeUpdate:query];
}

-(BOOL)deleteCommonWithLoaclId:(NSString *)localid{
    NSString * query = [NSString stringWithFormat:@"DELETE from %@ where localid = '%@'",TutuTopicComment,localid];

    //删除主题中的评论
    query=[query stringByAppendingFormat:@";DELETE from %@ where localtopicid = '%@'",TutuTopicComment,localid];
//    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    return [_db executeUpdate:query];
}

-(BOOL)deleteTopicWithLoaclId:(NSString *)localid{
    NSString * query = [NSString stringWithFormat:@"DELETE FROM %@ WHERE localid = '%@'",TutuTopic,localid];
//    WSLog(@"%@",query);
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    return [_db executeUpdate:query];
}


-(NSMutableArray *)findTopicCommentWithTopicId:(NSString *)topicid page:(int)page len:(int)length{
    if(page==0){
        page=1;
    }
    
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopicComment];
    
    query = [query stringByAppendingFormat:@" where topicid='%@' ORDER BY time DESC limit %d offset %d ",topicid,length,(page-1)*length];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [array addObject:[self parseCommentModelRs:rs]];
    }
    [rs close];
    return array;
}

-(NSMutableArray *)findTopicCommentWithLocalTopicId:(NSString *)localtopicid{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopicComment];
    
    query = [query stringByAppendingFormat:@" where localtopicid='%@' ORDER BY time DESC",localtopicid];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [array addObject:[self parseCommentModelRs:rs]];
    }
    [rs close];
    return array;
}



-(NSMutableArray *)findTopicWithType:(int)topicType{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    query = [query stringByAppendingFormat:@" where topicType=1 and type=%d ORDER BY time DESC",topicType];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [array addObject:[self parseTopicModelRs:rs len:0]];
    }
    [rs close];
    return array;
}

//只查询，非本地未上传主题的评论
-(NSMutableArray *)findLocalTopicComment{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopicComment];
    
    query = [query stringByAppendingFormat:@" where len(localid)>0 and len(topicid)>0 ORDER BY time DESC"];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [array addObject:[self parseCommentModelRs:rs]];
    }
    [rs close];
    return array;
}

-(TopicModel *)checkTopicModel:(NSString *)topicId topicStatus:(TopicStatusValue)type{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    query = [query stringByAppendingFormat:@" where topicType=0 and topicid='%@' and topicStatus=%d ORDER BY time DESC limit 1",topicId,(int)type];
//    WSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    
    TopicModel *model=nil;
    if ([rs next]) {
        model=[self parseTopicModelRs:rs len:0];
    }
    [rs close];
    return model;
}

-(TopicModel *)checkTopicModelWithLocalId:(NSString *)localtopicid topicStatus:(TopicStatusValue)type{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    query = [query stringByAppendingFormat:@" where topicType=0 and localtopicid='%@' and topicStatus=%d ORDER BY time DESC limit 1",localtopicid,(int)type];
//    WSLog(@"%@",query);
    FMResultSet * rs = [_db executeQuery:query];
    
    TopicModel *model=nil;
    if ([rs next]) {
        model=[self parseTopicModelRs:rs len:0];
    }
    [rs close];
    return model;
}

-(TopicModel *)getNewTopicModel:(TopicStatusValue)type{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    query = [query stringByAppendingFormat:@" where topicType=0 and topicStatus=%d ORDER BY time DESC  limit 1 ",(int)type];
    
    FMResultSet * rs = [_db executeQuery:query];
    
    TopicModel *model=nil;
    if ([rs next]) {
        model=[self parseTopicModelRs:rs len:0];
    }
    [rs close];
    return model;
}

-(TopicModel *)getOldTopicModel:(TopicStatusValue)type{
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    query = [query stringByAppendingFormat:@" where topicType=0 and topicStatus=%d ORDER BY time ASC limit 1 ",(int)type];
    
    FMResultSet * rs = [_db executeQuery:query];
    
    TopicModel *model=nil;
    if ([rs next]) {
        model=[self parseTopicModelRs:rs len:0];
    }
    [rs close];
    return model;
}

-(NSMutableArray *)getCacheListWithType:(TopicStatusValue)topicType{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    
    //如果是发布，获取本地未发布数据和线上数据
    if(topicType==TopicStatusSend){
        query = [query stringByAppendingFormat:@" where topicType=1 or topicStatus=%d ORDER BY createtime DESC",(int)topicType];
    }else{
        query = [query stringByAppendingFormat:@" where topicType=0 and topicStatus=%d ORDER BY createtime DESC",(int)topicType];
    }
    
//    WSLog(@"%@",query);

    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        // 不查询评论
        [array addObject:[self parseTopicModelRs:rs len:0 showComment:NO]];
    }
    [rs close];
    return array;
}


-(NSMutableArray *)getCacheListWithType:(TopicStatusValue)topicType startTime:(NSString *)time{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuTopic];
    //如果是发布，获取本地未发布数据和线上数据
    if(topicType==TopicStatusSend){
        query = [query stringByAppendingFormat:@" where topicType=1 or topicStatus=%d and time<%@ ORDER BY time DESC",(int)topicType,time];
    }else{
        query = [query stringByAppendingFormat:@" where topicType=0 and topicStatus=%d and time<%@ ORDER BY time DESC",(int)topicType,time];
    }
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    while ([rs next]) {
        [array addObject:[self parseTopicModelRs:rs len:0]];
    }
    [rs close];
    return array;
}


-(TopicModel *)parseTopicModelRs:(FMResultSet *)rs len:(int) len{
    return [self parseTopicModelRs:rs len:len showComment:YES];
}

-(TopicModel *)parseTopicModelRs:(FMResultSet *)rs len:(int) len showComment:(BOOL) ishowComment{
    TopicModel *item=[TopicModel new];
    @try {
        item.topicid=[rs stringForColumn:@"topicid"];
        item.sourcepath=[rs stringForColumn:@"sourcepath"];
        item.smallcontent=[rs stringForColumn:@"smallcontent"];
        item.commentnum=[rs stringForColumn:@"commentnum"];
        item.time=[rs stringForColumn:@"time"];
        item.formattime=[rs stringForColumn:@"formattime"];
        item.zan=[rs stringForColumn:@"zan"];
        item.uid=[rs stringForColumn:@"uid"];
        item.views=[[rs stringForColumn:@"views"] intValue];
        item.location=[rs stringForColumn:@"location"];
        item.type=[[rs stringForColumn:@"type"] intValue];
        item.videourl=[rs stringForColumn:@"videourl"];
        item.times=[[rs stringForColumn:@"times"] floatValue];
        item.width=[[rs stringForColumn:@"width"] floatValue];
        item.height=[[rs stringForColumn:@"height"] floatValue];
        item.isLike=[[rs stringForColumn:@"isLike"] boolValue];
        item.emptyCommentText=[rs stringForColumn:@"emptyCommentText"];
        item.favorite=[[rs stringForColumn:@"favorite"] boolValue];
        item.nickname=[rs stringForColumn:@"nickname"];
        item.avatar=[rs stringForColumn:@"avatar"];
        item.localid=[rs stringForColumn:@"localid"];
        item.topicType=[rs stringForColumn:@"topicType"];
        item.topicStatus=[rs stringForColumn:@"topicStatus"];
        item.showtype=[[rs stringForColumn:@"showtype"] intValue];
        item.topicDesc=CheckNilValue([rs stringForColumn:@"topicDesc"]);
        NSString *shareType=[rs stringForColumn:@"shareType"];
        if([@"" isEqual:CheckNilValue(shareType)]){
            item.shareType=0;
        }else{
            item.shareType=[shareType intValue];
        }
        
        item.reposttopicid=[rs stringForColumn:@"reposttopicid"];
        item.roottopicid=[rs stringForColumn:@"roottopicid"];
        item.createtime=[rs stringForColumn:@"createtime"];
        item.fromrepost=[[rs stringForColumn:@"fromrepost"] intValue];
        
        item.userisrepost=[[rs stringForColumn:@"userisrepost"] intValue];
        
        if(ishowComment){
            if(len>0){
                item.commentList=[self findTopicCommentWithTopicId:item.topicid page:1 len:len];
            }else{
                item.commentList=[self findTopicCommentWithLocalTopicId:item.localid];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


-(CommentModel *)parseCommentModelRs:(FMResultSet *)rs{
    CommentModel *item=[CommentModel new];
    @try {
        item.commentid=[rs stringForColumn:@"commentid"];
        item.topicid=[rs stringForColumn:@"topicid"];
        item.uid=[rs stringForColumn:@"uid"];
        item.type=[rs stringForColumn:@"type"];
        item.comment=[rs stringForColumn:@"comment"];
        item.commentbg=[rs stringForColumn:@"commentbg"];
        item.time=[rs stringForColumn:@"time"];
        item.pid=[rs stringForColumn:@"pid"];
        item.pointX=[rs stringForColumn:@"pointX"];
        item.pointY=[rs stringForColumn:@"pointY"];
        item.nickname=[rs stringForColumn:@"nickname"];
        item.avatar=[rs stringForColumn:@"avatar"];
        item.localtopicid=[rs stringForColumn:@"localtopicid"];
        item.localid=[rs stringForColumn:@"localid"];
        item.invideotime=[rs stringForColumn:@"invideotime"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


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
                        update sqlite_sequence SET seq = 0 where name = '%@';",TutuTopic,TutuTopic];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    
    query = [query stringByAppendingFormat:@";delete from %@ ;\
             update sqlite_sequence SET seq = 0 where name = '%@';",TutuTopicComment,TutuTopicComment];
    BOOL isOK=[_db executeUpdate:query];
    return isOK;
}



@end
