classdef displacements
  %UNTITLED4 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    visual_word
    vectors
  end
  
  methods
    function obj = displacements(visual_word)
      %UNTITLED4 Construct an instance of this class
      %   Detailed explanation goes here
      if nargin == 0
        obj.visual_word = 0;
      else
        obj.visual_word = visual_word;
      end
    end
    
    function obj = add_displacement_vector(obj,vector)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      obj.vectors = [obj.vectors; vector];
    end
    
    function vector = get_displacement_vector(obj, index)
      vector = obj.vectors(index, :);
    end
  end
end

