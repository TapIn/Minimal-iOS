//
//  ViewController.h
//  TapIn2.0
//
//  Created by Vu Tran on 10/12/12.
//  Copyright (c) 2012 Vu Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ASIHTTPRequest.h"
#import "GPUImage.h"

@interface ViewController : UIViewController 
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
ASIHTTPRequestDelegate>
{
    UIToolbar *toolbar;
    UIPopoverController *popoverController;
    UIImageView *imageView;
    BOOL newMedia;
    IBOutlet UIProgressView * progress;
    IBOutlet UIButton * recordButton;
    GPUImageVideoCamera *videoCamera;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    IBOutlet GPUImageView * gpuImageView;
}
- (IBAction)updateSliderValue:(id)sender;
- (IBAction)toggleRecord:(id)sender;
- (IBAction)toggleCamera:(id)sender;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@end
