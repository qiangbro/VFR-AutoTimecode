#             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                     Version 2, December 2004
# 
#  Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
# 
#  Everyone is permitted to copy and distribute verbatim or modified
#  copies of this license document, and changing it is allowed as long
#  as the name is changed.
# 
#             DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#   0. You just DO WHAT THE FUCK YOU WANT TO.




#
#   VFR-AutoTimecode 1.4.1
#
#
#   在用avisynth脚本拼接帧率不同的影视片段制作VFR视频时，
#   通过一套简易的函数来实现程序自动编写timecode文件。
#
#   作者 : Mikey
#   E-mail : qiangbro@qq.com
#   所在团队 : 有村花纯字幕组
#   项目网址 : https://github.com/qiangbro/VFR-AutoTimecode
#


# --- CODE SAMPLES ---
#
#       LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#       LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#       Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\VFR-AutoTimecode-1.4.avsi")
#
#       v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#       a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#       AudioDub(v, a)
#
#       tcInit()
#
#       Trim(7451,7666).Yadif(mode=3).tcAppend() + Trim(727,1536).tcAppend()
#
#       tcWrite()
#


# --- 接口说明 ---
#
#   本脚本提供3个函数：
#
#       tcInit(clip src, float "default_fps", bool "auto_assume_fps")
#           收集片源的基本信息，初始化timecode信息。
#           调用时机：
#               在加载完片源后，调用一次本函数。
#           参数：
#               src 片源影片
#               default_fps 指定timecode的默认帧率。默认取片源影片的帧率
#                           支持AssumeFPS预设的字符串形式的fps，即：
#
#                           preset              numerator denominator approximate FPS
#                           "ntsc_film"         24000       1001    23.976
#                           "ntsc_video"        30000       1001    29.970
#                           "ntsc_double"       60000       1001    59.940
#                           "ntsc_quad"         120000      1001    119.880
#                           "ntsc_round_film"   2997        125     23.976
#                           "ntsc_round_video"  2997        100     29.97
#                           "ntsc_round_double" 2997        50      59.94
#                           "ntsc_round_quad"   2997        25      119.88
#                           "film"              24          1       24.0
#                           "pal_film"          25          1       25.0
#                           "pal_video"         25          1       25.0
#                           "pal_double"        50          1       50.0
#                           "pal_quad"          100         1       100.0
#
#               auto_assume_fps 是否在调用了tcAppend方法后自动对影片做AssumeFPS(fps=default_fps)。默认true
#
#           返回值：
#               原影片src
#
#       tcAppend(clip c)
#           收集各个片段的帧数和帧率信息。
#           调用时机：
#               对每一个片段调用一次本函数，请按顺序调用。
#           参数：
#               c 组成成品的、帧率可能不同的片段影片片段
#           返回值：
#               如果auto_assume_fps为true，则返回做了AssumeFPS之后的影片c，否则返回原影片c
#
#       tcWrite(clip spliced, string "filename")
#           将已收集的timecode写到文件。默认写到该avs脚本的同一目录中。
#           调用时机：
#               在将所有分段全都调用了tcAppend且合并到主影片之后，对合并好的主影片调用一次本函数。
#           参数：
#               spliced 已拼接好的成品影片
#               filename 指定输出timecode文件的文件名。默认：原avs文件名 + -auto-timecode_v1.txt
#           返回值：
#               原影片spliced
#
#
#   正确调用以上三个函数，就可以在脚本被执行的时候（例如用播放器预览时）自动生成timecode文件。
#


# --- REQUIREMENTS ---
#
#   Avisynth 2.6 或更高版本
#



# --- 名词解释 ---
#
#   CFR:
#       Constant Frame Rates, 恒定帧率
#
#   VFR:
#       Variable Frame Rates, 可变帧率
#
#   timecode文件:
#       时间码文件，可以用于指定视频轨道每一帧的播放速率
#       mkvmerge 可识别四种格式的时间码，
#       请参阅 https://mkvtoolnix.download/doc/mkvmerge.html#mkvmerge.external_timecode_files
#
#   5烂2:
#       一种交错方式。将24帧每秒的电影进行TELECINE(3:2 pulldown)处理，转换为29.970的电视信号，
#       得到的影片每5帧中有2帧是交错的图像，所以称这种交错的方式为5烂2。
#



