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
//-(void)ParagraphStyle
//{
//    NSString *src = @"其实流程是这样的： 1、生成要绘制的NSAttributedString对象。 2、生成一个CTFramesetterRef对象，然后创建一个CGPath对象，这个Path对象用于表示可绘制区域坐标值、长宽。 3、使用上面生成的setter和path生成一个CTFrameRef对象，这个对象包含了这两个对象的信息（字体信息、坐标信息），它就可以使用CTFrameDraw方法绘制了。";
//
//    //修改windows回车换行为mac的回车换行
//    //src = [src stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
//
//    NSMutableAttributedString * mabstring = [[NSMutableAttributedString alloc]initWithString:src];
//    long slen = [mabstring length];
//
//    //创建文本对齐方式
//    CTTextAlignment alignment = kCTRightTextAlignment;//kCTNaturalTextAlignment;
//    CTParagraphStyleSetting alignmentStyle;
//    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
//    alignmentStyle.valueSize=sizeof(alignment);
//    alignmentStyle.value=&alignment;
//
//    //首行缩进
//    CGFloat fristlineindent = 24.0f;
//    CTParagraphStyleSetting fristline;
//    fristline.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
//    fristline.value = &fristlineindent;
//    fristline.valueSize = sizeof(float);
//
//    //段缩进
//    CGFloat headindent = 10.0f;
//    CTParagraphStyleSetting head;
//    head.spec = kCTParagraphStyleSpecifierHeadIndent;
//    head.value = &headindent;
//    head.valueSize = sizeof(float);
//
//    //段尾缩进
//    CGFloat tailindent = 50.0f;
//    CTParagraphStyleSetting tail;
//    tail.spec = kCTParagraphStyleSpecifierTailIndent;
//    tail.value = &tailindent;
//    tail.valueSize = sizeof(float);
//
//    //tab
//    CTTextAlignment tabalignment = kCTJustifiedTextAlignment;
//    CTTextTabRef texttab = CTTextTabCreate(tabalignment, 24, NULL);
//    CTParagraphStyleSetting tab;
//    tab.spec = kCTParagraphStyleSpecifierTabStops;
//    tab.value = &texttab;
//    tab.valueSize = sizeof(CTTextTabRef);
//
//    //换行模式
//    CTParagraphStyleSetting lineBreakMode;
//    CTLineBreakMode lineBreak = kCTLineBreakByTruncatingMiddle;//kCTLineBreakByWordWrapping;//换行模式
//    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
//    lineBreakMode.value = &lineBreak;
//    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
//
//    //多行高
//    CGFloat MutiHeight = 10.0f;
//    CTParagraphStyleSetting Muti;
//    Muti.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
//    Muti.value = &MutiHeight;
//    Muti.valueSize = sizeof(float);
//
//    //最大行高
//    CGFloat MaxHeight = 5.0f;
//    CTParagraphStyleSetting Max;
//    Max.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
//    Max.value = &MaxHeight;
//    Max.valueSize = sizeof(float);
//
//    //行距
//    CGFloat _linespace = 5.0f;
//    CTParagraphStyleSetting lineSpaceSetting;
//    lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
//    lineSpaceSetting.value = &_linespace;
//    lineSpaceSetting.valueSize = sizeof(float);
//
//    //段前间隔
//    CGFloat paragraphspace = 5.0f;
//    CTParagraphStyleSetting paragraph;
//    paragraph.spec = kCTParagraphStyleSpecifierLineSpacing;
//    paragraph.value = paragraphspace;
//    paragraph.valueSize = sizeof(float);
//
//    //书写方向
//    CTWritingDirection wd = kCTWritingDirectionRightToLeft;
//    CTParagraphStyleSetting writedic;
//    writedic.spec = kCTParagraphStyleSpecifierBaseWritingDirection;
//    writedic.value = &wd;
//    writedic.valueSize = sizeof(CTWritingDirection);
//
//    //组合设置
//    CTParagraphStyleSetting settings[] = {
//        alignmentStyle,
//        fristline,
//        head,
//        tail,
//        tab,
//        lineBreakMode,
//        Muti,
//        Max,
//        lineSpaceSetting,
//        writedic,
//        indentSetting
//    };
//
//    //通过设置项产生段落样式对象
//    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 11);
//
//    // build attributes
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)style forKey:(id)kCTParagraphStyleAttributeName ];
//
//    // set attributes to attributed string
//    [mabstring addAttributes:attributes range:NSMakeRange(0, slen)];
//
//
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mabstring);
//
//    CGMutablePathRef Path = CGPathCreateMutable();
//
//    //坐标点在左下角
//    CGPathAddRect(Path, NULL ,CGRectMake(10 , 10 ,self.bounds.size.width-20 , self.bounds.size.height-20));
//
//    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), Path, NULL);
//
//
//
//    //获取当前(View)上下文以便于之后的绘画，这个是一个离屏。
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
//
//    //压栈，压入图形状态栈中.每个图形上下文维护一个图形状态栈，并不是所有的当前绘画环境的图形状态的元素都被保存。图形状态中不考虑当前路径，所以不保存
//    //保存现在得上下文图形状态。不管后续对context上绘制什么都不会影响真正得屏幕。
//    CGContextSaveGState(context);
//
//    //x，y轴方向移动
//    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
//
//    //缩放x，y轴方向缩放，－1.0为反向1.0倍,坐标系转换,沿x轴翻转180度
//    CGContextScaleCTM(context, 1.0 ,-1.0);
//
//    CTFrameDraw(frame,context);
//
//    CGPathRelease(Path);
//    CFRelease(framesetter);
//}



