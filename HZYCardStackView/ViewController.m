//
//  ViewController.m
//  HZYCardStackView
//
//  Created by Michael-Nine on 2016/12/27.
//  Copyright © 2016年 Michael. All rights reserved.
//

#import "ViewController.h"
#import "HZYCardStackView.h"
#import "CustomCard.h"
@interface ViewController ()<HZYCardStackViewDataSource, HZYCardStackViewDelegate>
@property (nonatomic, strong) HZYCardStackView *cardStack;
@property (nonatomic, copy) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableArray *tempArr = [NSMutableArray array];
    for (NSInteger i=1; i<10; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%zd", i]];
        [tempArr addObject:image];
    }
    self.dataArray = tempArr;
    
    HZYCardStackView *cardStack = [[HZYCardStackView alloc]initWithFrame:CGRectOffset(self.view.bounds, 0, -60)];
    cardStack.dataSource = self;
    cardStack.delegate = self;
//    cardStack.minDistanceForNext = 1000;
    cardStack.numberOfCardsShown = 3;
    cardStack.cardOffset = CGPointMake(0, -8);
    cardStack.cardScalingRate = 0.92;
    [cardStack registerClass:[CustomCard class] forCardReuseIdentifier:@"hhh"];
    [self.view addSubview:cardStack];
    self.cardStack = cardStack;
}

//- (void)cardStack:(HZYCardStackView *)cardStack cardWillAppear:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index{
//    NSLog(@"will appear:%zd", index);
//}
//
//- (void)cardStack:(HZYCardStackView *)cardStack cardDidRemove:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index{
//    NSLog(@"did remove:%zd", index);
//}
//
//- (void)cardStack:(HZYCardStackView *)cardStack cardWillBeginDragging:(HZYCardStackViewCard *)card atIndex:(NSUInteger)index{
//    NSLog(@"will dragging:%zd", index);
//}

- (NSUInteger)numberOfCards{
    return 99999;
}

- (HZYCardStackViewCard *)cardStack:(HZYCardStackView *)cardStack cardViewForIndex:(NSUInteger)index{
    CustomCard *card = [cardStack dequeueReusableCardWithIdentifier:@"hhh"];
    if (index % 2) {
        card.backgroundColor = [UIColor blueColor];
    }else{
        card.backgroundColor = [UIColor redColor];
    }
    card.imageView.image = self.dataArray[index % 9];
    return card;
}

- (CGSize)cardStack:(HZYCardStackView *)cardStack sizeForCardAtIndex:(NSUInteger)index{
    return CGSizeMake(300, 300);
}

- (IBAction)reload:(id)sender {
    [self.cardStack reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
