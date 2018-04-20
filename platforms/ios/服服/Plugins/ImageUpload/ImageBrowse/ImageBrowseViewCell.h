//
//  ImageBrowseViewCell.h
//  服服
//
//  Created by shangzh on 16/12/14.
//
//

#import <UIKit/UIKit.h>
#import "FLImageShowScrollView.h"

@protocol ImageBrowseViewCellDelegate <NSObject>

- (void)dissMissImageBrowseViewController;

@end

@interface ImageBrowseViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet FLImageShowScrollView *imageBrowseScrollView;

@property (nonatomic,strong)UIImageView *imageView;

/**
 *  网络图片url
 */
@property (nonatomic,strong)NSString *netImageUrl;

@property (nonatomic,retain) id<ImageBrowseViewCellDelegate> imageBrowViewCellDelegate;

@property (nonatomic,assign) BOOL isLast;


@end
