//
//  TView.m
//  drawTest
//
//  Created by zhangyun on 2018/2/23.
//  Copyright © 2018年 zy. All rights reserved.
//

#import "TView.h"
#import "TLayer.h"

#import <CoreText/CoreText.h>
#import "GWWImageAttachment.h"
#import "GWWTextAttachmentCallbackModel.h"
//
#define ImgWidth (([[UIScreen mainScreen] bounds].size.width - 20) / 3)
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


@interface TView(){
    CTFrameRef _frame;
    CTLineRef _lastLine;
}
//@property (nonatomic,strong) NSMutableArray *imgAry; // 图片地址
//@property (nonatomic,strong) NSMutableArray *imgRangeAry; // 图片range
@property (nonatomic,strong) NSMutableArray *imgAttachmentAry; // 图片附件
@property (nonatomic,copy) NSString *originString; //
//@property (nonatomic,assign) CTFrameRef frame;

@end

@implementation TView
//
//+ (Class)layerClass{
//    return [TLayer class];
//}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        _imgAry = [NSMutableArray array];
//        _imgRangeAry = [NSMutableArray array];
        _imgAttachmentAry = [NSMutableArray array];
    }
    return self;
}

- (void)setAttributeStringPath:(NSString *)attributeStringPath{
    if (attributeStringPath.length > 0 && attributeStringPath) {
        NSString *attriStr = [[NSString alloc] initWithContentsOfFile:attributeStringPath encoding:NSUTF8StringEncoding error:nil];
        if (attriStr.length > 0 && attriStr) {
            self.originString = attriStr;
            [self processOriginString:attriStr];
        }
    }
}

// 处理原始字符串，分离
- (void)processOriginString:(NSString *)originString{
    __weak typeof(self) wself = self;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"<img src=.*/>" options:NSRegularExpressionCaseInsensitive error:nil];
     [reg enumerateMatchesInString:originString options:NSMatchingReportCompletion range:NSMakeRange(0, originString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
         if (result.range.length == 0) {
             *stop = YES;
             [wself assmbleAttributrString];
//             [wself caculateImgRect];
         }
         
         GWWImageAttachment *img = [[GWWImageAttachment alloc] init];
         img.imgString = [originString substringWithRange:result.range];
         img.imgStringRange = result.range;
         [wself.imgAttachmentAry addObject:img];
    }];
}

// 把普通文本和图片组装成富文本
- (void)assmbleAttributrString{
#warning  这里使用最简答的上面文字，下面图片方式，其他的以后扩展
    NSRange firstImgRange = [[self.imgAttachmentAry firstObject] imgStringRange];
    NSRange txtRange =NSMakeRange(0, firstImgRange.location - 1);
    if (txtRange.length == 0) {
        return;
    }
    NSString *txtStr = [self.originString substringToIndex:10];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:txtStr];
//    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:txtRange];
//    for (int i = 0; i < self.imgAttachmentAry.count; i++) {
//        CTRunDelegateCallbacks callbacks;
//        memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
//        callbacks.version = kCTRunDelegateVersion1;
//        callbacks.getAscent = ascentCallback;
//        callbacks.getDescent = descentCallback;
//        callbacks.getWidth = widthCallback;
//        CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, nil);
//
//        unichar whiteChar = 0xFFFC;
//        NSString *whiteStr = [NSString stringWithCharacters:&whiteChar length:1];
//        NSMutableAttributedString *whiteAttr = [[NSMutableAttributedString alloc] initWithString:whiteStr];
//        CFAttributedStringSetAttribute((CFMutableAttributedStringRef)whiteAttr, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
//        CFRelease(delegate);
//        [attrStr appendAttributedString:whiteAttr];
//    }
    self.attributeString = attrStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = touches.anyObject;
    CGPoint point  = [touch locationInView:self];
    CFIndex index =  CTLineGetStringIndexForPosition(_lastLine, point);
    NSLog(@"index = %ld",index);
}

// 计算图片的frame
- (void)caculateImgRect{

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributeString);
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, CGSizeMake(ScreenWith - 20, CGFLOAT_MAX), nil);
    
    NSLog(@"suggest frame = %@",NSStringFromCGSize(suggestSize));

    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, CGRectMake(0, 0, ScreenWith - 20, suggestSize.height));
    CGPathAddRect(path, NULL,self.bounds);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    _frame = frame;
    CFRelease(path);

    NSArray *lines = (NSArray *)CTFrameGetLines(frame);
    NSInteger linesCount = [lines count];
    CGPoint lineOrigins[linesCount];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);

    NSInteger imgAttacchmentIndex = 0;
    GWWImageAttachment *imgAttachment = self.imgAttachmentAry[imgAttacchmentIndex];
    for (int i = 0;  i < linesCount; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runobj in runs) {
            CTRunRef run = (__bridge CTRunRef)runobj;
            NSDictionary *runAttributes =  (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil) {
                continue;
            }

            CGFloat ascent;
            CGFloat dscent;
            CGRect runBounds;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &dscent, NULL);
            runBounds.size.height = ascent + dscent;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;

            imgAttachment.drawRect = runBounds;
            imgAttacchmentIndex++;
            if (imgAttacchmentIndex == self.imgAttachmentAry.count) {
                break;
            }else{
                imgAttachment = self.imgAttachmentAry[imgAttacchmentIndex];
            }
        }
    }
}

