//
//  RCIMClient.h
//  RongIM
//
//  Created by Heq.Shinoda on 14-6-13.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#include "RCClientDelegate.h"

@class RCNotificationMessage;
@class RCStatusMessage;
@class RCConversation;

/**
 *  IM 客户端核心类。
 *  <p/>
 *  所有 IM 相关方法、监听器都由此调用和设置。
 */
@interface RCIMClient : NSObject

/**
 *  获取通讯能力库的核心类单例。
 *
 *  @return 通讯能力库的核心类单例。
 */
+(instancetype)sharedRCIMClient;

//+(void)setOptions:(RCOptions)options;

/**
 *  初始化 SDK。
 *
 *  @param appKey       开发者平台(<a src="https://developer.rongcloud.cn">developer.rongcloud.cn</>)申请的应用 Id。
 *  @param deviceToken  用于 Apple Push Notification Service 的设备唯一标识。
 */
+(void)init:(NSString*)appKey deviceToken:(NSData*)deviceToken;

/**
 *  注册消息类型，如果对消息类型进行扩展，可以忽略此方法。
 *
 *  @param messageClass   消息类型名称，对应的继承自 RCMessageContent 的消息类型。
 */

+(void)registerMessageType:(Class)messageClass;

/**
 *  连接服务器。
 *
 *  @param token    从服务端获取的用户身份令牌（Token）。
 *  @param delegate 连接的回调。
 */
+(void)connect:(NSString*)token delegate:(id<RCConnectDelegate>)delegate;

/**
 *  重新连接服务器。
 *
 *  @param delegate 连接回调。
 */
+(void)reconnect:(id<RCConnectDelegate>)delegate;

/**
 *  重新连接服务器。
 *
 *  @param reconnectBlock 重连回调block
 */
-(void)reconnect:(void(^)(int status))reconnectBlock;

/**
 *  断开连接。
 *
 *  @param isReceivePush 是否接收回调。
 */
-(void)disconnect:(BOOL)isReceivePush;

/**
 *  断开连接。
 */
-(void)disconnect;

/**
 *  设置DeviceToken
 *
 *  @param deviceToken 从苹果服务器获取的设备唯一标识
 */
-(void)setDeviceToken:(NSData*)deviceToken;

/**
 *  获取DeviceToken
 *
 *  @return return DeviceToken
 */
-(NSData*)getDeviceToken;

/**
 *  获取会话列表,会话列表按照时间从前往后排列，如果有置顶会话，则置顶会话在前。
 *
 *  @param conversationTypes 会话类型,会话类型枚举转换成NSNumber数组
 *
 *  @return 会话列表
 */
-(NSArray*)getConversationList:(NSArray*)conversationTypes;

/**
 *  获取会话信息。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         会话 Id。
 *
 *  @return 会话信息。
 */
-(RCConversation*)getConversation:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  从会话列表中移除某一会话，但是不删除会话内的消息。
 *
 *  如果此会话中有新的消息，该会话将重新在会话列表中显示，并显示最近的历史消息。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *
 *  @return 是否移除成功。
 */
-(BOOL)removeConversation:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  设置某一会话为置顶或者取消置顶。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param isTop            是否置顶。
 *
 *  @return 是否设置成功。
 */
-(BOOL)setConversationToTop:(RCConversationType)conversationType targetId:(NSString*)targetId isTop:(BOOL)isTop;

/**
 *  获取所有未读消息数。
 *
 *  @return 未读消息数。
 */
-(NSInteger)getTotalUnreadCount;

/**
 *  获取来自某用户（某会话）的未读消息数。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *
 *  @return 未读消息数。
 */
-(NSInteger)getUnreadCount:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  获取某会话类型的未读消息数.
 *
 *  @param conversationTypes 会话类型
 *
 *  @return 未读消息数。
 */
-(NSInteger)getUnreadCount:(NSArray*)conversationTypes;

/**
 *  获取最新消息记录。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。
 *  @param count            要获取的消息数量。
 *
 *  @return 最新消息记录，按照时间顺序从新到旧排列。
 */
-(NSArray*)getLatestMessages:(RCConversationType)conversationType targetId:(NSString*)targetId count:(int)count;

