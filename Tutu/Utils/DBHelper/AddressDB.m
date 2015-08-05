//
//  AddressDB.m
//  Tutu
//
//  Created by 刘大治 on 14/12/10.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "AddressDB.h"
#import "TutuDBManager.h"
#import "AddressBookDictionary.h"

@implementation AddressDB

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
                       local_id VARCHAR(50), \
                       phonenumber VARCHAR, \
                       relation INTEGER, \
                       tutuid VARCHAR, \
                       mytutuid VARCHAR, \
                       status INTEGER, \
                       createtime VARCHAR, \
                       modifytime VARCHAR)",TutuContast];
    [_db executeUpdate:sql1];
}


-(BOOL)saveListContanst:(NSMutableArray *)arr{
    if(arr==nil || arr.count==0){
        return NO;
    }
    [_db beginTransaction];
    BOOL isRollBack = NO;
    @try {
        for (LinkManModel *item in arr) {
            LinkManModel *m=[self findModelWithMyTutuId:item.mytutuid lid:item.local_id phones:@[item.phonenumber]];
            
            NSString *date=dateTransformString(@"yyyy-MM-dd hh:mm:ss", [NSDate date]);
            if(m==nil || m.local_id==nil){
                 NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(local_id,phonenumber,relation,tutuid,mytutuid,status,createtime,modifytime) VALUES (?,?,?,?,?,?,?,?)",TutuContast];
                NSArray *items=[[NSArray alloc] initWithObjects:item.local_id,item.phonenumber,[NSString stringWithFormat:@"%d",item.relation],item.tutuid,item.mytutuid,@"0",date,date, nil];
                BOOL a = [_db executeUpdate:sql withArgumentsInArray:items];
                if (!a) {
                    NSLog(@"插入失败1");
                }
            }else{
                NSString *sql =[NSString stringWithFormat:@"update %@ set relation=%d,modifytime=? where local_id=? and tutuid=? and mytutuid=? and phonenumber=? ",TutuContast,item.relation];
                
                NSArray *items=[[NSArray alloc] initWithObjects:date,item.local_id,item.tutuid,item.mytutuid,item.phonenumber, nil];
                
                BOOL a = [_db executeUpdate:sql withArgumentsInArray:items];
                if (!a) {
                    NSLog(@"修改失败1");
                }
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
        }
    }
    
    return !isRollBack;
}


- (BOOL) updateContanst:(LinkManModel *)item{
    LinkManModel *m=[self findModelWithMyTutuId:item.mytutuid lid:item.local_id phones:@[item.phonenumber]];
    BOOL a=false;
    NSString *date=dateTransformString(@"yyyy-MM-dd hh:mm:ss", [NSDate date]);
    if(m==nil || m.local_id==nil){
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(local_id,phonenumber,relation,tutuid,mytutuid,status,createtime,modifytime) VALUES (?,?,?,?,?,?,?,?)",TutuContast];
        NSArray *items=[[NSArray alloc] initWithObjects:item.local_id,item.phonenumber,[NSString stringWithFormat:@"%d",item.relation],item.tutuid,item.mytutuid,@"0",date,date, nil];
        a = [_db executeUpdate:sql withArgumentsInArray:items];
        if (!a) {
            NSLog(@"插入失败1");
        }
    }else{
        NSString *sql =[NSString stringWithFormat:@"update %@ set relation=%d,modifytime=? where local_id=? and tutuid=? and mytutuid=? and phonenumber=? ",TutuContast,item.relation];
        
        NSArray *items=[[NSArray alloc] initWithObjects:date,item.local_id,item.tutuid,item.mytutuid,item.phonenumber, nil];
        
        a = [_db executeUpdate:sql withArgumentsInArray:items];
        if (!a) {
            NSLog(@"修改失败1");
        }
    }
    
    return a;
}


//判断是否已经添加
-(LinkManModel *)findModelWithMyTutuId:(NSString *)mytutuid lid:(NSString *)localid phones:(NSArray *)phones{
    LinkManModel *model=nil;
    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ ",TutuContast];
    
    NSString *phoneNumbers=@"";
    for (NSString *p in phones) {
        phoneNumbers=[NSString stringWithFormat:@"%@,'%@'",phoneNumbers,p];
    }
    phoneNumbers=[NSString stringWithFormat:@"#%@",phoneNumbers];
    phoneNumbers=[phoneNumbers stringByReplacingOccurrencesOfString:@"#," withString:@""];
    
    query = [query stringByAppendingFormat:@" where mytutuid=%@ and local_id=%@ and phonenumber in(%@) ORDER BY relation DESC",mytutuid,localid,phoneNumbers];
//    WSLog(@"%@",query);
    
    FMResultSet * rs = [_db executeQuery:query];
    
    if ([rs next]) {
        model=[self parseLinkManModelRs:rs];
    }
    [rs close];
    return model;
}


-(NSMutableArray *)findAllContacts{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    
    
    AddressBookDictionary * add = [[AddressBookDictionary alloc]init];
    NSArray *items = [add getAllRecord];
    for (NSDictionary *item in items) {
        NSMutableArray *parr=[[NSMutableArray alloc] init];
        @try {
            NSArray *phones=[item objectForKey:@"phone"];
            
            for (NSDictionary *p in phones) {
                NSString *dp=[p objectForKey:@"detail"];
                
                NSString *pnum=@"";
                unichar c;
                for(int i=0;i<dp.length;i++){
                    c=[dp characterAtIndex:i];
                    if(isnumber(c)){
                        pnum=[NSString stringWithFormat:@"%@%c",pnum,c];
                    }
                }
                if([pnum length]<11){
                    continue;
                }
                
                pnum=[pnum substringWithRange:NSMakeRange([pnum length]-11, 11)];
                
//                if(validateMobile(pnum)){
                if([pnum hasPrefix:@"1"]){
                    [parr addObject:pnum];
                }
            }
        }
        @catch (NSException *exception) {
            WSLog(@"")
        }
        @finally {
            
        }
        
        LinkManModel *model=[LinkManModel new];
        /*
        UIImage *himg=[item objectForKey:@"headerImage"];
        if(himg==nil){
            himg=[UIImage imageNamed:@"avatar_default"];
        }
        model.avatar=himg;
         */
        model.nickName= CheckNilValue([item objectForKey:@"name"]);
//        if (model.nickName.length == 0) {
//            model.fristLetter = @"#";
//            model.pinyin = @"#";
//        }else{
//            model.fristLetter = [ChineseToPinyin firstPinyinCharacter:model.nickName];
//            model.pinyin = [ChineseToPinyin pinyinFromChiniseString:model.nickName];
//        }
        model.mytutuid=[[LoginManager getInstance] getUid];
        model.local_id=[item objectForKey:@"local_id"];
        model.createtime=[item objectForKey:@"first"];
        model.modifytime=[item objectForKey:@"last"];
        
        LinkManModel *cm=[self findModelWithMyTutuId:model.mytutuid lid:model.local_id phones:parr];
        if(cm!=nil){
            model.tutuid=cm.tutuid;
            model.relation=cm.relation;
            model.phonenumber=cm.phonenumber;
            model.status=cm.status;
        }else{
            model.tutuid=@"";
            model.relation= -1;
            if(parr.count >0){
                model.phonenumber=[parr objectAtIndex:0];
            }else{
                model.phonenumber=@"";
            }
            model.status=@"0";
        }
        if (model.pinyin == nil) {
            model.pinyin = @"";
        }
        [array addObject:model];
    }
            
    return array;
}


-(LinkManModel *)parseLinkManModelRs:(FMResultSet *)rs{
    LinkManModel *item=[LinkManModel new];
    @try {
        item.local_id=[rs stringForColumn:@"local_id"];
        item.phonenumber=[rs stringForColumn:@"phonenumber"];
        item.relation=[[rs stringForColumn:@"relation"] intValue];
        item.tutuid=[rs stringForColumn:@"tutuid"];
        item.mytutuid=[rs stringForColumn:@"mytutuid"];
        item.status=[rs stringForColumn:@"status"];
        item.createtime=[rs stringForColumn:@"createtime"];
        item.modifytime=[rs stringForColumn:@"modifytime"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return item;
}


//////////////////////////////////////////////////////////////////////////
-(BOOL) clearTable{
    NSString * query = [NSString stringWithFormat:@"delete from %@ ;\
                        update sqlite_sequence SET seq = 0 where name = 'table_name'; %@",TutuContast,TutuContast];
    //    [AppDelegate showStatusWithText:@"删除一条数据" duration:2.0];
    BOOL isOK=[_db executeUpdate:query];
    return isOK;
}


@end
