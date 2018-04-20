//
//  ShowImageListController.m
//  服服
//
//  Created by shangzh on 16/8/18.
//  显示所有照片
//

#import "ShowImageListController.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "SelectPhotoCollectionViewCell.h"
#import "CustomeNaigationViewController.h"

#import "ImageModel.h"

#import "FLImageShowVC.h"
#import "ImageUploadBottomView.h"
#import "Constan.h"
#import "CDVAlertMessageView.h"

@interface ShowImageListController () <FLImageShowVCDelegate,UICollectionViewDelegate,UICollectionViewDataSource,CDVAlertMessageViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsLocalizedTitles;

@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic,strong) NSMutableArray *albumsArray;

//总共需要加载的照片
@property (nonatomic,assign) NSInteger countImage;

@property (nonatomic,strong) NSMutableArray *imageDataArr;
//加载照片的当前页数
@property (nonatomic,assign) NSInteger page;
//选择的照片
@property (nonatomic,strong) NSMutableArray *checkArr;

@property (nonatomic,strong) UIButton *btn;

//当前点击的item
@property (nonatomic,strong) NSIndexPath *currtentIndex;

@property (nonatomic,strong) ALAssetsGroup *group;

@property (nonatomic,strong) NSMutableArray *groupArray;

@property (nonatomic,strong)NSMutableArray *imageAssetAray;
@property (nonatomic,strong)NSMutableArray *imageUrlArray;
@property (nonatomic,strong)NSMutableArray *thumbnailArray;

//保存选择图片的index
@property (nonatomic,strong) NSMutableArray *selectImageArray;

//BottomView
@property (nonatomic,strong) ImageUploadBottomView *bottomView;

@end

@implementation ShowImageListController

- (NSMutableArray *)imageDataArr {
    if (_imageDataArr == nil) {
        _imageDataArr = [[NSMutableArray alloc] init];
    }
    return _imageDataArr;
}

- (NSMutableArray *)checkArr {
    if (_checkArr == nil) {
        _checkArr = [[NSMutableArray alloc] init];
    }
    return _checkArr;
}

- (NSMutableArray *)imageAssetAray {
    if (_imageAssetAray == nil) {
        _imageAssetAray = [[NSMutableArray alloc] init];
    }
    return _imageAssetAray;
}

- (NSMutableArray *)thumbnailArray {
    if (_thumbnailArray == nil) {
        _thumbnailArray = [[NSMutableArray alloc] init];
    }
    return _thumbnailArray;
}

- (NSMutableArray *)imageUrlArray {
    if (_imageUrlArray == nil) {
        _imageUrlArray = [[NSMutableArray alloc] init];
    }
    return _imageUrlArray;
}

- (NSMutableArray *)selectImageArray {
    if (_selectImageArray == nil) {
        _selectImageArray = [[NSMutableArray alloc] init];
    }
    return _selectImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"相册"];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.page = 1;
    
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _albumsArray = [[NSMutableArray alloc] init];
    
//    [self addLeftBarButton];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    
    [self getAlbumList];
    
    //添加BottomView
    self.bottomView = [[ImageUploadBottomView alloc] initWithFrame:CGRectMake(0, screenHeight-45, screenWidth, 45)];
    [self.bottomView.rightBtn setTitle:[NSString stringWithFormat:@"完成(%ld/%d)",(unsigned long)self.selectImageArray.count,9-_selectCount] forState:UIControlStateNormal];
    [self.bottomView.rightBtn addTarget:self action:@selector(imageSureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveImageAlert:) name:@"ImageMessage" object:nil];
    
}

- (CGRect)buttonFrame{
    
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width-20)/3;
    
    CGRect fram = CGRectMake(10+itemWidth, 5+66, itemWidth, itemWidth);
    
    return fram;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"" object:nil];
}

- (void)reciveImageAlert:(NSNotification *)notification{
                    CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"提示" message: @"您已选择9张图片!" okButtonTitle:@"确定" textType:TextCenter delegate:self];
                    [message showInView:self.view];
}

- (void)imageSureBtnClick {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *path = @"";
        for (ImageModel *model in self.selectImageArray) {
            if (model.url != nil && model.url.length > 0) {
                if (path.length == 0) {
                    path = [path stringByAppendingString:model.url];
                } else {
                    path = [path stringByAppendingString:[NSString stringWithFormat:@",%@",model.url]];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate retunSelectImage:path imageArr:self.checkArr];
        });
    });
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)loadPhotoWithAsset {
    
    NSString *tipTextWhenNoPhotosAuthorization; // 提示语
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
        tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
    }  else {
        NSLog(@"可以访问照片");
    }

}

#pragma mark PhotosKit


