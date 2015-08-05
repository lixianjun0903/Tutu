//
//  RecommendUserModel.h
//  Tutu
//
//  Created by gexing on 5/21/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//

#import "JSONModel.h"

@interface RecommendUserModel : JSONModel
//addtime = "2015-05-17 21:17:00";
//age = 14;
//area = "";
//authreason = "";
//avatartime = 1431868622;
//birthday = "2000-08-13";
//city = "\U4fe1\U9633";
//constellation = "\U72ee\U5b50\U5ea7";
//descinfo = "\U8d75\U660a\U4e5f\U5173\U6ce8\U4e86TA\U3002";
//gender = 1;
//isauth = 0;
//isblock = 0;
//isblockme = 0;
//nickname = "\U72ec\U9738\U2198\U5929\U4e0b\U2121";
//province = "\U6cb3\U5357";
//relation = 0;
//remarkname = "";
//sign = "";
//status = 1;
//topicblock = 0;
//uid = 1556649;
//userhonorlevel = 0;
@property(nonatomic)int              avatartime;
@property(nonatomic,strong)NSString *descinfo;
@property(nonatomic)int              uid;
@property(nonatomic)int              gender;
@property(nonatomic)int              age;
@property(nonatomic)int              relation;
@property(nonatomic)int              userhonorlevel;
@property(nonatomic)int              isauth;
@property(nonatomic,strong)NSString *nickname;


//@property(nonatomic,strong)NSString *area;
//@property(nonatomic,strong)NSString *authreason;
//@property(nonatomic)int              avatartime;
//@property(nonatomic,strong)NSString *birthday;
//@property(nonatomic,strong)NSString *city;
//@property(nonatomic,strong)NSString *constellation;
//
//@property(nonatomic)int              isauth;
//@property(nonatomic)int              isblock;
//@property(nonatomic)int              isblockme;

//@property(nonatomic,strong)NSString *province;
//
//@property(nonatomic,strong)NSString *remarkname;
//@property(nonatomic,strong)NSString *sign;
//@property(nonatomic)int              status;
//
//@property(nonatomic)int              userhonorlevel;
@end
