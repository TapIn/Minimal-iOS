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
#import "Mixpanel.h"
#import "ASIHTTPRequest.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    UIImagePickerController *imagePicker;
    NSString * videoFilename;
}

@end

@implementation ViewController
@synthesize imageView, toolbar;

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self performSelector:@selector(useCamera:) withObject:nil afterDelay:0];

}


- (IBAction) useCamera: (id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Use Camera"];
    
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Use Camera Roll"];
           if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum])
        {
            imagePicker =
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
//        
//        
//        AVURLAsset * footageVideo = [AVURLAsset URLAssetWithURL:videoURL options:nil];
//        AVAssetTrack * footageVideoTrack = [footageVideo compatibleTrackForCompositionTrack:videoTrack];
//        
//        CGAffineTransform t = footageVideoTrack.preferredTransform;
        
        
        [ASIS3Request setSharedSecretAccessKey:@"ajQqlwKdktd4HtbgAQbvLJSD32FzZ+Q1n270BfGX"];
        [ASIS3Request setSharedAccessKey:@"AKIAJDBX254H3PJLPGDQ"];
        videoFilename = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i-%@.mp4", [Utilities timestamp], [Utilities phoneID]]];
        ASIS3ObjectRequest * request = [ASIS3ObjectRequest PUTRequestForData:data withBucket:@"content.duck.tapin.tv" key:videoFilename];
        [request setDownloadProgressDelegate:progress];
        [request setDelegate:self];
        [request setAccessPolicy:@"public-read"];
        NSLog(@"Value: %f",[progress progress]);
//        [imagePicker.view addSubview:progress];
        UILabel * test = [[UILabel alloc]initWithFrame:CGRectMake(50, 300, 500, 50)];
        test.text = @"FOIWEJFOIWJF WJFWFJWLEFJ W";
        test.textColor = [UIColor whiteColor];
        [imagePicker.view addSubview:test];
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Don't be alarmed!" message:@"Your videos are automatically being uploaded. See the progress bar." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
        
        [request setShowAccurateProgress:YES];
        [request startAsynchronous];
        
        if ([request error]) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"There was an error" message:@"Coudln't upload it. Tap the upload button, pick your video to try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            NSLog(@"%@",[[request error] localizedDescription]);
            [alert show];
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            [mixpanel track:@"Upload Video Error"];
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

+ (UIInterfaceOrientation)orientationForTrack:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIInterfaceOrientationPortrait;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Don't be alarmed!" message:@"Your video has been uploaded successfully!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
    // Use when fetching binary data
    NSData *responseData = [request responseData];
    NSLog(@"This is the response: %@", responseString);
    NSLog(@"%@", [[request url] absoluteString]);
    //Check the URL of the request before sending to prevent loop
    NSString * requestString = [[request url] absoluteString];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Upload Video"];
    
//    if ([requestString rangeOfString:@"http://content.duck.tapin.tv.s3.amazonaws.com"].location != NSNotFound)
//    {
//        //Send push
//        NSString * urlString = [NSString stringWithFormat:@"http://duck.tapin.tv/sendpush.php?from=%@&video=%@", [Utilities phoneID], videoFilename];
//        NSURL *url = [NSURL URLWithString: urlString];
//        NSLog(@"This is the URLSTring: %@", urlString);
//        ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
//        [_request startSynchronous];
//        NSError *error = [_request error];
//        if (!error) {
//            NSString *response = [_request responseString];
//            NSLog(@"%@", response);
//        }
//    }
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
//    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
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
