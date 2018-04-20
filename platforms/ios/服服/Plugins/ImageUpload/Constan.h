//
//  Constan.h
//  服服
//
//  Created by shangzh on 16/10/28.
//
//

#define screenWidth  [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define Version [[[UIDevice currentDevice] systemVersion] floatValue]



#ifdef DEBUG
#define DeBugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
//#define NSLog(...) NSLog(__VA_ARGS__);

#define NSLog(format, ...) NSLog(format, ##  __VA_ARGS__)

#define MyNSLog(FORMAT, ...)


#else
#define DLog(...)
#define DeBugLog(...)
#define NSLog(...)

#define MyNSLog(FORMAT, ...) fprintf(stderr,"[%s]:[line %d行] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#endif
