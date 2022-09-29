function [frames,descriptors,scalespace,difofg]=do_sift(file,varargin)
warning off all;
tic
%% ��ȡͼƬת��Ϊ�Ҷ�ͼ
I=im2double(imread(file)) ;
if(size(I,3) > 1)
  I = rgb2gray( I ) ;
end

% ��˹��������O��S�㹹��
S=3 ;
omin= 0 ;
%O=floor(log2(min(M,N)))-omin-4 ; % Up to 16x16 images
O = 4;

sigma0=1.6*2^(1/S) ;% �����˹����߶ȵĹ�ʽ
sigmaN=0.5 ;
thresh = 0.2 / S / 2 ; % 0.04 / S / 2 ;
r = 18 ;

% ȡ��������Χ4��4������飬ͳ��ÿС����8���ݶȷ��򣬹�4��4��8=128ά
NBP = 4 ;
NBO = 8 ;
magnif = 3.0 ;

frames = [] ;
descriptors = [] ;

%% ��DoG����߶ȿռ�
% ���и�˹�˲�ƽ������
scalespace = do_gaussian(I,sigmaN,O,S,omin,-1,S+1,sigma0) ;
% ��ͼ����в������õ���ͬ�߶ȵ�ͼ��
%��������߶ȿռ�
difofg = do_diffofg(scalespace) ;


%% ��DOG��ѡȡ�ֲ���ֵ��
for o=1:scalespace.O      % �߶ȿռ���O��S�㹹��
  %  DOG octave �ľֲ���ֵ���
  % ÿ�����ص����άͼ��ռ�ͳ߶ȿռ������ڵ�26������бȽϣ�������λ���ؼ���
    oframes1 = do_localmax(  difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
    oframes2 = do_localmax( -difofg.octave{o}, 0.8*thresh, difofg.smin  ) ;
	oframes = [oframes1 ,oframes2 ] ; 
	
    if size(oframes, 2) == 0
        continue;
    end
    
  % scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S)����ǵ�ǰ��˹�߶ȣ�Ȼ����ݵ�ǰ��˹�߶ȼ����˹ģ��뾶��
  % *NBP����ø�˹����˵�ģ��Ĵ�С���ٳ���2����ø�ģ��İ뾶
    rad = magnif * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) * NBP / 2 ;%radΪ��˹ģ��뾶

  %% �Ƴ������߽�Ĺؼ��㣬���˳������Ƚ����Ĺؼ����Լ�����λ�Ĺؼ��㣬ɸѡ�����յ��ȶ���������
    sel=find(...
      oframes(1,:)-rad >= 1                     & ...
      oframes(1,:)+rad <= size(scalespace.octave{o},2) & ...����������%ͼ�����
      oframes(2,:)-rad >= 1                     & ...
      oframes(2,:)+rad <= size(scalespace.octave{o},1)     ) ;       %ͼ����

    oframes=oframes(:,sel) ;%�Ѳ��ǿ����߽��ļ�ֵ�����·���oframes��
		

  % �����Ż�������ֲ�, ��ֵǿ�Ⱥ��Ƴ���Ե�ؼ���
   	oframes = do_extrefine(...
 		oframes, ...
 		difofg.octave{o}, ...
 		difofg.smin, ...
 		thresh, ...
 		r) ;

    
    if size(oframes, 2) == 0
        continue;
    end
    
    
%% ����ؼ��㷽��
	oframes = do_orientation(...
		oframes, ...
		scalespace.octave{o}, ...
		scalespace.S, ...
		scalespace.smin, ...
		scalespace.sigma0 ) ;

%% ���ɹؼ���������	
% ����ͬ������껹ԭ�ص���һ��ͼ����ȥ
	x     = 2^(o-1+scalespace.omin) * oframes(1,:) ;
	y     = 2^(o-1+scalespace.omin) * oframes(2,:) ;
	sigma = 2^(o-1+scalespace.omin) * scalespace.sigma0 * 2.^(oframes(3,:)/scalespace.S) ;	%ͼ��ĳ߶�	
	frames = [frames, [x(:)' ; y(:)' ; sigma(:)' ; oframes(4,:)] ] ;
		
	sh = do_descriptor(scalespace.octave{o}, ...
                    oframes, ...
                    scalespace.sigma0, ...
                    scalespace.S, ...
                    scalespace.smin, ...
                    'Magnif', magnif, ...
                    'NumSpatialBins', NBP, ...
                    'NumOrientBins', NBO) ;
   % ��������Ϊ���ĸ���������ȡһ��16��16�Ĵ���
   % ��������������ת��ˮƽ
   % Ϊÿ�����ؼ����Ե����Ϊ��Ե������ֱ��ͼ
   % ����ÿ����Ԫ��ķ���ֱ��ͼ��4*4����Ԫ�� * 8 ���� = 128 ά������
   % ����128ά������һ������λ����
    
    descriptors = [descriptors, sh] ;%ÿһ����������������󲹳䵽descriptors������   
    
end 
fprintf('SIFT������ȡ���̣�');
toc
fprintf('SIFT�ؼ�������: %d \n\n\n', size(frames,2)) ;
