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
#   VFR-AutoTimecode 1.3
#
#   ������дavisynth�ű�ƴ��֡�ʲ�ͬ��Ӱ��Ƭ������VFR��Ƶʱ��
#   ͨ������һ�׼��׵ĺ������ռ�timecode��Ϣ����ʵ���Զ�
#   ����v1��ʽ��timecode�ļ�������˹�ȥ��дtimecode�ļ���
#
#
#   Author : Mikey
#   E-mail : qiangbro@qq.com
#
#   �����Ŷ� : �д廨����Ļ��
#
#   ��л����ʹ������ԡ��������bug����ӭ������
#   �����Ҫ���ơ��������޸ı�������룬������ WTFPL 2.0��ϣ������������а�����
#   �ٴθ�л��ף��������죡
#
#
#       Mikey
#       2016.6
#



# --- VERSION HISTORY ---
#
#   2016.6.27
#   1.3 by Mikey
#       ����������ͳһ��Ϊ�շ�������ʽ��tcInit��tcAdd��tcWrite
#       ���ɵ��ļ�����׺��Ϊ-auto-timecode_v1.txt
#
#
#   2016.6.26
#   1.2.1 by Mikey
#       �����İ���
#       ������Ϣ����Ϊȫ�ֱ������Ӷ�����֧�ֶ������
#
#
#   2016.6.25
#   1.2 by Mikey
#       tcInit ���Ӷ���AssumeFPSԤ����ַ�����ʽ��fps��֧�֣�����
#
#       preset              numerator denominator approximate FPS
#       "ntsc_film"         24000       1001    23.976
#       "ntsc_video"        30000       1001    29.970
#       "ntsc_double"       60000       1001    59.940
#       "ntsc_quad"         120000      1001    119.880
#       "ntsc_round_film"   2997        125     23.976
#       "ntsc_round_video"  2997        100     29.97
#       "ntsc_round_double" 2997        50      59.94
#       "ntsc_round_quad"   2997        25      119.88
#       "film"              24          1       24.0
#       "pal_film"          25          1       25.0
#       "pal_video"         25          1       25.0
#       "pal_double"        50          1       50.0
#       "pal_quad"          100         1       100.0
#
#       ʾ����tcInit("ntsc_film")
#
#
#   2016.6.24
#   1.1 by Mikey
#       ���ӷֶ�֡��֮�͵�ͳ�ƣ�tc_frame_counter
#       ���Ӵ�����ʾ������tcAdd��tcWrite֮ǰ�����ȵ���tcInit��
#       ���Ӵ�����ʾ������tcWriteʱ�����뱣֤ӰƬ����֡��������ֶε�֡��֮��һ�¡�
#
#
#   2016.6.23
#   1.0 by Mikey
#       tcInit��tcAdd��tcWrite��������ʵ�֡�
#       ��д�İ���
#



# --- REQUIREMENTS ---
#
#   Avisynth 2.6 or Avisynth+



# --- ���ʽ��� ---
#
#   CFR:
#       Constant Frame Rates, �㶨֡��
#
#   VFR:
#       Variable Frame Rates, �ɱ�֡��
#
#   timecode�ļ�:
#       ʱ�����ļ�����������ָ����Ƶ���ÿһ֡�Ĳ�������
#       mkvmerge ��ʶ�����ָ�ʽ��ʱ���룬
#       ����� https://mkvtoolnix.download/doc/mkvmerge.html#mkvmerge.external_timecode_files
#
#   5��2:
#       һ�ֽ�����ʽ����24֡ÿ��ĵ�Ӱ����TELECINE(3:2 pulldown)������ת��Ϊ29.970�ĵ����źţ�
#       �õ���ӰƬÿ5֡����2֡�ǽ�����ͼ�����Գ����ֽ����ķ�ʽΪ5��2��



