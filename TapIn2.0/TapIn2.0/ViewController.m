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
#import <AudioToolbox/AudioToolbox.h>
#import "VideoViewController.h"
#import "Reachability.h"

// Private vars
@interface ViewController ()
{
    UIImagePickerController *imagePicker;
    NSString * videoFilename;
    NSString * pathToMovie;
    BOOL recording;
    NSTimer * recordTimer;
    int bytesPerSecond;
    int filesize;
    NSTimer * progressTimer;
    NSString * tempFilePath;
    Utilities * util;
}
-(void) uploadVideo:(NSURL*) url;
-(void) recording;
-(void) updateProgressBar;
-(void) sendPushNotification;
@end

@implementation ViewController
@synthesize imageView, toolbar;

#pragma mark - view delegates

- (void)viewDidLoad
{
    [super viewDidLoad];
    util = [Utilities sharedInstance];
    double delayToStartRecording = 0;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        
        [self useCamera:nil];
    });
    
    //Set S3 creds
    [ASIS3Request setSharedSecretAccessKey:@"ajQqlwKdktd4HtbgAQbvLJSD32FzZ+Q1n270BfGX"];
    [ASIS3Request setSharedAccessKey:@"AKIAJDBX254H3PJLPGDQ"];    
    
//    This controls the AVAsset writer
//
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
//    videoCamera.horizontallyMirrorRearFacingCamera = NO;
//    
//    filter = [[GPUImageBrightnessFilter alloc] init];
//    [videoCamera addTarget:filter];
//    GPUImageView *filterView = gpuImageView;
//    [filter addTarget:filterView];
//    
//    pathToMovie = [[NSString alloc]initWithString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"]];
//    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
//    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//    
//    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//    [filter addTarget:movieWriter];
//    [(GPUImageBrightnessFilter *)filter setBrightness:0];
//
//    [videoCamera startCameraCapture];
//    videoCamera.audioEncodingTarget = movieWriter;
}

-(void)viewDidAppear:(BOOL)animated
{
    // Whenever thew view appears, check what network connection the user is on
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
        bytesPerSecond = 0;
    else if (status == ReachableViaWiFi)
        bytesPerSecond = 507152;
    else if (status == ReachableViaWWAN)
        bytesPerSecond = 112000;
}

#pragma mark - camera functions

- (IBAction)toggleRecord:(id)sender{
    [self useCamera:nil];

//    This controls the AVAsset writer
//
//    if(recording)
//    {
//        double delayToStartRecording = 0;
//        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
//        dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
//            [filter removeTarget:movieWriter];
//            videoCamera.audioEncodingTarget = nil;
//            [movieWriter finishRecording];
//            NSLog(@"Movie completed: path to movie %@", pathToMovie);
//            UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie, nil, NULL, NULL);
//            recording = NO;
//            NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
//            movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
//            videoCamera.audioEncodingTarget = movieWriter;
//            //        [self uploadVideo:movieURL];
//            Mixpanel *mixpanel = [Mixpanel sharedInstance];
//            [mixpanel track:@"Stop Record"];
//            [recordTimer invalidate];
//            recordTimer = nil;
//            
//            [recordButton setBackgroundColor:[UIColor whiteColor]];
//        });
//    }
//    else {
//        double delayToStartRecording = 0;
//        dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
//        dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
//            NSLog(@"the fuck 2");
//            [movieWriter startRecording];
//            Mixpanel *mixpanel = [Mixpanel sharedInstance];
//            [mixpanel track:@"Start Record"];
//            recording = YES;
//            
//            //start record timer
//            recordTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(recording) userInfo:nil repeats:YES];
//            //
//        });
//    }
}

// Open the camera taking screen
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
        newMedia = YES;
    }
}

// Open the existing video library
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

#pragma mark- picker and upload methods

// Fires once a user picks or records a video
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info
                           objectForKey:UIImagePickerControllerMediaType];
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        // To create the object
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        [self uploadVideo:videoURL];
        
        tempFilePath = [[NSString alloc]initWithString:[[info objectForKey:UIImagePickerControllerMediaURL] path]];
    
        //Only save if it was taken from the camera
        if(newMedia) UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, nil, (__bridge void *)(tempFilePath));
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

