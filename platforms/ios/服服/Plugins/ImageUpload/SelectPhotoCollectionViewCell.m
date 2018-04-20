//
//  SelectPhotoCollectionViewCell.m
//  服服
//
//  Created by shangzh on 16/8/18.
//
//

#import "SelectPhotoCollectionViewCell.h"
#import "ImageModel.h"

#import "UIView+UIViewAnimation.h"
#import "Constan.h"
#import "CDVAlertMessageView.h"

@interface SelectPhotoCollectionViewCell()

@property (nonatomic,strong) UIImageView *cellImageView;

@property (nonatomic,assign) NSInteger currtentSelected;

//蒙板
@property (nonatomic,strong) UIView *markView;

@end

@implementation SelectPhotoCollectionViewCell

- (void)setCellImage:(UIImage *)cellImage {
    self.cellImageView.image = cellImage;
}

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndex:(NSIndexPath *)indexPath {
    
    SelectPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.item;
    if ([[cell.contentView.subviews lastObject] isKindOfClass:[UIImage class]]) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    return cell;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.cellImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 9.0) { // iOS系统版本 >= 8.0
            self.cellImageView.contentMode=UIViewContentModeScaleAspectFill;
            self.cellImageView.clipsToBounds=YES;
        }
        [self.contentView addSubview:self.cellImageView];
        
        self.markView = [[UIView alloc] initWithFrame:self.bounds];
        self.markView.backgroundColor = kUIColorFromRGB(0x000000);
        self.markView.alpha = 0.1;
        self.markView.hidden = YES;
        [self.contentView addSubview:self.markView];
        
        self.selectedBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-34, 0, 34, 34)];
        
        [self.selectedBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
//        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
//        [self.selectedBtn setBackgroundImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
        
        [self.selectedBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        
        [self.selectedBtn addTarget:self action:@selector(imgBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.selectedBtn];
        
    }
    
    return self;
}

- (void)imgBtnClick:(UIButton *)btn {
    
    self.currtentSelected = 0;
    
    for (ImageModel *model in self.dataSource) {
        if (model.isSelected) {
            self.currtentSelected++;
        }
    }
    
    if (!btn.selected) {
        self.currtentSelected++;
        [btn ViewZoomWith];
        if (self.currtentSelected <= 9-self.selectCount) {
            self.markView.hidden = NO;
           [btn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
        } else {
            self.markView.hidden = YES;
            [btn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        }
    } else {
        self.markView.hidden = YES;
        self.currtentSelected--;
        [btn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    }
    
    if (self.currtentSelected <= 9-self.selectCount) {
        self.imgBtnSelect(!btn.selected);
        btn.selected = !btn.selected;
    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已选取9张图片！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ImageMessage" object:nil userInfo:nil];
    }
}
@end
