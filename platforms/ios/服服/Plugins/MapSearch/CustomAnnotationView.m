//
//  CustomAnnotationView.m
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import "CustomAnnotationView.h"

#define kscreenWidth [UIScreen mainScreen].bounds.size.width

#define kCalloutWidth       200.0
#define kCalloutHeight      40.0

@implementation CustomAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    if (self.isShowCallout) {
        
//    if (self.selected == selected)
//    {
//        return;
//    }
    
    if (selected)
    {
        
        
            if (self.calloutView == nil)
            {
                
                CGFloat width = 0.0;
                CGSize  size = [self boundingRectWithSize:CGSizeMake(kscreenWidth-40, 30) text:self.title];
                if (size.width < kscreenWidth-40) {
                    width = size.width;
                } else {
                    width = kscreenWidth-40;
                }
                self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, width+10, kCalloutHeight)];
                self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                      -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            }
            
            self.calloutView.addressTitle = self.title;
            
            [self addSubview:self.calloutView];
        }
        else
        {
            [self.calloutView removeFromSuperview];
        }

        [super setSelected:selected animated:animated];
        
    } else {
        if (selected && self.markCanScal) {
                self.image = [UIImage imageNamed:@"address_small"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PosterOne" object:self.title];
        }
    }

}

- (CGSize)boundingRectWithSize:(CGSize)size text:(NSString *)text
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGSize retSize = [text boundingRectWithSize:size
                                        options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return retSize;
}

@end
