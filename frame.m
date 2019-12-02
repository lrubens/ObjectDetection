classdef frame
  %frame Individual frames of training or test set
  
  properties
    image
    frame_num
    size
    corners
    num_features
    patches
    displacement
    accumulator
    accumulator_max
  end
  
  methods
    function obj = frame(image, size, frame_num)
      %frame Construct an instance of this class
      %   Constructor takes in image and size of the image
      obj.image = image;
      obj.size = size;
      obj.frame_num = frame_num;
%       obj.patches = [];
    end
    
    function img = get_image(obj)
      img = obj.image;
    end
    
    function obj = set_corners(obj, threshold)
      %set_corners Finds corners of image
      %   Gets corners using Harris Corner Detector
      window = 3;
      features = harris_corner_detector(obj.image, threshold, window);
%       features = detectHarrisFeatures(obj.image);
      obj.corners = features;
%       display_corners(obj.image, features);
    end
    
    function obj = set_patches(obj)
      %set_patches Create patches from corners
      %   Creates 25 by 25 patch around each corner
      for i = 1:length(obj.corners)
        location = round(obj.corners(i,:));
        patch = get_window(obj.image, location, 25);
        if isnan(patch)
          continue;
        end
        patch_obj = feature_patch(patch, obj.frame_num, location);
        obj.patches = [obj.patches; patch_obj];
      end
      obj.num_features = length(obj.patches);
    end
    
    function flat_patches = get_patches(obj)
      %get_patches Get flat patches
      %   Gets all patches in frame reshaped to 1D
      flat_patches = [];
      for i = 1:obj.num_features
        flat_patches = vertcat(flat_patches, obj.patches(i).flat_patch);
      end
    end
    
    function patch_obj = get_patch_objs(obj)
      %get_patch_objs Get patch objects
      patch_obj = obj.patches;
    end
    
    function centroid = get_centroid(obj)
      centroid = round(obj.size / 2);
    end
    
    function patch = get_feature_patch(obj, index)
      patch = obj.patches(index).get_patch();
    end
    
    function patch_obj = get_feature_obj(obj, index)
      patch_obj = obj.patches(index);
    end
    
    function features = get_features(obj)
      features = [];
      for i = 1:obj.num_features
        features = [features; obj.patches(i).feature];
      end
    end
    
    function feature = get_feature(obj, index)
      feature = obj.patches(index).feature;
    end
    
    function obj = assign_word(obj, index, word)
      obj.patches(index) = obj.patches(index).assign_visual_word(word);
    end
    
    function obj = set_visual_word(obj, words)
      %set_visual_word Assigns each local patch with visual word based on
      %which visual word is closest based on SSD
      for i = 1:obj.num_features
        temp_ssd = inf;
        temp_match = 0;
        for j = 1:length(words)
          ssd = get_ssd(obj.patches(i).get_patch(), words(j).get_patch());
          if ssd < temp_ssd
            temp_ssd = ssd;
            temp_match = j;
          end
        end
%         imshowpair(imresize(obj.patches(i).get_patch(), 4), imresize(words(temp_match).get_patch(), 4), 'montage');
        obj.patches(i) = obj.patches(i).assign_visual_word(temp_match);
      end
    end
  end
end

