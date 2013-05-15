//
//  ViewController.m
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"
#import <QuartzCore/QuartzCore.h>
#import "EditViewController.h"



@interface FeedViewController ()

@end

@implementation FeedViewController
{
    EditViewController *controllerForSegue;
    UIImage *imageToSend;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _rawImages = [[NSMutableArray alloc] init];
    _displayImages = [[NSMutableArray alloc] init];
    
    //set delegate and data source
    self.FeedScroll.delegate = self;
    self.FeedScroll.dataSource = self;
    
    [self downloadAllImages];
    [self setUpImages:_rawImages];
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//implement library picker also
- (IBAction)CameraButton:(UIBarButtonItem *)sender {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]==YES) {
        //create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        //Set source to the camera
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        //delegate is self
        imagePicker.delegate = self;
        
        //show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
        //allow to pick from library as well?
    }
    else {
        //device has no camera
        //look into this later
    }
}

- (IBAction)RefreshButton:(UIBarButtonItem *)sender {
    _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_refreshHUD];
    
    //register for HUD callbacks so we can remove it from the window at the right time
    _refreshHUD.delegate = self;
    
    //show the HUD while provided method executes in new thread
    [_refreshHUD show:YES];
    
    [self downloadAllImages];
    [_FeedScroll reloadData];
}


-(void)downloadAllImages
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
//    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error) {
            //the find succeeded
            if (_refreshHUD) {
                [_refreshHUD hide:YES];
                
                //get check mark working later
            }
        
        
        NSLog(@"successfully retrieved %d photos", objects.count);
    
        _rawImages = [objects copy];
        
        [self setUpImages:_rawImages];

       
        }
        else {
            [_refreshHUD hide: YES];
        
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }

     
     
    }];
    
}

-(void)setUpImages:(NSArray *)images
{
    NSLog(@"setting up images");
    
    _displayImages = [[NSMutableArray alloc] init]; //setting up new array each time--probably not the best
                                                    //ensures no duplicates, but worse performance
    
    // This method sets up the downloaded images and places them nicely in a grid
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
//        NSMutableArray *imageDataArray = [NSMutableArray array];
        
        // Iterate over all images and get the data from the PFFile
        for (int i = 0; i < images.count; i++) {
            PFObject *eachObject = [images objectAtIndex:i];
            PFFile *theImage = [eachObject objectForKey:@"imageFile"];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            [_displayImages addObject:image];
            NSLog(@"what's inside displayimages? %@",_displayImages);
            NSLog(@"how many images in displayimages? %i",_displayImages.count);   
        }
    });
//        [[self FeedScroll] reloadData];
    
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //access the uncropped image from info dictioanry
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    //dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 640));
    [image drawInRect:CGRectMake(0, 0, 640, 640)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Upload Image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    [self uploadImages:imageData];
}

-(void)hudWasHidden:(MBProgressHUD *)hud {
    //remove HUD from screen when the HUD hides
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

//    else {
        return 1;
//    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (_displayImages != NULL) {
        return _displayImages.count;
    }
    else return 0;  //TODO check this later
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FeedCell";
    
//    if (_displayImages != NULL && _displayImages.count>0) {

    
        FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([_displayImages objectAtIndex:indexPath.item]) {
    
        [[cell cellImage]setImage:[_displayImages objectAtIndex:indexPath.item]];
    }
    if([_displayTags objectAtIndex:indexPath.item]) {
        [[cell cellLabel]setText:[_displayTags objectAtIndex:indexPath.item]];
    }
    
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.cornerRadius=10;         //make it pretty
        return cell;
//    }
//    else return NULL;
    
}

//segue methods



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"clicked on picture at index %i",indexPath.item);
    NSLog(@"what the hell kind of object is this %@",[self.displayImages objectAtIndex:indexPath.item]);
    
    UIImage *image = [_displayImages objectAtIndex:indexPath.item];
    controllerForSegue.destImage = image;

    [self performSegueWithIdentifier:@"editImage" sender:image];
    [self.FeedScroll deselectItemAtIndexPath:indexPath animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editImage"]) {
        
        controllerForSegue = segue.destinationViewController;
        
        controllerForSegue.destImage = sender;

    }
}
@end
