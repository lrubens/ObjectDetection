function display_corners(image, corners)
  figure;
  imshow(image);
  hold on;
  plot(corners(:, 2), corners(:, 1), 'g+');
%   hold off;
end
