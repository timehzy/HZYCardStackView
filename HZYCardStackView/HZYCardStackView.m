//
//  HZYCardStackView.m
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "HZYCardStackView.h"
#import "HZYCardStackViewCard.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@implementation HZYCardStackView{
    NSMutableArray<HZYCardStackViewCard *> *_reuseViewArray;
    NSMutableArray *_visiableCards;
    NSMutableArray *_indexArray;
    NSMutableArray *_cardTranformArray;
    NSUInteger _frontCardIndex;
    NSUInteger _lastCardIndex;
    CGPoint _frontCardCenter;
    UINib *_registedNib;
    NSString *_registedIdentifier;
    Class _registedClass;
    UIDynamicAnimator *_dynamicAnimator;
}
#pragma mark - init & life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self hzy_configView];
        _reuseViewArray = [NSMutableArray array];
        _visiableCards = [NSMutableArray array];
        _indexArray = [NSMutableArray array];
        _numberOfCardsShown = 3;
        _frontCardCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _minSpeedForNext = 800;
        _minDistanceForNext = 160;
        _cardScalingRate = 0.9;
        _cardOffset = CGPointMake(0, -8);
        _cardOffsetCurve = HZYCardStackOffsetCurveSquareDecrease;
        _dynamicAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self reloadData];
    });
}

#pragma mark - public func
- (void)reloadData{
    [_visiableCards removeAllObjects];
    [_indexArray removeAllObjects];
    [_reuseViewArray removeAllObjects];
    [_cardTranformArray removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _frontCardIndex = 0;
    _lastCardIndex = MIN(_numberOfCardsShown, [self.dataSource numberOfCards:self])-1;
    if ([self.dataSource numberOfCards:self] == 0) {
        return;
    }
    for (NSInteger i=0; i<=_lastCardIndex; i++) {
        HZYCardStackViewCard *card = [self hzy_loadACard:i];
        [self hzy_showCard:card ForIndex:i];
    }
}

- (HZYCardStackViewCard *)dequeueReusableCardWithIdentifier:(NSString *)identifier{
    HZYCardStackViewCard *reuseCard;
    for (HZYCardStackViewCard *card in _reuseViewArray) {
        if ([card.reuseIdentifier isEqualToString:identifier]) {
            card.transform = CGAffineTransformIdentity;
            card.alpha = 1;
            reuseCard = card;
            [_reuseViewArray removeObject:card];
            break;
        }
    }
    if (!reuseCard && _registedIdentifier) {
        if ( _registedClass) {
            NSAssert([_registedClass isSubclassOfClass:[HZYCardStackViewCard class]], @"rigister class must be a subclass of 'HZYCardStackViewCard'");
            reuseCard = [[_registedClass alloc]initWithReuseIdentifier:_registedIdentifier];
        }else if (_registedNib) {
            reuseCard = [_registedNib instantiateWithOwner:nil options:nil].firstObject;
            NSAssert([[reuseCard class] isSubclassOfClass:[HZYCardStackViewCard class]], @"rigister class must be a subclass of 'HZYCardStackViewCard'");
            [reuseCard setValue:_registedIdentifier forKey:@"reuseIdentifier"];
        }
    }
    if (reuseCard) {
        CGSize size = CGSizeEqualToSize(_cardSize, CGSizeZero) ? [self.dataSource cardStack:self sizeForCardAtIndex:_visiableCards.count] : _cardSize;
        reuseCard.frame = CGRectMake(0, 0, size.width, size.height);
        reuseCard.center = _frontCardCenter;
    }

    return reuseCard;
}

- (void)registerClass:(Class)cardClass forCardReuseIdentifier:(NSString *)identifier{
    _registedClass = cardClass;
    _registedIdentifier = [identifier copy];
}

- (void)registerNib:(UINib *)nib forCardReuseIdentifier:(NSString *)identifier{
    _registedNib = nib;
    _registedIdentifier = identifier;
}

- (HZYCardStackViewCard *)cardForIndex:(NSInteger)index{
    if (index >= [self.dataSource numberOfCards:self]) {
        return nil;
    }
    return [self.dataSource cardStack:self cardViewForIndex:index];
}

#pragma mark - private func
- (void)hzy_configView{
    self.backgroundColor = [UIColor clearColor];
}

- (void)hzy_cardViewPan:(UIPanGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            NSUInteger index = [_indexArray[[_visiableCards indexOfObject:gesture.view]] integerValue];
            NSUInteger cardRemain = [self.dataSource numberOfCards:self] - index;
            if ([self hzy_delegateCanRespondSelector:@selector(cardStack:cardWillBeginDragging:atIndex:cardRemain:)]) {
                [self.delegate cardStack:self cardWillBeginDragging:(HZYCardStackViewCard *)gesture.view atIndex:index cardRemain:cardRemain];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            HZYCardStackViewCard *cardView = (HZYCardStackViewCard *)gesture.view;
            CGPoint point = [gesture translationInView:self];
            CGPoint movedPoint = CGPointMake(gesture.view.center.x+point.x, gesture.view.center.y + point.y);
            cardView.center = movedPoint;
            
//            cardView.transform = CGAffineTransformRotate(cardView.transform, (gesture.view.center.x - _frontCardCenter.x) / _frontCardCenter.x * (M_PI_4 / 12));
            [gesture setTranslation:CGPointZero inView:self];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            [self hzy_finishedPanGesture:gesture];
        }
            break;
        default:
            break;
    }
}

