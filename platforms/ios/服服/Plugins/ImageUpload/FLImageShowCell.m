
#import "FLImageShowCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Constan.h"



@interface FLImageShowCell () <UIGestureRecognizerDelegate>

//标识topView是否移动上最上面隐藏
@property (nonatomic,assign) BOOL viewIsRemove;

//是否双击放大图片
@property (nonatomic,assign) BOOL imageIsZoom;

@end

@implementation FLImageShowCell 

- (void)awakeFromNib
{
    //设置实现缩放
    //设置代理scrollview的代理对象
    _scrollView.delegate=self;
    //设置最大伸缩比例
    _scrollView.maximumZoomScale = 2.0;
    //设置最小伸缩比例
    _scrollView.minimumZoomScale = 1;
    
    _imageView = [[UIImageView alloc] init];
    _scrollView.childView = _imageView;
    
    UITapGestureRecognizer *tapRecognizerSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerSingleAction:)];
    tapRecognizerSingle.numberOfTapsRequired = 1; // 单击
    tapRecognizerSingle.delegate = self;
    // 图像视图添加单击手势
    [_scrollView addGestureRecognizer:tapRecognizerSingle];

    // 双击的手势
    UITapGestureRecognizer *tapRecognizerDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerDoubleAction:)];
    tapRecognizerDouble.numberOfTapsRequired = 2; // 双击
    tapRecognizerDouble.delegate = self;
    // 如果双击确定检测失败触发单击
    [tapRecognizerSingle requireGestureRecognizerToFail:tapRecognizerDouble];
    // 图像视图添加双击手势
    [_scrollView addGestureRecognizer:tapRecognizerDouble];
    
}

- (void)updateImageViewFrame:(UIImage *)image
{
    CGFloat mainScreenWidth;
    CGFloat mainScreenHeight;
    
    UIDeviceOrientation orient = [[[NSUserDefaults standardUserDefaults] objectForKey:DeviceOrientationKey] integerValue];
    if (orient == DeviceOrientationHorizontal)
    {
        //横屏
        mainScreenWidth = [UIScreen mainScreen].bounds.size.height;
        mainScreenHeight = [UIScreen mainScreen].bounds.size.width;
    }
    else
    {
        //竖屏
        mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
        mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
    }
    
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
    _scrollView.childView = _imageView;
}
#pragma mark--重写

- (void)setAlbumImageUrl:(NSURL *)albumImageUrl
{
    _albumImageUrl = albumImageUrl;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:albumImageUrl resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        _imageView.image = [UIImage imageWithCGImage:representation.fullResolutionImage
                                               scale:representation.scale
                                         orientation:(UIImageOrientation)representation.orientation];
        [self updateImageViewFrame:_imageView.image];
    } failureBlock:^(NSError *error) {
        NSLog(@"相册url错误");
    }];
}

#pragma mark--UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

#pragma mark UIGestureRecognizer Delegate
- (void)tapRecognizerSingleAction:(UITapGestureRecognizer *)recognizer
{
    if (self.imageIsZoom) {
        float newScale;
        newScale = _scrollView.zoomScale *0.0;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:CGPointMake(10, 10)];
        [_scrollView zoomToRect:zoomRect animated:YES];

        self.imageIsZoom = false;
    } else {
        if (self.viewIsRemove == NO) {
            self.viewIsRemove = YES;
        } else {
            self.viewIsRemove = NO;
        }

        if ([_flimageShowCellDelegate respondsToSelector:@selector(tapRecognizerActionWithType:)]) {
            [self.flimageShowCellDelegate tapRecognizerActionWithType:_viewIsRemove];
        }
    }
}

// 点击手势方法 双击
bool isChangeSize;
- (void)tapRecognizerDoubleAction:(UITapGestureRecognizer *)recognizer
{
    // 放大或缩小视图
    float newScale;
    newScale = _scrollView.zoomScale *2.0;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[recognizer locationInView:recognizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
    self.imageIsZoom = YES;
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
