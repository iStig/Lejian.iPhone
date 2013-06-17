//
//  NewCardView.h
//  LeJian
//
//  Created by gongxuehan on 8/14/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/ABPeoplePickerNavigationController.h>
#import "MapViewController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <CoreLocation/CoreLocation.h>
#import "BDGuideView.h"

@protocol NewCardViewDelegate;
@interface NewCardView : UIView <ABPeoplePickerNavigationControllerDelegate, MapViewControllerDelegate,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, MKReverseGeocoderDelegate, CLLocationManagerDelegate, BDGuideViewDelegate>
{
    id <NewCardViewDelegate> _delegate;
    FuntionType     _type;
}

@property (nonatomic, assign) FuntionType type;
@property (nonatomic, assign) id<NewCardViewDelegate> delegate;

- (void)saveNewCard;
- (void)cancelNewCard;
- (void)setEditCardInfo:(NSDictionary *)card_info funtionType:(FuntionType)type;

@end

@protocol NewCardViewDelegate <NSObject>

- (void)newCardIsFinishedEdit:(NSDictionary *)card_info;
- (void)pickerViewIsShowed:(BOOL)isShow;

@end