//
//  UIViewController+DependencyCoordinator.m
//  MHDependencyKit
//
//  Created by Milen Halachev on 22.10.18.
//  Copyright © 2018 KoCMoHaBTa. All rights reserved.
//

#import "UIViewController+DependencyCoordinator.h"
#import <objc/runtime.h>
#import <MHDependencyKit/MHDependencyKit-Swift.h>

@implementation UIViewController (DependencyCoordinator)

+(void)load {
    
    Method m1 = class_getInstanceMethod([self class], @selector(prepareForSegue:sender:));
    Method m2 = class_getInstanceMethod([self class], @selector(sph_prepareForSegue:sender:));
    
    method_exchangeImplementations(m1, m2);
}

-(void)sph_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self prepareUsingDependencyCoordinatorFromSender:sender toSegue:segue];
    [self sph_prepareForSegue:segue sender:sender];
}


@end