//Upload a video to S3
-(void) uploadVideo:(NSURL*) videoURL{
    
    // To create the object
    NSData * data  = [NSData dataWithContentsOfURL:videoURL];
    //
    //
    //        AVURLAsset * footageVideo = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    //        AVAssetTrack * footageVideoTrack = [footageVideo compatibleTrackForCompositionTrack:videoTrack];
    //
    //        CGAffineTransform t = footageVideoTrack.preferredTransform;
    
    videoFilename = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i-%@.mp4", [Utilities timestamp], [Utilities phoneID]]];
    ASIS3ObjectRequest * request = [ASIS3ObjectRequest PUTRequestForData:data withBucket:@"content.duck.tapin.tv" key:videoFilename];
    
    [request setDownloadProgressDelegate:progress];
    [request setDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setAccessPolicy:@"public-read"];
    
    NSLog(@"Value: %f",[progress progress]);
    NSLog(@"this is the size of the upload: %u", [data length]);
    
    filesize = [data length];
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Don't be alarmed!" message:@"Your videos are automatically being uploaded. See the progress bar." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
    [request startAsynchronous];
    [request setShowAccurateProgress:YES];
    
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(updateProgressBar)
                                                   userInfo:nil
                                                    repeats:YES];
    
    if ([request error]) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"There was an error" message:@"Coudln't upload it. Tap the upload button, pick your video to try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        NSLog(@"%@",[[request error] localizedDescription]);
        [alert show];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Upload Video Error"];
    }
}

//Gets called by a timer to indicate upload progress
-(void) updateProgressBar {
    NSLog(@"Upload speed %f",  (float)bytesPerSecond / (float)filesize);
    NSLog(@"Current progress %f",  progress.progress);
    
    //Stop updating if progress is more than 100%
    if(progress.progress + ((float)bytesPerSecond / (float)filesize)>1.0)
    {
        [progressTimer invalidate];
        progressTimer = nil;
    }
    else{
        progress.progress = progress.progress + ((float)bytesPerSecond  / (float)filesize);
    }
}

-(void) sendPushNotification {
    NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Utilities phoneID], @"phone_id", videoFilename, @"file", nil];
    [util sendGet:@"phone/upload" params:params delegate:self];
}

#pragma mark - ASIHTTP Delegates

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
    
    if ([requestString rangeOfString:@"http://content.duck.tapin.tv.s3.amazonaws.com"].location != NSNotFound)
    {
        [self sendPushNotification];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"This is the error yo %@", error);
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"There was an error" message:@"Couldn't upload it. Tap the upload button, pick your video to try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    NSLog(@"%@",[[request error] localizedDescription]);
    [alert show];
    [progressTimer invalidate];
    progressTimer = nil;
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

#pragma mark - house keeping

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // Map UIDeviceOrientation to UIInterfaceOrientation.
    UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationLandscapeLeft:
            orient = UIInterfaceOrientationLandscapeLeft;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orient = UIInterfaceOrientationLandscapeRight;
            break;
            
        case UIDeviceOrientationPortrait:
            orient = UIInterfaceOrientationPortrait;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orient = UIInterfaceOrientationPortraitUpsideDown;
            break;
            
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationUnknown:
            // When in doubt, stay the same.
            orient = fromInterfaceOrientation;
            break;
    }
    videoCamera.outputImageOrientation = orient;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - unused methods for AVAsset Writer / Filter mode

//Switches cameras in AVAsset Writer mode
- (IBAction)toggleCamera:(id)sender
{
    // [videoCamera rotateCamera];
    VideoViewController * vc = [[VideoViewController alloc]init];
    [self presentModalViewController:vc animated:YES];
    
}

//Makes button blink in AVAsset Writer mode
-(void) recording {
    if(recordButton.backgroundColor == [UIColor redColor]) [recordButton setBackgroundColor:[UIColor whiteColor]];
    else [recordButton setBackgroundColor:[UIColor redColor]];
}

- (IBAction)updateSliderValue:(id)sender
{
    // [(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]];
}


@end
