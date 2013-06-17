//
//  LogViewController.h
//  LeJian
//
//  Created by gongxuehan on 8/20/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KalView.h"
#import "KalDataSource.h"
#import "KalLogic.h"
#import "KalDate.h"
#import "LeJianDatabase.h"
#import "NavigationController.h"

@protocol LogViewControllerDelegate;
@interface LogViewController : UIViewController <KalViewDelegate, KalDataSourceCallbacks, UITableViewDelegate, UITableViewDataSource>
{
    KalLogic *logic;
    id <KalDataSource> dataSource;
    KalDate *selectedDate;
    KalView *_kalView;
    id<LogViewControllerDelegate> _delegate;
}

@property (nonatomic ,assign) id<LogViewControllerDelegate> delegate;
- (id)initWithDataSource:(id<KalDataSource>)source;

@end

@protocol LogViewControllerDelegate <NSObject>

- (void)oneCardIsBeenSelected:(NSDictionary *)card_info;

@end