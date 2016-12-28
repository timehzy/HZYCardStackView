//
//  CustomCard.m
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "CustomCard.h"

@implementation CustomCard
- (instancetype)initWithReuseIdentifier:(NSString *)identifier{
    if (self = [super initWithReuseIdentifier:identifier]) {
        [self configView];
    }
    return self;
}

- (void)configView{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 300-32, 300-32)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    self.imageView = imageView;
}
@end
