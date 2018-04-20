//
//  ShowMapViewCell.h
//  服服
//
//  Created by shangzh on 17/1/12.
//
//

#import <UIKit/UIKit.h>

@interface ShowMapViewCell : UITableViewCell

@property (nonatomic,copy) NSString *address;

@property (nonatomic,copy) NSString *detailAddress;

@property (nonatomic,assign) BOOL isSelected;


+ (instancetype)Item;

@end
