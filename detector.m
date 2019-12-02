classdef detector
  %detector Class for object category detector
  %   Comprises all the project steps

  properties
    training_images
    test_images
    train_num_frames
    test_num_frames
    train_total_features
    test_total_features
    patches
    patches_obj
    visual_vocab
    displacement_vectors
    num_clusters
    cluster_idx
    centroids
    harris_threshold
    harris_window
    accumulator_images
    results_dir
  end

  methods
    function obj = detector(harris_threshold, harris_window, num_clusters, results_dir)
      %detector Construct an instance of this class
      %   Initializes class
      obj.harris_threshold = harris_threshold;
      obj.harris_window = harris_window;
      obj.num_clusters = num_clusters;
      obj.train_total_features = 0;
      obj.test_total_features = 0;
      obj.results_dir = results_dir;
    end
    
    function obj = init_training_stage(obj, training_images)
      obj.train_num_frames = length(training_images.Files);
      [row1, col1, ~] = size(read(training_images));
      size1 = [row1, col1];

      for i = 1:obj.train_num_frames
        imframe = frame(readimage(training_images, i), size1, i);
        imframe = imframe.set_corners(obj.harris_threshold);
        imframe = imframe.set_patches();
        obj.patches = vertcat(obj.patches, imframe.get_patches());
        obj.train_total_features = obj.train_total_features + length(imframe.get_patches());
        obj.patches_obj = [obj.patches_obj; imframe.get_patch_objs()];
        obj.training_images = [obj.training_images; imframe];
      end
    end

    function obj = add_patches(obj, patches)
      obj.patches = uint8(patches);
    end

    function obj = apply_kmeans(obj, clusters)
      if nargin == 0
        clusters = obj.num_clusters;
      end
      disp("Applying K-Means clustering method on image patches...");
      stream = RandStream('mlfg6331_64');
      options = statset('UseParallel',1,'UseSubstreams',1,'Streams',stream);
      [obj.cluster_idx, obj.centroids] = kmeans(obj.patches, clusters, 'Options', options, 'MaxIter', 10000, 'Display', 'final'); %, 'distance', 'cosine');
    end

    function obj = build_visual_vocab(obj)
%       figure;
      for i = 1:obj.num_clusters
%         imshow(imresize(uint8(reshape(obj.centroids(i, :), 25, 25)), 4));
        index = find(obj.cluster_idx==i);
        % Assign representative for each visual word in visual vocab
        centroid = reshape(obj.centroids(i, :), 25, 25);
        centroid_obj = feature_patch(centroid);
%         obj.visual_vocab = [obj.visual_vocab; obj.patches_obj(index(1))];
        obj.visual_vocab = [obj.visual_vocab; centroid_obj];
      end
    end

    function obj = set_training_visual_words(obj)
%       index = 1;
%       figure;
      for i = 1:obj.train_num_frames
        obj.training_images(i) = obj.training_images(i).set_visual_word(obj.visual_vocab);
%         for j = 1:obj.training_images(i).num_features
%           obj.training_images(i) = obj.training_images(i).assign_word(j, obj.cluster_idx(index));
%           index = index + 1;
%         end
      end
    end

    function obj = get_displacement_vectors(obj)
%       figure;
      obj.displacement_vectors = displacements.empty(30, 0);
      for i = 1:obj.num_clusters
        obj.displacement_vectors(i) = displacements(i);
      end
      for i = 1:obj.train_num_frames
        centroid = obj.training_images(i).get_centroid();
        for j = 1:obj.training_images(i).num_features
          feature = obj.training_images(i).patches(j).feature;
          visual_word = obj.training_images(i).patches(j).visual_word;
          displacement = feature - centroid;
          obj.displacement_vectors(visual_word) = obj.displacement_vectors(visual_word).add_displacement_vector(displacement);
        end
      end
    end

    function obj = init_detection_stage(obj, test_images)
      obj.test_num_frames = length(test_images.Files);
      [row2, col2, ~] = size(read(test_images));
      size2 = [row2, col2];
      for i = 1:obj.test_num_frames
        imframe = frame(readimage(test_images, i), size2, i);
        imframe = imframe.set_corners(obj.harris_threshold);
        imframe = imframe.set_patches();
        obj.test_total_features = obj.test_total_features + length(imframe.get_patches());
        obj.test_images = [obj.test_images; imframe];
      end
    end
    
    function obj = set_testing_visual_words(obj)
      for i = 1:obj.test_num_frames
        obj.test_images(i) = obj.test_images(i).set_visual_word(obj.visual_vocab);
      end
    end
    
    function debug_frames(obj)
      figure;
      for i = 1:obj.test_num_frames
        frame = obj.test_images(i);
        for j = 1:obj.test_images(i).num_features
          visual_word = frame.get_feature_obj(j).get_visual_word();
          imshowpair(imresize(frame.get_feature_patch(j), 4), imresize(obj.visual_vocab(visual_word).get_patch(), 4), 'montage');
        end
      end
    end
    
    function obj = perform_hough_transform_voting(obj)
      for i = 1:obj.test_num_frames
        im_size = obj.test_images(i).size;
        obj.test_images(i).accumulator = uint8(zeros(im_size));
        for j = 1:obj.test_images(i).num_features
          feature_patch = obj.test_images(i).patches(j);
          visual_word = feature_patch.visual_word;
          visual_vocab_entry = obj.displacement_vectors(visual_word).vectors;
          feature = obj.test_images(i).get_feature(j);
          visual_vocab_size = size(visual_vocab_entry, 1);
          for k = 1:visual_vocab_size
            displacement_vector = obj.displacement_vectors(visual_word).get_displacement_vector(k);
            vote = feature - displacement_vector;
            if vote(1)>0 && vote(1)<=im_size(1) && vote(2)>0 && vote(2)<=im_size(2)
              obj.test_images(i).accumulator(vote(1), vote(2)) = obj.test_images(i).accumulator(vote(1), vote(2)) + 1;
            end
          end
        end
      end
    end
    
    function debug_detector(obj, sample)
      max_value = max(max(obj.test_images(sample).accumulator));
      [x, y] = find(obj.test_images(sample).accumulator == max_value);
      display_corners(obj.test_images(sample).get_image(), [x, y]);
    end
    
    function debug_accumulator(obj, sample)
      max_value = double(max(max(obj.test_images(sample).accumulator)));
      scaled_accumulator = double(obj.test_images(sample).accumulator) ./ max_value;
      resized_accumulator = imresize(scaled_accumulator, 4);
%       figure;
%       imshow(resized_accumulator);
%       title('Sample accumulator array for test_image' + num2str(sample));
      imwrite(resized_accumulator, obj.results_dir + 'accumulator_frame' + num2str(sample) + '.jpg');
    end
  end
end
