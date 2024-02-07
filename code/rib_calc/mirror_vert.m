function mirrored = mirror_vert(vec, flp)
% Mirrors a vector, ignoring the first (zeroed) value.

if nargin < 2
    flp = false;
end

if flp
    mirrored = [flipud(-vec(2:end)); vec];
else
    mirrored = [flipud(vec(2:end)); vec];
end
end