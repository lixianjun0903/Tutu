//
//  RCParamsDefines.h
//  Tutu
//
//  Created by zhangxinyao on 15-1-9.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#define RCT_CONVERSATION @"RCT_CONVERSATION"
#define RCT_MESSAGE @"RCT_MESSAGE"

#define RCT_MESSAGE_COLUMNS @"id,target_id,category_id,message_direction,read_status,receive_time,send_time,clazz_name,content,send_status,sender_id,extra_content,extra_column1,extra_column2,extra_column3,extra_column4,extra_column5,extra_column6"

#define RCT_MESSAGE_COLUMNS_WITHOUTID @"target_id,category_id,message_direction,read_status,receive_time,send_time,clazz_name,content,send_status,sender_id,extra_content,extra_column1,extra_column2,extra_column3,extra_column4,extra_column5,extra_column6"
//17个待插入字段
#define RCT_MESSAGE_COLUMNS_ADDNum @":target_id,:category_id,:message_direction,:read_status,:receive_time,:send_time,:clazz_name,:content,:send_status,:sender_id,:extra_content,:extra_column1,:extra_column2,:extra_column3,:extra_column4,:extra_column5,:extra_column6"

#define RCT_CONVERSATION_COLUMNS @"target_id,category_id,conversation_title,draft_message,is_top,last_time,top_time,extra_column1,extra_column2,extra_column3,extra_column4,extra_column5,extra_column6"
//13个待插入字段
#define RCT_CONVERSATION_COLUMNS_ADDNum @":target_id,:category_id,:conversation_title,:draft_message,:is_top,:last_time,:top_time,:extra_column1,:extra_column2,:extra_column3,:extra_column4,:extra_column5,:extra_column6"



