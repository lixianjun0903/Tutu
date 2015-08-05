//
//  ShareActonSheet.h
//  Tutu
//
//  Created by gexing on 4/13/15.
//  Copyright (c) 2015 zxy. All rights reserved.
//
typedef NS_ENUM(NSInteger, ActionSheetType) {
    ActionSheetTypeTutu = 0,
    ActionSheetTypeQQ,
    ActionSheetTypeQQZone,
    ActionSheetTypeWXFriend,
    ActionSheetTypeWXSection,
    ActionSheetTypeSina,
    ActionSheetTypeBlock,
    ActionSheetTypeReport,
    ActionSheetTypeFavorite,
    ActionSheetTypeCopyLink,
};

typedef NS_ENUM(NSInteger, ActionSheetButtonType) {
    ActionSheetButtonTypeAll,
    ActionSheetButtonTypeReportAndCopy,
    ActionSheetButtonTypeCopy,
};
#import <Foundation/Foundation.h>
@protocol ShareActonSheetDelegate <NSObject>

- (void)shareActionSheetButtonClick:(NSInteger)index;

@end
@interface ShareActonSheet : NSObject

+ (ShareActonSheet *)instancedSheetWith:(TopicModel *)topicModel type:(ActionSheetButtonType)type;
- (void)showInWindow;

@property(nonatomic,weak)id <ShareActonSheetDelegate>delegate;
@property(nonatomic,strong)UIButton *blockBtn;
@property(nonatomic,strong)UIButton *reportBtn;
@property(nonatomic,strong)UIButton *collectionBtn;
@property(nonatomic,strong)UIButton *cpyBtn;
@property(nonatomic,strong)UILabel *reportLabel;
@property(nonatomic,strong)UILabel *cpyLabel;
@property(nonatomic,strong)UILabel *blockLabel;
@property(nonatomic,strong)UILabel *collectionLabel;
@end
