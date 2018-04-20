//
//  AddressViewCell.m
//  服服
//
//  Created by shangzh on 16/6/17.
//
//

#import "AddressViewCell.h"
#import "MapModel.h"

@interface AddressViewCell()

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *address;

@end

@implementation AddressViewCell

+ (instancetype)Item {
    return [[[NSBundle mainBundle] loadNibNamed:@"AddressViewCell" owner:self options:nil] lastObject];
}

- (void)setModel:(MapModel *)model {
    self.name.text = model.title;
    self.address.text = model.searchAddress;
}

@end
