//
//  CardViewController.m
//  Bright
//
//  Created by Rich on 10/31/13.
//  Copyright (c) 2013 mobifusion. All rights reserved.
///

#import "CardViewController.h"
#import "AppDelegate.h"
@interface CardViewController ()

@end

@implementation CardViewController

#define COLOR_1 [UIColor colorWithRed:255.0/255.0 green:132.0/255.0 blue:0.0 alpha:1.0f];
#define COLOR_2 [UIColor colorWithRed:0.0f green:145.0/255.0 blue:206.0/255.0 alpha:1.0f];

#pragma mark View Life Cycle

-(void)viewWillAppear:(BOOL)animated
{
    [self addInitialContent];
}

-(void)addInitialContent
{
    selectedIndex = 0;
    [self addContentToArray];
    if(self.cardsArray.count>0)
    {
        [self addNullObjectsToCardViewsArray];
        [self loadScrollViewContents];
        [self removeGesturesFromView];
        [self addSwipeRecognizerForDirection:UISwipeGestureRecognizerDirectionUp];
        [self addSwipeRecognizerForDirection:UISwipeGestureRecognizerDirectionDown];
        [self addTapGestureRecognizerToGoReadViewController];
        [self addPanGestureToView];
        [self addPageControl];
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void) addContentToArray
{
    self.cardsArray = [NSMutableArray arrayWithObjects:@"Card 1", @"Card 2",@"Card 3", @"Card 4", nil];
}

-(void)addPageControl
{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 40, self.view.frame.size.width-40, 36)];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.cardsArray.count;
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.pageControl];
}

-(void) removeGesturesFromView
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        
        [self.view removeGestureRecognizer:recognizer];
    }
}

-(CGRect)getToFrameForCardView:(UIView *)cardView
{
    CGRect frame = cardView.frame;
    frame.origin.y = -(self.view.frame.size.height);
    return frame;
}

-(void)addPanGestureToView
{
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didReceivePanGestureEvent:)];
    [self.view addGestureRecognizer:self.panGesture];
}

-(void)addShadow:(BOOL)shouldAdd{
    
    UIView *view = activeCard;
    CALayer *layer=[view layer];
    [layer setShadowPath:[UIBezierPath bezierPathWithRect:layer.bounds].CGPath];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:CGSizeMake(0, 4)];
    [layer setShadowOpacity:0.80];
}

-(CGFloat)getAnimationDurationForFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame velocity:(CGFloat)velocity{
    
    velocity=fabs(velocity)>0.0?velocity:1;
    CGFloat displacement=fromFrame.origin.x-toFrame.origin.x;
    CGFloat deltaT=fabs(displacement/velocity);
    if(deltaT > 0.4){
        deltaT = 0.4;
    }else if(deltaT < 0.01){
        deltaT = 0.01;
    }
    return deltaT;
}

-(void) addCards
{
    [self loadScrollViewWithPage:selectedIndex-1];
    [self loadScrollViewWithPage:selectedIndex];
    [self loadScrollViewWithPage:selectedIndex+1];
    
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.cardViewsArray.count;
    self.pageControl.currentPage = selectedIndex;
}

-(void) cardsChanged
{
    for (int index = 0; index < [self.cardViewsArray count]; index++) {
        if (index != selectedIndex - 1 && index != selectedIndex && index != selectedIndex + 1) {
            
            [self.cardViewsArray replaceObjectAtIndex:index withObject:[NSNull null]];
        }
    }
    [self addCards];
}

-(CGRect)getCardViewFrameForState:(BOOL)isHiding{
    
    CGRect frame = activeCard.frame;
    if(isHiding){
        
        frame.origin.x = self.view.frame.size.width;
    }
    else
    {
        frame.origin.x = 0;
    }
    return frame;
}

-(void)performPanEndActivitiesWithVelocity:(CGPoint)velocityPoint
{
    
    CGFloat velocity = velocityPoint.x;
    CGFloat constraintX = self.view.frame.size.width/2;
    CGRect fromFrame = activeCard.frame;
    BOOL isHidingCards;
    if (activeCard.frame.origin.x > constraintX) {
        isHidingCards = YES;
    }
    else
    {
        isHidingCards = NO;
    }
    CGRect toFrame = [self getCardViewFrameForState:isHidingCards];
    CGFloat animationDuration=[self getAnimationDurationForFrame:fromFrame toFrame:toFrame velocity:velocity];
    [UIView animateWithDuration:animationDuration animations:^{
        [activeCard setFrame:toFrame];
    }completion:^(BOOL finished) {
        if ((isHidingCards && newCardAdding) || (!isHidingCards && currentCardRemoving)) {
            
        }
        else if(isHidingCards && currentCardRemoving)
        {
            --selectedIndex;
            [self cardsChanged];
        }
        else if(!isHidingCards && newCardAdding)
        {
            ++selectedIndex;
            [self cardsChanged];
        }
    }];
}

