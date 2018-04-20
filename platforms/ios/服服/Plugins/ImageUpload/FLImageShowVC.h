
#import <UIKit/UIKit.h>

@protocol FLImageShowVCDelegate <NSObject>

//更新collectionView
- (void)updateCollectionViewSelectImage:(NSMutableArray *)arr;

@end

@interface FLImageShowVC : UIViewController

//html页面已选择的图片数目
@property (nonatomic,assign) int selectCount;

/**
 *  相册图片url数组
 */
@property (nonatomic,strong)NSArray *albumImageUrlArray;

//选中的index数组
@property (nonatomic,strong) NSMutableArray *flSelectedImageArr;

/**
 *  当前图片位置，值在0到数组最大值之间
 */
@property (nonatomic,assign)NSInteger currentIndex;

@property (nonatomic,retain) id<FLImageShowVCDelegate> delegate;

@end
