arr = readmatrix("Mingde_dragpolar_noCD0.csv");

CD = arr(:, 1);
CL = arr(:, 2);

AR = 5.106;

e_invisc = CL.^2 ./ (CD .* pi .* AR);