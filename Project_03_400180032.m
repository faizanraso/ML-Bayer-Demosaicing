% CE 3SK3 - Project 3
% Faizan Rasool, rasoolf, 400180032

clc; clear;

% load full colour image
training_img = im2double(imread('training.jpg'));

% Extract the color channels corresponding to the Bayer pattern
r = training_img(:,:,1);
g = training_img(:,:,2);
b = training_img(:,:,3);

% Convert seperate channels to individual column vectors
r_col = im2col(r, [1,1]);
g_col = im2col(g, [1,1]);
b_col = im2col(b, [1,1]);

% Create windows for each channel
r_window = im2col(padarray(r,[2,2],'symmetric', 'both'),[5 5]);
g_window = im2col(padarray(g,[2,2],'symmetric', 'both'),[5 5]);
b_window = im2col(padarray(b,[2,2],'symmetric', 'both'),[5 5]);

% Calculate coefficents
[g_rggb,b_rggb] = rggb_coefficents(r_window,g_window,b_window,g_col,b_col); 
[r_grbg,b_grbg] = grbg_coefficents(r_window,g_window,b_window,r_col,b_col);
[r_gbrg,b_gbrg] = gbrg_coefficents(r_window,g_window,b_window,r_col,b_col);
[r_bggr,g_bggr] = bggr_coefficents(r_window,g_window,b_window,r_col,g_col);

% ---- Perform Linear Regresion ----
input_img = im2double(imread('testing.png'));
r = input_img(:,:,1);
g = input_img(:,:,2);
b = input_img(:,:,3);
[m, n, ~] = size(input_img);

% Can change function for a different patch pattern -- this function is
% used for testing purposes (creating a beyer image)
pattern_img = im2double(generate_grbg_patch(input_img, r, g, b));
r_channel = pattern_img(:,:,1);
g_channel = pattern_img(:,:,2);
b_channel = pattern_img(:,:,3);

% Generate black and white image
bw_image = r_channel(:,:) + g_channel(:,:) + b_channel(:,:);
% imwrite(bw_image, 'bw_image.png')

% Pad the black and white image - This is to ensure the window aligns with
% the targeted pixel
bw_padded = padarray(bw_image,[3 3],'symmetric');
bw_padded(3,:) = [];
bw_padded(:,3) = [];
bw_padded(end - 2,:) = [];
bw_padded(:,end - 2) = [];


% used to test for which bayer pattern is being used
b_padded = padarray(b_channel,[3 3],'symmetric');
b_padded(end-2,:) = []; b_padded(:,end-2) = [];
b_padded(3,:) = []; b_padded(:,3) = [];

% Process image
for i=3:m+2
    for j=3:n+2
        window = im2double(bw_padded(i-2:i+2,j-2:j+2));
        window = window(:);
        bayer_pattern = b_padded(i:i+1, j:j+1);
        if isequal(bayer_pattern .* [1 1; 1 0], zeros(2))
            b_channel(i-2,j-2) = sum(b_rggb.*window);
            g_channel(i-2,j-2)= sum(g_rggb.*window);
        elseif isequal(bayer_pattern .* [1 0; 1 1], zeros(2))
            r_channel(i-2,j-2) = sum(r_gbrg.*window);
            b_channel(i-2,j-2)= sum(b_gbrg.*window);
        elseif isequal(bayer_pattern .* [1 1; 0 1], zeros(2))
            b_channel(i-2,j-2)= sum(b_grbg.*window);
            r_channel(i-2,j-2)= sum(r_grbg.*window);
        elseif isequal(bayer_pattern .* [0 1; 1 1], zeros(2))
            g_channel(i-2,j-2) = sum(g_bggr.*window);
            r_channel(i-2,j-2)= sum(r_bggr.*window);
        end
    end
end

output_img = cat(3,r_channel,g_channel,b_channel);

% Original image
figure(1);
imshow('testing.png')
title('Original Image')

% Reconstructed image using linear regression
figure(2);
imshow(output_img)
title('Demosaiced Image')

% Using matlabs demosaic function
matlab_output = demosaic(im2uint8(bw_image), "grbg");
figure(3);
imshow(matlab_output)
title('Matlab Demosaiced Image')

mse = immse(im2uint8(output_img),im2uint8(input_img));
matlab_mse = immse(matlab_output, im2uint8(input_img));

fprintf("MSE using linear regression: %.3f \n", mse)
fprintf("MSE using demosaic function: %.3f \n", matlab_mse)

% Generate the various bayer mosaic patches
% rggb_patch = generate_rggb_patch(training_img, r, g, b);
% grbg_patch = generate_grbg_patch(training_img, r, g, b);
% gbrg_patch = generate_gbrg_patch(training_img, r, g, b);
% bggr_patch = generate_bggr_patch(training_img, r, g, b);

