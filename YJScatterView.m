//
//  YJScatterView.m
//  ONCPatient
//
//  Created by GuiXian Feng on 2016/11/25.
//  Copyright © 2016年 Fengguixian. All rights reserved.
//

#import "YJScatterView.h"
#import "ScatterModel.h"

@interface YJScatterView ()

@property(nonatomic) CGPoint chartOrigin;

@property(nonatomic) CGFloat xLenth;

@property(nonatomic) CGFloat yLenth;

@property(nonatomic) CGFloat unit;

@end

@implementation YJScatterView

- (void)setValues:(NSArray *)values
{
    _values = values;
    
    [self setNeedsDisplay];
}

- (void)setStandardLineTime:(NSDate *)standardLineTime
{
    _standardLineTime = standardLineTime;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [self drawSection];
    
    [self showPionts];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _chartOrigin = CGPointMake(35, frame.size.height-5-20);
        
        _xLenth = self.frame.size.width-_chartOrigin.x-10;
        _yLenth = _chartOrigin.y;
        
        UILabel *unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 100, 15)];
        unitLabel.textColor = [UIColor grayColor];
        unitLabel.font = [UIFont systemFontOfSize:12.0];
        unitLabel.text = @"时间";
        [self addSubview:unitLabel];
    }
    
    return self;
}

// 描绘x轴和y轴
- (void)drawXY
{
    [self drawLine:CGPointMake(_chartOrigin.x, 5) end:CGPointMake(_chartOrigin.x, _chartOrigin.y) width:1.0 color:[UIColor redColor]];
    [self drawLine:CGPointMake(_chartOrigin.x, _chartOrigin.y) end:CGPointMake(_chartOrigin.x+_xLenth, _chartOrigin.y) width:1.0 color:[UIColor redColor]];
    [self drawArrows];
    [self drawSection];
}

// 描绘箭头
- (void)drawArrows
{
    // y轴的箭头
    [self drawLine:CGPointMake(_chartOrigin.x, 5) end:CGPointMake(_chartOrigin.x-5, 10) width:1.0 color:[UIColor redColor]];
    [self drawLine:CGPointMake(_chartOrigin.x, 5) end:CGPointMake(_chartOrigin.x+5, 10) width:1.0 color:[UIColor redColor]];
    // y轴的箭头
    [self drawLine:CGPointMake(_chartOrigin.x+_xLenth, _chartOrigin.y) end:CGPointMake(_xLenth+_chartOrigin.x-5, _chartOrigin.y-5) width:1.0 color:[UIColor redColor]];
    [self drawLine:CGPointMake(_chartOrigin.x+_xLenth, _chartOrigin.y) end:CGPointMake(_xLenth+_chartOrigin.x-5, _chartOrigin.y+5) width:1.0 color:[UIColor redColor]];
}

// 描绘分段
- (void)drawSection
{
    // y轴的分段
    CGFloat space = (_yLenth-5) / 9;
    _unit = space/180;
    for (int i=0; i<9; i++) {
        [self drawText:[NSString stringWithFormat:@"%02d:00", i*3] frame:CGRectMake(0, _chartOrigin.y-space*i-10, _chartOrigin.x, 20) font:[UIFont systemFontOfSize:10.0] color:[UIColor lightGrayColor]];
            [self drawLine:CGPointMake(_chartOrigin.x, _chartOrigin.y-space*i-5) end:CGPointMake(_chartOrigin.x+_xLenth, _chartOrigin.y-space*i-5) width:1.0 color:kDefaultLightGrayColor];
    }
    
    // x轴的分段
    CGFloat xSpace = ((_xLenth-5)-20)/6;
    for (int i=0; i<7; i++) {
        ScatterModel *temp = _values[i][0];
        [self drawText:temp.MMdd frame:CGRectMake(_chartOrigin.x+10+xSpace*i-(xSpace-2)/2, _chartOrigin.y, xSpace-2, 20) font:[UIFont systemFontOfSize:10.0] color:[UIColor lightGrayColor]];
    }
    
    if (_standardLineTime) {
        NSString *timeStr = [[ShareMethod yymmddhhmm:_standardLineTime separator:@"-"] substringWithRange:NSMakeRange(11, 5)];
        ONCLog(@"setTime: %@", timeStr);
        NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
        NSInteger hour = [timeArray[0] integerValue];
        NSInteger mintue = [timeArray[1] integerValue];
        
        CGFloat len = _unit * (hour*60+mintue);
        CGFloat y = _chartOrigin.y-5-len;
        [self drawLine:CGPointMake(_chartOrigin.x, y) end:CGPointMake(_chartOrigin.x+_xLenth, y) width:1.0 color:kDefaultColor];
    }
}

- (void)showPionts
{
    CGFloat xSpace = ((_xLenth-5)-20)/6;
    
//    NSMutableArray *temp = [[NSMutableArray alloc] init];
//    for (int i=0; i<7; i++) {
//        ScatterModel *model = [[ScatterModel alloc] init];
//        model.hhmm = [NSString stringWithFormat:@"%02d:%02d", arc4random()%24, arc4random()%60];//[NSString stringWithFormat:@"%02d:00", i];
//        [temp addObject:model];
//        NSLog(@"hhmm: %@", model.hhmm);
//    }
    
    for (int i=0; i<_values.count; i++) {
        NSArray *models = _values[i];
        for (ScatterModel *model in models) {
            CGFloat len = _unit * model.minutes;
            if (len!=0) {
                [self drawArc:CGPointMake(_chartOrigin.x+10+xSpace*i, _chartOrigin.y-5-len) color:model.color];
            }
        }
    }
}

// 描绘点
- (void)drawArc:(CGPoint)point color:(UIColor *)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    CGContextSetLineWidth(context, 0);//线的宽度
    CGContextAddArc(context, point.x, point.y, 5, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
}

- (void)drawLine:(CGPoint)start end:(CGPoint)end width:(CGFloat)width color:(UIColor *)color
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, width);
    CGContextSetAllowsAntialiasing(context, true);
    [color setStroke];
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context, start.x, start.y); //起点坐标
    CGContextAddLineToPoint(context, end.x, end.y);  //终点坐标
    
    CGContextStrokePath(context);
}

- (void)drawText:(NSString *)text frame:(CGRect)frame font:(UIFont *)font color:(UIColor *)color
{
    //获得当前画板
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    //开始写字
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [text drawInRect:frame withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:color}];
}

@end
