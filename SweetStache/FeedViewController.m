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
    _rawImages = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}


-(void)downloadAllImages
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"user" equalTo:user];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error) {
            //the find succeeded
            if (_refreshHUD) {
                [_refreshHUD hide:YES];
                
                //get check mark working later
            }
        
        
        NSLog(@"successfully retrieved %d photos", objects.count);
        
        
        //if there are photos, we start extracting the data
        //save a list of object IDs while extracting this data
        
//        NSMutableArray *newObjectIDArray = [NSMutableArray array];
//        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//        
//        if (objects.count >0) {
//            for (PFObject *eachObject in objects) {
//                [newObjectIDArray addObject:[eachObject objectId]];
//            }
//        }
//
//        //compare the old and new object IDs
//        NSMutableArray *newCompareObjectIDArray = [NSMutableArray arrayWithArray:newObjectIDArray];
//        NSMutableArray *newCompareObjectIDArray2 = [NSMutableArray arrayWithArray:newObjectIDArray];
//        NSMutableArray *oldCompareObjectIDArray = [NSMutableArray arrayWithArray:[standardUserDefaults objectForKey:@"objectIDArray"]];
//        
//        if([standardUserDefaults objectForKey:@"objectIDArray"]) {
//            [newCompareObjectIDArray removeObjectsInArray:oldCompareObjectIDArray]; //new objects
//            
//            //remove old objects if you delete them using the web browser
//            [oldCompareObjectIDArray removeObjectsInArray:newCompareObjectIDArray2];
//            if (oldCompareObjectIDArray.count >0) {
//                //check the position in the objectIDArray and remove
//                NSMutableArray *listOfToRemove = [[NSMutableArray alloc] init];
//                for (NSString *objectID in oldCompareObjectIDArray) {
//                    int i = 0;
//                    for(NSString *oldObjectID in [standardUserDefaults objectForKey:@"objectIDArray"]){
//                        if([objectID isEqualToString:oldObjectID]) {
//                            //remove it
//                            for(UIView *view in [_FeedScroll subviews]) {
//                                if([view isKindOfClass:[UIButton class]]) {
//                                    if (view.tag == i) {
//                                        [view removeFromSuperview];
//                                        NSLog(@"removing pic at position %i", i);
//                                    }
//                                }
//                            }
//                            
//                            //make list of all that you want to remove and remove at the end
//                            [listOfToRemove addObject:[NSNumber numberWithInt:i]];
//                        }
//                        i++;
//                    }
//                }
//                
//                //remove from the back
//                NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
//                [listOfToRemove sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
//                
//                for (NSNumber *index in listOfToRemove) {
//                    [_allImages removeObjectAtIndex:[index intValue]];
////                    [self setUpImages:_allImages];
//                }
//                
//                //this method sets up the downloaded images and places them in a grid
//                //here?
//            }
//            
//        }
//        
        //add new objects
//        for (NSString *objectID in newCompareObjectIDArray){
//        for (NSString *objectID in newObjectIDArray){
//            for (PFObject *eachObject in objects){
//                if ([[eachObject objectId] isEqualToString:objectID]) {
//                    NSMutableArray *selectedPhotoArray = [[NSMutableArray alloc] init];
//                    [selectedPhotoArray addObject:eachObject];
//                    
//                    if (selectedPhotoArray.count > 0) {
//                        [_allImages addObjectsFromArray:selectedPhotoArray];
//                    }
//                }
//            }
//        }

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