/**
 *  获取历史消息记录。
 *
 *  @param conversationType 会话类型。不支持传入 RCConversationType.CHATROOM。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param oldestMessageId  最后一条消息的 Id，获取此消息之前的 count 条消息；如果传入 -1，则从最新一条消息开始获取。
 *  @param count            要获取的消息数量。
 *
 *  @return 历史消息记录，按照时间顺序新到旧排列。
 */
-(NSArray*)getHistoryMessages:(RCConversationType)conversationType targetId:(NSString*)targetId oldestMessageId:(long)oldestMessageId count:(int)count;

/**
 *  获取历史消息记录。
 *
 *  @param conversationType 会话类型。不支持传入 RCConversationType.CHATROOM。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param objectName       消息类型
 *  @param oldestMessageId  最后一条消息的 Id，获取此消息之前的 count 条消息；如果传入 -1，则从最新一条消息开始获取。
 *  @param count            要获取的消息数量。
 *
 *  @return 历史消息记录，按照时间顺序新到旧排列。
 */
-(NSArray*)getHistoryMessages:(RCConversationType)conversationType targetId:(NSString*)targetId objectName:(NSString *)objectName oldestMessageId:(long)oldestMessageId count:(int)count;

/**
 *  删除指定的一条或者一组消息。
 *
 *  @param messageIds 要删除的消息 Id 列表。
 *
 *  @return 是否删除成功。
 */
-(BOOL)deleteMessages:(NSArray*)messageIds;

/**
 *  清空某一会话的所有聊天消息记录。
 *
 *  @param conversationType 会话类型。不支持传入 RCConversationType.CHATROOM。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *
 *  @return 是否清空成功。
 */
-(BOOL)clearMessages:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  清除消息未读状态。
 *
 *  @param conversationType 会话类型。不支持传入 RCConversationType.CHATROOM。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *
 *  @return 是否清空成功。
 */
-(BOOL)clearMessagesUnreadStatus:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  清空会话列表.
 *
 *  @param conversationtypes 会话类型,会话类型枚举转换成NSNumber数组。
 *
 *  @return 操作结果
 */
-(BOOL)clearConversations:(NSArray *)conversationtypes;

/**
 *  设置消息的附加信息，此信息只保存在本地。
 *
 *  @param messageId 消息 Id。
 *  @param value     消息附加信息，最大 1024 字节。
 *
 *  @return 是否设置成功。
 */
-(BOOL)setMessageExtra:(long)messageId value:(NSString*)value;

/**
 *  设置接收到的消息状态。
 *
 *  @param messageId      消息 Id。
 *  @param receivedStatus 接收到的消息状态。
 */
-(BOOL)setMessageReceivedStatus:(long)messageId receivedStatus:(RCReceivedStatus)receivedStatus;

/**
 *  获取某一会话的文字消息草稿。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *
 *  @return 草稿的文字内容。
 */
-(NSString*)getTextMessageDraft:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  保存文字消息草稿。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param content          草稿的文字内容。
 *
 *  @return 是否保存成功。
 */
-(BOOL)saveTextMessageDraft:(RCConversationType)conversationType targetId:(NSString*)targetId content:(NSString*)content;

/**
 *  清除某一会话的文字消息草稿。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *
 *  @return 是否清除成功。
 */
-(BOOL)clearTextMessageDraft:(RCConversationType)conversationType targetId:(NSString*)targetId;

/**
 *  获取讨论组信息和设置。此方法后续版本会废弃。
 *
 *  @param discussionId 讨论组 Id。
 *  @param delegate     获取讨论组的回调。
 *  @param userData     用户自定义数据，该值会在 delegate 中返回。
 */
-(void)getDiscussion:(NSString*)discussionId delegate:(id<RCGetDiscussionDelegate>)delegate object:(id)userData;

/**
 *  获取讨论组信息和设置。
 *
 *  @param discussionId 讨论组 Id。
 *  @param completion   调用完成的处理。
 *  @param error        调用返回的错误信息。
 */
-(void)getDiscussion:(NSString*)discussionId completion:(void (^)(RCDiscussion* discussion))completion error:(void (^)(RCErrorCode status))error;

/**
 *  设置讨论组名称
 *
 *  @param targetId       讨论组 Id。
 *  @param discussionName 讨论组名称。
 *  @param completion     调用完成的处理。
 *  @param error          调用返回的错误信息。
 */
