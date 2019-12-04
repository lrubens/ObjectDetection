clear
close all
imtool close all

global DEBUG
DEBUG = 0;
train_dir = "CarTrainImages";
test_dir = "CarTestImages";
ground_truth = "GroundTruth/CarsGroundTruthBoundingBoxes.mat";

%% Set Detector Parameters

harris_threshold = 5e7;
harris_window = 9;
num_clusters = 50;
ssd_threshold = 2;
hough_vote_below_threshold = 1;

%% Get images
train_imgs = get_images(train_dir);
test_imgs = get_images(test_dir);

%% Init Object Detection process

categorizer = detector(harris_threshold, harris_window, num_clusters, ground_truth);

%% Perform training

categorizer = categorizer.init_training_stage(train_imgs);
categorizer = categorizer.apply_kmeans(num_clusters);
categorizer = categorizer.build_visual_vocab();
categorizer = categorizer.set_training_visual_words(ssd_threshold);
categorizer = categorizer.get_displacement_vectors();

if DEBUG == 1
  categorizer.debug_frames();
end

%% Perform Object Detection Tests

categorizer = categorizer.init_detection_stage(test_imgs);
categorizer = categorizer.set_testing_visual_words(ssd_threshold);
categorizer = categorizer.perform_hough_transform_voting(hough_vote_below_threshold);
categorizer = categorizer.compute_accuracy();

%% Test detector for sample image
test_sample = 100;
categorizer.debug_accumulator(test_sample);    % Saves accumulator to file
categorizer.display_bounding_box(test_sample);   % Displays bounding box for one test sample
categorizer.debug_detector(test_sample);       % Displays detector result

%% Debug bounding boxes for test images
% Careful with this one as it may spawn 100 figures
if DEBUG == 1
  figure;
  categorizer.debug_bounding_box();
end

%% Utility Functions
function images = get_images(dir)
  if ~isfolder(dir)
    sprintf("Directory does not exist\n");
    return;
  end
  images = imageDatastore(dir);
end
