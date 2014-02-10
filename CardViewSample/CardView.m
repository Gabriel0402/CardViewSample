//
//  CardView.m
//  Bright
//
//  Created by Mobi on 19/11/13.
//  Copyright (c) 2013 mobifusion. All rights reserved.
//

#import "CardView.h"
#define Padding 30

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
        [self addTitleLabelForCard];
    }
    return self;
}

-(void) addTitleLabelForCard
{    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, screenSize.width - (2*Padding), 60)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.title;
    [self addSubview:titleLabel];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
