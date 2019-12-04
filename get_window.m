function window = get_window(image, location, windowsize)
  % Getting window size around corner
  row = location(1);
  col = location(2);
  image = double(image);
  imsize = size(image);
  offset = floor(windowsize / 2);
  row_low_bound = row - offset;
  row_upper_bound = row + offset;
  col_low_bound = col - offset;
  col_upper_bound = col + offset;
  if row_low_bound >= 1 && row_upper_bound < imsize(1) && col_low_bound >= 1 && col_upper_bound < imsize(2)
    window = image(row - offset: row + offset, col - offset: col + offset);
  else
    window = NaN;
  end
end


