//
//  SettingsNode.h
//  Dimensional
//
//  Created by Ярослав Ерохин on 18.01.15.
//  Copyright (c) 2015 Yaroslav Erohin. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SettingsNode;

@protocol SettingsNodeDelegate
-(void)settingsDone;
@end

@interface SettingsNode : SKSpriteNode
-(instancetype)initWithPosition:(CGPoint)position;
-(void)closeSettings;

@property (nonatomic, weak) id delegate;
@end
