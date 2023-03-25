% 3SK3 Project 3
% Abdulrahman Hamideh - 400170395 - hamideha

training_img = double(imread("Training Images/training_image.jpg"));

r = training_img(:,:,1);
g = training_img(:,:,2);
b = training_img(:,:,3);

r_padded = padarray(r, [2 2], 'symmetric', 'both');
g_padded = padarray(g, [2 2], 'symmetric', 'both');
b_padded = padarray(b, [2 2], 'symmetric', 'both');

r = r(:);
g = g(:);
b = b(:);

r_patch = im2col(r_padded, [5,5]);
g_patch = im2col(g_padded, [5,5]);
b_patch = im2col(b_padded, [5,5]);

[Ag_rggb, Ab_rggb] = rggb(r_patch, g_patch, b_patch, g, b);
[Ar_gbrg, Ab_gbrg] = gbrg(r_patch, g_patch, b_patch, r, b);
[Ar_grbg, Ab_grbg] = grbg(r_patch, g_patch, b_patch, r, b);
[Ar_bggr, Ag_bggr] = bggr(r_patch, g_patch, b_patch, r, g);

img_i = imread("testing_image.jpeg");
img = im2double(img_i);
[m, n, z] = size(img);

bayer_img = im2double(bayer(img, "bggr"));
bayer_img = padarray(bayer_img, [3 3], 'symmetric', 'both');
bayer_img(end - 2, :) = []; bayer_img(:, end - 2) = [];
bayer_img(3, :) = []; bayer_img(:, 3) = [];

% Assume BGGR Bayer filter
final_r = zeros(m, n); 
final_r(2:2:end, 2:2:end) = img(2:2:end, 2:2:end, 1);
final_g = zeros(m, n); 
final_g(1:2:end, 2:2:end) = img(1:2:end, 2:2:end, 2);
final_g(2:2:end, 1:2:end) = img(2:2:end, 1:2:end, 2);
final_b = zeros(m, n); 
final_b(1:2:end, 1:2:end) = img(1:2:end, 1:2:end, 3);

for row = 3:m + 2
    for col = 3:n + 2
        img_mono = bayer_img(row - 2:row + 2, col - 2:col + 2);
        img_mono = img_mono(:);
        if mod(row, 2) && mod(col, 2)
            final_g(row - 2, col - 2) = Ag_bggr'*img_mono;
            final_r(row - 2, col - 2) = Ar_bggr'*img_mono;
        elseif ~mod(row, 2) && ~mod(col, 2)
            final_b(row - 2, col - 2) = Ab_rggb'*img_mono;
            final_g(row - 2, col - 2) = Ag_rggb'*img_mono;
        elseif mod(row, 2) && ~mod(col, 2)
            final_b(row - 2, col - 2) = Ab_gbrg'*img_mono;
            final_r(row - 2, col - 2) = Ar_gbrg'*img_mono;
        elseif ~mod(row, 2) && mod(col, 2)
            final_r(row - 2, col - 2) = Ar_grbg'*img_mono;
            final_b(row - 2, col - 2) = Ab_grbg'*img_mono;
        end
    end
end

final = cat(3, final_r, final_g, final_b);
native_demosaic = demosaic(bayer(img_i, "rggb"), "rggb");

figure;
imshow(final)
title("Demosaiced image")

rmse = immse(uint8(final.*255), img_i);
fprintf("The RMSE between the original and demosaiced image is: %.5f\n", rmse);

figure;
imshow(native_demosaic)
title("Demosaiced image using MATLAB demosaic()")
fprintf("The RMSE between the original and demosaiced image using MATLAB demosaic() is: %.5f\n", rmse_de);

error = rgb2gray(uint8(final.*255) - img_i).^2;
figure;
imshow(error);
title("Error");

function bayer_img = bayer(img, pattern)
    [h, w, ~] = size(img);
    % Green
    bayer_img = img(:,:,2);

    if pattern == "rggb"    
        % Red
        bayer_img(1:2:h, 1:2:w) = img(1:2:h, 1:2:w, 1);
        % Blue
        bayer_img(2:2:h, 2:2:w) = img(2:2:h, 2:2:w, 3); 
    elseif pattern == "bggr"
        % Red
        bayer_img(2:2:h, 2:2:w) = img(2:2:h, 2:2:w, 1);
        % Blue
        bayer_img(1:2:h, 1:2:w) = img(1:2:h, 1:2:w, 3); 
    elseif pattern == "gbrg"
        % Red
        bayer_img(2:2:h, 1:2:w) = img(2:2:h, 1:2:w, 1);
        % Blue
        bayer_img(1:2:h, 2:2:w) = img(1:2:h, 2:2:w, 3);
    elseif pattern == "grbg"
        % Red
        bayer_img(1:2:h, 2:2:w) = img(1:2:h, 2:2:w, 1);
        % Blue
        bayer_img(2:2:h, 1:2:w) = img(2:2:h, 1:2:w, 3);
    else
        error("Invalid pattern. Must be either 'rggb', 'bggr', 'grbg', or 'gbgr'")
    end
end

function [Ag,Ab] = rggb(Xr, Xg, Xb, green, blue)
    r = zeros(5); r(1:2:end, 1:2:end) = 1;
    g = zeros(5); g(2:2:end) = 1;
    b = zeros(5); b(2:2:end, 2:2:end) = 1;

    X = (r(:).*Xr + g(:).*Xg + b(:).*Xb)';

    Ag = (X'*X)\X'*green;
    Ab = (X'*X)\X'*blue;
end

function [Ar,Ab] = gbrg(Xr, Xg, Xb, red, blue)
    r = zeros(5); r(2:2:end, 1:2:end) = 1;
    g = zeros(5); g(1:2:end) = 1;
    b = zeros(5); b(1:2:end, 2:2:end) = 1;

    X = (r(:).*Xr + g(:).*Xg + b(:).*Xb)';
    
    Ar = (X'*X)\X'*red;
    Ab = (X'*X)\X'*blue;
end

function [Ar,Ab] = grbg(Xr, Xg, Xb, red, blue)
    r = zeros(5); r(1:2:end, 2:2:end) = 1;
    g = zeros(5); g(1:2:end) = 1;
    b = zeros(5); b(2:2:end, 1:2:end) = 1;

    X = (r(:).*Xr + g(:).*Xg + b(:).*Xb)';
    
    Ar = (X'*X)\X'*red;
    Ab = (X'*X)\X'*blue;
end

function [Ar,Ag] = bggr(Xr, Xg, Xb, red, green)
    r = zeros(5); r(2:2:end, 2:2:end) = 1;
    g = zeros(5); g(2:2:end) = 1;
    b = zeros(5); b(1:2:end, 1:2:end) = 1;

    X = (r(:).*Xr + g(:).*Xg + b(:).*Xb)';
    
    Ar = (X'*X)\X'*red;
    Ag = (X'*X)\X'*green;
end