# --- �������� ---
#
#   ��ЩTSƬԴ�У�����Ÿ��ָ�����ͬ�������͵�Ƭ�Σ�
#   ���磬WOWOW������2014��廨���ݵ���̨�硶ʥŮ��¡���ƬԴ֡��=29.970����Ƭ��5��2��ʽ��������������֡��=23.976��
#   ��Ƭͷ���е����&�׾����ݵĲɷû������Լ�Ƭβ��ְ��Ա�Ĺ�����������30i����������֡��=59.940��
#
#   ����֪������ͬ֡�ʵ�Ӱ��Ƭ����avisynth���ǲ���ƴ�ӵģ��������ǵĴ�����ʽ�ǣ�
#   ��֡�ʲ�ͬ��Ƭ��ͳһ����Ϊ��Ƭ23.976��֡�ʣ���ʱ�����䣬����ƴ����ѹ�ƣ���װ�ɺ㶨֡�ʵĳ�Ʒ��
#
#   ΪʲôҪͳһ����Ƭ֡���أ���Ϊ��Ļ��һ������ȿ�������Ƶ��Ʒ�и��㷺�ļ����ԣ������ȱ�����Ƭ��Ʒ�ʡ�
#   �㷺�ļ�������ָ:
#       �� ��Ʒ���ڹ㷺���豸�����ԵĲ���������������
#       �� ��Ʒ�ܱ��㷺��������Ƶվ����ȷת�룬������ҳ�������Լ��ͻ�������������
#   ��������ָ����:
#       �������á�����ͬ������������ ��
#
#   ��Ϊ�㶨֡�ʵ���Ƶ���и��õļ����ԣ��������ǲ��ú㶨֡�ʷ�װ��Ƶ��Ʒ��
#   ��Ϊ�˱�����Ƭ��Ʒ�ʣ���������ѡ��ȥ������������������Ƭ�ε�֡�ʣ��Ա�֤��Ƭ����ԭ����֡�ʲ��š�
#
#
#
#   ʵ���ϣ�һ����Ƶ�ļ�����ͬ��Ƭ��ӵ�в�ͬ��֡�����ǿ���ʵ�ֵġ�
#   ��һ�ַ�װ�������пɱ�֡��(VFR)��
#   ��Ƶ��������Ȼ���Լ����е�֡�ʣ����Ƿ�װ���������ÿһ֡�Ĳ������ʿ����ǲ��̶��ġ�
#
#   VFR��һ�������ơ�
#   VFR��Ƶ����֡�ʿɱ䣬ʹ��ͬ��֡�ʵ�Ƭ�ο��Ա����ϵ�һ����Ƶ�У������б�������
#   һЩ������Ƶ��ʹ��֧��VFR��ѹ�ƹ��ߣ��磺Direct264������ѹ�ƣ����CFR������Ч�ؽ�ʡ���ʡ�
#
#   ���ż����ķ�չ��VFR�ļ�����Ҳ����ǿ��
#   Ŀǰ��������Ƶ��������mp4��mkv������֧��VFR��װ�ģ�
#   �����ĵ��Զ˲���������potplayer�ȣ�������������VFR��Ƶ��
#   �Ժ�֧��VFR��Ƶ���豸��Խ��Խ�࣬�ܹ�����ת��VFR��������Ƶվ��Ӧ��Ҳ��Խ��Խ�ࡣ
#
#   VFR��һ����Ӧ�þ����ԡ�
#   ������������վ����Ҫ�󣬲�Ҫ�ϴ����ٵȾ������⴦������Ƶ��
#   ������Ƶ��վ���Ҫת��VFR��Ƶ�����CFR���в�ͬ�����ת�봦�����������ܻᵼ��������ͬ����
#   ��Щ���߱�������VFR��Ƶ���д�����ʱ��Ҳ�л�����ͬ��������
#
#   Ŀǰ����VFR��Ƶ�ľ����ԣ����ڿ��ܲ����ڴ������Ļ����ʹ�ã�
#   ����Ϊһ������̽��(zuo si)��ѹ����Ա������Ը��������ҷ���һ������VFR��Ƶ��֪ʶ��
#


# --- һ������VFR��Ƶ��˼· ---
#
#   ����VFR��Ƶ�ж��ַ���������Ȥ�Ļ����Կ���avisynth��վ http://avisynth.nl/index.php/VFR
#
#   ����ƪ���������������һ�������������һ������VFR��Ƶ��˼·��
#       ����avs��������ӰƬ��һ��fps=59.940����һ��fps=29.970
#       ������ӰƬͳһAssumeFPS(29.970)��ʹ��+ƴ�ӡ�
#       ѹ�Ƴɺ㶨������Ƶ��
#       ��дtimecode�ļ���Ϊ������ӰƬ�ֱ�ָ��֡�ʡ�
#       ��װ��Ʒʱ����timecode�ļ����õ�VFR��Ƶ��
#   
#   �õģ�������ôһ��˼·���ҽ���һ�¾��岽�衣
#   ��ϣ����������Ѿ������˺㶨֡����Ƶ��ѹ�ƺͷ�װ��������������������
#


