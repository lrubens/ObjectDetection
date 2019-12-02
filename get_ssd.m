function ssd = get_ssd(window, template)
  window = double(window);
  template = double(template);
  window = window - mean2(window);
  template = template - mean2(template);
  normal1 = sqrt(sum(sum(window.^2)));
  normal2 = sqrt(sum(sum(template.^2)));
  normalized_window = window / normal1;
  normalized_template = template / normal2;
%   normalized_window = window;
%   normalized_template = template;
  ssd = sum(sum((normalized_window - normalized_template) .^ 2));
end
