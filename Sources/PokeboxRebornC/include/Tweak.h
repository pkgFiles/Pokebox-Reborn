#import <UIKit/UIKit.h>
#import "RemoteLog.h"
#import "UIFontTTF/UIFont-TTF.h"

// Pokébox Headers
#import <UserNotifications/UserNotifications.h>

@protocol NCNotificationContentDisplaying
@end

@protocol NCNotificationSeamlessContentViewDelegate <NSObject>
@end

@protocol BSUIDateLabel <NSObject>
@end

@interface PLPlatterView : UIView
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@end

@interface MTMaterialView : UIView
@end

@interface NCNotificationContentView : UIView
@end

@interface PBHeaderView : UIView
@property (nonatomic, retain) UIButton *iconButton;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@end

@interface NCNotificationShortLookView : PLPlatterView {
    UIView<NCNotificationContentDisplaying> *_notificationContentView;
}
@property (nonatomic,readonly) MTMaterialView *backgroundMaterialView;
@property (assign, nonatomic) BOOL hasShadow;
@property (nonatomic, retain) NCNotificationContentView *notificationContentView;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, copy) NSString *primaryText;
@property (nonatomic, assign) NSString *secondaryText;
- (double)_continuousCornerRadius;
@end

@interface NCNotificationContent : NSObject
@property (nonatomic, assign) NSString *header;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSArray<UIImage *> *icons;
@end

@interface NCNotificationSeamlessContentView : UIView {
    UIView * _crossfadingContentView;
    UILabel * _primaryTextLabel;
    UILabel * _primarySubtitleTextLabel;
    UILabel * _importantTextLabel;
    UILabel * _footerTextLabel;
    UILabel<BSUIDateLabel> * _dateLabel;
    UIView * _secondaryTextElement;
    UIView * _badgedIconView;
    id<NCNotificationSeamlessContentViewDelegate> _delegate;
}
@property (nonatomic, copy) NSString *primaryText;
@property (nonatomic, copy) NSString *primarySubtitleText;
@property (nonatomic, copy) NSString *secondaryText;
@property (nonatomic, copy) NSString *footerText;
@property (nonatomic, copy) NSString *summaryText;
- (CGRect)_textFrameForBounds:(CGRect)arg1;
- (CGSize)sizeThatFits:(CGSize)arg1 ;
@end

@interface NCNotificationRequest : NSObject
- (NCNotificationContent *)content;
@end

@interface SBNotificationBannerDestination : NSObject
@end

@interface NCNotificationViewController : UIViewController
- (UIView *)_longLookViewIfLoaded;
@end

@interface NCNotificationShortLookViewController : NCNotificationViewController
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NCNotificationShortLookView *viewForPreview;
@property (getter=_presentedLongLookViewController,nonatomic,readonly) NCNotificationViewController * presentedLongLookViewController;
@property (nonatomic, retain) UIImageView *backgroundImageView;
@property (nonatomic, retain) UIImageView *backgroundColorView;
@property (nonatomic, retain) NSString *originalSecondaryText;
@end
