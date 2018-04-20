//
//  CustomCalloutView.m
//  服服
//
//  Created by shangzh on 16/6/16.
//
//

#import "CustomerImageView.h"

#define kArrorHeight        10
#define kPortraitMargin     5
#define kTitleHeight        20


@interface CustomerImageView()

@end

@implementation CustomerImageView

- (void)setAddressTitle:(NSString *)addressTitle {
    self.titleLabel.text = addressTitle;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.9];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    
    // 添加标题，即商户名
//    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin * 2, 7.5, self.bounds.size.width - kPortraitMargin * 4, kTitleHeight)];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = self.addressTitle;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];    
}

- (void)drawRect:(CGRect)rect
{
    
//    [self drawInContext:UIGraphicsGetCurrentContext()];
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOpacity = 0.1;
//    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context
{
    
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.9].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context
{
    
    CGRect rrect = self.bounds;
    CGFloat radius = 2.5;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    CGContextMoveToPoint(context, midx+2, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-2, maxy);
    
//    CGContextAddArcToPoint(context, 40, 100, 40, 140, 5);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
    
}
@end
