//
//  EditViewController.h
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (strong, nonatomic) UIImage *mainImage;
@property (weak, nonatomic) IBOutlet UICollectionView *filterCollection;

- (IBAction)shareButton:(UIBarButtonItem *)sender;

- (IBAction)doneButton:(UIBarButtonItem *)sender;

@end