- (void)hzy_finishedPanGesture:(UIPanGestureRecognizer *)gesture{
    NSUInteger index = [_indexArray[[_visiableCards indexOfObject:gesture.view]] integerValue];
    NSUInteger cardRemain = [self.dataSource numberOfCards:self] - index;
    CGFloat moveWidth  = (gesture.view.center.x  - _frontCardCenter.x);
    CGFloat moveHeight = (gesture.view.center.y - _frontCardCenter.y);
    CGFloat moveDistance = sqrtf(pow(moveWidth, 2) + pow(moveHeight, 2));
    CGPoint speedPoint = [gesture velocityInView:gesture.view];
    CGFloat speed = sqrtf(powf(speedPoint.x, 2)+ powf(speedPoint.y, 2));
    if (moveDistance > _minDistanceForNext || speed > _minSpeedForNext) {//移除card
        [self hzy_removeACard:(HZYCardStackViewCard *)gesture.view velocity:speedPoint movedDistace:CGPointMake(moveWidth, moveHeight)];
        [self hzy_loadNext];
        cardRemain--;
    }else{//复原card
        [UIView animateWithDuration:.25 delay:0 usingSpringWithDamping:.6 initialSpringVelocity:.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            gesture.view.center = _frontCardCenter;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if ([self hzy_delegateCanRespondSelector:@selector(cardStack:cardDidEndDragging:atIndex:cardRemain:)]) {
        [self.delegate cardStack:self cardDidEndDragging:(HZYCardStackViewCard *)gesture.view atIndex:index cardRemain:cardRemain];
    }
}

- (void)hzy_loadNext{
    if (_lastCardIndex+1 < [self.dataSource numberOfCards:self]) {
        [self hzy_loadACard:++_lastCardIndex];
    }

    for (NSUInteger i=0; i<_visiableCards.count; i++) {
        HZYCardStackViewCard *card = _visiableCards[i];
        [self hzy_showCard:card ForIndex:i];
    }
}


/**
 卡片移除的方法，拖拽成功或者调用方法移除

 @param card 要移除的card
 @param velocity 拖拽手势的末速度
 @param moved 已经移动的位置，x为正则中心偏右，y为正则中心偏下，反之亦然
 */
- (void)hzy_removeACard:(HZYCardStackViewCard *)card velocity:(CGPoint)velocity movedDistace:(CGPoint)moved{
    NSUInteger index = [_indexArray[[_visiableCards indexOfObject:card]] integerValue];
    [_indexArray removeObjectAtIndex:[_visiableCards indexOfObject:card]];
    [_visiableCards removeObject:card];
    if (index == _frontCardIndex) {
        _frontCardIndex++;
    }
    
    NSUInteger cardRemain = [self.dataSource numberOfCards:self] - index - 1;
    CGPoint targetPoint = velocity;
    targetPoint.x += card.center.x;
    targetPoint.y += card.center.y;
    [UIView animateWithDuration:.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        card.alpha = 0.3;
        card.transform = CGAffineTransformScale(card.transform, .5, .5);
        card.center = targetPoint;
    } completion:^(BOOL finished) {
        [card removeFromSuperview];
        [_reuseViewArray addObject:card];
        if ([self hzy_delegateCanRespondSelector:@selector(cardStack:cardDidRemove:atIndex:cardRemain:)]) {
            [self.delegate cardStack:self cardDidRemove:card atIndex:index cardRemain:cardRemain];
        }
    }];
}

- (HZYCardStackViewCard *)hzy_loadACard:(NSUInteger)index{
    NSUInteger cardRemain = [self.dataSource numberOfCards:self] - index;
    HZYCardStackViewCard *card = [self.dataSource cardStack:self cardViewForIndex:index];
    card.transform = CGAffineTransformScale(card.transform, 0.8, 0.8);
    [card addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hzy_cardViewPan:)]];
    [self insertSubview:card atIndex:0];
    [_visiableCards addObject:card];
    [_indexArray addObject:[NSNumber numberWithInteger:index]];
    if ([self hzy_delegateCanRespondSelector:@selector(cardStack:cardWillAppear:atIndex:cardRemain:)]) {
        [self.delegate cardStack:self cardWillAppear:card atIndex:index cardRemain:cardRemain];
    }
    return card;
}

