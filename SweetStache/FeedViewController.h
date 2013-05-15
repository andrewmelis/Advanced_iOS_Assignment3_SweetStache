//
//  ViewController.h
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

//help from Parse Tutorial: https://www.parse.com/tutorials/saving-images


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "MBProgressHUD.h"
//#include <stdlib.h> //for randomizer

@interface FeedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray *rawImages;
@property (strong, nonatomic) NSMutableArray *displayImages;
@property (strong, nonatomic) NSMutableArray *displayTags;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) MBProgressHUD *refreshHUD;

@property (weak, nonatomic) IBOutlet UICollectionView *FeedScroll;

- (IBAction)RefreshButton:(UIBarButtonItem *)sender;
- (IBAction)CameraButton:(UIBarButtonItem *)sender;

-(void)uploadImages:(NSData *)imageData;
-(void)setUpImages:(NSArray *)images;

@end
