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

@interface FeedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) NSMutableArray *allImages;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) MBProgressHUD *refreshHUD;

@property (weak, nonatomic) IBOutlet UIScrollView *FeedScroll;

- (IBAction)RefreshButton:(UIBarButtonItem *)sender;
- (IBAction)CameraButton:(UIBarButtonItem *)sender;

-(void)uploadImages:(NSData *)imageData;
-(void)setUpImages:(NSArray *)images;
-(void)buttonTouched:(id) sender;

@end
