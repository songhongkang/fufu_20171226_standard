//
//  SelectPhotoCollectionViewCell.h
//  服服
//
//  Created by shangzh on 16/8/18.
//
//

#import <UIKit/UIKit.h>

static NSString *const _cellIdentifier = @"collectionCell";

@interface SelectPhotoCollectionViewCell : UICollectionViewCell

typedef void(^imgBtnSelect)(BOOL);

@property (nonatomic, copy) imgBtnSelect imgBtnSelect;

@property (nonatomic,strong) UIImage *cellImage;

@property (nonatomic,strong) UIButton *selectedBtn;

@property (nonatomic,assign) BOOL isSelected;

@property (nonatomic,strong) NSArray *dataSource;

@property (nonatomic,assign) NSInteger selectCount;


+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndex:(NSIndexPath *)indexPath;

@end
