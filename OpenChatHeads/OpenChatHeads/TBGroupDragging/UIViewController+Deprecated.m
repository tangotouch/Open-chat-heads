//
//  UIViewController+Deprecated.m
//  Taobao2013
//
//  Created by 香象 on 14/10/13.
//  Copyright (c) 2013 Taobao.com. All rights reserved.
//

#import "UIViewController+Deprecated.h"

@implementation UIViewController (Deprecated)


- (void)tb_dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion{
    
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:completion];
    } else{
        [self performSelector:@selector(dismissModalViewControllerAnimated:) withObject:[NSNumber numberWithBool:flag]];
        if (completion) {
            
            completion();
        }
    }
}

@end
