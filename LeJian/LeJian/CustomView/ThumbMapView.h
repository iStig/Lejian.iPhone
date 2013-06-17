//
//  ThumbMapView.h
//  LeJian
//
//  Created by gongxuehan on 9/2/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbMapView : UIView
- (id)initWithFrame:(CGRect)frame mapView:(NSString *)path topClickedMethod:(SEL)method bottomClickMethod:(SEL)method2 superView:(UIView *)superView  name:(NSString *)name tag:(SInt32)tag;

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled;
@end