-(void)setDiscussionName:(NSString*)targetId name:(NSString*)discussionName completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  创建讨论组。此方法后续版本会废弃。
 *
 *  @param name       讨论组名称，如：当前所有成员的名字的组合。
 *  @param userIdList 讨论组成员 Id 列表。
 *  @param delegate   创建讨论组成功后的回调。
 *  @param userData   用户自定义数据，该值会在 delegate 中返回。
 */
-(void)createDiscussion:(NSString*)name userIdList:(NSArray*)userIdList delegate:(id<RCCreateDiscussionDelegate>)delegate object:(id)userData;

/**
 *  创建讨论组。
 *
 *  @param name       讨论组名称，如：当前所有成员的名字的组合。
 *  @param userIdList 讨论组成员 Id 列表。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)createDiscussion:(NSString *)name userIdList:(NSArray *)userIdList completion:(void (^)(RCDiscussion* discussion))completion error:(void (^)(RCErrorCode status))error;

/**
 *  邀请一名或者一组用户加入讨论组。
 *
 *  @param discussionId 讨论组 Id。
 *  @param userIdList   邀请的用户 Id 列表。
 *  @param completion   调用完成的处理。
 *  @param error        调用返回的错误信息。
 */
-(void)addMemberToDiscussion:(NSString*)discussionId userIdList:(NSArray*)userIdList completion:(void (^)(RCDiscussion* discussion))completion error:(void (^)(RCErrorCode status))error;

/**
 *  供创建者将某用户移出讨论组。
 *
 *  移出自己或者调用者非讨论组创建者将产生错误。
 *
 *  @param discussionId 讨论组 Id。
 *  @param userId       用户 Id。
 *  @param completion   调用完成的处理。
 *  @param error        调用返回的错误信息。
 */
-(void)removeMemberFromDiscussion:(NSString*)discussionId userId:(NSString*)userId completion:(void (^)(RCDiscussion* discussion))completion error:(void (^)(RCErrorCode status))error;

/**
 *  退出当前用户所在的某讨论组。
 *
 *  @param discussionId 讨论组 Id。
 *  @param completion   调用完成的处理。
 *  @param error        调用返回的错误信息。
 */
-(void)quitDiscussion:(NSString*)discussionId completion:(void (^)(RCDiscussion* discussion))completion error:(void (^)(RCErrorCode status))error;

/**
 *  发送消息。
 *
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param conversationType 会话类型。
 *  @param content          消息内容。
 *  @param delegate         发送消息的回调。
 *  @param userData         用户自定义数据，该值会在 delegate 中返回。
 *
 *  @return 发送的消息实体。
 */
-(RCMessage*)sendMessage:(RCConversationType)conversationType targetId:(NSString*)targetId  content:(RCMessageContent*)content delegate:(id<RCSendMessageDelegate>)delegate object:(id)userData;

/**
 *  发送消息。
 *  @warning                此API目前存在bug，请使用@method sendMessage:targetId:content:content:delegate:object
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param conversationType 会话类型。
 *  @param content          消息内容。
 *  @param completion       调用完成的处理。
 *  @param progress         调用进度的处理。
 *  @param error            调用返回的错误信息。
 *
 *  @return 发送的消息实体。
 */
-(RCMessage*)sendMessage:(RCConversationType)conversationType targetId:(NSString*)targetId content:(RCMessageContent*)content completion:(void (^)(RCErrorCode status, long messageId))completion progress:(void (^)(int iProgress, long messageId))progress error:(void (^)(int nErrorCode, long messageId))error;


/**
 *  保存消息。
 *
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param conversationType 会话类型。
 *  @param senderId         发送者Id。
 *  @param content          消息内容。
 */
- (RCMessage *)insertMessage:(RCConversationType)conversationType targetId:(NSString *)targetId senderId:(NSString *)senderId content:(RCMessageContent*)content;

/**
 *  发送通知消息。此方法后续版本会废弃。
 *
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param conversationType 会话类型。
 *  @param content          通知消息内容。
 *  @param delegate         发送通知消息的回调。
 *  @param userData         用户自定义数据，该值会在 delegate 中返回。
 *
 *  @return 发送的通知消息实体。
 */
-(RCMessage*)sendNotification:(RCConversationType)conversationType targetId:(NSString*)targetId content:(RCNotificationMessage*)content delegate:(id<RCSendMessageDelegate>)delegate object:(id)userData;

