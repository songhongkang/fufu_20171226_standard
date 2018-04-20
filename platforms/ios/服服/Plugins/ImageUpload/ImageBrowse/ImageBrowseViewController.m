//
//  ImageBrowseViewController.m
//  服服
//
//  Created by shangzh on 16/12/14.
//

#import "ImageBrowseViewController.h"
#import "ImageBrowseViewCell.h"
#import "Constan.h"

@interface ImageBrowseViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,ImageBrowseViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *imageBrowseCollection;

@property (nonatomic,strong) NSArray *arr;

@property (nonatomic,strong) UIView *pointView;

@property (nonatomic,strong) UIPageControl *pageControl;

@end

@implementation ImageBrowseViewController

- (NSArray *)arr{
    if (_arr == nil) {
        _arr =[NSArray arrayWithObjects:@"http://120.24.153.50/cb_hrms/upload/6A71C3A9-62AC-4D33-85A7F4849E96E723.png",@"http://120.24.153.50/cb_hrms/upload/C7D0983E-0697-4647-B5428487C6E6994E.png",@"http://120.24.153.50/cb_hrms/upload/C84F1725-C997-45B6-BD663C0EC9514E87.png", nil];
    }
    return _arr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [_imageBrowseCollection registerNib:[UINib nibWithNibName:@"ImageBrowseViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ImageBrowseViewCell"];
    
    //设置layout
    _imageBrowseCollection.pagingEnabled = YES;
    _imageBrowseCollection.showsHorizontalScrollIndicator = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(width, height+22);
    _imageBrowseCollection.backgroundColor = kUIColorFromRGB(0x000000);
    _imageBrowseCollection.collectionViewLayout = layout;
    
//    _pointView = [[UIView alloc] initWithFrame:CGRectMake(0, height-40, width, 40)];
//    _pointView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_pointView];
//    
//    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 12, 12)];
//    image.image = [UIImage imageNamed:@"img_browse_sel"];
//    [_pointView addSubview:image];
    
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.frame = CGRectMake(0, 0, 100, 20);//指定位置大小
    _pageControl.center = CGPointMake(width/2, height-20);
    _pageControl.numberOfPages = 3;//指定页面个数
    _pageControl.currentPage = 0;//指定pagecontroll的值，默认选中的小白点（第一个）
    //添加委托方法，当点击小白点就执行此方法
    
    _pageControl.pageIndicatorTintColor = [UIColor redColor];// 设置非选中页的圆点颜色
    
    _pageControl.currentPageIndicatorTintColor = [UIColor blueColor]; // 设置选中页的圆点颜色
    [self.view addSubview:_pageControl];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //滑动后改变顶部显示的当前位置
    int page  = scrollView.contentOffset.x/screenWidth;
    _pageControl.currentPage = page;
    
}

#pragma mark--UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.arr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageBrowseViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageBrowseViewCell" forIndexPath:indexPath];
    cell.imageBrowViewCellDelegate = self;
    cell.netImageUrl = _arr[indexPath.row];
    cell.backgroundColor = [UIColor redColor];
    if (indexPath.row == self.arr.count) {
        cell.isLast = YES;
    } else {
        cell.isLast = NO;
    }
    return cell;
}

#pragma mark ImageBrowseDelegate
- (void)dissMissImageBrowseViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