# --- STORY ---
#
#   有些TS片源中，混合着各种各样不同交错类型的片段，
#   例如，WOWOW播出的2014年村花主演的舞台剧《圣女贞德》，片源帧率=29.970，正片是5烂2方式交错，反交错后帧率=23.976，
#   而片头对中岛编剧&白井导演的采访花絮，以及片尾演职人员的滚动名单，是60i，反交错后帧率=59.940。
#
#   我们知道，不同帧率的影视片段在avisynth中是不能拼接的，于是我们的处理方式是，
#   将帧率不同的片段统一调整为正片23.976的帧率，总时长不变，进行拼接来压制，封装成恒定帧率的成品。
#
#   为什么要统一成正片帧率呢？因为字幕组一般会优先考虑让视频作品有更广泛的兼容性，并优先保护正片的品质。
#   广泛的兼容性是指:
#       ① 作品能在广泛的设备、电脑的播放器上正常播放
#       ② 作品能被广泛的在线视频站点正确转码，并在网页播放器以及客户端上正常播放
#   正常播放指的是:
#       画质良好、音画同步、播放流畅 等
#
#   因为恒定帧率的视频具有更好的兼容性，所以我们采用恒定帧率封装视频作品，
#   而为了保护正片的品质，所以我们选择去牺牲花絮、滚动名单片段的帧率，以保证正片按照原本的帧率播放。
#
#
#
#   实际上，一个视频文件，不同的片段拥有不同的帧率这是可以实现的。
#   有一种封装技术，叫可变帧率(VFR)。
#   视频流本身虽然有自己固有的帧率，但是封装到容器里后，每一帧的播放速率可以是不固定的。
#
#   VFR有一定的优势。
#   VFR视频由于帧率可变，使不同的帧率的片段可以被整合到一个视频中，更具有表现力。
#   一些动画视频，使用支持VFR的压制工具（如：Direct264）进行压制，相比CFR可以有效地节省码率。
#
#   随着技术的发展，VFR的兼容性也在增强。
#   目前主流的视频容器，如mp4、mkv，都是支持VFR封装的，
#   主流的电脑端播放器，如potplayer等，都能正常播放VFR视频。
#   以后支持VFR视频的设备会越来越多，能够正常转码VFR的在线视频站点应该也会越来越多。
#
#   VFR有一定的应用局限性。
#   比如哔哩哔哩站点有要求，不要上传倍速等经过特殊处理的视频。
#   在线视频网站如果要转码VFR视频，相比CFR稍有不同，如果转码处理不当，可能会导致音画不同步。
#   有些非线编软件对VFR视频进行处理的时候也有画音不同步的现象。
#
#   目前由于VFR视频的局限性，短期可能不会在大多数字幕组中使用，
#   但作为一个敢于探索(zuo si)的压制人员，还是愿意来给大家分享一下制作VFR视频的知识。
#



