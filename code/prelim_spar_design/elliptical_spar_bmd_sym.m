%% Givens
syms m W n b y positive real;
C = 4/sym(pi) * n * W / b;

%% Define lift dist and shear as functions so integration is more precise
l_y(y) = C*sqrt(1-(2.*y./b).^2);

% shear BC: no shear at end of cantilever
V_y(y) = simplify(-int(l_y, y, 0, y) + int(l_y, y, 0, b/2), "Steps", 10);

% moment BC: no moment at end of cantilever
M_y(y) = simplify(-int(V_y, y, 0, y) + int(V_y, y, 0, b/2), "Steps", 10);

disp(M_y(0))