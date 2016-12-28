//
//  HZYCardStackCard.h
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

/*
 使用时自定义一个类继承自此类，其它用法与UITableViewCell相同，只是没有默认的样式
 */

#import <UIKit/UIKit.h>

@interface HZYCardStackViewCard : UIView<NSCopying>
- (instancetype)initWithReuseIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;
@end