# --- 一种制作VFR视频的思路 ---
#
#   制作VFR视频有多种方案。感兴趣的话可以看看avisynth网站 http://avisynth.nl/index.php/VFR
#
#   限于篇幅，这次我来分享一下我最近整理的一个制作VFR视频的思路：
#       假设avs里有两段影片，一个fps=59.940，另一个fps=29.970
#       将两段影片统一AssumeFPS(29.970)，使用+拼接。
#       压制成恒定码率视频。
#       编写timecode文件，为这两段影片分别指定帧率。
#       封装成品时加载timecode文件，得到VFR视频。
#   
#   好的，根据这么一个思路，我介绍一下具体步骤。
#   （希望假设读者已经掌握了恒定帧率视频的压制和封装，否则读起来会吃力。）
#
#
#   使用Avisynth读取混合交错的CFR片源，分段反交错，制作分段帧率不同的VFR视频的参考步骤：
#
#   1. 正常编写avs文件，加载片源。
#       加载各种插件的dll或avsi，读取恒定帧率的片源视频轨，读取片源音频轨，用AudioDub合并视频轨和音频轨。
#
#       示例：[Kimamani Arinomamani - vfr-test.avs]
#           LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#           LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#           v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#           a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#           AudioDub(v, a)
#
#
#   2. 使用Trim剪档、根据影片的交错方式拆分片段。
#       确保每个Trim区间的交错方式是单一的，否则请拆分。
#
#       示例：[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666) ++ Trim(727,1536)
#
#
#   3. 正常处理音频轨，得到成品音频轨。
#       压制音频轨，或者根据Trim区间以恒定fps换算成时间区间来裁剪音频轨。
#
#   4. 对各个Trim区间分别反交错并用AssumeFPS设定统一的帧率。
#       ① 根据该区间的交错方式，应用反交错滤镜
#       ② 用AssumeFPS设定为统一的帧率（有的片段会变快放，有的片段会变慢放）
#       ③ 与其他区间之间改为用单加号（或UnalignedSplice函数）拼接起来
#
#       示例：[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666).Yadif(mode=3).AssumeFPS("ntsc_video") + Trim(727,1536).AssumeFPS("ntsc_video")
#
#
#   5. 正常以恒定帧率压制视频轨。
#
#
#   6. 编写timecode文件，通过timecode文件指定每一帧的播放帧率。
#
#       示例：[timecode.txt]
#           # timecode format v1
#           Assume 29.970030
#           0,431,59.940060
#           432,1241,29.970030
#
#       我们来读一下mkvmerge文档中对Timecode file format v1 的说明：
#           This format starts with the version line.
#           The second line declares the default number of frames per second.
#           All following lines contain three numbers separated by commas:
#               the start frame (0 is the first frame),
#               the end frame and the number of frames in this range.
#           The FPS is a floating point number with the dot '.' as the decimal point.
#           The ranges can contain gaps for which the default FPS is used.
#
#       我来介绍一下本例中timecode文件中的数据是如何得来的：
#
#           已知片源的帧率=30000/1001=29.970030，将它作为默认帧率
#           所以有了：Assume 29.970030
#
#           然后逐段计算推导。
#
#           首段：Trim(7451,7666)，共216帧，用Yadif(mode=3)反交错，得到双倍帧，即432帧，
#           得出成品的编号是0~431的帧的帧率是2*30000/1001=59.940060
#           所以有了：0,431,59.940060
#
#           第二段：Trim(727,1536)，共810帧，不进行反交错，成品依然是810帧，
#           得出成品的编号是432~1241的帧的帧率是30000/1001=29.970030
#           所以有了：432,1241,29.970030
#
#
#   7. 封装，得到VFR成品。
#       本例演示mkv的VFR封装。
#       ① 用mkvtoolnixGUI载入视频轨，单击导入的视频轨，为它导入timecode文件。
#       ② 正常导入音频轨
#       ③ 完善其他的封装参数。
#       ④ 合成mkv文件，最后得到成品VFR视频。
#



# --- 使用VFR-AutoTimecode避免人工编写timecode文件 ---
#
#   在上面的步骤6，如果你自己人工编写timecode文件，可以体会到：
#       ① 需要人为去做琐碎的推导计算工作，工作效率低，而工作量多的话容易出错。
#       ② 如果发现某一步推导的数据出了错，后面的数据都要做修正（这可麻烦了，可能又会产生新的错）。
#       ③ 对于5烂2的反交错，原帧数乘以0.8得到反交错的帧数，可能会产生小数，我尚不明确所用的反交错滤镜会如何进行取舍。
#
#   综上几点我认为，生产环境中，压制人员人工去编写timecode文件的做法并不太实际可行。于是，本脚本产生。
#
#
#   下面，介绍如何将本脚本应用到之前介绍的制作VFR视频的工作步骤中：
#
#   在步骤1:
#       在avs文件中加载各种插件时，将VFR-AutoTimecode-1.3.avsi引入。
#       在用AudioDub合并了视频与音频之后，需要对该影片调用一下tcInit()方法，以此收集视频轨的基本信息，初始化timecode信息。
#
#       示例：[Kimamani Arinomamani - vfr-test.avs]
#           LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#           LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#           Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\VFR-AutoTimecode-1.4.avsi")
#           v = DGSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#           a = WavSource("H:\fansub-work\[任务\[存档\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#           AudioDub(v, a)
#           tcInit()
#
#   在步骤2:
#       无变化。
#
#   在步骤3:
#       无变化。
#
#   在步骤4:
#       在为每个Trim区间应用了反交错之后，需要调用tcAppend()，以此来收集该片段的帧数量和帧率信息。
#       调用完了tcAppend函数以后，可以将原来的AssumeFPS语句统一全都去掉，因为tcAppend会捎带着做AssumeFPS。
#       当所有的Trim区间处理完善后，另起一行，对合并好的影片调用一次tcWrite()，以此将收集到的timecode信息一次性输出到timecode文件。
#
#       示例：[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666).Yadif(mode=3).tcAppend() + Trim(727,1536).tcAppend()
#           tcWrite()
#
#   在步骤5:
#       无变化。
#
#   在步骤6:
#       timecode文件由本脚本自动编写生成。
#       当你尝试用播放器预览该avs，或用megui成功读取了avs文件之后，
#       会在该avs文件所在目录中找到一个以-timecode_v1.txt结尾的文件，它就是本脚本自动编写出来的timecode文件。
#       如果你不再需要每次运行avs都生成timecode文件（比如，你已经得到了需要的timecode文件了），可以注释掉tcWrite()这一行。
#
#       生成的timecode文件样例: [Kimamani Arinomamani - vfr-test.avs-auto-timecode_v1.txt]
#           # timecode format v1
#           # generated by Mikey's Fansub Utilities Pack - VFR-AutoTimecode 1.4 at 2016-07-08 14:19:03
#           Assume 29.970030
#           0,431,59.940060
#           432,1241,29.970030
#
#   在步骤7:
#       无变化。
#




