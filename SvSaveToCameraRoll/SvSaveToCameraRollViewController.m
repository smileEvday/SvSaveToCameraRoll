//
//  SvSaveToCameraRollViewController.m
//  SvSaveToCameraRoll
//
//  Created by mapleCao on 13-4-15.
//  Copyright (c) 2013年 smileEvday. All rights reserved.
//

#import "SvSaveToCameraRollViewController.h"

#define PROGRESS_VIEW_WIDTH     250
#define PROGRESS_VIEW_HEIGHT    40

#define TIPS_LBL_WIDHT          200
#define TIPS_LBL_HEIGHT         70
#define TIPS_LBL_TOP_MARGIN     20

@interface SvSaveToCameraRollViewController () {
    UIButton            *_btn;
    UIProgressView      *_progressView;
    UILabel             *_tipsLbl;
    
    NSInteger           _mediaItemCount;
    NSInteger           _failItemCount;
}

@end

@implementation SvSaveToCameraRollViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0xDA / 255.0 green:0xDA / 255.0 blue:0xDA / 255.0 alpha:1];
    
    _btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _btn.frame = CGRectMake(0, 0, 210, 50);
    _btn.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - 50);
    _btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_btn setTitle:@"Start Copy to Camera roll" forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(copyToSys) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = CGRectMake(self.view.bounds.size.width / 2 - PROGRESS_VIEW_WIDTH / 2,
                                     self.view.bounds.size.height / 2 - PROGRESS_VIEW_HEIGHT / 2 - 50,
                                     PROGRESS_VIEW_WIDTH,
                                     PROGRESS_VIEW_HEIGHT);
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _progressView.trackTintColor = [UIColor grayColor];
    _progressView.progressTintColor = [UIColor whiteColor];
    [self.view addSubview:_progressView];
    [_progressView release];
    
    _tipsLbl = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2 - TIPS_LBL_WIDHT / 2,
                                                        _progressView.frame.origin.y + _progressView.frame.size.height + TIPS_LBL_TOP_MARGIN,
                                                        TIPS_LBL_WIDHT,
                                                        TIPS_LBL_HEIGHT)];
    _tipsLbl.font = [UIFont boldSystemFontOfSize:19];
    _tipsLbl.numberOfLines = 2;
    _tipsLbl.backgroundColor = [UIColor clearColor];
    _tipsLbl.textAlignment = NSTextAlignmentCenter;
    _tipsLbl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _tipsLbl.text = @"Tap the button to start copy";
    [self.view addSubview:_tipsLbl];
    [_tipsLbl release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)copyToSys
{
    // disabled copy btn until the copy action finished
    _btn.enabled = NO;
    
    SvSaveToUtils *util = [[[SvSaveToUtils alloc] init] autorelease];
    util.delegate = self;
    [util saveMediaToCameraRoll];
}


#pragma mark -
#pragma mark SvSaveToDelegate

- (void)saveToUtilStartCopy:(NSInteger)itemCount
{
    _mediaItemCount = itemCount;
    _failItemCount  = 0;
    _tipsLbl.text   = [NSString stringWithFormat:@"Copying %d / %d", 0, itemCount];
}

- (void)mediaItemCopiedIsSuccess:(BOOL)success
{
    static int index = 0;
    index += 1;         // caculate copied item count
    NSLog(@"progress %f", (CGFloat)index / _mediaItemCount);
    [_progressView setProgress:((CGFloat)index / _mediaItemCount) animated:YES];
    
    _tipsLbl.text = [NSString stringWithFormat:@"Copying %d / %d", index, _mediaItemCount];
    
    if (!success) {
        _failItemCount++;
    }
}

- (void)savetoUtilCopyFinished
{
    [_progressView setProgress:1 animated:YES];
    _tipsLbl.text = [NSString stringWithFormat:@"%@\r success: %d, failed: %d", @"Copy finished", _mediaItemCount - _failItemCount, _failItemCount];
    
    _btn.enabled = YES;
}

@end
