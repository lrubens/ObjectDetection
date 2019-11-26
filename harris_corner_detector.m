function corners = harris_corner_detector(image, threshold)
  global DEBUG
  k = .04;
  window = 13;
  [Ix, Iy] = imgradientxy(image);
  Ix_2 = Ix .^ 2;
  Iy_2 = Iy .^ 2;
  Ix_y = Ix .* Iy;
  Sx_2 = imgaussfilt(Ix_2, 2);
  Sy_2 = imgaussfilt(Iy_2, 2);
  Sx_y = imgaussfilt(Ix_y, 2);

  % Measure determinant of M at each pixel location
  det_M = (Sx_2 .* Sy_2) - (Sx_y .^2);

  % Measure trace of M at each pixel location
  trace_M = Sx_2 + Sy_2;

  % Measure R corner response
  R = det_M - k * (trace_M) .^ 2;

  % Harris corner detector
  nonmax = ordfilt2(R, window ^2, ones([window window]));
  corners = (R == nonmax) & (R > threshold);
  [row, col] = ind2sub(size(corners), find(corners >= 1));
  num_corners = length(row);
  corners = zeros(num_corners, 2);
  for i = 1:num_corners
    corners(i, 1) = row(i);
    corners(i, 2) = col(i);
  end
  if DEBUG == 1
%     display_corners(image, corners);
  end
end
