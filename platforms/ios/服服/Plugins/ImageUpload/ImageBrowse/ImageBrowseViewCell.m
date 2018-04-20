//
//  ImageBrowseViewCell.m
//  服服
//
//  Created by shangzh on 16/12/14.
//
//

#import "ImageBrowseViewCell.h"
//#import "UIImageView+WebCache.h"

@interface ImageBrowseViewCell()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
//是否双击放大图片
@property (nonatomic,assign) BOOL imageIsZoom;

@end

@implementation ImageBrowseViewCell

- (void)awakeFromNib {
    //设置实现缩放
    //设置代理scrollview的代理对象
    _imageBrowseScrollView.delegate=self;
    //设置最大伸缩比例
    _imageBrowseScrollView.maximumZoomScale = 2.0;
    //设置最小伸缩比例
    _imageBrowseScrollView.minimumZoomScale = 1;
    
    _imageView = [[UIImageView alloc] init];
    _imageBrowseScrollView.childView = _imageView;
    
    UITapGestureRecognizer *tapRecognizerSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageBrowseTapRecognizerSingleAction:)];
    tapRecognizerSingle.numberOfTapsRequired = 1; // 单击
    tapRecognizerSingle.delegate = self;
    // 图像视图添加单击手势
    [_imageBrowseScrollView addGestureRecognizer:tapRecognizerSingle];
    
    // 双击的手势
    UITapGestureRecognizer *tapRecognizerDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerDoubleAction:)];
    tapRecognizerDouble.numberOfTapsRequired = 2; // 双击
    tapRecognizerDouble.delegate = self;
    // 如果双击确定检测失败触发单击
    [tapRecognizerSingle requireGestureRecognizerToFail:tapRecognizerDouble];
    // 图像视图添加双击手势
    [_imageBrowseScrollView addGestureRecognizer:tapRecognizerDouble];
    
}

- (void)updateImageViewFrame:(UIImage *)image
{
    CGFloat mainScreenWidth;
    CGFloat mainScreenHeight;
    
//    UIDeviceOrientation orient = [[[NSUserDefaults standardUserDefaults] objectForKey:DeviceOrientationKey] integerValue];
//    if (orient == DeviceOrientationHorizontal)
//    {
//        //横屏
//        mainScreenWidth = [UIScreen mainScreen].bounds.size.height;
//        mainScreenHeight = [UIScreen mainScreen].bounds.size.width;
//    }
//    else
//    {
        //竖屏
        mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
        mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
//    }
    
    CGSize imageSize = image.size;
    CGSize imageViewSize;
    if (imageSize.width > mainScreenWidth)
    {
        imageViewSize = CGSizeMake(mainScreenWidth, imageSize.height / imageSize.width * mainScreenWidth);
        if (imageViewSize.height > mainScreenHeight)
        {
            imageViewSize = CGSizeMake(imageSize.width / imageSize.height * mainScreenHeight, mainScreenHeight);
        }
    }
    else
    {
        if (imageSize.height > mainScreenHeight)
        {
            imageViewSize = CGSizeMake(imageSize.width / imageSize.height * mainScreenHeight, mainScreenHeight);
        }
        else
        {
            imageViewSize = imageSize;
        }
    }
    _imageView.frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    _imageBrowseScrollView.childView = _imageView;
}
#pragma mark--重写
- (void)setNetImageUrl:(NSString *)netImageUrl
{
    _netImageUrl = netImageUrl;
//    [_imageView sd_setImageWithURL:[NSURL URLWithString:netImageUrl] placeholderImage:[UIImage imageNamed:@"friends_sends_pictures_no"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (error)
//        {
//            _imageView.image = [UIImage imageNamed:@"friends_sends_pictures_no"];
//            [self updateImageViewFrame:_imageView.image];
//        }
//        else
//        {
//            [self updateImageViewFrame:image];
//        }
//    }];
}

#pragma mark--UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark UIGestureRecognizer Delegate
- (void)imageBrowseTapRecognizerSingleAction:(UITapGestureRecognizer *)recognizer
{
    if ([self.imageBrowViewCellDelegate respondsToSelector:@selector(dissMissImageBrowseViewController)] ) {
        [self.imageBrowViewCellDelegate dissMissImageBrowseViewController];
    }
}

// 点击手势方法 双击
bool isChangeSize;
- (void)tapRecognizerDoubleAction:(UITapGestureRecognizer *)recognizer
{
    float newScale;
    // 放大或缩小视图
    if (self.imageIsZoom) {
        newScale = _imageBrowseScrollView.zoomScale *0.0;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:CGPointMake(10, 10)];
        [_imageBrowseScrollView zoomToRect:zoomRect animated:YES];
        self.imageIsZoom = NO;
    } else {
        newScale = _imageBrowseScrollView.zoomScale *2.0;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
        [_imageBrowseScrollView zoomToRect:zoomRect animated:YES];
        self.imageIsZoom = YES;
    }


}

#pragma mark - CommonMethods
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}


@end
