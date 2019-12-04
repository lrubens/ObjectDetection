classdef displacements
  %displacements Object for storing displacement vectors for a specific
  %visual word
  
  properties
    visual_word
    vectors
  end
  
  methods
    function obj = displacements(visual_word)
      if nargin == 0
        obj.visual_word = 0;
      else
        obj.visual_word = visual_word;
      end
    end
    
    function obj = add_displacement_vector(obj,vector)
      obj.vectors = [obj.vectors; vector];
    end
    
    function vector = get_displacement_vector(obj, index)
      vector = obj.vectors(index, :);
    end
  end
end

