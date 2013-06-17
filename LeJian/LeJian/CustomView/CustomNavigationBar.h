//
//  CustomNavigationBar.h
//  SystemExpert
//
//  Created by Ray Zhang  on 11-8-9.
//  Copyright 2011 QIHOO. All rights reserved.
//

#import <UIKit/UIKit.h>

//@interface UINavigationBar (CustomStyle)
//
//- (void)applyDefaultStyle;
//
//@end


@interface CustomNavigationBar : UIImageView 

@property(nonatomic, readwrite) BOOL                    showBackButtonItem;
@property(nonatomic, assign) UINavigationController     *navigationController;

- (void)setShowBackButtonItemAnimated:(BOOL)animated;
- (void)setHideBackButtonItemAnimated:(BOOL)animated;

- (void)setTitle:(NSString *)title;
- (void)setTitleLogoHiden:(BOOL)hide;
//- (void)setTitleImageNamed:(NSString *)name;

@end
