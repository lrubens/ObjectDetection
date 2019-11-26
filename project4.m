clear
close all
imtool close all

global DEBUG
DEBUG = 1;
train_dir = "CarTrainImages";
test_dir = "CarTestImages";

train_imgs = get_images(train_dir);
test_imgs = get_images(test_dir);
train_num_frames = length(train_imgs.Files);
test_num_frames = length(test_imgs.Files);
[row1, col1, ~] = size(read(train_imgs));
[row2, col2, ~] = size(read(test_imgs));
size1 = [row1, col1];

harris_threshold = 1e6;

train_corners = [];
video = [];
figure;
for i = 1:train_num_frames
  imframe = frame(readimage(train_imgs, i), size1);
  imframe = imframe.set_corners(harris_threshold);
  imframe = imframe.set_patches();
  video = [video; imframe];
end

play_video(video);


%% Utility Functions

% Read images from directory
function images = get_images(dir)
  if ~isfolder(dir)
    sprintf("Directory does not exits\n");
    return;
  end
  images = imageDatastore(dir);
end

%% Debugging functions
function play_video(video)
  num_frames = length(video);
  figure;
  for i = 1:100
    imshow(video(i, 1).get_image());
  end
end