# --- CHANGELOG ---
#
#   2016.7.16
#   1.4.1 by Mikey
#       文案整理
#       私用全局变量添加__前缀
#
#   2016.7.8
#   1.4 by Mikey
#       tcInit增加auto_assume_fps参数
#       函数改名，将添加分段的函数改为tcAppend
#
#
#   2016.6.27
#   1.3 by Mikey
#       函数改名，统一改为驼峰命名方式：tcInit，tcAppend，tcWrite
#       生成的文件名后缀改为-auto-timecode_v1.txt
#
#
#   2016.6.26
#   1.2.1 by Mikey
#       完善文案。
#       错误信息定义为全局变量，从而允许支持多国语言
#
#
#   2016.6.25
#   1.2 by Mikey
#       tcInit 增加对于AssumeFPS预设的字符串形式的fps的支持。示例：tcInit("ntsc_film")
#
#
#   2016.6.24
#   1.1 by Mikey
#       增加分段帧数之和的统计：__tc_frame_counter
#       增加错误提示：调用tcAppend、tcWrite之前必须先调用tcInit。
#       增加错误提示：调用tcWrite时，必须保证影片的总帧数与各个分段的帧数之和一致。
#
#
#   2016.6.23
#   1.0 by Mikey
#       tcInit、tcAppend、tcWrite基本功能实现。
#       编写文案。
#




global __tc_is_inited = false
#~ global __tc_offset = -1
#~ global __tc_default_fps = 0
#~ global __tc_frame_counter = 0
#~ global __tc_appender = "#not yet ready..."
#~ global __tc_auto_assume_fps = true

global __tc_ENTER = """
"""

global tc_MSG_CALL_INIT_BEFORE_APPEND = "在调用tcAppend()之前，请先调用tcInit()"
global tc_MSG_CALL_INIT_BEFORE_WRITE = "在调用tcWrite()之前，请先调用tcInit()"
global tc_MSG_FRAME_COUNT_NOT_CONSISTENT = "分段帧数之和与影片总帧数不一致。请检查确保组成影片的每个分段都调用了一次tcAppend()"


function __tc_get_float_fps(val fps) {
    return Colorbars(512,384).AssumeFPS(fps).FrameRate()
}

function tcInit(clip src, val "default_fps", bool "auto_assume_fps") {

    global __tc_is_inited = true
    global __tc_offset = -1
    global __tc_default_fps = Default(default_fps, src.FrameRate())
    global __tc_frame_counter = 0
    global __tc_auto_assume_fps = Default(auto_assume_fps, true)

    format_line = "# timecode format v1"
    notice_line = "# generated by Mikey's Fansub Utilities Pack - VFR-AutoTimecode 1.4 at " + Time("%Y-%m-%d %H:%M:%S")
    assume_line = "Assume " + string(__tc_get_float_fps(__tc_default_fps), "%f")

    global __tc_appender = format_line + __tc_ENTER + notice_line + __tc_ENTER + assume_line

    return src
}

function tcAppend(clip c) {

    Assert(__tc_is_inited, tc_MSG_CALL_INIT_BEFORE_APPEND)

    start = __tc_offset + 1
    end = __tc_offset + c.FrameCount()

    global __tc_offset = end
    global __tc_frame_counter = __tc_frame_counter + c.FrameCount()

    line = string(start) + "," + string(end) + "," + string(c.FrameRate(), "%f")

    global __tc_appender = __tc_appender + __tc_ENTER + line

    
    return __tc_auto_assume_fps ? c.AssumeFPS(__tc_default_fps, sync_audio=false) : c
}


function tcWrite(clip spliced, string "filename") {

    Assert(__tc_is_inited, tc_MSG_CALL_INIT_BEFORE_WRITE)
    Assert(__tc_frame_counter == spliced.FrameCount(), tc_MSG_FRAME_COUNT_NOT_CONSISTENT)
    
    filename = Default(filename, ScriptName() + "-auto-timecode_v1.txt")
    WriteFileStart(spliced, filename, "__tc_appender", append=false)

    return spliced
}