-(void) setActiveCardForTransitionDelta:(CGFloat) translationDelta
{
    if (translationDelta < 0) {
        currentCardRemoving = NO;
        if (selectedIndex >= 0 && selectedIndex < [self.cardsArray count]-1) {
            newCardAdding = YES;
            activeCard = [self.cardViewsArray objectAtIndex:selectedIndex+1];
        }
        else
        {
            newCardAdding = NO;
            activeCard = nil;
        }
    }
    else
    {
        newCardAdding = NO;
        currentCardRemoving = YES;
        if (selectedIndex != 0) {
            activeCard = [self.cardViewsArray objectAtIndex:selectedIndex];
        }
        else
            activeCard = nil;
    }
    [self addShadow:YES];
}

-(IBAction)didReceivePanGestureEvent:(UIPanGestureRecognizer *)recognizer
{
    static CGFloat previousTranslation=0;
    CGPoint translationPoint = [recognizer translationInView:self.view];
    CGFloat currentTranslation = translationPoint.x;
    CGFloat translationDelta=0;
    switch(recognizer.state)
    {
        case UIGestureRecognizerStateBegan:{
            panDraggingStarted = YES;
         
        }break;
            
        case UIGestureRecognizerStateEnded:{
            
            translationDelta=currentTranslation-previousTranslation;
            previousTranslation=currentTranslation;
            CGPoint velocity=[recognizer velocityInView:self.view];
            [self performPanEndActivitiesWithVelocity:velocity];
            return;
        }break;
            
        case UIGestureRecognizerStateChanged:{
            if (panDraggingStarted) {
                [self setActiveCardForTransitionDelta:currentTranslation];
                previousTranslation=currentTranslation;
                panDraggingStarted = NO;
            }
            translationDelta=currentTranslation-previousTranslation;
            previousTranslation=currentTranslation;
        }break;
            
        default:{
            return;
        }break;
    }
    CGRect frame = activeCard.frame;
    frame.origin.x+=translationDelta;
    float minX = 0;
    float maxX = self.view.frame.size.width;
    if(frame.origin.x<minX){
        frame.origin.x=minX;
    }else if(frame.origin.x>maxX){
        frame.origin.x=maxX;
    }
    [activeCard setFrame:frame];
}

-(void)tappedOnView:(UITapGestureRecognizer *)tapGesture
{
    //hide delete button and change cardview frame to its original position when tapped on view
    [UIView animateWithDuration:0.3f animations:^{
        UIView *cardView = [self.cardViewsArray objectAtIndex:selectedIndex];
        [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
        self.deleteButton.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 00);
        cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y+30, cardView.frame.size.width, cardView.frame.size.height);
    }];
    [self.view addGestureRecognizer:self.readTapGesture];
    [self.view addGestureRecognizer:self.panGesture];
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    isDeleteVisible = NO;
}

-(void)deleteCard:(UIButton *) sender
{
    deleteIndex = selectedIndex;
    UIView *cardView = [self.cardViewsArray objectAtIndex:deleteIndex];
    CGRect toFrame = [self getToFrameForCardView:cardView];
    [UIView animateWithDuration:0.3 animations:^{
        [cardView setFrame:toFrame];
        [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
        self.deleteButton.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 00);
        [self.view addGestureRecognizer:self.readTapGesture];
         [self.view addGestureRecognizer:self.panGesture];
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        isDeleteVisible = NO;
    }completion:^(BOOL finished) {
        
        [cardView removeFromSuperview];
        int pageIndex = selectedIndex;
        [self.cardViewsArray removeObjectAtIndex:pageIndex];
        [self.cardsArray removeObjectAtIndex:pageIndex];
        
        if (self.cardsArray.count > 0) {
            
            if (selectedIndex != 0)
                --selectedIndex;
            
            [self addCards];
        }
        else
        {
            for (UIView *subView in self.view.subviews)
                [subView removeFromSuperview];
            self.pageControl.numberOfPages = 0;
            [self removeGesturesFromView];
        }
    }];
}

