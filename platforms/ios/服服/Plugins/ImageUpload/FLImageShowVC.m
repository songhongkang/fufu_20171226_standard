
#import "FLImageShowVC.h"
#import "FLImageShowCell.h"
#import "ImageModel.h"
#import "Constan.h"
#import "ImageUploadBottomView.h"
#import "UIView+UIViewAnimation.h"
#import "CDVAlertMessageView.h"

@interface FLImageShowVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,FLImgeShowCellDelegate,CDVAlertMessageViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
//@property (weak, nonatomic) IBOutlet UIView *topView;
//@property (weak, nonatomic) IBOutlet UILabel *topLabel;
//@property (weak, nonatomic) IBOutlet UIButton *topRightBtn;
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UIButton *topRightBtn;

@property (nonatomic,strong) UIButton *bottomRightBtn;

@property (nonatomic,strong) ImageUploadBottomView *bottomView;

@end

@implementation FLImageShowVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    _topView.backgroundColor = [kUIColorFromRGB(0x000000) colorWithAlphaComponent:0.75];
    
    [self.view addSubview:_topView];
    
    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenWidth-70)/2, 7, 70, 30)];
    _topLabel.textColor = kUIColorFromRGB(0xffffff);
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.font = [UIFont systemFontOfSize:17];
    [_topView addSubview:_topLabel];
    
    UIButton *topLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 7, 24, 30)];
    [topLeftBtn setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    topLeftBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 8, 7, 0);
    [topLeftBtn addTarget:self action:@selector(topLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:topLeftBtn];
    
    _topRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-44, 0, 44, 44)];
    [_topRightBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    [_topRightBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [_topView addSubview:_topRightBtn];
    
    if (_albumImageUrlArray.count > 0)
    {
        _topLabel.text = [NSString stringWithFormat:@"%d/%lu",_currentIndex + 1, (unsigned long)_albumImageUrlArray.count];
    }
    else
    {
        _topLabel.text = @"0/9";
    }
    
    [_myCollectionView registerNib:[UINib nibWithNibName:@"FLImageShowCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"FLImageShowCell"];
   
    //设置layout
    _myCollectionView.pagingEnabled = YES;
    _myCollectionView.showsHorizontalScrollIndicator = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(width, height);
    _myCollectionView.collectionViewLayout = layout;
    
    [self addBottomRightbtn];
    
    self.bottomView = [[ImageUploadBottomView alloc] initWithFrame:CGRectMake(0, screenHeight-45, screenWidth, 45)];
    self.bottomView.backgroundColor = [kUIColorFromRGB(0x000000) colorWithAlphaComponent:0.75];
    [self.bottomView.rightBtn setTitle:[NSString stringWithFormat:@"选择(%lu/%d)",(unsigned long)self.flSelectedImageArr.count,(9-_selectCount)] forState:UIControlStateNormal];
    [self.bottomView.rightBtn addTarget:self action:@selector(backSelectedImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    
    [_topRightBtn addTarget:self action:@selector(addSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
    
    ImageModel *model = self.albumImageUrlArray[_currentIndex];
    for (ImageModel *imageModel in self.flSelectedImageArr) {
        if ([imageModel.url isEqualToString:model.url]) {
             [_topRightBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
              _topRightBtn.selected = YES;
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)addBottomRightbtn {
    
    _bottomRightBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 100 -12, 7, 100,30)];
    _bottomRightBtn.alpha = 1.0;
    [_bottomRightBtn setTitle:[NSString stringWithFormat:@"选中(%ld/%d)",(unsigned long)self.flSelectedImageArr.count,(9-_selectCount)] forState:UIControlStateNormal];
    
    ImageModel *model = _albumImageUrlArray[_currentIndex];
    
    if (model.isSelected) {
        _bottomRightBtn.selected = YES;
        [_bottomRightBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];

    } else {
        _bottomRightBtn.selected = NO;
        [_bottomRightBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
    }

    [_bottomRightBtn setTitleColor:kUIColorFromRGB(0x53afff) forState:UIControlStateNormal];
    [_bottomRightBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    _bottomRightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [_bottomRightBtn addTarget:self action:@selector(addSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:_bottomRightBtn];

}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //滚动到当前图片位置
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
    [_myCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark--选择图片
- (void)addSelectedImage:(UIButton *)btn {

        if (btn.selected) {
    
            [_topRightBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
            ImageModel *model = _albumImageUrlArray[_currentIndex];
            model.isSelected = NO;
            _topRightBtn.selected = NO;
            for (ImageModel *mod in self.flSelectedImageArr) {
                if ([mod.url isEqualToString:model.url]) {
                    [self.flSelectedImageArr removeObject:mod];
                    break;
                }
            }
            
        } else {
            
            if (_selectCount + self.flSelectedImageArr.count < 9) {
                [_topRightBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
                [_topRightBtn ViewZoomWith];
                ImageModel *model = _albumImageUrlArray[_currentIndex];
                model.isSelected = YES;
                _topRightBtn.selected = YES;
                [self.flSelectedImageArr addObject:model];
            } else {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已选择9张图片!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//                [alert show];
                CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"提示" message:@"您已选择9张图片!" okButtonTitle:@"确定" textType:TextCenter delegate:self];
                [message showInView:self.view];
            }
        }
    
    [self.bottomView.rightBtn setTitle:[NSString stringWithFormat:@"选择(%lu/%d)",(unsigned long)self.flSelectedImageArr.count,(9-_selectCount)]  forState:UIControlStateNormal];
    
}

- (void)topLeftBtnClick {
    if ([_delegate respondsToSelector:@selector(updateCollectionViewSelectImage:)]) {
        [_delegate updateCollectionViewSelectImage:self.flSelectedImageArr];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//返回选择的图片
- (void)backSelectedImage {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = @"";
        for (ImageModel *model in self.flSelectedImageArr) {
            if (model.isSelected) {
                if (path.length == 0) {
                    path = [path stringByAppendingFormat:@"%@",model.url];
                } else {
                    path = [path stringByAppendingFormat:@",%@",model.url];
                }
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturImageUrl" object:nil userInfo:[NSDictionary dictionaryWithObject:path forKey:@"path"]];
    });
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //滑动后改变顶部显示的当前位置
    _currentIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    NSInteger allCount = 0;
    allCount = _albumImageUrlArray.count;
    _topLabel.text = [NSString stringWithFormat:@"%d/%ld",_currentIndex + 1, (long)allCount];
    
    CGRect rect = self.topView.frame;

    if (rect.origin.y < 0) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.topView setFrame:CGRectMake(0, 0, screenWidth, 44)];
            [self.bottomView setFrame:CGRectMake(0, screenHeight-45, screenWidth, 45)];
        }];
        
    }
    
    ImageModel *model = _albumImageUrlArray[_currentIndex];
    if (model.isSelected) {
        _topRightBtn.selected = YES;
        [_topRightBtn setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateNormal];
    } else {
        _topRightBtn.selected = NO;
        [_topRightBtn setImage:[UIImage imageNamed:@"unselected"] forState:UIControlStateNormal];
        
    }
    
    [_bottomRightBtn setTitle:[NSString stringWithFormat:@"选择(%ld/%d)",(unsigned long)self.flSelectedImageArr.count,(9-_selectCount)] forState:UIControlStateNormal];
}

#pragma mark--UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _albumImageUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageModel *model = _albumImageUrlArray[indexPath.row];
    
    FLImageShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FLImageShowCell" forIndexPath:indexPath];
    cell.scrollView.zoomScale = 1.0;
    cell.flimageShowCellDelegate = self;
    
    cell.albumImageUrl = [NSURL URLWithString:model.url];
    
    return cell;
}

// FLImage Delegate
- (void)tapRecognizerActionWithType:(BOOL)type {
    
    if (type) {
        [UIView animateWithDuration:0.5 animations:^{
            [self.topView setFrame:CGRectMake(0, -44, screenWidth, 44)];
            [self.bottomView setFrame:CGRectMake(0, screenHeight, screenWidth, 44)];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            [self.topView setFrame:CGRectMake(0, 0, screenWidth, 44)];
            [self.bottomView setFrame:CGRectMake(0, screenHeight-45, screenWidth, 45)];
        }];
    }
}

@end
