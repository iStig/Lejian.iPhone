//
//  BDGuideView.h
//  qBatteryDoctor
//
//  Created by Su Peng on 23/4/12.
//  Copyright (c) 2012 Qihoo 360. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BDGuideViewDelegate;

@interface BDGuideView : UIView

@property (nonatomic, assign) id<BDGuideViewDelegate>   delegate;

+ (void)showGuideImageNamed:(NSString *)imageName withDelegate:(id<BDGuideViewDelegate>)aDelegate;

@end


@protocol BDGuideViewDelegate<NSObject>

@optional
- (void)guideViewWillDisappear:(BDGuideView *)guideView;

@end

