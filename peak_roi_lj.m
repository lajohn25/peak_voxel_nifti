function peak_roi_lj(filename, pathname);

addpath (pwd)

%load all filenames for the fmri file of interest
fmri_fname = fullfile (pathname, filename);


atlas = 'jhu'
roiNum = 186; %we are interested in region 186 (LH pMTG)

atlas_hdr = spm_vol([atlas '.nii']);
atlas_nii = spm_read_vols(atlas_hdr);
     
%I'm inputting a random fmri nifti file (which has been resliced according to our atlas) here
img_hdr = spm_vol(fmri_fname);
img_nii = spm_read_vols(img_hdr);


imgFilt = img_nii;
imgFilt(atlas_nii ~= roiNum) = NaN;


[mx, mxIdx] = max(imgFilt(:));
mxIdx
[x,y,z] = ind2sub(size(img_nii), mxIdx);

fprintf('Brightest voxel for region %d is %g at location %d %d %d\n', roiNum, mx,  x,y,z);

%now I'd like to dilate the VOI to a 5x5x5mm, spherical ROI
%to do that, we first need to put down some info on our image

atlas_dim_x = atlas_hdr.dim(1);
atlas_dim_y = atlas_hdr.dim(2);
atlas_dim_z = atlas_hdr.dim(3);
[yImage xImage zImage] = meshgrid(1:atlas_dim_y, 1:atlas_dim_x, 1:atlas_dim_z);

radius = 5;
roi_nii = (yImage - y).^2 + (xImage - x).^2 + (zImage - z).^2 <= radius.^2;

%the next two lines are if you would prefer just to have a specific 1x1x1mm
%voxel highlighted.
% roi_nii = zeros(size (atlas_nii)); 
% roi_nii(x, y, z) = 1;


roi_hdr = atlas_hdr;
roi_hdr.fname = [fmri_fname 'posterior_roi.nii']; %name your roi nifti here
roi_hdr.pinfo = [1;0;0];
roi_hdr.private.dat.scl_slope = 1;
roi_hdr.private.dat.scl_inter = 0;
roi_hdr.private.dat.dtype = 'FLOAT32-LE';
roi_hdr.dt = [16,0]; %4= 16-bit integer; 16 =32-bit real datatype
spm_write_vol (roi_hdr, roi_nii);

