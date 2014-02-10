//
//  CardView.h
//  Bright
//
//  Created by Mobi on 19/11/13.
//  Copyright (c) 2013 mobifusion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView<UIActionSheetDelegate, UIGestureRecognizerDelegate>
{
    int deleteIndex;
    BOOL isDeleteVisible, newCardAdding, currentCardRemoving;
}
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer, *readTapGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *deleteButton;

-(id)initWithTitle:(NSString *)title;
@end
