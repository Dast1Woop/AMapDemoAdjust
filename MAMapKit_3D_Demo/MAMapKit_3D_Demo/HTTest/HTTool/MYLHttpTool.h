
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

///http请求方法类型
typedef NS_ENUM(NSInteger,kHttpMethods){
    kGETMethod = 0,
    kPOSTMethod = 1
};

@interface MYLHttpTool : NSObject


/**
 网络请求

 @param httpMethod http方法，用kHttpMethods中某种枚举
 @param URLString url地址
 @param parameters 参数，传字典
 @param downProgressBlcok 下载进度回调
 @param successBlcok 成功回调
 @param failureBlcok 失败回调
 */
+ (void)GETOrPOST:(kHttpMethods)httpMethod
              url:(NSString *)URLString
       parameters:(id)parameters
//isNeedJsonSerilize:(BOOL)isNeedJsonSerilize//如果后台可以统一请求格式，就可以省略此参数了。暂不做。
         progress:(void (^)(NSProgress * _Nonnull))downProgressBlcok
     successBlcok:(void (^)(NSURLSessionDataTask *_Nonnull task, id responseObject))successBlcok
     failureBlcok:(void (^)(NSURLSessionDataTask *_Nonnull task, NSError *error))failureBlcok;

@end
NS_ASSUME_NONNULL_END

