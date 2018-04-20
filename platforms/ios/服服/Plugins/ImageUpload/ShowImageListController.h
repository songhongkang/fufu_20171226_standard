//
//  ShowImageListController.h
//  服服
//
//  Created by shangzh on 16/8/18.
//
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol ShowImageListDelegate <NSObject>

- (void)retunSelectImage:(NSString *)imageUrl imageArr:(NSArray *)imageArr;

@end

@interface ShowImageListController : UIViewController

//html页面已选择的图片数目
@property (nonatomic,assign) int selectCount;

@property (nonatomic,retain) id<ShowImageListDelegate> delegate;

@property (nonatomic, assign) CGRect buttonFrame;

@end
