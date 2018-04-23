
//
//  GWWTextAttachmentCallbackModel.m
//  drawTest
//
//  Created by zhangyun on 2018/4/20.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "GWWTextAttachmentCallbackModel.h"


static CGFloat RunDelegateGetAscentCallback(void *refCon){
    GWWTextAttachmentCallbackModel *object = (__bridge GWWTextAttachmentCallbackModel *)refCon;
    return object.size.height;
}

static CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0.0f;
}

static CGFloat RunDelegateGetWidthCallback(void *refCon){
    GWWTextAttachmentCallbackModel *object = (__bridge GWWTextAttachmentCallbackModel *)refCon;
    return object.size.width;
}


@implementation GWWTextAttachmentCallbackModel

- (CTRunDelegateCallbacks)callbacks
{
    CTRunDelegateCallbacks callbacks;
    callbacks.version    = kCTRunDelegateCurrentVersion;
    callbacks.getAscent  = RunDelegateGetAscentCallback;
    callbacks.getDescent = RunDelegateGetDescentCallback;
    callbacks.getWidth   = RunDelegateGetWidthCallback;
    return callbacks;
}
@end
