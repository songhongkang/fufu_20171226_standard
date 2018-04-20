//
//  ShowMapViewCell.m
//  服服
//
//  Created by shangzh on 17/1/12.
//
//

#import "ShowMapViewCell.h"

@interface ShowMapViewCell()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailAddressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImage;
@end

@implementation ShowMapViewCell

+ (instancetype)Item {
    return [[[NSBundle mainBundle] loadNibNamed:@"ShowMapViewCell" owner:self options:nil] lastObject];
}

- (void)setAddress:(NSString *)address {
    self.addressLabel.text = address;
}

- (void)setDetailAddress:(NSString *)detailAddress {
    self.detailAddressLabel.text = detailAddress;
}

- (void)setIsSelected:(BOOL)isSelected {
    if (isSelected) {
        self.selectedImage.image = [UIImage imageNamed:@"showmapseleced"];
    } else {
        self.selectedImage.image = nil;
    }
}
@end
