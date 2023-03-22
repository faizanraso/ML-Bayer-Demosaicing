% CE 3SK3 - Project 3
% Faizan Rasool, rasoolf, 400180032

clc; clear;

% load full colour image
img = im2double(imread('Training Images/training_image.jpg'));

% Extract the color channels corresponding to the Bayer pattern
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

% Create padded versions 
r_padded = padarray(r,[2,2],'symmetric', 'both');
g_padded = padarray(g,[2,2],'symmetric', 'both');
b_padded = padarray(b,[2,2],'symmetric', 'both');

% Convert seperate channels to individual column vectors
r_col = im2col(r, [1,1]);
g_col = im2col(g, [1,1]);
b_col = im2col(b, [1,1]);

% Create windows for each channel
r_window = im2col(r_padded,[5 5]);
g_window = im2col(g_padded,[5 5]);
b_window = im2col(b_padded,[5 5]);

% Generate the various bayer mosaic patches
rggb_patch = generate_rggb_patch(img, r, g, b);
grbg_patch = generate_grbg_patch(img, r, g, b);
gbrg_patch = generate_gbrg_patch(img, r, g, b);
bggr_patch = generate_bggr_patch(img, r, g, b);

% Save images using the various patches
% imwrite(rggb_patch, 'Generated Images/rggb_image.png', 'png')
% imwrite(grbg_patch, 'Generated Images/grbg_image.png', 'png')
% imwrite(gbrg_patch, 'Generated Images/gbrg_image.png', 'png')
% imwrite(bggr_patch, 'Generated Images/bggr_image.png', 'png')

% Calculate coefficents
[g_rggb,b_rggb] = rggb_coefficents(r_window,g_window,b_window,g_col,b_col); 
[r_grbg,b_grbg] = grbg_coefficents(r_window,g_window,b_window,r_col,b_col);
[r_gbrg,b_gbrg] = gbrg_coefficents(r_window,g_window,b_window,r_col,b_col);
[r_bggr,g_bggr] = bggr_coefficents(r_window,g_window,b_window,r_col,g_col);


% ---- Perform Linear Regresion ----
input_image = im2double(imread('testing_image.jpeg'));
r = input_image(:,:,1);
g = input_image(:,:,2);
b = input_image(:,:,3);
[m, n, z] = size(input_image);

r_rep = repmat ([1 0;0 0],[round(m/2),round(n/2)]);
g_rep = repmat ([0 1;1 0],[round(m/2),round(n/2)]);
b_rep = repmat ([0 0;0 1],[round(m/2),round(n/2)]);

 % resize if needed
% if(size(r_rep, 1) > m)
%     r_rep(m+1,:) = [];
% end
% 
% if(size(r_rep, 2) > n)
%     r_rep(:,n+1) = [];
% end
% 
% if(size(g_rep, 1) > m)
%     g_rep(m+1,:) = [];
% end
% 
% if(size(g_rep, 2) > n)
%     g_rep(:,n+1) = [];
% end
% 
% if(size(b_rep, 1) > m)
%     b_rep(m+1,:) = [];
% end
% 
% if(size(b_rep, 2) > n)
%     b_rep(:,n+1) = [];
% end
% 
% r_channel1 = input_image(:,:,1).*r_rep;
% g_channel2 = input_image(:,:,2).*g_rep;
% b_channel3 = input_image(:,:,3).*b_rep;

patch = generate_rggb_patch(input_image, r, g, b);
r_channel = patch(:,:,1);
g_channel = patch(:,:,2);
b_channel = patch(:,:,3);


% Generate black and white image
bw_image = r_channel(:,:) + g_channel(:,:) + b_channel(:,:);
imwrite(bw_image,"bw_image.png");


bw_padded = padarray(bw_image,[3 3],'symmetric');


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
    
    r_column = im2col(r_rep,[1 1])';
    g_column = im2col(g_rep,[1 1])';
    b_column = im2col(b_rep,[1 1])';
    
    X = (r_column.*r_window + g_column.*g_window + b_column.*b_window)';
    
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
    
    r_column = im2col(r_rep,[1 1])';
    g_column = im2col(g_rep,[1 1])';
    b_column = im2col(b_rep,[1 1])';
    
    X = (r_column.*r_window + g_column.*g_window + b_column.*b_window)';
    
    r_grbg = inv(X'*X)*X'*(r_col');
    b_grbg = inv(X'*X)*X'*(b_col');
end

function [r_gbrg,b_gbrg] = gbrg_coefficents(r_window,g_window,b_window,r_col,b_col)
    % gbrg matrix -> [g b;r g]
    r_rep = repmat ([0 1;0 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 0;1 0], [3,3]);

    % Apply offset to ensure center of the pixel is aligned with the 
    % corresponding pixel in the image
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    r_column = im2col(r_rep,[1 1])';
    g_column = im2col(g_rep,[1 1])';
    b_column = im2col(b_rep,[1 1])';
    
    X = (r_column.*r_window + g_column.*g_window + b_column.*b_window)';
    
    r_gbrg = inv(X'*X)*X'*(r_col');
    b_gbrg = inv(X'*X)*X'*(b_col');
end

function [r_bggr,g_bggr] = bggr_coefficents(r_window,g_window,b_window,r_col,g_col)
    % bggr matrix -> [b g;g r]
    r_rep = repmat ([0 1;0 0], [3,3]);
    g_rep = repmat ([1 0;0 1], [3,3]);
    b_rep = repmat ([0 0;1 0], [3,3]);

    % Remove the last row and column in the array to create a 5x5 matrix
    % as shown in the lab instructions
    r_rep(6,:) = []; r_rep(:,6) = [];
    g_rep(6,:) = []; g_rep(:,6) = [];
    b_rep(6,:) = []; b_rep(:,6) = [];
    
    r_column = im2col(r_rep,[1 1])';
    g_column = im2col(g_rep,[1 1])';
    b_column = im2col(b_rep,[1 1])';
    
    X = (r_column.*r_window + g_column.*g_window + b_column.*b_window)';
    
    r_bggr = inv(X'*X)*X'*(r_col');
    g_bggr = inv(X'*X)*X'*(g_col');
end

