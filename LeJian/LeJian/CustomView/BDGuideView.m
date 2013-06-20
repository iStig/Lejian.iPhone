//
//  BDGuideView.m
//  qBatteryDoctor
//
//  Created by Su Peng on 23/4/12.
//  Copyright (c) 2012 Qihoo 360. All rights reserved.
//

#import "BDGuideView.h"

@interface BDGuideView ()

- (void)closeGuide:(UITapGestureRecognizer *)tapGesture;

@end

@implementation BDGuideView

@synthesize delegate = _delegate;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithGuideImageNamed:(NSString *)imageName
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:rect];
    UIImageView *guideImageView =nil;
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        if (DEVICE_HEIGHT==480) {
         guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, DEVICE_HEIGHT-20)];
        }
        else{
        
         guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, DEVICE_HEIGHT-20)];
        
        }
       
        guideImageView.image = [UIImage imageNamed:imageName];
        [guideImageView setUserInteractionEnabled:YES];
        [self addSubview:guideImageView];
        [guideImageView release];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeGuide:)];
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
    }
    return self;
}

- (void)closeGuide:(UITapGestureRecognizer *)tapGesture
{
    if (UIGestureRecognizerStateEnded == tapGesture.state) {
        if ([_delegate respondsToSelector:@selector(guideViewWillDisappear:)]) {
            [_delegate guideViewWillDisappear:self];
        }
        [UIView animateWithDuration:0.1
                              delay:0
                            options:0
                         animations:^(void) {
                             self.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    }
}

#pragma mark -- Class APIs --

+ (void)showGuideImageNamed:(NSString *)imageName withDelegate:(id<BDGuideViewDelegate>)aDelegate
{
    if (!imageName)
        return;

    BDGuideView *guideView = [[BDGuideView alloc] initWithGuideImageNamed:imageName];
    guideView.delegate = aDelegate;
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    if (window) {
        [window addSubview:guideView];
    }
    [guideView release];
}

@end