/**
 *  发送状态消息。此方法后续版本会废弃。
 *
 *  此类消息不保证必达，但是速度最快，所以通常用来传递状态信息。如：发送对方正在输入的状态。
 *
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param conversationType 会话类型。
 *  @param content          状态消息的内容。
 *  @param delegate         发送状态消息的回调。
 *  @param userData         用户自定义数据，该值会在 delegate 中返回。
 *
 *  @return 发送的状态消息实体。
 */
-(RCMessage*)sendStatus:(RCConversationType)conversationType targetId:(NSString*)targetId content:(RCStatusMessage*)content delegate:(id<RCSendMessageDelegate>)delegate object:(id)userData;

/**
 *  下载文件。此方法后续版本会废弃。
 *
 *  用来获取媒体原文件时调用。如果本地缓存中包含此文件，则从本地缓存中直接获取，否则将从服务器端下载。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id 或聊天室 Id。
 *  @param mediaType        文件类型。
 *  @param imageUrl         文件的 URL 地址。
 *  @param delegate         下载文件的回调。
 *  @param userData         用户自定义数据，该值会在 delegate 中返回。
 */
-(void)downloadMedia:(RCConversationType)conversationType targetId:(NSString*)targetId mediaType:(RCMediaType)mediaType imageUrl:(NSString*)imageUrl delegate:(id<RCDownloadMediaDelegate>)delegate object:(id)userData;

/**
 *  获取会话消息提醒状态。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param completion       调用完成的处理。
 *  @param error            调用返回的错误信息。
 */
-(void)getConversationNotificationStatus:(RCConversationType)conversationType targetId:(NSString*)targetId completion:(void (^)(RCConversationNotificationStatus nStatus))completion error:(void (^)(RCErrorCode status))error;

/**
 *  设置会话消息提醒状态。
 *
 *  @param conversationType 会话类型。
 *  @param targetId         目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param isBlocked        是否屏蔽。
 *  @param completion       调用完成的处理。
 *  @param error            调用返回的错误信息。
 */
-(void)setConversationNotificationStatus:(RCConversationType)conversationType targetId:(NSString*)targetId isBlocked:(BOOL)isBlocked completion:(void (^)(RCConversationNotificationStatus nStatus))completion error:(void (^)(RCErrorCode status))error;

/**
 *  设置讨论组成员邀请权限。
 *
 *  @param targetId   目标 Id。根据不同的 conversationType，可能是聊天 Id、讨论组 Id、群组 Id。
 *  @param isOpen     开放状态，默认开放。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)setDiscussionInviteStatus:(NSString*)targetId isOpen:(BOOL)isOpen completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  同步当前用户的群组信息。
 *
 *  @param groupList  群组对象列表。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)syncGroups:(NSArray*)groupList completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  加入群组。
 *
 *  @param groupId    群组Id。
 *  @param groupName  群组名称。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)joinGroup:(NSString*)groupId groupName:(NSString*)groupName completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  退出群组。
 *
 *  @param groupId    群组Id。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)quitGroup:(NSString *)groupId completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  获取用户信息。此方法后续版本会废弃。
 *
 *  如果本地缓存中包含用户信息，则从本地缓存中直接获取，否则将访问融云服务器获取用户登录时注册的信息；<br/>
 *  但如果该用户如果从来没有登录过融云服务器，返回的用户信息会为空值。
 *
 *  @param userId   用户 Id。
 *  @param delegate 获取用户信息的回调。
 *  @param userData 用户自定义数据，该值会在 delegate 中返回。
 */
-(void)getUserInfo:(NSString*)userId delegate:(id<RCGetUserInfoDelegate>)delegate object:(id)userData;

/**
 *  获取用户信息。
 *
 *  如果本地缓存中包含用户信息，则从本地缓存中直接获取，否则将访问融云服务器获取用户登录时注册的信息；<br/>
 *  但如果该用户如果从来没有登录过融云服务器，返回的用户信息会为空值。
 *
 *  @param userId     用户 Id。
 *  @param completion 调用完成的处理。
 *  @param error      调用返回的错误信息。
 */
-(void)getUserInfo:(NSString*)userId completion:(void (^)(RCUserInfo* userInfo))completion error:(void (^)(RCErrorCode status))error;

/**
 *  获取当前连接用户的信息。
 *
 *  @return 当前连接用户的信息。
 */
@property (NS_NONATOMIC_IOSONLY, getter=getCurrentUserInfo, readonly, strong) RCUserInfo *currentUserInfo;

