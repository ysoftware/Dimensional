//
//  AlertNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 13.12.14.
//  Copyright (c) 2014 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class AlertNode;

@protocol AlertNodeDelegate
-(void)alertOKWithId:(NSString*)id;
-(void)alertCancelWithId:(NSString*)id;
@end

@interface AlertNode : SKSpriteNode
@property (weak, nonatomic) id delegate;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *title;

-(instancetype)initWithTitle:(NSString*)title;

@end