- (BOOL)hzy_delegateCanRespondSelector:(SEL)selector{
    return self.delegate && [self.delegate respondsToSelector:selector];
}

- (void)hzy_showCard:(HZYCardStackViewCard *)card ForIndex:(NSInteger)index{
    CGFloat scalingRate = pow(_cardScalingRate, index);
    CGPoint offset = _cardOffset;
    if ([self.dataSource respondsToSelector:@selector(cardStack:offsetForIndex:)]) {
        offset = [self.dataSource cardStack:self offsetForIndex:index];
    }
    //先将缩放造成的偏移抹平
    NSInteger flagX;
    NSInteger flagY;
    if (_cardOffset.x > 0) {
        flagX = 1;
    }else if (_cardOffset.x < 0){
        flagX = -1;
    }else{
        flagX = 0;
    }
    if (_cardOffset.y > 0) {
        flagY = 1;
    }else if (_cardOffset.y < 0){
        flagY = -1;
    }else{
        flagY = 0;
    }
    CGSize cardSize = [self.dataSource cardStack:self sizeForCardAtIndex:index];
    CGFloat offsetX = (cardSize.width - cardSize.width * scalingRate) * flagX * .5 / scalingRate;
    CGFloat offsetY = (cardSize.height - cardSize.height * scalingRate) * flagY * .5 / scalingRate;
    //加上设定的偏移量
    switch (_cardOffsetCurve) {
        case HZYCardStackOffsetCurveNormal:
            offsetX = offsetX + offset.x / scalingRate*index;
            offsetY = offsetY + offset.y / scalingRate*index;
            break;
        case HZYCardStackOffsetCurveSquareDecrease:
            offsetX = offsetX + offset.x *index;
            offsetY = offsetY + offset.y *index;
            break;
    }
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //缩放
        card.transform = CGAffineTransformScale(CGAffineTransformIdentity, scalingRate, scalingRate);
        //偏移
        card.transform = CGAffineTransformTranslate(card.transform, offsetX, offsetY);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - setter & getter
- (id<HZYCardStackViewDataSource>)dataSource{
    NSAssert(_dataSource, @"data source can not be nil");
    return _dataSource;
}
@end
