//
//  SGQRCodeScanView.m
//  SGQRCodeExample
//
//  Created by kingsic on 2017/8/23.
//  Copyright © 2017年 kingsic All rights reserved.
//

#import "SGQRCodeScanView.h"

/** 扫描内容的 W 值 */
#define scanBorderW 0.8 * self.frame.size.width
/** 扫描内容的 x 值 */
#define scanBorderX 0.5 * (1 - 0.8) * self.frame.size.width
/** 扫描内容的 Y 值 */
#define scanBorderY 0.5 * (self.frame.size.height - scanBorderW)

@interface SGQRCodeScanView ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *scanningline;
@end

@implementation SGQRCodeScanView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
}

- (void)initialization {
    _scanAnimationStyle = ScanAnimationStyleDefault;
    _borderColor = [UIColor whiteColor];
    _cornerLocation = CornerLoactionDefault;
    _cornerColor = [UIColor colorWithRed:85/255.0f green:183/255.0 blue:55/255.0 alpha:1.0];
    _cornerWidth = 2.0;
    _backgroundAlpha = 0.5;
    _animationTimeInterval = 0.02;
    _scanImageName = @"QRCodeScanLine";
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(scanBorderX, scanBorderY, scanBorderW, scanBorderW);
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    /// 边框 frame
    CGFloat borderW = scanBorderW;
    CGFloat borderH = 1.3*borderW;
    CGFloat borderX = scanBorderX;
    CGFloat borderY = scanBorderY;
    CGFloat borderLineW = 0.2;

    /// 空白区域设置
    [[[UIColor blackColor] colorWithAlphaComponent:self.backgroundAlpha] setFill];
    UIRectFill(rect);
    // 获取上下文，并设置混合模式 -> kCGBlendModeDestinationOut
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
    // 设置空白区
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX + 0.5 * borderLineW, borderY + 0.5 *borderLineW, borderW - borderLineW, borderH - borderLineW)];
    [bezierPath fill];
    // 执行混合模式
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    /// 边框设置
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:CGRectMake(borderX, borderY, borderW, borderH)];
    borderPath.lineCapStyle = kCGLineCapButt;
    borderPath.lineWidth = borderLineW;
    [self.borderColor set];
    [borderPath stroke];
    
    
    CGFloat cornerLenght = 20;
    /// 左上角小图标
    UIBezierPath *leftTopPath = [UIBezierPath bezierPath];
    leftTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    CGFloat insideExcess = fabs(0.5 * (self.cornerWidth - borderLineW));
    CGFloat outsideExcess = 0.5 * (borderLineW + self.cornerWidth);
    if (self.cornerLocation == CornerLoactionInside) {
        [leftTopPath moveToPoint:CGPointMake(borderX + insideExcess, borderY + cornerLenght + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + insideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [leftTopPath moveToPoint:CGPointMake(borderX - outsideExcess, borderY + cornerLenght - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY - outsideExcess)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY - outsideExcess)];
    } else {
        [leftTopPath moveToPoint:CGPointMake(borderX, borderY + cornerLenght)];
        [leftTopPath addLineToPoint:CGPointMake(borderX, borderY)];
        [leftTopPath addLineToPoint:CGPointMake(borderX + cornerLenght, borderY)];
    }

    [leftTopPath stroke];
    
    /// 左下角小图标
    UIBezierPath *leftBottomPath = [UIBezierPath bezierPath];
    leftBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - insideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX + insideExcess, borderY + borderH - cornerLenght - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH + outsideExcess)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX - outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
    } else {
        [leftBottomPath moveToPoint:CGPointMake(borderX + cornerLenght, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH)];
        [leftBottomPath addLineToPoint:CGPointMake(borderX, borderY + borderH - cornerLenght)];
    }

    [leftBottomPath stroke];
    
    /// 右上角小图标
    UIBezierPath *rightTopPath = [UIBezierPath bezierPath];
    rightTopPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + insideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + cornerLenght + insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY - outsideExcess)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + cornerLenght - outsideExcess)];
    } else {
        [rightTopPath moveToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY)];
        [rightTopPath addLineToPoint:CGPointMake(borderX + borderW, borderY + cornerLenght)];
    }

    [rightTopPath stroke];
    
    /// 右下角小图标
    UIBezierPath *rightBottomPath = [UIBezierPath bezierPath];
    rightBottomPath.lineWidth = self.cornerWidth;
    [self.cornerColor set];
    
    if (self.cornerLocation == CornerLoactionInside) {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - cornerLenght - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - insideExcess, borderY + borderH - insideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght - insideExcess, borderY + borderH - insideExcess)];
    } else if (self.cornerLocation == CornerLoactionOutside) {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH - cornerLenght + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW + outsideExcess, borderY + borderH + outsideExcess)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght + outsideExcess, borderY + borderH + outsideExcess)];
    } else {
        [rightBottomPath moveToPoint:CGPointMake(borderX + borderW, borderY + borderH - cornerLenght)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW, borderY + borderH)];
        [rightBottomPath addLineToPoint:CGPointMake(borderX + borderW - cornerLenght, borderY + borderH)];
    }

    [rightBottomPath stroke];
}

