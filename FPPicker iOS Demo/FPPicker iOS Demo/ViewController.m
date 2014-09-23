//
//  ViewController.m
//  FPPicker iOS Demo
//
//  Created by Ruben Nine on 13/06/14.
//  Copyright (c) 2014 Ruben Nine. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()

@property (nonatomic, retain) FPSaveController *fpSave;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    else
    {
        return YES;
    }
}

- (IBAction)pickerAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];
    //fpController.dataTypes = @[@"image/*", @"video/quicktime"];

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 5;

    /*
     * Display it.
     */
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:fpController];

    self.myPopoverController = popoverController;
    self.myPopoverController.popoverContentSize = CGSizeMake(320, 520);

    [self.myPopoverController presentPopoverFromRect:[sender frame]
                                              inView:self.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
}

- (IBAction)pickerModalAction:(id)sender
{
    /*
     * Create the object
     */
    FPPickerController *fpController = [FPPickerController new];

    /*
     * Set the delegate
     */
    fpController.fpdelegate = self;

    /*
     * Ask for specific data types. (Optional) Default is all files.
     */
    fpController.dataTypes = @[@"image/*"];
    //fpController.dataTypes = [NSArray arrayWithObjects:@"image/*", @"video/quicktime", nil];

    fpController.shouldUpload = YES;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //fpController.sourceNames = [[NSArray alloc] initWithObjects: FPSourceImagesearch, nil];

    /*
     * Enable multselect (Optional) Default is single select
     */
    fpController.selectMultiple = YES;

    /*
     * Specify the maximum number of files (Optional) Default is 0, no limit
     */
    fpController.maxFiles = 10;

    /*
     * Display it.
     */
    [self presentViewController:fpController
                       animated:YES
                     completion:nil];
}

- (IBAction)savingAction:(id)sender
{
    UIImage *firstImage;

    if (!self.imageView.image &&
        !self.imageView.animationImages)
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Nothing to Save"
                                                          message:@"Select an image first."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];

        [message show];

        return;
    }

    if (self.imageView.image)
    {
        firstImage = self.imageView.image;
    }
    else if (self.imageView.animationImages)
    {
        // For the purposes of our demo, we will simply use the first image

        firstImage = self.imageView.animationImages[0];
    }

    NSData *imgData = UIImagePNGRepresentation(firstImage);

    /*
     * Create the object
     */
    self.fpSave = [FPSaveController new];

    /*
     * Set the delegate
     */
    self.fpSave.fpdelegate = self;

    /*
     * Select and order the sources (Optional) Default is all sources
     */
    //self.fpSave.sourceNames = @[FPSourceDropbox, FPSourceFacebook, FPSourceBox];

    /*
     * Set the data and data type to be saved.
     */
    self.fpSave.data = imgData;
    self.fpSave.dataType = @"image/png";

    /*
     * Display it.
     */
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:self.fpSave];

        self.myPopoverController = popoverController;
        self.myPopoverController.popoverContentSize = CGSizeMake(320, 520);

        [self.myPopoverController presentPopoverFromRect:[sender frame]
                                                  inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
    }
    else
    {
        [self presentViewController:self.fpSave
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - FPPickerControllerDelegate Methods

- (void)FPPickerController:(FPPickerController *)picker didPickMediaWithInfo:(NSDictionary *)info
{
}

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"FILE CHOSEN: %@", info);

    if (info[@"FPPickerControllerOriginalImage"])
    {
        self.imageView.image = info[@"FPPickerControllerOriginalImage"];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)FPPickerController:(FPPickerController *)picker didFinishPickingMultipleMediaWithResults:(NSArray *)results
{
    NSLog(@"FILES CHOSEN: %@", results);

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];

    // Making a little carousel effect with the images

    NSMutableArray *images = [NSMutableArray arrayWithCapacity:results.count];

    for (NSDictionary *data in results)
    {
        // Check if uploaded file is an image to add it to carousel

        if (data[@"FPPickerControllerOriginalImage"])
        {
            [images addObject:data[@"FPPickerControllerOriginalImage"]];
        }
    }

    self.imageView.animationImages = images;
    self.imageView.animationRepeatCount = 100.f;
    self.imageView.animationDuration = 2.f * images.count; // 2 seconds per image
    [self.imageView startAnimating];
}

- (void)FPPickerControllerDidCancel:(FPPickerController *)picker
{
    NSLog(@"FP Cancelled Open");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - FPSaveControllerDelegate Methods

- (void)FPSaveControllerDidSave:(FPSaveController *)picker
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self.fpSave dismissViewControllerAnimated:YES
                                        completion:nil];
    }
}

- (void)FPSaveController:(FPSaveController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"FILE SAVED: %@", info);
}

- (void)FPSaveControllerDidCancel:(FPSaveController *)picker
{
    NSLog(@"FP Cancelled Save");

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.myPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self.fpSave dismissViewControllerAnimated:YES
                                        completion:nil];
    }
}

- (void)FPSaveController:(FPSaveController *)picker didError:(NSDictionary *)info
{
    NSLog(@"FP Error");
}

@end
