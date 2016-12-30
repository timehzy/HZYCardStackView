//
//  HZYCardStackCard.m
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "HZYCardStackViewCard.h"

@implementation HZYCardStackViewCard
- (instancetype)initWithReuseIdentifier:(NSString *)identifier{
    if (self = [super initWithFrame:CGRectZero]) {
        _reuseIdentifier = [identifier copy];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithReuseIdentifier:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self initWithReuseIdentifier:nil];
}

- (id)copyWithZone:(NSZone *)zone{
    HZYCardStackViewCard *card = [[[self class] alloc] initWithReuseIdentifier:_reuseIdentifier];
    return card;
}

#pragma mark - private func
//- (NSUInteger)hash{
//    return [_reuseIdentifier hash];
//}
//
//- (BOOL)isEqual:(id)object{
//    if (![object isKindOfClass:[self class]]) {
//        return NO;
//    }
//    if ([((HZYCardStackViewCard *)object).reuseIdentifier isEqualToString:_reuseIdentifier]) {
//        return YES;
//    }
//    return NO;
//}
@end
