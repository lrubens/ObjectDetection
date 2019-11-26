classdef frame
  %frame Individual frames of training or test set
  
  properties
    image
    size
    corners
    patches
  end
  
  methods
    function obj = frame(image,size)
      %frame Construct an instance of this class
      %   Constructor takes in image and size of the image
      obj.image = image;
      obj.size = size;
%       obj.patches = [];
    end
    
    function gray_img = get_gray(obj)
      %get_gray Gets gray scale of image
      %   Converts RGB image to grayscale image
      gray_img = rgb2gray(obj.image);
    end
    
    function img = get_image(obj)
      img = obj.image;
    end
    
    function obj = set_corners(obj, threshold)
      %set_corners Finds corners of image
      %   Gets corners using Harris Corner Detector
      obj.corners = harris_corner_detector(obj.image, threshold);
    end
    
    function obj = set_patches(obj)
      for i = 1:length(obj.corners)
        location = obj.corners(i,:);
        patch = get_window(obj.image, location, 25);
        imshow(uint8(patch));
        obj.patches = cat(3, obj.patches, patch);
      end
    end
  end
end

