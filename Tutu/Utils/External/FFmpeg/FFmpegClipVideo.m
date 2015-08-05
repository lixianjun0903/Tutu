//
//  FFmpegClipVideo.m
//  Tutu
//
//  Created by zhanglingyu on 15/3/26.
//  Copyright (c) 2015年 zxy. All rights reserved.
//

#import "FFmpegClipVideo.h"

AVFormatContext *_ifmt_ctx;

@implementation FFmpegClipVideo

+ (NSString *)getVideoMergeFilePathString
{
    NSString *fileName = [NSString stringWithFormat:@"%@%@",getTempVideoPath(),@"merge.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:fileName error:&error] == NO) {
            NSLog(@"removeitematpath %@ error :%@", fileName, error);
        }
    }
    return fileName;
}

/**
 剪切视频播放时间长
 */
+ (void)clipVideoDuration:(NSString *)videoPath begin:(double)begin duration:(double)duration block:(ClipVideoDurationBlock) block
{
    NSString *savePath=[self getVideoMergeFilePathString];
    const char *in_filename  = [videoPath cStringUsingEncoding:NSASCIIStringEncoding];
    const char *out_filename = [savePath cStringUsingEncoding:NSASCIIStringEncoding];
    
    //输入对应一个AVFormatContext，输出对应一个AVFormatContext
    AVFormatContext *ofmt_ctx = NULL;
    AVOutputFormat *ofmt = NULL;
    AVPacket pkt;
    int ret=0, i;
    int frame_index=0;
    
    av_register_all();
    
    //输入（Input）
    if ((ret = avformat_open_input(&_ifmt_ctx, in_filename, 0, 0)) < 0) {
        printf( "Could not open input file.");
        goto end;
    }
    if ((ret = avformat_find_stream_info(_ifmt_ctx, 0)) < 0) {
        printf( "Failed to retrieve input stream information");
        goto end;
    }
    av_dump_format(_ifmt_ctx, 0, in_filename, 0);
    
    //输出（Output）
    avformat_alloc_output_context2(&ofmt_ctx, NULL, NULL, out_filename);
    if (!ofmt_ctx) {
        printf( "Could not create output context\n");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    ofmt = ofmt_ctx->oformat;
    for (i = 0; i < _ifmt_ctx->nb_streams; i++) {
        //根据输入流创建输出流（Create output AVStream according to input AVStream）
        AVStream *in_stream = _ifmt_ctx->streams[i];
        AVStream *out_stream = avformat_new_stream(ofmt_ctx, in_stream->codec->codec);
        
        //*设置旋转角度*
        AVDictionaryEntry *rotate_tag = av_dict_get(in_stream->metadata, "rotate", NULL, 0);
        if (rotate_tag!=NULL) {
            av_dict_set(&out_stream->metadata, "rotate", rotate_tag->value, 0);
        }
        
        if (!out_stream) {
            printf( "Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }
        //复制AVCodecContext的设置（Copy the settings of AVCodecContext）
        if (avcodec_copy_context(out_stream->codec, in_stream->codec) < 0) {
            printf( "Failed to copy context from input to output stream codec context\n");
            goto end;
        }
        out_stream->codec->codec_tag = 0;
        if (ofmt_ctx->oformat->flags & AVFMT_GLOBALHEADER)
            out_stream->codec->flags |= CODEC_FLAG_GLOBAL_HEADER;
    }
    
    //输出一下格式
    av_dump_format(ofmt_ctx, 0, out_filename, 1);
    
    //打开输出文件（Open output file）
    if (!(ofmt->flags & AVFMT_NOFILE)) {
        ret = avio_open(&ofmt_ctx->pb, out_filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
            printf( "Could not open output file '%s'", out_filename);
            goto end;
        }
    }
    
    //写文件头（Write file header）
    if (avformat_write_header(ofmt_ctx, NULL) < 0) {
        printf( "Error occurred when opening output file\n");
        goto end;
    }
    
    if (begin!=0) {
        [self seekTime:_ifmt_ctx type:AVMEDIA_TYPE_VIDEO begin:begin];
    }
    double beginTime=-100;
    
    while (1){
        //获取一个AVPacket（Get an AVPacket）
        ret = av_read_frame(_ifmt_ctx, &pkt);
        if (ret < 0)
            break;
        AVStream *in_stream  = _ifmt_ctx->streams[pkt.stream_index];
        AVStream *out_stream = ofmt_ctx->streams[pkt.stream_index];
        
        //AVRational这个结构标识一个分数，num为分数，den为分母。
        NSLog(@"%f %i %i",av_q2d(in_stream->time_base),in_stream->time_base.num,in_stream->time_base.den);
        NSLog(@"%f %i %i",av_q2d(out_stream->time_base),out_stream->time_base.num,out_stream->time_base.den);
        
        //计算一帧在整个视频中的时间位置，单位：秒
        double in_time = pkt.pts * av_q2d(in_stream->time_base);
        NSLog(@"输入文件当前播放时间：%fs",in_time);
        if (beginTime==-100) {
            beginTime=in_time;
        }
        
        //转换PTS/DTS（Convert PTS/DTS）
        pkt.pts = av_rescale_q_rnd(pkt.pts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.dts = av_rescale_q_rnd(pkt.dts, in_stream->time_base, out_stream->time_base, (AV_ROUND_NEAR_INF|AV_ROUND_PASS_MINMAX));
        pkt.duration = (double)av_rescale_q(pkt.duration, in_stream->time_base, out_stream->time_base);
        pkt.pos = -1;
        
        //修改播放时间
        pkt.pts=pkt.pts-out_stream->time_base.den*beginTime;
        pkt.dts=pkt.dts-out_stream->time_base.den*beginTime;
        
        //计算一帧在整个视频中的时间位置，单位：秒
        double out_time = pkt.pts * av_q2d(out_stream->time_base);
        NSLog(@"输出文件当前播放时间：%fs",out_time);
        
        //写入（Write）
        if (av_interleaved_write_frame(ofmt_ctx, &pkt) < 0){
            printf( "Error muxing packet\n");
            break;
        }
        printf("Write %2d frames to output file size %i\n",frame_index,pkt.size);
        av_free_packet(&pkt);
        frame_index++;
        
        if (out_time>duration) {
            break;
        }
    }
    //写文件尾（Write file trailer）
    av_write_trailer(ofmt_ctx);
    
end:
    avformat_close_input(&_ifmt_ctx);
    /* close output */
    if (ofmt_ctx && !(ofmt->flags & AVFMT_NOFILE)){
        avio_close(ofmt_ctx->pb);
    }
    avformat_free_context(ofmt_ctx);
    
    //剪切成功
    if (ret < 0 && ret != AVERROR_EOF){
        printf( "Error occurred.\n");
        block(videoPath,duration,nil);
        return;
    }
    //剪切失败
    else{
        
        block(savePath,duration,nil);
    }
    return;
}

@end