# --- ʹ��Avisynth��ȡ��Ͻ�����CFRƬԴ���ֶη������������ֶ�֡�ʲ�ͬ��VFR��Ƶ�Ĳο����� ---
#
#   1. ������дavs�ļ�������ƬԴ��
#       ���ظ��ֲ����dll��avsi����ȡ�㶨֡�ʵ�ƬԴ��Ƶ�죬��ȡƬԴ��Ƶ�죬��AudioDub�ϲ���Ƶ�����Ƶ�졣
#
#       ʾ����[Kimamani Arinomamani - vfr-test.avs]
#           LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#           LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#           v = DGSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#           a = WavSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#           AudioDub(v, a)
#
#
#   2. ʹ��Trim����������ӰƬ�Ľ�����ʽ���Ƭ�Ρ�
#       ȷ��ÿ��Trim����Ľ�����ʽ�ǵ�һ�ģ��������֡�
#
#       ʾ����[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666) ++ Trim(727,1536)
#
#
#   3. ����������Ƶ�죬�õ���Ʒ��Ƶ�졣
#       ѹ����Ƶ�죬���߸���Trim�����Ժ㶨fps�����ʱ���������ü���Ƶ�졣
#
#   4. �Ը���Trim����ֱ𷴽�������AssumeFPS�趨ͳһ��֡�ʡ�
#       �� ���ݸ�����Ľ�����ʽ��Ӧ�÷������˾�
#       �� ��AssumeFPS�趨Ϊͳһ��֡�ʣ��е�Ƭ�λ���ţ��е�Ƭ�λ�����ţ�
#       �� ����������֮���Ϊ�õ��Ӻţ���UnalignedSplice������ƴ������
#
#       ʾ����[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666).Yadif(mode=3).AssumeFPS("ntsc_video") + Trim(727,1536).AssumeFPS("ntsc_video")
#
#
#   5. �����Ժ㶨֡��ѹ����Ƶ�졣
#
#
#   6. ��дtimecode�ļ���ͨ��timecode�ļ�ָ��ÿһ֡�Ĳ���֡�ʡ�
#
#       ʾ����[timecode.txt]
#           # timecode format v1
#           Assume 29.970030
#           0,431,59.940060
#           432,1241,29.970030
#
#       ��������һ��mkvmerge�ĵ��ж�Timecode file format v1 ��˵����
#           This format starts with the version line.
#           The second line declares the default number of frames per second.
#           All following lines contain three numbers separated by commas:
#               the start frame (0 is the first frame),
#               the end frame and the number of frames in this range.
#           The FPS is a floating point number with the dot '.' as the decimal point.
#           The ranges can contain gaps for which the default FPS is used.
#
#       �������ϵ�˵������������һ��timecode�ļ��е���������ε����ģ�
#
#           ��֪ƬԴ��֡��=30000/1001=29.970030��������ΪĬ��֡��
#           �������ˣ�Assume 29.970030
#
#           �׸�Ƭ�Σ�Trim(7451,7666)����216֡����Yadif(mode=3)���������õ�˫��֡����432֡��
#           �ó���Ʒ�ı����0~431��֡��֡����2*30000/1001=59.940060
#           �������ˣ�0,431,59.940060
#
#           �ڶ���Ƭ�Σ�Trim(727,1536)����810֡�������з���������Ʒ��Ȼ��810֡��
#           �ó���Ʒ�ı����432~1241��֡��֡����30000/1001=29.970030
#           �������ˣ�432,1241,29.970030
#
#
#   7. ��װ���õ�VFR��Ʒ��
#       �� ��mkvtoolnixGUI������Ƶ�죬�����������Ƶ�죬Ϊ������timecode�ļ���
#       �� ����������Ƶ�죬���������ķ�װ�������������֮�ࡣ
#       �� �ϳ�mkv�ļ������õ���ƷVFR��Ƶ��
#       ���⣬mp4��ʽ��VFR��װ��λ���������о�



