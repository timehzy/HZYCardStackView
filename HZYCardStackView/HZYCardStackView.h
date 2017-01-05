//
//  HZYCardStackView.h
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HZYCardStackOffsetCurve) {
    HZYCardStackOffsetCurveNormal,
    HZYCardStackOffsetCurveSquareDecrease
};

@class HZYCardStackViewCard;
@class HZYCardStackView;

@protocol HZYCardStackViewDataSource <NSObject>
@required
- (NSUInteger)numberOfCards:(HZYCardStackView *)cardStack;
- (HZYCardStackViewCard *)cardStack:(HZYCardStackView *)cardStack cardViewForIndex:(NSUInteger)index;
@optional
- (CGSize)cardStack:(HZYCardStackView *)cardStack sizeForCardAtIndex:(NSUInteger)index;
- (CGPoint)cardStack:(HZYCardStackView *)cardStack offsetForIndex:(NSInteger)index;
@end

@protocol HZYCardStackViewDelegate <NSObject>
@optional
- (void)cardStack:(HZYCardStackView *)cardStack cardWillBeginDragging:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index cardRemain:(NSUInteger)remain;
- (void)cardStack:(HZYCardStackView *)cardStack cardDidEndDragging:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index cardRemain:(NSUInteger)remain;
- (void)cardStack:(HZYCardStackView *)cardStack cardWillAppear:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index cardRemain:(NSUInteger)remain;
- (void)cardStack:(HZYCardStackView *)cardStack cardDidRemove:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index cardRemain:(NSUInteger)remain;
@end

@interface HZYCardStackView : UIView
@property (nonatomic, weak) id<HZYCardStackViewDelegate> delegate;
@property (nonatomic, weak) id<HZYCardStackViewDataSource> dataSource;
@property (nonatomic, assign) CGSize cardSize;
@property (nonatomic, assign) NSUInteger numberOfCardsShown;//能看到几张卡片（加载几张卡片到界面）,默认3
@property (nonatomic, assign) CGFloat minDistanceForNext;//拖拽到下一张卡片的最小距离, 默认160
@property (nonatomic, assign) CGFloat minSpeedForNext;//拖拽到下一张卡片的最小速度，默认800
@property (nonatomic, assign) CGFloat cardScalingRate;//后面图片的缩放比率，默认0.9
@property (nonatomic, assign) CGPoint cardOffset;//后面图片的垂直偏移量，默认(0, -8)
@property (nonatomic, assign) HZYCardStackOffsetCurve cardOffsetCurve;//默认HZYCardStackOffsetCurveSquareDecrease，看起来更自然


//- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<HZYCardStackViewDataSource>)dataSource NS_DESIGNATED_INITIALIZER;
- (void)reloadData;
- (void)registerClass:(Class)cardClass forCardReuseIdentifier:(NSString *)identifier;
- (void)registerNib:(UINib *)nib forCardReuseIdentifier:(NSString *)identifier;
- (__kindof HZYCardStackViewCard *)dequeueReusableCardWithIdentifier:(NSString *)identifier;
- (__kindof HZYCardStackViewCard *)cardForIndex:(NSInteger)index;
@end