/**
 *  设置接收消息的监听器。
 *
 *  所有接收到的消息、通知、状态都经由此处设置的监听器处理。包括私聊消息、讨论组消息、群组消息、聊天室消息以及各种状态。
 *
 *  @param delegate 接收消息的监听器。
 *  @param userData 用户自定义数据，该值会在 delegate 中返回。
 */
-(void)setReceiveMessageDelegate:(id<RCReceiveMessageDelegate>)delegate object:(id)userData;

/**
 *  设置连接状态变化的监听器。
 *
 *  @param delegate 连接状态变化的监听器。
 */
-(void)setConnectionStatusDelegate:(id<RCConnectionStatusDelegate>)delegate;

/**
 *  设置重新连接状态变化的监听器。
 *
 *  @param delegate 重新连接状态变化的监听器。
 */
-(void)setReconnectionStatusDelegate:(id<RCReconnectStatusDelegate>)delegate;

/**
 *  加入聊天室。
 *
 *  @param targetId     聊天室ID。
 *  @param messageCount 进入聊天室获取获取多少条历史信息。
 *  @param completion   加入聊天室成功。
 *  @param error        加入聊天室失败。
 */
-(void)joinChatRoom:(NSString* )targetId messageCount:(int)messageCount completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  退出聊天室。
 *
 *  @param targetId   聊天室ID。
 *  @param completion 退出聊天室成功。
 *  @param error      退出聊天室失败。
 */

-(void)quitChatRoom:(NSString* )targetId completion:(void (^)())completion error:(void (^)(RCErrorCode status))error;

/**
 *  获取当前连接状态
 *
 *  @return 当前连接状态
 */
-(RCCurrentConnectionStatus)getCurrentConnectionstatus;

/**
 *  获取当前组件的版本号。
 *
 *  @return 当前组件的版本号。
 */
+(NSString*)getLibraryVersion;

/**
 *  加入黑名单
 *
 *  @param userId   用户id
 *  @param completion 加入黑名单成功。
 *  @param error      加入黑名单失败。
 */
-(void)addToBlacklist:(NSString *)userId completion:(void(^)())completion error:(void(^)(RCErrorCode status))error;

/**
 *  移出黑名单
 *
 *  @param userId   用户id
 *  @param completion 移出黑名单成功。
 *  @param error      移出黑名单失败。
 */
-(void) removeFromBlacklist:(NSString *)userId completion:(void(^)())completion error:(void(^)(RCErrorCode status))error;

/**
 *  获取用户黑名单状态
 *
 *  @param userId   用户id
 *  @param completion 获取用户黑名单状态成功。bizStatus 0-在黑名单，101-不在黑名单
 *  @param error      获取用户黑名单状态失败。
 */
-(void) getBlacklistStatus:(NSString *)userId completion:(void(^)(int bizStatus))completion error:(void(^)(RCErrorCode status))error;

/**
 *  获取黑名单列表
 *
 *  @param completion 黑名单列表，多个id以回车分割
 *  @param error      获取用户黑名单状态失败
 */

-(void) getBlacklist:(void(^)(NSArray *blockUserIds))completion error:(void(^)(RCErrorCode status))error;

/**
 *  设置关闭push时间
 *
 *  @param startTime 关闭起始时间 格式 HH:MM:SS
 *  @param spanMins  间隔分钟数 0 < t < 1440
 *  @param SuccessCompletion 成功操作回调,status为0表示成功，其它表示失败
 *  @param errorCompletion 失败操作回调, 返回相应的错误码
 */

-(void) setConversationNotificationQuietHours:(NSString *) startTime
              spanMins:(int) spanMins
    SuccessCompletion :(void(^) ()) successCompletion
       errorCompletion:(void(^)(RCErrorCode status))errorCompletion;
/**
 *  删除push设置
 *
 *  @param successCompletion 成功回调
 *  @param errorCompletion   失败回调
 */
-(void) removeConversationNotificationQuietHours:(void(^) ()) successCompletion
          errorCompletion:(void(^)(RCErrorCode status))errorCompletion;

/**
 *  查询push设置
 *
 *  @param successCompletion startTime 关闭开始时间，spansMin间隔分钟
 *  @param errorCompletion   status为0表示成功，其它失败
 */
-(void) getConversationNotificationQuietHours:(void(^) (NSString *startTime,int spansMin)) successCompletion
         errorCompletion:(void(^)(RCErrorCode status))errorCompletion;

@end
