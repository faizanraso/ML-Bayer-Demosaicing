% CE 3SK3 - Project 3
% Faizan Rasool, rasoolf, 400180032

% load full colour image
img = im2double(imread('test_image.jpg'));

% Extract the color channels corresponding to the Bayer pattern
R = img(1:2:end, 1:2:end, 1);
G1 = img(1:2:end, 2:2:end, 2);
G2 = img(2:2:end, 1:2:end, 2);
B = img(2:2:end, 2:2:end, 3);

% generate the various bayer mosaic patches
rggb_patch = generate_rggb_patch(img, R, G1, G2, B);
grbg_patch = generate_grbg_patch(img, R, G1, G2, B);
gbrg_patch = generate_gbrg_patch(img, R, G1, G2, B);
bggr_patch = generate_bggr_patch(img, R, G1, G2, B);

% save images using the various patches
imwrite(rggb_patch, 'rggb_image.png', 'png')
imwrite(grbg_patch, 'grbg_image.png', 'png')
imwrite(gbrg_patch, 'gbrg_image.png', 'png')
imwrite(bggr_patch, 'bggr_image.png', 'png')

% Create bayer mosaic pattern patches
function rggb_patch = generate_rggb_patch(img, R, G1, G2, B)
    [m, n, ~] = size(img);
    rggb_patch = zeros(m, n, 3);
    rggb_patch(1:2:end, 1:2:end, 1) = R;
    rggb_patch(1:2:end, 2:2:end, 2) = G1;
    rggb_patch(2:2:end, 1:2:end, 2) = G2;
    rggb_patch(2:2:end, 2:2:end, 3) = B;
end

function grbg_patch = generate_grbg_patch(img, R, G1, G2, B)
    [m, n, ~] = size(img);
    grbg_patch = zeros(m, n, 3);
    grbg_patch(1:2:end, 1:2:end, 2) = G1;
    grbg_patch(1:2:end, 2:2:end, 1) = R;
    grbg_patch(2:2:end, 1:2:end, 3) = B;
    grbg_patch(2:2:end, 2:2:end, 2) = G2;
end

function gbrg_patch = generate_gbrg_patch(img, R, G1, G2, B)
    [m, n, ~] = size(img);
    gbrg_patch = zeros(m, n, 3);
    gbrg_patch(1:2:end, 1:2:end, 2) = G1;
    gbrg_patch(1:2:end, 2:2:end, 3) = B;
    gbrg_patch(2:2:end, 1:2:end, 1) = R;
    gbrg_patch(2:2:end, 2:2:end, 2) = G2;
end

function bggr_patch = generate_bggr_patch(img, R, G1, G2, B)
    [m, n, ~] = size(img);
    bggr_patch = zeros(m, n, 3);
    bggr_patch(1:2:end, 1:2:end, 3) = B;
    bggr_patch(1:2:end, 2:2:end, 2) = G1;
    bggr_patch(2:2:end, 1:2:end, 2) = G2;
    bggr_patch(2:2:end, 2:2:end, 1) = R;
end