% Save images using the various patches
% imwrite(rggb_patch, 'rggb_image.png', 'png')
% imwrite(grbg_patch, 'grbg_image.png', 'png')
% imwrite(gbrg_patch, 'gbrg_image.png', 'png')
% imwrite(bggr_patch, 'bggr_image.png', 'png')

% ------------------------------------- Functions -------------------------------------

% Create bayer mosaic pattern patches
function rggb_patch = generate_rggb_patch(img, R, G, B)
    [m, n, ~] = size(img);
    rggb_patch = zeros(m, n, 3);
    rggb_patch(1:2:end, 1:2:end, 1) = R(1:2:end, 1:2:end);
    rggb_patch(1:2:end, 2:2:end, 2) = G(1:2:end, 2:2:end);
    rggb_patch(2:2:end, 1:2:end, 2) = G(2:2:end, 1:2:end);
    rggb_patch(2:2:end, 2:2:end, 3) = B(2:2:end, 2:2:end);
end

function grbg_patch = generate_grbg_patch(img, R, G, B)
    [m, n, ~] = size(img);
    grbg_patch = zeros(m, n, 3);
    grbg_patch(1:2:end, 1:2:end, 2) = G(1:2:end, 1:2:end);
    grbg_patch(1:2:end, 2:2:end, 1) = R(1:2:end, 2:2:end);
    grbg_patch(2:2:end, 1:2:end, 3) = B(2:2:end, 1:2:end);
    grbg_patch(2:2:end, 2:2:end, 2) = G(2:2:end, 2:2:end);
end

function gbrg_patch = generate_gbrg_patch(img, R, G, B)
    [m, n, ~] = size(img);
    gbrg_patch = zeros(m, n, 3);
    gbrg_patch(1:2:end, 1:2:end, 2) = G(1:2:end, 1:2:end);
    gbrg_patch(1:2:end, 2:2:end, 3) = B(1:2:end, 2:2:end);
    gbrg_patch(2:2:end, 1:2:end, 1) = R(2:2:end, 1:2:end);
    gbrg_patch(2:2:end, 2:2:end, 2) = G(2:2:end, 2:2:end);
end

function bggr_patch = generate_bggr_patch(img, R, G, B)
    [m, n, ~] = size(img);
    bggr_patch = zeros(m, n, 3);
    bggr_patch(1:2:end, 1:2:end, 3) = B(1:2:end, 1:2:end);
    bggr_patch(1:2:end, 2:2:end, 2) = G(1:2:end, 2:2:end);
    bggr_patch(2:2:end, 1:2:end, 2) = G(2:2:end, 1:2:end);
    bggr_patch(2:2:end, 2:2:end, 1) = R(2:2:end, 2:2:end);
end


% Generate coefficents for various patch patterns
function [g_rggb,b_rggb] = rggb_coefficents(r_window,g_window,b_window,g_col,b_col)
    % rggb matrix -> [r g;g b]
    r_rep = repmat ([1 0;0 0], [3,3]);
    g_rep = repmat ([0 1;1 0], [3,3]);
    b_rep = repmat ([0 0;0 1], [3,3]);

    % Apply offset to ensure center of the pixel is aligned with the 
    % corresponding pixel in the image
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    g_rggb = inv(X'*X)*X'*(g_col');
    b_rggb = inv(X'*X)*X'*(b_col');
end


function [r_grbg,b_grbg] = grbg_coefficents(r_window,g_window,b_window,r_col,b_col)
    % grbg matrix -> [g r;b g]
    r_rep = repmat ([0 1;0 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 0;1 0], [3,3]);

    % Apply offset to ensure center of the pixel is aligned with the 
    % corresponding pixel in the image
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_grbg = inv(X'*X)*X'*(r_col');
    b_grbg = inv(X'*X)*X'*(b_col');
end

function [r_gbrg,b_gbrg] = gbrg_coefficents(r_window,g_window,b_window,r_col,b_col)
    % gbrg matrix -> [g b;r g]
    r_rep = repmat ([0 0;1 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 1;0 0], [3,3]);

    % Apply offset to ensure center of the pixel is aligned with the 
    % corresponding pixel in the image
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];

    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_gbrg = inv(X'*X)*X'*(r_col');
    b_gbrg = inv(X'*X)*X'*(b_col');
end

function [r_bggr,g_bggr] = bggr_coefficents(r_window,g_window,b_window,r_col,g_col)
    % bggr matrix -> [b g;g r]
    r_rep = repmat ([0 0;0 1], [3,3]);
    g_rep = repmat ([0 1;1 0], [3,3]);
    b_rep = repmat ([1 0;0 0], [3,3]);

    % Remove the last row and column in the array to create a 5x5 matrix
    % as shown in the lab instructions
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_bggr = inv(X'*X)*X'*(r_col');
    g_bggr = inv(X'*X)*X'*(g_col');
end

