//
//  GWWImageAttachment.m
//  drawTest
//
//  Created by zhangyun on 2018/2/26.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "GWWImageAttachment.h"

@implementation GWWImageAttachment

- (void)setImgString:(NSString *)imgString{
    if (imgString.length == 0) {
        return;
    }
    
    _imgString = [imgString copy];
    NSRange srcRange = NSMakeRange(10,  imgString.length - 13);
    _srcPath = [imgString substringWithRange:srcRange];
    
    NSLog(@"scr = %@",_srcPath);
    //         NSLog(@"match-range = %@",NSStringFromRange(result.range));
}
@end