- (NSDictionary *)p_addAttri:(int)i{
    CGFloat pSpacing = 0;
    pSpacing = roundf(0);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;
    
    UIFont *f = [UIFont systemFontOfSize:1];
    CFStringRef fontName = (__bridge CFStringRef)f.fontName;
    CGFloat fontSize     = f.pointSize;
    CTFontRef ctfont     = CTFontCreateWithName(fontName, fontSize, NULL);
    [attributes setObject:(__bridge id)ctfont forKey:(id)kCTFontAttributeName];
    
    CTParagraphStyleSetting setting[] = {
        { kCTParagraphStyleSpecifierParagraphSpacing,   sizeof(pSpacing), &pSpacing },
         { kCTParagraphStyleSpecifierLineBreakMode,      sizeof(CTLineBreakMode), &lineBreak }
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, sizeof(setting) / sizeof(CTParagraphStyleSetting));
    [attributes setObject:(__bridge id)paragraphStyle forKey:NSParagraphStyleAttributeName];
    // 注意这里要释放paragraphStyle 因为 addAttribute方法会Retain 一下
    
    GWWTextAttachmentCallbackModel *model = [GWWTextAttachmentCallbackModel new];
    if (i == 1) {
        model.size = CGSizeMake(360, 5);
    }else{
        model.size = CGSizeMake(360, 100);
    }
    model.originalString = @"\uFFFC";
    
    CTRunDelegateCallbacks callbacks = model.callbacks;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)model);
    [attributes setObject:(__bridge id _Nonnull)(runDelegate) forKey:(NSString *)kCTRunDelegateAttributeName];
    CFRelease(paragraphStyle);
    CFRelease(runDelegate);
    return attributes;
}

- (void)drawRect:(CGRect)rect{
    // 总结
    // 1. 一个长的string 生成多个frame 然后每个frame 都调用CTFrameDraw(frame, ctx);去绘制的时候每个frame都是从容器的原点开始绘制的
    // 2.
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    // --------- GWW ------------
    NSMutableAttributedString *atrriStr = [[NSMutableAttributedString alloc] initWithString:@"\uFFFC\uFFFC\uFFFC"];
    [atrriStr addAttributes:[self p_addAttri:0] range:NSMakeRange(0, 1)];
    [atrriStr addAttributes:[self p_addAttri:1] range:NSMakeRange(1, 1)];
    [atrriStr addAttributes:[self p_addAttri:2] range:NSMakeRange(2, 1)];

//    [atrriStr addAttributes:attributes range:NSMakeRange(0, atrriStr.length)];
//    [atrriStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, atrriStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)atrriStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL,rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, atrriStr.length), path,nil);

    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origin[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0),origin);
    
    // first line
    CGFloat ascent,descent,leading,width = 0;
    CTLineRef line1 = CFArrayGetValueAtIndex(lines,0);
    width = CTLineGetTypographicBounds(line1, &ascent, &descent, &leading);
    CGPoint line1Pos = origin[0];
    CGRect line1Rect =  CGRectMake(line1Pos.x, line1Pos.y - descent, width, ascent + descent);
    CGRect baseLine1 =  CGRectMake(line1Pos.x, line1Pos.y, width,0.1);
    
    // second line
    CTLineRef line2 = CFArrayGetValueAtIndex(lines,1);
    width = CTLineGetTypographicBounds(line2, &ascent, &descent, &leading);
    CGPoint line2Pos = origin[1];
    CGRect line2Rect =  CGRectMake(line2Pos.x, line2Pos.y - descent, width, ascent + descent);
    CGRect baseLine2 =  CGRectMake(line2Pos.x, line2Pos.y, width,0.1);

    // last line
    CTLineRef lastLine = CFArrayGetValueAtIndex(lines, count - 1);
    width = CTLineGetTypographicBounds(lastLine, &ascent, &descent, &leading);
    CGPoint lastLinePos = origin[count - 1];
    CGRect lastLineRect =  CGRectMake(lastLinePos.x, lastLinePos.y - descent, width, ascent + descent);
    CGRect baseLine =  CGRectMake(lastLinePos.x, lastLinePos.y, width,0.1);
    NSLog(@"lastlast rect= %@",NSStringFromCGRect(lastLineRect));
    CFRange lastLinerange = CTLineGetStringRange(lastLine);
    NSRange nsLastLineRange = NSMakeRange(lastLinerange.location, lastLinerange.length);
    
    
    
    

    CTFrameDraw(frame, ctx);
//    CTFrameDraw(frame2, ctx);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(30, 30), nil,self.bounds.size, nil);
    CGContextRestoreGState(ctx);
    
    // 绘制 最后一行的rect 和baseline 区域
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, 0);
    CGContextTranslateCTM(ctx, 0,  self.bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"img.jpeg" ofType:nil]];
    CGContextDrawImage(ctx, line1Rect, img.CGImage);
    CGContextDrawImage(ctx, lastLineRect, img.CGImage);
    
    UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:lastLineRect];
    CGContextAddPath(ctx, subPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx, 0.3);
    CGContextStrokePath(ctx);
    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:baseLine];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }

    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:baseLine1];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }

    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:line1Rect];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }

    
    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:baseLine2];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }
    
    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:line2Rect];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }

    
    CGContextRestoreGState(ctx);
    
}
@end
