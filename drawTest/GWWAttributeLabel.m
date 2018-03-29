//
//  GWWLabel.m
//  drawTest
//
//  Created by zhangyun on 2018/2/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "GWWAttributeLabel.h"

#import <CoreText/CoreText.h>
#import "GWWImageAttachment.h"

#define ImgWidth (([[UIScreen mainScreen] bounds].size.width - 20) / 4)
#define ScreenWith ([[UIScreen mainScreen] bounds].size.width)

static CGFloat ascentCallback(void *ref){
    return ImgWidth;
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void* ref){
    return ImgWidth;
}



@interface GWWAttributeLabel()
{
    CTFrameRef frame;
}
@property (nonatomic,strong) NSMutableArray *imgAttachmentAry; // 图片附件
@property (nonatomic,copy) NSString *originString; //
@end

@implementation GWWAttributeLabel

//
//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
////        _imgAry = [NSMutableArray array];
////        _imgRangeAry = [NSMutableArray array];
//        _imgAttachmentAry = [NSMutableArray array];
//    }
//    return self;
//}
//
/*

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
