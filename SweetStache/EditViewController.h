//
//  EditViewController.h
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import <Parse/Parse.h>

@interface EditViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) UIImage *destImage;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollection;

@property (strong, nonatomic) NSMutableArray *filters;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) MBProgressHUD *refreshHUD;

- (IBAction)shareButton:(UIBarButtonItem *)sender;

- (IBAction)doneButton:(UIBarButtonItem *)sender;

@end
