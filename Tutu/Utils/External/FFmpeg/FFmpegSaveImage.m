//
//  FFmpegSaveImage.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/25.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegSaveImage.h"

AVFormatContext *_pFormatCtx;
AVCodecContext *_pCodecCtx;
//视频旋转角度
int _rotate_v;
int _index_v;

@implementation FFmpegSaveImage

+ (int)decodeVideo:(const char *) in_fileName
{
    //注册文件格式和编码
    av_register_all();
    avcodec_register_all();
    
    //打开视频文件
    if(avformat_open_input(&_pFormatCtx, in_fileName, NULL, NULL)!=0){
        av_log(NULL, AV_LOG_ERROR, "打开视频文件，出错！");
        goto error;
    }
    
    //取出流信息
    if(avformat_find_stream_info(_pFormatCtx, NULL)<0){
        av_log(NULL, AV_LOG_ERROR, "取出流信息，出错！");
        goto error;
    }
    
    //打印编码格式信息
    av_dump_format(_pFormatCtx, 0, in_fileName, 0);
    
    //查找视频流信息
    AVCodec *pCodec;
    if((_index_v=av_find_best_stream(_pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0))<0){
        av_log(NULL, AV_LOG_ERROR, "未找到视频文件流！");
        goto error;
    }
    _pCodecCtx=_pFormatCtx->streams[_index_v]->codec;
    
    //视频流的旋转角度
    AVStream *stream_v=_pFormatCtx->streams[_index_v];
    AVDictionaryEntry *rotate_tag  = av_dict_get(stream_v->metadata, "rotate", NULL, 0);
    if (rotate_tag!=NULL) {
        _rotate_v=atoi(rotate_tag->value);
    }
    
    //查找视频流的解码器
    pCodec=avcodec_find_decoder(_pCodecCtx->codec_id);
    if(pCodec==NULL){
        av_log(NULL, AV_LOG_ERROR, "未找到相应解码器！");
        goto error;
    }
    
    //打开解码器
    if(avcodec_open2(_pCodecCtx, pCodec, NULL)<0){
        av_log(NULL, AV_LOG_ERROR, "未能打开解码器！");
        goto error;
    }
    return 1;
    
error:
    return 0;
}

/**
 *  根据个数获取图片
 */
+ (NSMutableArray *)getImages:(int)count withVideo:(NSString *)videoPath
{
    NSMutableArray *arrayImage=[[NSMutableArray alloc]init];
    
    //视频解码
    const char * in_fileName=[videoPath cStringUsingEncoding:NSASCIIStringEncoding];
    if (![self decodeVideo:in_fileName]) {
        return nil;
    }
    
    //获取视频播放时间(s)
    double duration=_pFormatCtx->duration/AV_TIME_BASE;
    double step=duration/count;
    NSLog(@"播放时间：%fs 时间间隔：%fs",duration,step);
    
    //颜色编码转换
    AVPicture picture;
    avpicture_alloc(&picture, PIX_FMT_RGB24, _pCodecCtx->width, _pCodecCtx->height);
    struct SwsContext * sws_context = sws_getContext(_pCodecCtx->width,_pCodecCtx->height,_pCodecCtx->pix_fmt,_pCodecCtx->width,_pCodecCtx->height,PIX_FMT_RGB24,SWS_POINT,NULL,NULL,NULL);
    
    AVFrame *pFrame=avcodec_alloc_frame();
    
    int frameFinished=0;
    int imageIndex=0;
    AVPacket packet;
    while(av_read_frame(_pFormatCtx, &packet)>=0)
    {
        if(packet.stream_index!=_index_v){
            continue;
        }
        
        //转换编码
        avcodec_decode_video2(_pCodecCtx, pFrame, &frameFinished, &packet);
        
        AVStream *stream=_pFormatCtx->streams[packet.stream_index];
        double curTime=packet.pts*av_q2d(stream->time_base);
        double stepTime=imageIndex*step;
        if (curTime<stepTime) {
            continue;
        }
        
        NSLog(@"当前播放时间：%fs 间隔时间：%fs",curTime,stepTime);
        int sws=sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, _pCodecCtx->height, picture.data, picture.linesize);
        if (!sws) {
            continue;
        }
        
        //获取图片
        UIImage *image=[[UIImage alloc]init];
        switch (_rotate_v) {
            case 0:
            {
                image= [self imageFromAVPicture:picture width:_pCodecCtx->width height:_pCodecCtx->height];
            }
                break;
            case 90:
            {
                AVPicture picture2;
                avpicture_alloc(&picture2, PIX_FMT_RGB24, _pCodecCtx->height, _pCodecCtx->width);
                rotate90_RGB24_CLW(picture2.data[0], picture.data[0], _pCodecCtx->width, _pCodecCtx->height);
                image= [self imageFromAVPicture:picture2 width:_pCodecCtx->height height:_pCodecCtx->width];
            }
                break;
            default:
                break;
        }
        UIImage *image2=[UIImage clipImageToSquare:image byWidth:400];
        [arrayImage addObject:[UIImage imageWithData:UIImagePNGRepresentation(image2)]];
        imageIndex++;
        if (imageIndex>=count) {
            break;
        }
    }
    NSLog(@"解码，完毕！");
    avformat_close_input(&_pFormatCtx);
    avformat_free_context(_pFormatCtx);
    return arrayImage;
}

