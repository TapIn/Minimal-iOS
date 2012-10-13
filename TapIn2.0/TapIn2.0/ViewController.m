//
//  ViewController.m
//  TapIn2.0
//
//  Created by Vu Tran on 10/12/12.
//  Copyright (c) 2012 Vu Tran. All rights reserved.
//

#import "ViewController.h"
#import "ASIS3Request.h"
#import "ASIS3ObjectRequest.h"
#import "Utilities.h"


@interface ViewController ()
{
    UIImagePickerController *imagePicker;
}

@end

@implementation ViewController
@synthesize imageView, toolbar;

- (void)viewDidLoad
{
       [super viewDidLoad];
    [self performSelector:@selector(useCamera:) withObject:nil afterDelay:0];

}


- (IBAction) useCamera: (id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeMovie,
                                  nil];
        imagePicker.allowsEditing = YES;
        [self presentModalViewController:imagePicker
                                animated:NO];
        UILabel * test = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 500, 50)];
        test.text = @"FOIWEJFOIWJF WJFWFJWLEFJ W";
        test.textColor = [UIColor whiteColor];
//        [imagePicker.view addSubview:test];
        [[imagePicker.toolbarItems objectAtIndex:0] setTitle:@"dicks"];
        newMedia = YES;
    }
}

- (IBAction) useCameraRoll: (id)sender
{
           if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            UIImagePickerController *imagePicker =
            [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeMovie,
                                      nil];
            imagePicker.allowsEditing = NO;
            [self presentModalViewController:imagePicker
                                    animated:YES];

            newMedia = NO;
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSLog(@"got here");
        // To create the object
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSData * data  = [NSData dataWithContentsOfURL:videoURL];
        [ASIS3Request setSharedSecretAccessKey:@"ajQqlwKdktd4HtbgAQbvLJSD32FzZ+Q1n270BfGX"];
        [ASIS3Request setSharedAccessKey:@"AKIAJDBX254H3PJLPGDQ"];
        
        ASIS3ObjectRequest * request = [ASIS3ObjectRequest PUTRequestForData:data withBucket:@"content.duck.tapin.tv" key:[NSString stringWithFormat:@"%i:%@.mp4", [Utilities timestamp], [Utilities phoneID]]];
        [request setDownloadProgressDelegate:progress];
        NSLog(@"Value: %f",[progress progress]);
        [imagePicker.view addSubview:progress];
        UILabel * test = [[UILabel alloc]initWithFrame:CGRectMake(50, 300, 500, 50)];
        test.text = @"FOIWEJFOIWJF WJFWFJWLEFJ W";
        test.textColor = [UIColor whiteColor];
        [imagePicker.view addSubview:test];

        [request setShowAccurateProgress:YES];
        [request startSynchronous];
        
        if ([request error]) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"There was an error" message:@"Coudln't upload it. Tap the upload button, pick your video to try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            NSLog(@"%@",[[request error] localizedDescription]);
            [alert show];
        }
        
        //get the videoURL
        NSString *tempFilePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        if ( UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath))
        {
            // Copy it to the camera roll.
            UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, nil, (__bridge void *)(tempFilePath));
        }
        
//        UIImage *image = [info
//                          objectForKey:UIImagePickerControllerOriginalImage];
//
//        imageView.image = image;
//        if (newMedia)
//            UIImageWriteToSavedPhotosAlbum(image,
//                                           self,
//                                           @selector(image:finishedSavingWithError:contextInfo:),
//                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}
-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"\
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
