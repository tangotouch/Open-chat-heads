//
//  YQTChatViewController.m
//  OpenChatHeads
//
//  Created by 香象 on 29/11/13.
//  Copyright (c) 2013 香象. All rights reserved.
//

#import "YQTChatViewController.h"

@interface YQTChatViewController ()

@end

@implementation YQTChatViewController

-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView=[[UIImageView alloc]initWithFrame:self.view.frame];
        if (_imagePath.length) {
            _imageView.image=[UIImage imageNamed:_imagePath];
            _imageView.contentMode=UIViewContentModeScaleAspectFit;
        }
        [self.view addSubview:_imageView];
    }
    return _imageView;
}


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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