-(void) swipeGestureRecognized:(UISwipeGestureRecognizer *) swipeGesture
{
    if (isDeleteVisible) {
        [UIView animateWithDuration:0.3f animations:^{
            UIView *cardView = [self.cardViewsArray objectAtIndex:selectedIndex];
            [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
            self.deleteButton.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 00);
            cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y+30, cardView.frame.size.width, cardView.frame.size.height);
        }];
        // remove tapGesture when delete button not visible
        [self.view addGestureRecognizer:self.readTapGesture];
        [self.view addGestureRecognizer:self.panGesture];
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
        isDeleteVisible = NO;
    }
    else
    {
        //Create delete button if its not in memory
        if (self.deleteButton == nil) {
            
            self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
            [self.deleteButton setBackgroundColor:[UIColor redColor]];
            [self.deleteButton addTarget:self action:@selector(deleteCard:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:self.deleteButton];
        [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(00, 0, 0, 0)];
        self.deleteButton.frame =  CGRectMake(00, self.view.frame.size.height, self.view.frame.size.width, 00);
        [UIView animateWithDuration:0.3f animations:^{
            UIView *cardView = [self.cardViewsArray objectAtIndex:selectedIndex];
            self.deleteButton.frame =  CGRectMake(00, self.view.frame.size.height-50, self.view.frame.size.width, 50);
            cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y-30, cardView.frame.size.width, cardView.frame.size.height);
        }];
        //Add TapGesture for view when delete button is visible
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnView:)];
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
        [self.view removeGestureRecognizer:self.readTapGesture];
        [self.view removeGestureRecognizer:self.panGesture];
        //[self.view removeGestureRecognizer:self.swipeGestureRecognizer];
        isDeleteVisible = YES;
    }
}

-(void)goToReadViewController
{
    [self performSegueWithIdentifier:@"goToReadViewController" sender:self];
    NSLog(@"go to read view controller");
}

-(void)addTapGestureRecognizerToGoReadViewController
{
    self.readTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToReadViewController)];
    [self.view addGestureRecognizer:self.readTapGesture];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)addSwipeRecognizerForDirection:(UISwipeGestureRecognizerDirection)direction
{
    // Create a swipe recognizer for the wanted direction
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
    swipeGestureRecognizer.delegate = self;
    swipeGestureRecognizer.direction = direction;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
}

-(UIColor *) backgroundColorForCardForIndex:(int) index
{
    UIColor *color;
    if (index == 0)
    {
        color = COLOR_1;
    }
    else if (index == 1)
    {
        color = COLOR_2;
    }
      return color;
}

#pragma mark Gesture Methods

-(void)loadScrollViewWithPage:(int)index
{
    if (index >= 0 && index < [self.cardsArray count]) {
        
        CardView *cardView = nil;
        if ([self.cardViewsArray objectAtIndex:index] == [NSNull null])
        {
            int colorIndex = self.cardsArray.count - index;
            UIColor *cardBackgroundColor = [self backgroundColorForCardForIndex:(colorIndex % 2)];
            cardView = [[CardView alloc] initWithTitle:[self.cardsArray objectAtIndex:index]];
            cardView.backgroundColor = cardBackgroundColor;
            if (isDeleteVisible) {
                [UIView animateWithDuration:0.3f animations:^{
                    UIView *cardView = [self.cardViewsArray objectAtIndex:selectedIndex];
                    [self.deleteButton setTitleEdgeInsets:UIEdgeInsetsMake(50, 0, 0, 0)];
                    self.deleteButton.frame =  CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 00);
                    cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y+30, cardView.frame.size.width, cardView.frame.size.height);
                }];
                [self.view addGestureRecognizer:self.readTapGesture];
                [self.view removeGestureRecognizer:self.tapGestureRecognizer];
                isDeleteVisible = NO;
            }
            [self.cardViewsArray replaceObjectAtIndex:index withObject:cardView];
        }
        else
        {
            cardView = [self.cardViewsArray objectAtIndex:index];
        }
        [self.view addSubview:cardView];
        int xFrame = 0;
        if (index == selectedIndex+1) {
            xFrame = self.view.frame.size.width;
        }
        cardView.frame = CGRectMake(xFrame, 20, self.view.frame.size.width, self.view.frame.size.height-20);
    }
}

-(void)loadScrollViewContents
{
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

-(void) addNullObjectsToCardViewsArray
{
    self.cardViewsArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.cardsArray count]; i++)
    {
        [self.cardViewsArray addObject:[NSNull null]];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end