- (void)drawRect:(CGRect)rect{
//    [self ParagraphStyle];
//    return;
//        [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    // --------- GWW ------------
    NSMutableAttributedString *atrriStr = [[NSMutableAttributedString alloc] initWithString:@"一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十\n一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十gh"];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    CFStringRef fontName = (__bridge CFStringRef)[UIFont systemFontOfSize:17].fontName;
    CGFloat fontSize     = [UIFont systemFontOfSize:17].pointSize;
    CTFontRef ctfont     = CTFontCreateWithName(fontName, fontSize, NULL);
    [attributes setObject:(__bridge id)ctfont forKey:(id)kCTFontAttributeName];
    CFRelease(ctfont);
    CGColorRef color = [UIColor blackColor].CGColor;
    [attributes setObject:(__bridge id)color forKey:(id)kCTForegroundColorAttributeName];
    
    CTTextAlignment alignment = kCTTextAlignmentLeft;
    CGFloat lSpacing = roundf(0);
    CGFloat headIndent = roundf(0);
    CGFloat tailIndent = round(-0);
    //    CGFloat minLine  = lineHeight;
    //    CGFloat maxLine  = lineHeight;
    CGFloat pSpacing = roundf(30);
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping;// kCTLineBreakByWordWrapping;//kCTLineBreakByClipping;//换行模式
    CTParagraphStyleSetting setting[] = {
        { kCTParagraphStyleSpecifierAlignment,          sizeof(alignment), &alignment},
        //        { kCTParagraphStyleSpecifierMinimumLineHeight,  sizeof(minLine), &minLine },
        //        { kCTParagraphStyleSpecifierMaximumLineHeight,  sizeof(maxLine), &maxLine },
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(lSpacing), &lSpacing },
        { kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lSpacing), &lSpacing },
        { kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lSpacing), &lSpacing },
        { kCTParagraphStyleSpecifierParagraphSpacingBefore,sizeof(pSpacing), &pSpacing },
        { kCTParagraphStyleSpecifierParagraphSpacing,   sizeof(pSpacing), &pSpacing },
        { kCTParagraphStyleSpecifierLineBreakMode,      sizeof(CTLineBreakMode), &lineBreak },
        // 每段中除第一行外每行的缩进大小
        {kCTParagraphStyleSpecifierHeadIndent,sizeof(headIndent),&headIndent },
        // 每段第一行缩进大小
        {kCTParagraphStyleSpecifierFirstLineHeadIndent,sizeof(headIndent),&headIndent},
        // 当为正值的时候 表示每行开头到尾部的距离，为负值的时候表示每行尾部到容器边界的距离
        {kCTParagraphStyleSpecifierTailIndent,sizeof(tailIndent),&tailIndent}
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, sizeof(setting) / sizeof(CTParagraphStyleSetting));
    [attributes setObject:(__bridge id)paragraphStyle forKey:(id)kCTParagraphStyleAttributeName];
    CFRelease(paragraphStyle);
    [atrriStr addAttributes:attributes range:NSMakeRange(0, atrriStr.length)];
//    [atrriStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, atrriStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)atrriStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL,rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 30), path,nil);
    CTFrameRef frame2 =  CTFramesetterCreateFrame(frameSetter, CFRangeMake(30, atrriStr.length - 30), path, nil);

    //
    CFArrayRef lines = CTFrameGetLines(frame2);
    CFIndex count = CFArrayGetCount(lines);
    CGPoint origin[count];
    CTFrameGetLineOrigins(frame2, CFRangeMake(0, 0),origin);
    CTLineRef lastLine = CFArrayGetValueAtIndex(lines, count - 1);
    CGFloat ascent,descent,leading,width = 0;
    width = CTLineGetTypographicBounds(lastLine, &ascent, &descent, &leading);
    CGPoint lastLinePos = origin[count - 1];
    CGRect lastLineRect =  CGRectMake(lastLinePos.x, lastLinePos.y - descent, width, ascent + descent);
    CGRect baseLine =  CGRectMake(lastLinePos.x, lastLinePos.y, width,0.1);
    NSLog(@"lastlast rect= %@",NSStringFromCGRect(lastLineRect));
    CFRange lastLinerange = CTLineGetStringRange(lastLine);
    NSRange nsLastLineRange = NSMakeRange(lastLinerange.location, lastLinerange.length);
    
    CTFrameDraw(frame, ctx);
    CTFrameDraw(frame2, ctx);
    
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(30, 30), nil,self.bounds.size, nil);
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, 0);
    CGContextTranslateCTM(ctx, 0,  self.bounds.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:lastLineRect];
    CGContextAddPath(ctx, subPath.CGPath);
    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
    CGContextSetLineWidth(ctx, 0.3);
    CGContextStrokePath(ctx);
    {
        UIBezierPath *subPath = [UIBezierPath bezierPathWithRect:baseLine];
        CGContextAddPath(ctx, subPath.CGPath);
        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextSetLineWidth(ctx, 0.3);
        CGContextStrokePath(ctx);
    }
    
    
    CGContextRestoreGState(ctx);
    
}
@end
