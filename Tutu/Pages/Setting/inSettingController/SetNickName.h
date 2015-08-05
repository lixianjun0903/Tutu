//
//  SetNickName.h
//  Tutu
//
//  Created by 刘大治 on 14-10-22.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "BaseController.h"
#import "YHShakeUITextField.h"
@interface SetNickName : BaseController


@property(nonatomic,strong)NSString *nick;
@property(nonatomic,strong)NSString * accesstoken;
@property(nonatomic,strong)NSString * qqOpenid;
@property(nonatomic,strong)NSString * nickname;


@property(nonatomic,strong)NSString * wbid;
@property(nonatomic,strong)NSDate * expiresinDate;

@property (weak, nonatomic) IBOutlet UITextField *nickInput;
@property (weak, nonatomic) IBOutlet UIView *textBackView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

-(id)initWithTitle:(NSString* )title accessToken:(NSString*)token openID:(NSString*)openid;
-(id)initWithTitle:(NSString* )title accessToken:(NSString*)token wbuid:(NSString*)uid date:(NSDate *) expirsindate;
@end