/**
 *  根据个数获取图片
 */
+ (void)getImages:(int)count withVideo:(NSString *)videoPath withBlock:(GetImageDataBlock)block
{
    //视频解码
    const char * in_fileName=[videoPath cStringUsingEncoding:NSASCIIStringEncoding];
    if (![self decodeVideo:in_fileName]) {
        return;
    }
    
    //获取视频播放时间(s)
    double duration=_pFormatCtx->duration/AV_TIME_BASE;
    double step=duration/count;
    NSLog(@"播放时间：%fs 时间间隔：%fs",duration,step);
    
    //颜色编码转换
    AVPicture picture;
    avpicture_alloc(&picture, PIX_FMT_RGB24, _pCodecCtx->width, _pCodecCtx->height);
    AVPicture picture2;
    avpicture_alloc(&picture2, PIX_FMT_RGB24, _pCodecCtx->height, _pCodecCtx->width);
    
    struct SwsContext * sws_context = sws_getContext(_pCodecCtx->width,_pCodecCtx->height,_pCodecCtx->pix_fmt,_pCodecCtx->width,_pCodecCtx->height,PIX_FMT_RGB24,SWS_POINT,NULL,NULL,NULL);
    
    AVFrame *pFrame=avcodec_alloc_frame();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int frameFinished=0;
        int imageIndex=0;
        AVPacket packet;
        while(av_read_frame(_pFormatCtx, &packet)>=0)
        {
            if(packet.stream_index!=_index_v){
                continue;
            }
            
            //转换编码
            avcodec_decode_video2(_pCodecCtx, pFrame, &frameFinished, &packet);
            
            AVStream *stream=_pFormatCtx->streams[packet.stream_index];
            double curTime=packet.pts*av_q2d(stream->time_base);
            double stepTime=imageIndex*step;
            
            NSLog(@"当前播放时间：%fs 间隔时间：%fs",curTime,stepTime);
            [self seekTime:_pFormatCtx type:AVMEDIA_TYPE_VIDEO begin:stepTime];
            if (curTime<stepTime) {
                continue;
            }
        
            int sws=sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, _pCodecCtx->height, picture.data, picture.linesize);
            if (!sws) {
                continue;
            }
            
            //获取图片
            UIImage *image=[[UIImage alloc]init];
            switch (_rotate_v) {
                case 0:
                {
                    image= [self imageFromAVPicture:picture width:_pCodecCtx->width height:_pCodecCtx->height];
                }
                    break;
                case 90:
                {
                    rotate90_RGB24_CLW(picture2.data[0], picture.data[0], _pCodecCtx->width, _pCodecCtx->height);
                    image= [self imageFromAVPicture:picture2 width:_pCodecCtx->height height:_pCodecCtx->width];
                }
                    break;
                default:
                    break;
            }
            UIImage *image2=[UIImage clipImageToSquare:image byWidth:80];
            NSData *data=UIImagePNGRepresentation(image2);
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(data,imageIndex);
                }
            });
            imageIndex++;
            if (imageIndex>=count) {
                break;
            }
        }
        NSLog(@"解码，完毕！");
        free(pFrame);
        avformat_close_input(&_pFormatCtx);
        avformat_free_context(_pFormatCtx);
    });
}

@end