# --- �����˹���дtimecode�ļ������� ---
#
#   ������Ĳ���6��������Լ��˹���дtimecode�ļ���������ᵽ��
#       �� ��Ҫ��Ϊȥ��������Ƶ����㹤��������Ч�ʵͣ�����������Ļ����׳�����
#       �� �������ĳһ���Ƶ������ݳ��˴�����������ݶ�Ҫ������������鷳�ˣ������ֻ�����µĴ�����
#       �� ����5��2�ķ�������ԭ֡������0.8�õ���������֡�������ܻ����С�������в���ȷ���õķ������˾�����ν���ȡ�ᡣ
#
#   ���ϼ�������Ϊ�����������У�ѹ����Ա�˹�ȥ��дtimecode�ļ�����������̫ʵ�ʿ��С�
#



# --- VFR-AutoTimecode ����˵�� ---
#
#   (������ô����̵棬���ڿ�ʼ����)
#
#   VFR-AutoTimecode ��һ��ʹ��avisynth�﷨��д�Ľű���
#   ��������дavisynth�ű���ƴ��֡�ʲ�ͬ��Ӱ��Ƭ������VFR��Ƶʱ��
#   ͨ������һ�׼��׵ĺ������ռ�timecode��Ϣ����ʵ���ɳ����дtimecode�ļ���
#   �Ӷ������˹���дtimecode�ļ���
#
#
#   ���ű��ṩ��3����Ҫ�ĺ�����
#
#       tcInit(clip src, float "default_fps")
#           �����ռ�ƬԴ�Ļ�����Ϣ����ʼ��timecode��Ϣ��
#           �ú�������ԭӰƬ
#           ����ʱ�����ڼ�����ƬԴ�󣬵���һ�α�������
#
#       tcAdd(clip c)
#           �����ռ�����Ƭ�ε�֡����֡����Ϣ��
#           �ú�����������AssumeFPS֮���ӰƬ���Դ��趨ͳһ��֡�ʡ�
#           ����ʱ������ÿһ����ɳ�Ʒ�ġ�֡�ʿ��ܲ�ͬ��Ƭ�ε���һ�α�������
#
#       tcWrite(clip c, string "filename")
#           ���ڽ�timecode����һ���������timecode�ļ���
#           �ú�������ԭӰƬ
#           ����ʱ�����ڽ����зֶ�ȫ��������tcAdd�Һϲ�����ӰƬ֮�󣬶Ժϲ��õ���ӰƬ����һ�α�������
#
#   ������Ĺ���ԭ���ǣ�ʹ��ȫ�ֱ�������¼timecode��Ϣ������ʹ��WriteFileStart�����timecode�ļ���
#
#
#   ͨ����avisynth�ű��е������������������Ϳ����ڽű����е�ͬʱ���Զ�����timecode�ļ���
#   ���棬������ν�VFR-AutoTimecodeӦ�õ�֮ǰ���ܵ�����VFR��Ƶ�Ĺ��������У�
#
#   �ڲ���1:
#       ��avs�ļ��м��ظ��ֲ��ʱ����VFR-AutoTimecode-1.3.avsi���롣
#       ����AudioDub�ϲ�����Ƶ����Ƶ֮����Ҫ�Ը�ӰƬ����һ��tcInit()�������Դ��ռ���Ƶ��Ļ�����Ϣ����ʼ��timecode��Ϣ��
#
#       ʾ����[Kimamani Arinomamani - vfr-test.avs]
#           LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#           LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#           Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\VFR-AutoTimecode-1.3.avsi")
#           v = DGSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#           a = WavSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#           AudioDub(v, a)
#           tcInit()
#
#   �ڲ���2:
#       �ޱ仯��
#
#   �ڲ���3:
#       �ޱ仯��
#
#   �ڲ���4:
#       ��Ϊÿ��Trim����Ӧ���˷�����֮����Ҫ����tcAdd()���Դ����ռ���Ƭ�ε�֡������֡����Ϣ��
#       ��������tcAdd�����Ժ󣬿��Խ�ԭ����AssumeFPS���ͳһȫ��ȥ������ΪtcAdd���Ӵ�����AssumeFPS��
#       �����е�Trim���䴦�����ƺ�����һ�У��Ժϲ��õ�ӰƬ����һ��tcWrite()���Դ˽��ռ�����timecode��Ϣһ���������timecode�ļ���
#
#       ʾ����[Kimamani Arinomamani - vfr-test.avs]
#           Trim(7451,7666).Yadif(mode=3).tcAdd() + Trim(727,1536).tcAdd()
#           tcWrite()
#
#   �ڲ���5:
#       �ޱ仯��
#
#   �ڲ���6:
#       timecode�ļ��ɱ��ű��Զ���д���ɡ�
#       ���㳢���ò�����Ԥ����avs������megui�ɹ���ȡ��avs�ļ�֮��
#       ���ڸ�avs�ļ�����Ŀ¼���ҵ�һ����-timecode_v1.txt��β���ļ��������Ǳ��ű��Զ���д������timecode�ļ���
#       ����㲻����Ҫÿ������avs������timecode�ļ������磬���Ѿ��õ�����Ҫ��timecode�ļ��ˣ�������ע�͵�tcWrite()��һ�С�
#
#       ���ɵ�timecode�ļ�����: [Kimamani Arinomamani - vfr-test.avs-auto-timecode_v1.txt]
#           # timecode format v1
#           # generated by [A.K.] Mikey's Fansub Utilities Pack - VFR-AutoTimecode 1.3
#           Assume 29.970030
#           0,431,59.940060
#           432,1241,29.970030
#
#   �ڲ���7:
#       �ޱ仯��



