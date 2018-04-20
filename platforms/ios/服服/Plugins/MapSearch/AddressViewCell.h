//
//  AddressViewCell.h
//  服服
//
//  Created by shangzh on 16/6/17.
//
//

#import <UIKit/UIKit.h>

@class MapModel;

@interface AddressViewCell : UITableViewCell

@property (nonatomic,strong) MapModel *model;

+ (instancetype)Item;

@end
