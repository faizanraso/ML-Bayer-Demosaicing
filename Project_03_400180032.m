% ---------------------------------------------------------------------------------------
% This script is desined for input/testing images that are Single channel
% Bayer Images  (Raw Mosaic Data)
% ---------------------------------------------------------------------------------------

% CE 3SK3 - Project 3
% Faizan Rasool, rasoolf, 400180032

clc; clear;

training_img_name = 'training.jpg';
test_img_name = 'test1.png';


% load full colour image
training_img = im2double(imread(training_img_name));

% Extract the colour channels
r = training_img(:,:,1);
g = training_img(:,:,2);
b = training_img(:,:,3);

% Convert separate channels to individual column vectors
r_col = im2col(r, [1,1]);
g_col = im2col(g, [1,1]);
b_col = im2col(b, [1,1]);

% Create windows for each channel
r_window = im2col(padarray(r,[2,2],'symmetric', 'both'),[5 5]);
g_window = im2col(padarray(g,[2,2],'symmetric', 'both'),[5 5]);
b_window = im2col(padarray(b,[2,2],'symmetric', 'both'),[5 5]);

% Calculate coefficients
[g_rggb,b_rggb] = rggb_coefficients(r_window,g_window,b_window,g_col,b_col); 
[r_grbg,b_grbg] = grbg_coefficients(r_window,g_window,b_window,r_col,b_col);
[r_gbrg,b_gbrg] = gbrg_coefficients(r_window,g_window,b_window,r_col,b_col);
[r_bggr,g_bggr] = bggr_coefficients(r_window,g_window,b_window,r_col,g_col);

% ---- Process a test image ---
input_img = im2double(imread(test_img_name));
[m, n, ~] = size(input_img);
pattern_img = im2double(input_img);

[m, n, ~] = size(pattern_img);
r_channel = zeros(m, n);
g_channel = zeros(m, n);
b_channel = zeros(m, n);

% RGGB input - use this
r_channel(1:2:end, 1:2:end) = pattern_img(1:2:end, 1:2:end);
g_channel(1:2:end, 2:2:end) = pattern_img(1:2:end, 2:2:end);
g_channel(2:2:end, 1:2:end) = pattern_img(2:2:end, 1:2:end);
b_channel(2:2:end, 2:2:end) = pattern_img(2:2:end, 2:2:end);

% BGGR Input - use this
% r_channel(2:2:end, 2:2:end) = pattern_img(2:2:end, 2:2:end);
% g_channel(1:2:end, 2:2:end) = pattern_img(1:2:end, 2:2:end);
% g_channel(2:2:end, 1:2:end) = pattern_img(2:2:end, 1:2:end);
% b_channel(1:2:end, 1:2:end) = pattern_img(1:2:end, 1:2:end);

% GRBG Input - use this
% r_channel(1:2:end, 2:2:end) = pattern_img(1:2:end, 2:2:end);
% g_channel(1:2:end, 1:2:end) = pattern_img(1:2:end, 1:2:end);
% g_channel(2:2:end, 2:2:end) = pattern_img(2:2:end, 2:2:end);
% b_channel(2:2:end, 1:2:end) = pattern_img(2:2:end, 1:2:end);

% GBRG Input - use this
% r_channel(2:2:end, 1:2:end) = pattern_img(2:2:end, 1:2:end);
% g_channel(1:2:end, 1:2:end) = pattern_img(1:2:end, 1:2:end);
% g_channel(2:2:end, 2:2:end) = pattern_img(2:2:end, 2:2:end);
% b_channel(1:2:end, 2:2:end) = pattern_img(1:2:end, 2:2:end);


% Generate black and white image
bw_image = r_channel(:,:) + g_channel(:,:) + b_channel(:,:);

% Pad the black and white image - This is to ensure the window aligns with
% the targeted pixel
bw_padded = padarray(bw_image,[3 3],'symmetric');
bw_padded(3,:) = [];
bw_padded(:,3) = [];
bw_padded(end - 2,:) = [];
bw_padded(:,end - 2) = [];

% used to test for which bayer pattern is being used
b_padded = padarray(b_channel,[3 3],'symmetric');
b_padded(3,:) = []; 
b_padded(:,3) = [];
b_padded(end-2,:) = []; 
b_padded(:,end-2) = [];

