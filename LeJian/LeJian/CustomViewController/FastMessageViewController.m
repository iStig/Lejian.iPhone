//
//  FastMessageViewController.m
//  LeJian
//
//  Created by gongxuehan on 8/26/12.
//  Copyright (c) 2012 smilingmobile. All rights reserved.
//

#import "FastMessageViewController.h"
#import "PublicMethod.h"

NSInteger const kFieldBaseTag = 69800;

@interface FastMessageViewController ()
{
    UIButton *_saveBtn;
    UILabel  *_timeLabel;
    UILabel  *_placeLabel;
    UIButton *_backButton;
}
@end
@implementation FastMessageViewController

- (void)dealloc
{
    [super dealloc];
    [_saveBtn release];
    [_backButton release];
    [_timeLabel release];
    [_placeLabel release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)addTextField:(NSString *)text rect:(CGRect)rect tag:(SInt32)tag
{
    UITextField *textField = [[UITextField alloc] initWithFrame:rect];
    textField.delegate = self;
    textField.tag = tag;
    textField.text = text;
    textField.textAlignment = UITextAlignmentCenter;
    textField.returnKeyType = UIReturnKeyDone;
    textField.backgroundColor = [UIColor clearColor];
    textField.font = [UIFont systemFontOfSize:16];
    textField.textColor = [UIColor blackColor];
    [self.view addSubview:textField];
}

- (void)showSampleText
{
    NSString *strTime = [[NSString alloc] initWithFormat:@"示例: %@ 15分钟 %@", [(UITextField *)[self.view viewWithTag:kFieldBaseTag] text], [(UITextField *)[self.view viewWithTag:kFieldBaseTag + 1] text]];
    
    NSString *strPlace = [[NSString alloc] initWithFormat:@"示例: %@ 人民广场 %@", [(UITextField *)[self.view viewWithTag:kFieldBaseTag + 2] text], [(UITextField *)[self.view viewWithTag:kFieldBaseTag + 3] text]];
    
    _timeLabel.text = strTime;
    _placeLabel.text = strPlace;
    
    [strTime release];
    [strPlace release];
}

- (void)saveMessage
{
    [[PublicMethod sharedMethod] saveValue:[(UITextField *)[self.view viewWithTag:kFieldBaseTag] text] forKey:kTimeBeforeKey];
    [[PublicMethod sharedMethod] saveValue:[(UITextField *)[self.view viewWithTag:kFieldBaseTag  + 1] text] forKey:kTimeAfterKey];
    
    [[PublicMethod sharedMethod] saveValue:[(UITextField *)[self.view viewWithTag:kFieldBaseTag + 2] text] forKey:kPlaceBeforeKey];
    [[PublicMethod sharedMethod] saveValue:[(UITextField *)[self.view viewWithTag:kFieldBaseTag + 3] text] forKey:kPlaceAfterKey];
}   

- (void)backButtonClicked
{
    [self saveMessage];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav popViewControllerAnimated:YES];
}   

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *vImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    vImg.image = [UIImage imageNamed:@"msg_st01.png"];
    [self.view addSubview:vImg];
    [vImg release];
    
    [self addTextField:[[PublicMethod sharedMethod] getValueForKey:kTimeBeforeKey] rect:CGRectMake(32, 59, 112, 20) tag:kFieldBaseTag];
    [self addTextField:[[PublicMethod sharedMethod] getValueForKey:kTimeAfterKey] rect:CGRectMake(178, 59, 110, 20) tag:kFieldBaseTag + 1];
    
    [self addTextField:[[PublicMethod sharedMethod] getValueForKey:kPlaceBeforeKey] rect:CGRectMake(32, 251, 112, 20) tag:kFieldBaseTag + 2];
    [self addTextField:[[PublicMethod sharedMethod] getValueForKey:kPlaceAfterKey] rect:CGRectMake(178, 251, 112, 20) tag:kFieldBaseTag + 3];
    
    _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _saveBtn.backgroundColor = [UIColor greenColor];
    [_saveBtn addTarget:self action:@selector(saveMessage) forControlEvents:UIControlEventTouchUpInside];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 87, 280, 20)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.shadowOffset = CGSizeMake(1, 1);
    _timeLabel.shadowColor = [UIColor whiteColor];
    [self.view addSubview:_timeLabel];
    
    _placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 280, 280, 20)];
    _placeLabel.backgroundColor = [UIColor clearColor];
    _placeLabel.font = [UIFont systemFontOfSize:12];
    _placeLabel.shadowOffset = CGSizeMake(1, 1);
    _placeLabel.shadowColor = [UIColor whiteColor];
    [self.view addSubview:_placeLabel];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 1.0, 41.0, 41.0)];
    UIImage *settingImageNormal = [UIImage imageNamed:@"back_01.png"];
    [_backButton setImage:settingImageNormal forState:UIControlStateNormal];
    UIImage *settingImageHighlight = [UIImage imageNamed:@"back_02.png"];
    [_backButton setImage:settingImageHighlight forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    [self showSampleText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NavigationController *nav = (NavigationController *)self.navigationController;
    [nav setLeftButton:_backButton animated:NO];
    nav.leftButton.hidden = NO;
    [nav setTitleLogoHiden:YES];
    [nav setTitle:@"编辑短信"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self showSampleText];
    return YES;
}

@end
