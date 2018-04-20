
#import <UIKit/UIKit.h>
#import "FLImageShowScrollView.h"
#define DeviceOrientationKey @"DeviceOrientationKey"

typedef enum : NSUInteger {
    DeviceOrientationVertical,//竖屏
    DeviceOrientationHorizontal,//横屏
} DeviceOrientation;


@protocol FLImgeShowCellDelegate <NSObject>

- (void)tapRecognizerActionWithType:(BOOL)type;

@end

@interface FLImageShowCell : UICollectionViewCell<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet FLImageShowScrollView *scrollView;
@property (nonatomic,strong)UIImageView *imageView;

/**
 *  相册图片url
 */
@property (nonatomic,strong)NSURL *albumImageUrl;

@property (nonatomic,retain) id<FLImgeShowCellDelegate> flimageShowCellDelegate;


@end
