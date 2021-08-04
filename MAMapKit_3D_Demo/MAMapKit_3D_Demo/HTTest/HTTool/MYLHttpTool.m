
//
#import "MYLHttpTool.h"
#import <AFNetworking.h>
#ifdef DEBUG
#define  NSLog(...) NSLog(__VA_ARGS__);
#else
#define NSLog(...)
#endif

@implementation MYLHttpTool

+ (void)GETOrPOST:(kHttpMethods)httpMethod
              url:(NSString *)URLString
       parameters:(id)parameters
         progress:(void (^)(NSProgress * _Nonnull))downProgressBlcok
     successBlcok:(void (^)(NSURLSessionDataTask *_Nonnull task,id responseObject))successBlcok
     failureBlcok:(void (^)(NSURLSessionDataTask *_Nonnull task,NSError *error))failureBlcok {
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    
    /** 请求方式：POST，调用接口时需要设置Content-Type头部为：application/json
     `AFJSONRequestSerializer` is a subclass of `AFHTTPRequestSerializer` that encodes parameters as JSON using `NSJSONSerialization`, setting the `Content-Type` of the encoded request to `application/json`.
     */
    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    
    if (httpMethod == kGETMethod) {
        [mgr GET:URLString
      parameters:parameters
         headers:nil
        progress:^(NSProgress *_Nonnull downloadProgress) {
//            NSLog(@"%@", downloadProgress);
            if (downProgressBlcok) {
                downProgressBlcok(downloadProgress);
            }
        }
         success:^(NSURLSessionDataTask *_Nonnull task,
                   id _Nullable responseObject) {
             if (successBlcok) {
                 successBlcok(task,responseObject);
             }
         }
         failure:^(NSURLSessionDataTask *_Nullable task,
                   NSError *_Nonnull error) {
             if (failureBlcok) {
                 failureBlcok(task,error);
             }
         }];
        
    } else if (httpMethod == kPOSTMethod) {
        
        //!!!: post授权请求，需要修正类型。@"text/plain",
        mgr.responseSerializer.acceptableContentTypes =
            [NSSet setWithObjects:@"application/json",@"text/plain",@"text/html", nil];
      
        [mgr POST:URLString
       parameters:parameters
         headers:nil
         progress:^(NSProgress *_Nonnull downloadProgress) {
//             NSLog(@"%@", downloadProgress);
             if (downProgressBlcok) {
                 downProgressBlcok(downloadProgress);
             }
         }
          success:^(NSURLSessionDataTask *_Nonnull task,
                    id _Nullable responseObject) {
              if (successBlcok) {
                  successBlcok(task, responseObject);
              }
          }
          failure:^(NSURLSessionDataTask *_Nullable task,
                    NSError *_Nonnull error) {
              if (failureBlcok) {
                  failureBlcok(task, error);
              }
          }];
    }
}

@end