# --- CODE SAMPLES ---
#
#   ����AVS�ļ�ʾ��: [Kimamani Arinomamani - vfr-test.avs]
#
#       LoadPlugin("E:\program_media\DG2044\dgindexnv\DGDecodeNV.dll")
#       LoadCPlugin("E:\program_media\avisynth-plugin\yadif17\yadif.dll")
#       Import("E:\program_media\[A.K.] Mikey's Fansub Utilities Pack\avisynth_plugin\VFR-AutoTimecode-1.3.avsi")
#
#       v = DGSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani Arinomamani.dgi")
#       a = WavSource("H:\fansub-work\[����\[�浵\2013.11.20 Kimamani Arinomamani\src\Kimamani_Arinomamani--track02.wav").DelayAudio(0.000)
#       AudioDub(v, a)
#
#       tcInit()
#
#       Trim(7451,7666).Yadif(mode=3).tcAdd() + Trim(727,1536).tcAdd()
#
#       tcWrite()
#





global tc_is_inited = false
global tc_offset = -1
global tc_default_fps = 0
global tc_frame_counter = 0
global tc_appender = "#not yet ready..."

global tc_ENTER = """
"""

global tc_MSG_CALL_INIT_BEFORE_ADD = "�ڵ���tcAdd()֮ǰ�����ȵ���tcInit()"
global tc_MSG_CALL_INIT_BEFORE_WRITE = "�ڵ���tcWrite()֮ǰ�����ȵ���tcInit()"
global tc_MSG_FRAME_COUNT_NOT_CONSISTENT = "�ֶ�֡��֮����ӰƬ��֡����һ�¡���ȷ�����ӰƬ��ÿ���ֶζ�������һ��tcAdd()"


function tc_get_float_fps(val fps) {
    return Colorbars(512,384).AssumeFPS(fps).FrameRate()
}

function tcInit(clip src, val "default_fps") {

    global tc_is_inited = true
    global tc_offset = -1
    global tc_default_fps = Default(default_fps, src.FrameRate())
    global tc_frame_counter = 0

    format_line = "# timecode format v1"
    notice_line = "# generated by Mikey's Fansub Utilities Pack - VFR-AutoTimecode 1.3"
    assume_line = "Assume " + string(tc_get_float_fps(tc_default_fps), "%f")

    global tc_appender = format_line + tc_ENTER + notice_line + tc_ENTER + assume_line

    return src
}

function tcAdd(clip c) {

    Assert(tc_is_inited, tc_MSG_CALL_INIT_BEFORE_ADD)

    start = tc_offset + 1
    end = tc_offset + c.FrameCount()

    global tc_offset = end
    global tc_frame_counter = tc_frame_counter + c.FrameCount()

    line = string(start, "%0.0f") + "," + string(end, "%0.0f") + "," + string(c.FrameRate(), "%f")

    global tc_appender = tc_appender + tc_ENTER + line

    return c.AssumeFPS(tc_default_fps, sync_audio=false)
}


function tcWrite(clip c, string "filename") {

    Assert(tc_is_inited, tc_MSG_CALL_INIT_BEFORE_WRITE)
    Assert(tc_frame_counter == c.FrameCount(), tc_MSG_FRAME_COUNT_NOT_CONSISTENT)
    
    filename = Default(filename, ScriptName() + "-auto-timecode_v1.txt")
    WriteFileStart(c, filename, "tc_appender", append=false)

    return c
}