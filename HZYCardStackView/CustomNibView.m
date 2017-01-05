//
//  CustomNibView.m
//  HZYCardStackView
//
//  Created by Michael-Nine on 2017/1/5.
//  Copyright © 2017年 Michael. All rights reserved.
//

#import "CustomNibView.h"

@interface CustomNibView ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
@implementation CustomNibView
- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}
@end
