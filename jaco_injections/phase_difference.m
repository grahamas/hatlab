function diff = phase_difference( a, b )
% Calculate a - b, accounting for circularity. ONLY TAKES VECTORS
a = a(:); b = b(:);
possible_diffs = [a - b,...
                  a + ((2*pi)-b),...
                  -(b+((2*pi)-a))];
[~, min_dx] = min(abs(possible_diffs),[],2);
diff = mean(diag(possible_diffs(:,min_dx)));

end

