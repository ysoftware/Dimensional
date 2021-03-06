//
//
//  Courtesy of Graf on Stack Overflow
//
//
//
#import <SpriteKit/SpriteKit.h>
@interface SKButton : SKSpriteNode

@property (nonatomic, readonly) SEL actionTouchUpInside;
@property (nonatomic, readonly) SEL actionTouchDown;
@property (nonatomic, readonly) SEL actionTouchUp;
@property (nonatomic, readonly, weak) id targetTouchUpInside;
@property (nonatomic, readonly, weak) id targetTouchDown;
@property (nonatomic, readonly, weak) id targetTouchUp;

@property (nonatomic) BOOL isEnabled;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, readonly, strong) SKLabelNode *title;
@property (nonatomic, readwrite, strong) SKTexture *normalTexture;
@property (nonatomic, readwrite, strong) SKTexture *selectedTexture;
@property (nonatomic, readwrite, strong) SKTexture *disabledTexture;

@property (nonatomic, strong) SKColor *normalColor;
@property (nonatomic, strong) SKColor *selectedColor;

- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected;
- (instancetype)initWithTextureNormal:(SKTexture *)normal selected:(SKTexture *)selected disabled:(SKTexture *)disabled; // Designated Initializer

- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected;
- (instancetype)initWithImageNamedNormal:(NSString *)normal selected:(NSString *)selected disabled:(NSString *)disabled;

- (instancetype)initWithImageNamed:(NSString*)image colorNormal:(SKColor*)normal colorSelected:(SKColor*)selected;
- (instancetype)initWithTexture:(SKTexture*)texture colorNormal:(SKColor *)normal colorSelected:(SKColor *)selected;

/** Sets the target-action pair, that is called when the Button is tapped.
 "target" won't be retained.
 */
- (void)setTouchUpInsideTarget:(id)target action:(SEL)action;
- (void)setTouchDownTarget:(id)target action:(SEL)action;
- (void)setTouchUpTarget:(id)target action:(SEL)action;

-(void)runTouchUpInsideAction;
-(void)runTouchDownAction;
-(void)runTouchUpAction;
@end