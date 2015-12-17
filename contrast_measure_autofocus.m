clear all; clc;
%% reading the images
% to change the image (test case) replace the code in this section for the
% one in test.m


% im1
% num of images
num_img = 33;
% this exists because of the camera img naming
init_img = 623;
% allocate array to run faster
i_array = zeros(600,800,3, num_img);
% read all images
for i=0:num_img-1
    i_array(:,:,:,i+1) = im2double(imread(strcat('im1/IMG_0', int2str(init_img+i), '.JPG')));
end

%% first try: standard deviation

max_std = 0;
max_index_1 = 0;
for i=1:num_img
    current_img = i_array(:,:,:,i);
    img_hsv = rgb2hsv(current_img);
    %intensity = current_img(:,:,1) + current_img(:,:,2) + current_img(:,:,3);
    intensity = img_hsv(:,:,3);
    past_max = max_std;
    max_std = max(max_std, std(intensity(:)));
    if(past_max < max_std)
        max_index_1 = i;
    end
end

%% second try: standard deviation with noise filter

g_filt = fspecial('gaussian', [10 10], .3);
max_std = 0;
max_index_2 = 0;
for i=1:num_img
    current_img = i_array(:,:,:,i);
    current_img = imfilter(current_img, g_filt, 'same');   
    img_hsv = rgb2hsv(current_img);
    %intensity = current_img(:,:,1) + current_img(:,:,2) + current_img(:,:,3);
    intensity = img_hsv(:,:,3);
    past_max = max_std;
    max_std = max(max_std, std(intensity(:)));
    if(past_max < max_std)
        max_index_2 = i;
    end
end

%% third try: standard deviation of histogram with noise filter


min_std = Inf;
max_index_3 = 0;
for i=1:num_img
    current_img = i_array(:,:,:,i);
    current_img = imfilter(current_img, g_filt, 'same');   
    img_hsv = rgb2hsv(current_img);
    %intensity = current_img(:,:,1) + current_img(:,:,2) + current_img(:,:,3);
    intensity = imhist(img_hsv(:,:,3));
    past_min = min_std;
    min_std = min(min_std, std(intensity(:)));
    if(past_min > min_std)
        max_index_3 = i;
    end
end

%% fourth try: standart deviation along axes with noise filter

max_std = 0;
max_index_4 = 0;
for i=1:num_img
    current_img = i_array(:,:,:,i);
    current_img = imfilter(current_img, g_filt, 'same');   
    img_hsv = rgb2hsv(current_img);
    %intensity = current_img(:,:,1) + current_img(:,:,2) + current_img(:,:,3);
    intensity = img_hsv(:,:,3);
    past_max = max_std;
    max_std = max(max_std, sum(std(intensity,0,1)) + sum(std(intensity,0,2)));
    if(past_max < max_std)
        max_index_4 = i;
    end
end

%% fifth try: CMSL (Contrast Measure based on Squared Laplacian)

max_l = 0;
max_index_5 = 0;
ls = zeros(num_img,1);
for i=1:num_img
    current_img = i_array(:,:,:,i);
    current_img = imfilter(current_img, g_filt, 'same');   
    img_hsv = rgb2hsv(current_img);
    %intensity = current_img(:,:,1) + current_img(:,:,2) + current_img(:,:,3);
    intensity = img_hsv(:,:,3);
    past_max = max_l;
    avg = mean(mean(intensity));
    g = abs(intensity - [intensity(:,2:end), ones(size(intensity,1),1)*avg]);
    g = g+abs(intensity - [ones(size(intensity,1),1)*avg, intensity(:,1:end-1)]);
    g = g+abs(intensity - [intensity(2:end,:);ones(1, size(intensity,2))*avg]);
    g = g+abs(intensity - [ones(1, size(intensity,2))*avg; intensity(1:end-1,:)]);
    
    l = sum(sum(g));
    ls(i) = l;
    max_l = max(max_l, l);
    if(past_max < max_l)
        max_index_5 = i;
    end
end

%% print results

% print all pictures
m = ceil(sqrt(num_img));
n = ceil(num_img/m);
figure
for i=1:num_img
    subplot(m,n,i)
    imshow(i_array(:,:,:,i))
end

% print the result for each algorithm
figure
subplot(3,2,1), imshow(i_array(:,:,:,max_index_1))
title(strcat('Standard Deviation: ', int2str(max_index_1)))
subplot(3,2,2), imshow(i_array(:,:,:,max_index_2))
title(strcat('Standard Deviation with noise filter: ', int2str(max_index_2)))
subplot(3,2,3), imshow(i_array(:,:,:,max_index_3))
title(strcat('Standard Deviation of Histogram with noise filter: ', int2str(max_index_3)))
subplot(3,2,4), imshow(i_array(:,:,:,max_index_4))
title(strcat('Standard Deviation along Axes with noise filter: ', int2str(max_index_4)))
subplot(3,2,5), imshow(i_array(:,:,:,max_index_5))
title(strcat('CMSL: ', int2str(max_index_5)))
subplot(3,2,6), plot(ls/size(intensity,1)/size(intensity,2))
title('CMSL contrast graph')
