//
//  SignUpViewController.m
//  TapIn2.0
//
//  Created by Vu Tran on 11/3/12.
//  Copyright (c) 2012 Vu Tran. All rights reserved.
//

#import "SignUpViewController.h"
#import "Utilities.h"
#import "ASIHTTPRequest.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)submitButtonTapped:(id)sender {
    NSMutableDictionary * params = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[Utilities phoneID], @"phone_id", firstname.text, @"first_name", lastname.text, @"last_name",  pass.text, @"password", nil];
    [[Utilities sharedInstance] sendGet:@"phone/associate" params:params delegate:self];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [Utilities setUserDefaultValue:firstname.text forKey:@"first_name"];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"This is the error yo %@", error);
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"There was an error" message:@"Check your network and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    NSLog(@"%@",[[request error] localizedDescription]);
    [alert show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
