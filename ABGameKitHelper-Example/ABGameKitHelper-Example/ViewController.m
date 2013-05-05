//
//  ViewController.m
//  ABGameKitHelper-Example
//
//  Created by Alexander Blunck on 5/5/13.
//  Copyright (c) 2013 Alexander Blunck. All rights reserved.
//

#import "ViewController.h"

//1. Import ABGameKitHelper header where you intend to use it (Don't forget to link GameKit.framework)
#import "ABGameKitHelper.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - LifeCycle
-(void) viewDidLoad
{
    [super viewDidLoad];
	
    //2. Call class once to authenticate user
    [ABGameKitHelper sharedHelper];
    
}

@end