- (UICollectionView *)collectionView {
    
    if (_collectionView == nil) {
        
        CGFloat cellW = (self.view.frame.size.width-10 - 5*2)/3;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(cellW, cellW);
        
        layout.minimumInteritemSpacing = 0;
        
        layout.minimumLineSpacing = 5;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[SelectPhotoCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        
        _collectionView.contentInset = UIEdgeInsetsMake(5, 0, 44, 0);
        
        _collectionView.frame = CGRectMake(5, 0, self.view.bounds.size.width-10, self.view.bounds.size.height);
        
    }
    
    return _collectionView;
}

#pragma mark showimageViewcontroler delegate

- (void)updateCollectionViewSelectImage:(NSMutableArray *)arr {

    [self.selectImageArray removeAllObjects];

    [self.selectImageArray addObjectsFromArray:arr];
    
    [self.collectionView reloadData];
    
    [self.bottomView.rightBtn setTitle:[NSString stringWithFormat:@"完成(%ld/%d)",(unsigned long)self.selectImageArray.count,9-_selectCount] forState:UIControlStateNormal];

}

//获取相册列表
- (void)getAlbumList
{
    //获取相册列表
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    _groupArray = [NSMutableArray array];
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         NSLog(@"groupt===%@",group);
         
         if (group)
         {
             [_groupArray addObject:group];
         }
         else
         {
//             ALAssetsGroup *group = [_groupArray lastObject];
             for (ALAssetsGroup *group in _groupArray) {
                 NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                 [self getImageWithGroup:group name:groupName];
             }
//             NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
//             [self getImageWithGroup:group name:groupName];
         }
         
     } failureBlock:^(NSError *error)
     {
         NSLog(@"error:%@",error.localizedDescription);
     }];
}

//根据相册获取下面的图片
- (void)getImageWithGroup:(ALAssetsGroup *)group name:(NSString *)name
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //根据相册获取下面的图片
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if (name && ![name isEqualToString:groupName])
        {
            return;
        }
        
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result) {
                NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                if ([assetType isEqualToString:ALAssetTypePhoto]) {
//                    [self.imageAssetAray addObject:result];
                    [self.imageAssetAray insertObject:result atIndex:0];
                    [self.thumbnailArray addObject:[UIImage imageWithCGImage:result.thumbnail]];
//                   [self.thumbnailArray addObject: [self imageByScalingAndCroppingForSize:CGSizeMake(40, 40) withSourceImage:[UIImage imageWithCGImage:result.aspectRatioThumbnail]]];
                    
                    ALAssetRepresentation *representation = result.defaultRepresentation;
                    ImageModel *model = [[ImageModel alloc] init];
                    model.isSelected = false;
                    model.url = [NSString stringWithFormat:@"%@",representation.url];
//                    [self.imageUrlArray addObject:model];
                    
                    //将最新图片放在最上面
//                    if ([self.imageUrlArray count] > 0) {
                        [self.imageUrlArray insertObject:model atIndex:0];
//                    } else {
//                        [self.imageUrlArray addObject:model];
//                    }
                    
                }
            }
            if (index == group.numberOfAssets - 1)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
        }];
    });
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageAssetAray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SelectPhotoCollectionViewCell *cell = [SelectPhotoCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndex:indexPath];
    ImageModel *model = self.imageUrlArray[indexPath.item];
    
    cell.dataSource = self.imageUrlArray;
    cell.selectCount = self.selectCount;
    
    ALAsset *asset = self.imageAssetAray[indexPath.row];
    NSString *version = [UIDevice currentDevice].systemVersion;
    UIImage *image = nil;
    if (version.doubleValue >= 9.0) { // iOS系统版本 >= 9.0
        image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    } else {
        image = [UIImage imageWithCGImage:asset.thumbnail];
    }
    
    cell.cellImage = image;
   
    if (model.isSelected) {
        cell.selectedBtn.selected = YES;
         [cell.selectedBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    } else {
        cell.selectedBtn.selected = NO;
         [cell.selectedBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    }
    
    cell.imgBtnSelect = ^(BOOL flag) {
        
        model.isSelected = flag;
        
        if (!flag) {
            if (self.selectImageArray.count > 0) {
                for (ImageModel *mod in self.selectImageArray) {
                    if ([mod.url isEqualToString:model.url]) {
                        [self.selectImageArray removeObject:mod];
                        break;
                    }
                }
            }
            
        } else {
            if (self.selectImageArray.count + self.selectCount < 9) {
                [self.selectImageArray addObject:model];
            }
        }
        
        [self.bottomView.rightBtn setTitle:[NSString stringWithFormat:@"完成(%ld/%d)",(unsigned long)self.selectImageArray.count,9-_selectCount] forState:UIControlStateNormal];
        
    };
    
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLImageShowVC *fvc = [[FLImageShowVC alloc] init];
    fvc.delegate = self;
    fvc.selectCount = self.selectCount;
    fvc.albumImageUrlArray = self.imageUrlArray;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObjectsFromArray:self.selectImageArray];
    
    fvc.flSelectedImageArr = arr;
    fvc.currentIndex = indexPath.item;
    [self.navigationController presentViewController:fvc animated:YES completion:nil];
}

/**
 *  图片压缩到指定大小
 *  @param targetSize  目标图片的大小
 *  @param sourceImage 源图片
 *  @return 目标图片
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImage
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
