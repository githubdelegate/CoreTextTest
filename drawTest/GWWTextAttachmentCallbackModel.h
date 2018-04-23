//
//  GWWTextAttachmentCallbackModel.h
//  drawTest
//
//  Created by zhangyun on 2018/4/20.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef NS_ENUM(NSUInteger, GWWTextAttachmentType) {
    GWWTextAttachmentTypeImage = 1, // 本地图片
    GWWTextAttachmentTypeImageView, // 网络图片 和 正常view
    GWWTextAttachmentTypeBlack, // 空白区
};


/**
 保存信息
 */
@interface GWWTextAttachmentCallbackModel : NSObject
@property (nonatomic,strong) NSString *originalString;
@property (nonatomic,assign) CGSize size;
@property (nonatomic) CTRunDelegateCallbacks callbacks;
@property (nonatomic,assign) GWWTextAttachmentType type;
@end


