function window = get_window(image, location, windowsize)
  % Getting window size around corner
  row = location(1);
  col = location(2);
  image = double(image);
  offset = floor(windowsize / 2);
  image = padarray(image, [offset offset], 0);
  row = row + offset;
  col = col + offset;
  window = image(row - offset: row + offset, col - offset: col + offset);
end


