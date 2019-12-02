classdef feature_patch
  %patch Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    visual_word
    patch
    feature
    flat_patch
    frame_num
  end
  
  methods
    function obj = feature_patch(patch, frame_num, feature)
      %UNTITLED2 Construct an instance of this class
      %   Detailed explanation goes here
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
      %assign_visual_word Summary of this method goes here
      %   Detailed explanation goes here
      obj.visual_word = visual_word;
    end
  end
end

