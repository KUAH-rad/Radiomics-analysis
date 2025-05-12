function [stat, status, msg] = Calc_Shape(mask, mask_res)
% By Bumwoo Park
% Update: 2018-01-23
% E-mail: julius0628@gmail.com
% Plz, Do not modify codes and distribute codes without my permission.

stat = [];
status = 1;
msg = '';


mask(isnan(mask))=0;
[Surface, labels] = imSurface(mask, mask_res);
not_a_zero_pt = mask>0;
counts = sum(not_a_zero_pt(:));
Volume = counts * prod(mask_res);

stat.Compt1 = Volume / (sqrt(pi) * (Surface .^ (2/3)));
stat.Compt2 = 36 * pi * (Surface.^2) / (Volume.^3);
stat.Dispro = Surface / ((6 * sqrt(pi) * Volume).^(2/3));
stat.Sphe = (6 * pi.^2 * Volume) .^ (2/3) / Surface;
stat.Surface = Surface;
stat.SVratio = Surface / Volume;
stat.Volume = counts * prod(mask_res);
end