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
    
}

-(void)createFilterCollection
{
    [_filters addObject:_destImage];
    
    [_filters addObject:[self filterVignette:_destImage]];
}


//filter methods
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

//collection view methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_filters count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIndentifier = @"filterCell";
    FilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIndentifier forIndexPath:indexPath];
    
    [[cell filterPreview]setImage:[_filters objectAtIndex:indexPath.item]];
    return cell;
}


- (IBAction)shareButton:(UIBarButtonItem *)sender {
    //come back to this
}

- (IBAction)doneButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
