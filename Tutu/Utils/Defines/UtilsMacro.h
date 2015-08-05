



//UtilsMacro.h 里放的是一些方便使用的宏定义

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define iOS7                                ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)? NO:YES)
#define NS_Bundle                           [NSBundle mainBundle]

#define IntToString(x)                      [NSString stringWithFormat:@"%d",x]
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define NOTIFICATION_CENTER                 [NSNotificationCenter defaultCenter]
#define NavBarHeight                        (iOS7 ? 64.0 : 44.0)
#define ViewOriginY                         (iOS7 ? 64.0 : 44.0)
#define StatusBarHeight                     (iOS7 ? 20.0 : 0.0)
#define TabBarHeight                        49.0
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define ScreenScale                          (ScreenWidth / 320.f)
#define BG_Queue                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//#define ContentViewHeight                   (iOS7 ? ScreenHeight : ScreenHeight - 64)
#define ContentViewHeight                   ScreenHeight - 64.0
#define iPhone5                             (ScreenHeight > 480 ? YES:NO)
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewWidth                       self.view.bounds.size.width
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define RGB(r, g, b)                        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c)                         [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0]
#define FormatString(string, args...)                  [NSString stringWithFormat:string, args]
#define ALERT(title, msg)                   [[[UIAlertView alloc]     initWithTitle:title\
                                                message:msg\
                                                delegate:nil\
                                                cancelButtonTitle:@"确定"\
                                                otherButtonTitles:nil] show]
//string转化成url
#define StrToUrl(x)                         [NSURL URLWithString:x]

#define UserDocumentPath                   [NSSearchPathForDirectoriesInDomains\
                                           ( NSDocumentDirectory, NSUserDomainMask, YES)\
                                           objectAtIndex:0]
//空NULL  等转换成空字符
#define CheckNilValue(object)              [SysTools covertToString:object]
//add by gaoyong
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)