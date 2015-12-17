%% img 1 test case

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


%% img 2 test case (faster)

% im2
% num of images
num_img = 23;
% this exists because of the camera img naming
init_img = 658;
% allocate array to run faster
i_array = zeros(340,407,3, num_img);
% read all images
for i=0:num_img-1
    im = im2double(imread(strcat('im2/IMG_0', int2str(init_img+i), '.JPG')));
    i_array(:,:,:,i+1) = imcrop(im, [119.5 144.5 406 339]);
end