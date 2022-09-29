function [frames,descriptors,scalespace,difofg]=do_sift(file,varargin)
warning off all;
tic
%% 读取图片转换为灰度图
I=im2double(imread(file)) ;
if(size(I,3) > 1)
  I = rgb2gray( I ) ;
end

% 高斯金字塔由O组S层构成
S=3 ;
omin= 0 ;
%O=floor(log2(min(M,N)))-omin-4 ; % Up to 16x16 images
O = 4;

sigma0=1.6*2^(1/S) ;% 计算高斯卷积尺度的公式
sigmaN=0.5 ;
thresh = 0.2 / S / 2 ; % 0.04 / S / 2 ;
r = 18 ;

% 取特征点周围4×4个区域块，统计每小块内8个梯度方向，共4×4×8=128维
NBP = 4 ;
NBO = 8 ;
magnif = 3.0 ;

frames = [] ;
descriptors = [] ;

%% 用DoG构造尺度空间
% 进行高斯滤波平滑处理
scalespace = do_gaussian(I,sigmaN,O,S,omin,-1,S+1,sigma0) ;
% 对图像进行采样，得到不同尺度的图像
%构建相减尺度空间
difofg = do_diffofg(scalespace) ;


%% 在DOG中选取局部极值点
for o=1:scalespace.O      % 尺度空间由O组S层构成
  %  DOG octave 的局部极值检测
  % 每个像素点与二维图像空间和尺度空间邻域内的26个点进行比较，初步定位出关键点
    oframes1 = do_localmax(  difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
    oframes2 = do_localmax( -difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
	oframes = [oframes1 ,oframes2 ] ; 
	
    if size(oframes, 2) == 0
        continue;
    end
    
  % scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S)求的是当前高斯尺度，然后根据当前高斯尺度计算高斯模版半径　
  % *NBP是求得高斯卷积核的模版的大小，再除以2就求得该模版的半径
    rad = magnif * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) * NBP / 2 ;%rad为高斯模版半径

  %% 移除靠近边界的关键点，过滤除能量比较弱的关键点以及错误定位的关键点，筛选出最终的稳定的特征点
    sel=find(...
      oframes(1,:)-rad >= 1                     & ...
      oframes(1,:)+rad <= size(scalespace.octave{o},2) & ...　　　　　%图像深度
      oframes(2,:)-rad >= 1                     & ...
      oframes(2,:)+rad <= size(scalespace.octave{o},1)     ) ;       %图像宽度

    oframes=oframes(:,sel) ;%把不是靠近边界点的极值点重新放入oframes中
		

  % 额外优化：精简局部, 阈值强度和移除边缘关键点
   	oframes = do_extrefine(...
 		oframes, ...
 		difofg.octave{o}, ...
 		difofg.smin, ...
 		thresh, ...
 		r) ;

    
    if size(oframes, 2) == 0
        continue;
    end
    
    
%% 计算关键点方向
	oframes = do_orientation(...
		oframes, ...
		scalespace.octave{o}, ...
		scalespace.S, ...
		scalespace.smin, ...
		scalespace.sigma0 ) ;

%% 生成关键点描述子	
% 将不同组的坐标还原回到第一组图像中去
	x     = 2^(o-1+scalespace.omin) * oframes(1,:) ;
	y     = 2^(o-1+scalespace.omin) * oframes(2,:) ;
	sigma = 2^(o-1+scalespace.omin) * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) ;	%图像的尺度	
	frames = [frames, [x(:)' ; y(:)' ; sigma(:)' ; oframes(4,:)] ] ;
		
	sh = do_descriptor(scalespace.octave{o}, ...
                    oframes, ...
                    scalespace.sigma0, ...
                    scalespace.S, ...
                    scalespace.smin, ...
                    'Magnif', magnif, ...
                    'NumSpatialBins', NBP, ...
                    'NumOrientBins', NBO) ;
   % 以特征点为中心根据主方向取一个16×16的窗口
   % 将窗口主方向旋转至水平
   % 为每个像素计算边缘方向，为边缘方向建立直方图
   % 计算每个单元格的方向直方图，4*4个单元格 * 8 方向 = 128 维描述符
   % 将该128维向量归一化到单位长度
    
    descriptors = [descriptors, sh] ;%每一组计算描述子向量后补充到descriptors数组中   
    
end 
fprintf('SIFT特征提取过程：');
toc
fprintf('SIFT关键点总数: %d \n\n\n', size(frames,2)) ;
