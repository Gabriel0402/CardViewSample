//
//  CardViewController.h
//  Bright
//
//  Created by Rich on 10/31/13.
//  Copyright (c) 2013 mobifusion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@interface CardViewController : UIViewController<UIGestureRecognizerDelegate>
{
    int selectedIndex, deleteIndex;
    BOOL isDeleteVisible, isDataAlreadyLoaded, newCardAdding, currentCardRemoving;
    BOOL panDraggingStarted;
    UIView *activeCard;
}
@property (nonatomic, strong) CardView *cardView;
@property (nonatomic, strong) NSMutableArray *cardsArray, *cardViewsArray ;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer, *readTapGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *deleteButton;

@end
