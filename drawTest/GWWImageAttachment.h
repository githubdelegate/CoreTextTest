//
//  GWWImageAttachment.h
//  drawTest
//
//  Created by zhangyun on 2018/2/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 图片附件类
@interface GWWImageAttachment : NSObject
@property (nonatomic,strong) NSString *srcPath; // src=
@property (nonatomic,assign) CGRect drawRect; //
@property (nonatomic,assign) NSRange imgStringRange; // <img />在原始string中range
@property (nonatomic,strong) NSString *imgString; // 原始string
@end