for i=3:m+2
    for j=3:n+2
        bayer_pattern = b_padded(i:i+1, j:j+1);
        window = im2double(bw_padded(i-2:i+2,j-2:j+2));
        window = window(:);
        % rggb
        if (bayer_pattern(1,1) == 0 && bayer_pattern(1,2) == 0 && bayer_pattern(2,1) == 0)
            b_channel(i-2,j-2) = sum(b_rggb.*window);
            g_channel(i-2,j-2)= sum(g_rggb.*window);
        % gbrg
        elseif (bayer_pattern(1,1) == 0 && bayer_pattern(2,1) == 0 && bayer_pattern(2,2) == 0)
            r_channel(i-2,j-2) = sum(r_gbrg.*window);
            b_channel(i-2,j-2)= sum(b_gbrg.*window);
        % grbg
        elseif (bayer_pattern(1,1) == 0 && bayer_pattern(1,2) == 0 && bayer_pattern(2,2) == 0)
            b_channel(i-2,j-2)= sum(b_grbg.*window);
            r_channel(i-2,j-2)= sum(r_grbg.*window);
        % bggr
        elseif (bayer_pattern(1,2) == 0 && bayer_pattern(2,1) == 0 && bayer_pattern(2,2) == 0)
            g_channel(i-2,j-2) = sum(g_bggr.*window);
            r_channel(i-2,j-2)= sum(r_bggr.*window);
        end
    end
end

output_img = cat(3,r_channel,g_channel,b_channel);

% Original image
figure(1);
imshow(test_img_name)
title('Original Image')

% Reconstructed image using linear regression
figure(2);
subplot(1,2,1)
imshow(output_img)
title('Demosaiced Image Using Linear Regression')

% Using matlabs demosaic function
matlab_output = demosaic(im2uint8(bw_image), "rggb");
subplot(1,2,2)
imshow(matlab_output)
title('Demosaiced Image Using Matlab')

% rmse = sqrt(immse(im2uint8(output_img),im2uint8(input_img)));
% matlab_rmse = sqrt(immse(matlab_output, im2uint8(input_img)));
% 
% fprintf("RMSE using linear regression: %.3f \n", rmse)
% fprintf("RMSE using demosaic function: %.3f \n", matlab_rmse)


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
function [g_rggb,b_rggb] = rggb_coefficients(r_window,g_window,b_window,g_col,b_col)
    % rggb matrix -> [r g;g b]
    r_rep = repmat ([1 0;0 0], [3,3]);
    g_rep = repmat ([0 1;1 0], [3,3]);
    b_rep = repmat ([0 0;0 1], [3,3]);

    % Remove the final column and row to create a 5x5 window
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    g_rggb = (X'*X)\X'*(g_col');
    b_rggb = (X'*X)\X'*(b_col');
end


function [r_grbg,b_grbg] = grbg_coefficients(r_window,g_window,b_window,r_col,b_col)
    % grbg matrix -> [g r;b g]
    r_rep = repmat ([0 1;0 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 0;1 0], [3,3]);

    % Remove the final column and row to create a 5x5 window
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_grbg = (X'*X)\X'*(r_col');
    b_grbg = (X'*X)\X'*(b_col');
end

function [r_gbrg,b_gbrg] = gbrg_coefficients(r_window,g_window,b_window,r_col,b_col)
    % gbrg matrix -> [g b;r g]
    r_rep = repmat ([0 0;1 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 1;0 0], [3,3]);

    % Remove the final column and row to create a 5x5 window
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];

    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_gbrg = (X'*X)\X'*(r_col');
    b_gbrg = (X'*X)\X'*(b_col');
end

function [r_bggr,g_bggr] = bggr_coefficients(r_window,g_window,b_window,r_col,g_col)
    % bggr matrix -> [b g;g r]
    r_rep = repmat ([0 0;0 1], [3,3]);
    g_rep = repmat ([0 1;1 0], [3,3]);
    b_rep = repmat ([1 0;0 0], [3,3]);

    % Remove the final column and row to create a 5x5 window
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    X = (r_rep(:).*r_window + g_rep(:).*g_window + b_rep(:).*b_window)';
    
    r_bggr = (X'*X)\X'*(r_col');
    g_bggr = (X'*X)\X'*(g_col');
end

