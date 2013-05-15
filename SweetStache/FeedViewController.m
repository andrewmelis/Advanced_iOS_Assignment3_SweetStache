//
//  ViewController.m
//  SweetStache
//
//  Created by Andrew Melis on 5/15/13.
//  Copyright (c) 2013 Baller Status Inc. All rights reserved.
//

#import "FeedViewController.h"



@interface FeedViewController ()

@end

@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)RefreshButton:(UIBarButtonItem *)sender {
    _refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_refreshHUD];
    
    //register for HUD callbacks so we can remove it from the window at the right time
    _refreshHUD.delegate = self;
    
    //show the HUD while provided method executes in new thread
    [_refreshHUD show:YES];
}

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
    }
    else {
        //device has no camera
        //look into this later
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
@end
