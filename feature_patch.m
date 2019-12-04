classdef feature_patch
  %feature_patch Object for image feature and corresponding patch
  
  properties
    visual_word
    patch
    feature
    flat_patch
    frame_num
  end
  
  methods
    function obj = feature_patch(patch, frame_num, feature)
      if nargin < 3
        frame_num = NaN;
        feature = NaN;
      end
      obj.patch = patch;
      obj.flat_patch = reshape(patch, 1, 25 * 25);
      obj.frame_num = frame_num;
      obj.feature = feature;
    end
    
    function patch = get_patch(obj)
      patch = obj.patch;
    end
    
    function visual_word = get_visual_word(obj)
      visual_word = obj.visual_word;
    end
    
    function obj = assign_visual_word(obj, visual_word) 
      %assign_visual_word Assign visual word to patch
      obj.visual_word = visual_word;
    end
  end
end

