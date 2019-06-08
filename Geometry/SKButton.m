//
//
//  Courtesy of Graf on Stack Overflow
//
//
//
#import "SKButton.h"

@implementation SKButton

#pragma mark Texture Initializer

@synthesize disabledTexture = _disabledTexture, normalTexture = _normalTexture;
/**
 * Override the super-classes designated initializer, to get a properly set SKButton in every case
 */
- (instancetype)initWithTexture:(SKTexture *)texture color:(SKColor *)color size:(CGSize)size {
    return [self initWithTextureNormal:texture selected:nil disabled:nil];
}

- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected {
    return [self initWithTextureNormal:normal selected:selected disabled:nil];
}

/**
 * This is the designated Initializer
 */

-(instancetype)initWithTexture:(SKTexture*)texture colorNormal:(SKColor *)normal colorSelected:(SKColor *)selected{
    self = [super initWithTexture:texture];
    if (self){
        [self setNormalColor:normal];
        [self setSelectedColor:selected];
        [self setColorBlendFactor:1];

        [self setIsEnabled:YES];
        [self setIsSelected:NO];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

-(instancetype)initWithImageNamed:(NSString *)image colorNormal:(SKColor *)normal colorSelected:(SKColor *)selected{
    self = [super initWithImageNamed:image];
    if (self){
        [self setNormalColor:normal];
        [self setSelectedColor:selected];
        [self setColorBlendFactor:1];

        [self setIsEnabled:YES];
        [self setIsSelected:NO];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled {
    self = [super initWithTexture:normal color:[SKColor whiteColor] size:normal.size];
    if (self) {
        [self setNormalTexture:normal];
        [self setSelectedTexture:selected];
        [self setDisabledTexture:disabled];
        [self setIsEnabled:YES];
        [self setIsSelected:NO];

        _title = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        [_title setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [_title setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];

        [self addChild:_title];
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

#pragma mark Image Initializer

- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected {
    return [self initWithImageNamedNormal:normal selected:selected disabled:nil];
}

- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled {
    SKTexture *textureNormal = nil;
    if (normal) {
        textureNormal = [SKTexture textureWithImageNamed:normal];
    }

    SKTexture *textureSelected = nil;
    if (selected) {
        textureSelected = [SKTexture textureWithImageNamed:selected];
    }

    SKTexture *textureDisabled = nil;
    if (disabled) {
        textureDisabled = [SKTexture textureWithImageNamed:disabled];
    }

    return [self initWithTextureNormal:textureNormal selected:textureSelected disabled:textureDisabled];
}

#pragma -
#pragma mark Setting Target-Action pairs

- (void)setTouchUpInsideTarget:(id)target action:(SEL)action {
    _targetTouchUpInside = target;
    _actionTouchUpInside = action;
}

- (void)setTouchDownTarget:(id)target action:(SEL)action {
    _targetTouchDown = target;
    _actionTouchDown = action;
}

- (void)setTouchUpTarget:(id)target action:(SEL)action {
    _targetTouchUp = target;
    _actionTouchUp = action;
}

#pragma -
#pragma mark Setter overrides

- (void)setIsEnabled:(BOOL)isEnabled {
    _isEnabled = isEnabled;
    if ([self disabledTexture]) {
        if (!_isEnabled) {
            [self setTexture:_disabledTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
    else if (_normalColor){
        [self setColor:_normalColor];

    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if ([self selectedTexture] && [self isEnabled]) {
        if (_isSelected) {
            [self setTexture:_selectedTexture];
        } else {
            [self setTexture:_normalTexture];
        }
    }
    else if ([self selectedColor] && [self isEnabled]){
        if (_isSelected){
            [self setColor:_selectedColor];
        }
        else{
            [self setColor:_normalColor];
        }
    }
}

#pragma -
#pragma mark Touch Handling

/**
 * This method only occurs, if the touch was inside this node. Furthermore if
 * the Button is enabled, the texture should change to "selectedTexture".
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        if (_actionTouchDown){
            [self runTouchDownAction];
        }
        [self setIsSelected:YES];
    }
}

/**
 * If the Button is enabled: This method looks, where the touch was moved to.
 * If the touch moves outside of the button, the isSelected property is restored
 * to NO and the texture changes to "normalTexture".
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isEnabled]) {
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInNode:self.parent];

        if (CGRectContainsPoint(self.frame, touchPoint)) {
            [self setIsSelected:YES];
        } else {
            [self setIsSelected:NO];
        }
    }
}

/**
 * If the Button is enabled AND the touch ended in the buttons frame, the
 * selector of the target is run.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self.parent];

    if ([self isEnabled] && CGRectContainsPoint(self.frame, touchPoint)) {
        if (_actionTouchUpInside){
            [self runTouchUpInsideAction];
        }
    }
    [self setIsSelected:NO];
    if (_actionTouchUp){
        [self runTouchUpAction];
    }
}

//ПОМЕНЯЛ [self.parent на [_targetXXX

#pragma mark - Programmatically control button

-(void)runTouchUpInsideAction{
    [_targetTouchUpInside performSelectorOnMainThread:_actionTouchUpInside withObject:_targetTouchUpInside waitUntilDone:YES];
}

-(void)runTouchDownAction{
    [_targetTouchDown performSelectorOnMainThread:_actionTouchDown withObject:_targetTouchDown waitUntilDone:YES];
}

-(void)runTouchUpAction{
    [_targetTouchUp performSelectorOnMainThread:_actionTouchUp withObject:_targetTouchUp waitUntilDone:YES];
}

@end