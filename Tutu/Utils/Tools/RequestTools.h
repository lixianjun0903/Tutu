//
//  RequestTools.h
//  Tutu
//
//  Created by zhangxinyao on 14-10-23.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface RequestTools : NSObject


// 新粉丝数
@property(nonatomic,strong) NSString * newfanscount;

// 新动态数
@property(nonatomic,strong) NSString * newtipscount;

// 首页热门列表新增数
@property(nonatomic,strong) NSString * newhottopiccount;

// 首页关注列表新增数
@property(nonatomic,strong) NSString * newfollowtopiccount;

//关注页面  关注话题新消息数
@property(nonatomic,strong) NSString * newfollowhtcount;
//关注页面  关注位置新消息数
@property(nonatomic,strong) NSString * newfollowpoicount;



+(RequestTools *) getInstance;

/****
 * 发送get请求
 * finished，成功或失败均会请求
 */
-(void)get:(NSString *)url isCache:(BOOL)isCache
completion:(void (^)(NSDictionary *dict))completeBlock
   failure:(void (^)(ASIHTTPRequest *request,NSString *message))failBlock
  finished:(void (^)(ASIHTTPRequest *request))finishBlock;


/***
 * 发送post请求
 * fileKey:上传文件的字段名称
 * filePath:上传文件的路径
 */
-(void)post:(NSString *)url
   filePath:(NSString *)filepath
    fileKey:(NSString *) key
     params:(NSMutableDictionary *) dict
 completion:(void (^)(NSDictionary *dict))completeBlock
    failure:(void (^)(ASIFormDataRequest *request,NSString *message))failBlock
   finished:(void (^)(ASIFormDataRequest *request))finishBlock;



/**
 * 根据消息通道获取实时数量
 * extra
 **/
-(void)doCleanMessageNum;

-(void)setNewsCountWithDict:(NSDictionary *)dict;

-(void)doSetNewfollowtopiccount:(NSString *)newfollowcount;

-(void)doSetNewFanscount:(NSString *)newfriendcount;

-(void)doSetNewhottopiccount:(NSString *)newhotcount;

-(void)doSetNewtipscount:(NSString *)newtipscount;

-(void)doSetNewfollowpoicount:(NSString *)newfollowpoicount;

-(void)doSetNewfollowhtcount:(NSString *)newfollowhtcount;

/**
 * 获取好友数量
 */
-(int)getNewfanscount;

/**
 * 获取动态数量
 */
-(int)getTipsNum;

/**
 * 获取首页关注数量
 */
-(int)getNewfollowtopiccount;

/**
 * 获取首页热门数量
 */
-(int)getNewhottopiccount;

/**
 * 获取个人页关注话题数量
 */
-(int)getNewfollowhtcount;

/**
 * 获取个人页关注位置数量
 */
-(int)getNewfollowpoicount;

/**
 * 获取私信数量
 */
-(int)getMessagesNum;

/**
 * 获取消息总数
 */
-(int)getAllNewsNum;


@end
