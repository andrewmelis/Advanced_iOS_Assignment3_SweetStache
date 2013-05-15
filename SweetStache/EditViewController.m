//
//  EditViewController.m
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

#import "EditViewController.h"
#import "FilterCell.h"
#import <CoreImage/CoreImage.h>


@interface EditViewController ()

@end

@implementation EditViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"in edit view controller %@",_destImage);
    [_mainImageView initWithImage:_destImage];
    
    _filters = [[NSMutableArray alloc] init];
    
    _filterCollection.delegate = self;
    _filterCollection.dataSource = self;
    
//    _filterCollection.dataSource = self;
//    _filterCollection.delegate = self;
    
    [self createFilterCollection ];
    
}

-(void)createFilterCollection
{
    [_filters addObject:_destImage];
    
    [_filters addObject:[self filterSepia:_destImage]];
//    [_filters addObject:[self filterVignette:_destImage]];
//    [_filters addObject:[self filterVibrance:_destImage]];
//    [_filters addObject:[self filterGloom:_destImage]];
//    [_filters addObject:[self filterZoomBlur:_destImage]];
    
    [_filterCollection reloadData];
}

//kCIInputImageKey, 

//filter methods

-(UIImage*) filterSepia:(UIImage *) originalUI {
    CIImage *originalCI = [CIImage imageWithCGImage:originalUI.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepia"
                                  keysAndValues:kCIInputImageKey, originalCI, @"inputIntensity", 0.8, nil];
    CIImage *outputCI = [filter outputImage];
    
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgimg = [context createCGImage:outputCI fromRect:[outputCI extent]];
//    UIImage *outputUI = [UIImage imageWithCGImage:cgimg];
    
    UIImage *outputUI = [UIImage imageWithCIImage:outputCI];
//    CGImageRelease(cgimg);
    
    return outputUI;
}


-(UIImage*) filterVignette:(UIImage *) originalUI {
    CIImage *originalCI = [CIImage imageWithCGImage:originalUI.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIVignette"
                        keysAndValues:kCIInputImageKey, originalCI, @"inputIntensity", 0.8, nil];
    CIImage *outputCI = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputCI fromRect:[outputCI extent]];
    UIImage *outputUI = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return outputUI;
}

-(UIImage*) filterGloom:(UIImage *) originalUI {
    CIImage *originalCI = [CIImage imageWithCGImage:originalUI.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGloom"
                                  keysAndValues:kCIInputImageKey, originalCI, @"inputIntensity", 0.8, nil];
    CIImage *outputCI = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputCI fromRect:[outputCI extent]];
    UIImage *outputUI = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return outputUI;
}

-(UIImage*) filterVibrance:(UIImage *) originalUI {
    CIImage *originalCI = [CIImage imageWithCGImage:originalUI.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIVibrance"
                                  keysAndValues:kCIInputImageKey, originalCI, @"inputAmount", 0.8, nil];
    CIImage *outputCI = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputCI fromRect:[outputCI extent]];
    UIImage *outputUI = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return outputUI;
}

-(UIImage*) filterZoomBlur:(UIImage *) originalUI {
    CIImage *originalCI = [CIImage imageWithCGImage:originalUI.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIZoomBlur"
                                  keysAndValues:kCIInputImageKey, originalCI, nil];
    CIImage *outputCI = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputCI fromRect:[outputCI extent]];
    UIImage *outputUI = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);
    
    return outputUI;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"clicked on filter number %i",indexPath.item);
    
    UIImage *temp = _mainImageView.image;
    if (indexPath.item==0) {
        [_mainImageView setImage:_destImage];
    }
    else if (indexPath.item==1) {
        [_mainImageView setImage:[self filterSepia:temp ]];
    }
}



//collection view methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_filters count];
//    return 2;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIndentifier = @"FilterCell";
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    
    [[cell filterPreview]setImage:[_filters objectAtIndex:indexPath.item]];
    return cell;
}

- (IBAction)doneButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)shareButton:(UIBarButtonItem *)sender {
    NSData *data = UIImageJPEGRepresentation(_mainImageView.image, 1.0);
    if(data != NULL) {
        [self uploadImages: data];
    }

}




-(void)uploadImages:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    //HUD creation here
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    
    //set determinate mode
    _HUD.mode = MBProgressHUDModeDeterminate;
    _HUD.delegate = self;
    _HUD.labelText = @"Uploading";
    [_HUD show:YES];
    
    //Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
            
            
            
            
            //Hide old HUD, show completed HUD
            [_HUD hide:YES];
            
            
            //fix this later
            //show checkmark
            //            _HUD = [[MBProgressHUD alloc] initWithView:self.view];
            //            [self.view addSubview:_HUD];
            
            
            
            
            //create a PFObject around a PFFile and associate it with current user
            PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            //set the access control list to current user for security reasons
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error) {
                    //log details of failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else {
            [_HUD hide:YES];
            //log details of failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        //update progress spinner
        _HUD.progress = (float)percentDone/100;
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
