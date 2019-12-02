clear
close all
imtool close all

global DEBUG
DEBUG = 0;
train_dir = "CarTrainImages";
test_dir = "CarTestImages";
results_dir = "results/";
harris_threshold = 1e4;
harris_window = 8;
clusters = 20;

%% Get images
train_imgs = get_images(train_dir);
test_imgs = get_images(test_dir);

%% Init Object Detection process

categorizer = detector(harris_threshold, harris_window, clusters, results_dir);

%% Perform training

categorizer = categorizer.init_training_stage(train_imgs);
categorizer = categorizer.apply_kmeans(clusters);
categorizer = categorizer.build_visual_vocab();
categorizer = categorizer.set_training_visual_words();
categorizer = categorizer.get_displacement_vectors();

% categorizer.debug_frames();

%% Perform Object Detection Tests

categorizer = categorizer.init_detection_stage(test_imgs);
categorizer = categorizer.set_testing_visual_words();
categorizer = categorizer.perform_hough_transform_voting();

%% Test detector
test_sample = 25;
categorizer.debug_accumulator(test_sample);    % Saves accumulator to file
categorizer.debug_detector(test_sample);       % Displays detector result

%% Utility Functions
function images = get_images(dir)
  if ~isfolder(dir)
    sprintf("Directory does not exist\n");
    return;
  end
  images = imageDatastore(dir);
end