#pragma mark - - - 添加定时器
- (void)addTimer {
    CGFloat scanninglineX = 0;
    CGFloat scanninglineY = 0;
    CGFloat scanninglineW = 0;
    CGFloat scanninglineH = 0;
    if (self.scanAnimationStyle == ScanAnimationStyleGrid) {
        [self addSubview:self.contentView];
        [_contentView addSubview:self.scanningline];
        scanninglineW = scanBorderW;
        scanninglineH = scanBorderW;
        scanninglineX = 0;
        scanninglineY = - scanBorderW;
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);

    } else {
        [self addSubview:self.scanningline];
        scanninglineW = scanBorderW;
        scanninglineH = 12;
        scanninglineX = scanBorderX;
        scanninglineY = scanBorderY;
        _scanningline.frame = CGRectMake(scanninglineX, scanninglineY, scanninglineW, scanninglineH);
    }
    self.timer = [NSTimer timerWithTimeInterval:self.animationTimeInterval target:self selector:@selector(beginRefreshUI) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
#pragma mark - - - 移除定时器
- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
    [_scanningline removeFromSuperview];
    _scanningline = nil;
}
#pragma mark - - - 执行定时器方法
- (void)beginRefreshUI {
    __block CGRect frame = _scanningline.frame;
    static BOOL flag = YES;
    
    __weak typeof(self) weakSelf = self;

    if (self.scanAnimationStyle == ScanAnimationStyleGrid) {
        if (flag) {
            frame.origin.y = - scanBorderW;
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                weakSelf.scanningline.frame = frame;
            } completion:nil];
        } else {
            if (_scanningline.frame.origin.y >= - scanBorderW) {
                CGFloat scanContent_MaxY = - scanBorderW + self.frame.size.width - 2 * scanBorderX;
                if (_scanningline.frame.origin.y >= scanContent_MaxY) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        frame.origin.y = - scanBorderW;
                        weakSelf.scanningline.frame = frame;
                        flag = YES;
                    });
                } else {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        weakSelf.scanningline.frame = frame;
                    } completion:nil];
                }
            } else {
                flag = !flag;
            }
        }
    } else {
        if (flag) {
            frame.origin.y = scanBorderY;
            flag = NO;
            [UIView animateWithDuration:self.animationTimeInterval animations:^{
                frame.origin.y += 2;
                weakSelf.scanningline.frame = frame;
            } completion:nil];
        } else {
            if (_scanningline.frame.origin.y >= scanBorderY) {
                CGFloat scanContent_MaxY = scanBorderY + self.frame.size.width - 2 * scanBorderX;
                if (_scanningline.frame.origin.y >= scanContent_MaxY - 10) {
                    frame.origin.y = scanBorderY;
                    weakSelf.scanningline.frame = frame;
                    flag = YES;
                } else {
                    [UIView animateWithDuration:self.animationTimeInterval animations:^{
                        frame.origin.y += 2;
                        weakSelf.scanningline.frame = frame;
                    } completion:nil];
                }
            } else {
                flag = !flag;
            }
        }
    }
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        
        /// 静态库 url 的获取
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"SGQRCode" withExtension:@"bundle"];
        if (!url) {
            /// 动态库 url 的获取
            url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SGQRCode" withExtension:@"bundle"];
        }
        NSBundle *bundle = [NSBundle bundleWithURL:url];
        
        UIImage *image = [UIImage imageNamed:self.scanImageName inBundle:bundle compatibleWithTraitCollection:nil];
        if (!image) {
            image = [UIImage imageNamed:self.scanImageName];
        }
        _scanningline.image = image;
    }
    return _scanningline;
}

#pragma mark - - - set
- (void)setScanAnimationStyle:(ScanAnimationStyle)scanAnimationStyle {
    _scanAnimationStyle = scanAnimationStyle;
}

- (void)setScanImageName:(NSString *)scanImageName {
    _scanImageName = scanImageName;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
}

- (void)setCornerLocation:(CornerLoaction)cornerLocation {
    _cornerLocation = cornerLocation;
}

- (void)setCornerColor:(UIColor *)cornerColor {
    _cornerColor = cornerColor;
}

- (void)setCornerWidth:(CGFloat)cornerWidth {
    _cornerWidth = cornerWidth;
}

- (void)setBackgroundAlpha:(CGFloat)backgroundAlpha {
    _backgroundAlpha = backgroundAlpha;
}

- (void)setAnimationTimeInterval:(NSTimeInterval)animationTimeInterval {
    _animationTimeInterval = animationTimeInterval;
}

@end
