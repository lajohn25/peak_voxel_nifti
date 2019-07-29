function roiStat(fnm);
%report statistics for brain region in statistical map fnm
% fnm: statistical map normalized by SPM12
%Examples
% roiStat
% roitStat('sw2019.nii');
 
roi = 'JHU';
fnm = 'meanc2_mirr.nii'
if ~exist('fnm', 'var')
 fnm = spm_select(1,'image','Select statistical image');
end
if ~exist(fnm,'file')
   error('Unable to find %s\n', fnm); 
end
%find path to region of interest
p = fileparts(which('NiiStat'));
roifnm = fullfile(p,'roi',[roi, '.nii']);
if ~exist(roifnm,'file')
   error('Have you installed NiiStat? Unable to find %s\n', roifnm); 
end
atlas_hdr = spm_vol(roifnm);
atlas_nii = spm_read_vols(atlas_hdr);
numROI = max(atlas_nii(:));
fprintf('Atlas %s has %d regions\n', roifnm, numROI);
%load stat map
img_hdr = spm_vol(fnm);
img_nii = spm_read_vols(img_hdr);
%check that ROI and 
if ~isequal(size(img_nii), size(atlas_nii))
   fprintf('Image dimensions do not match roi %dx%dx%d img %dx%dx%d\n', size(atlas_nii,1),size(atlas_nii,2),size(atlas_nii,3), size(img_nii,1),size(img_nii,2),size(img_nii,3)); 
   if ~exist('nii_reslice_target','file'), error('Make sure spmScripts are in your path\n'); end
   %we could either warp the atlas->nii or nii->atlas
   % here we warp nii->atlas as it is likely higher resolution
   % if you warp atlas->nii make sure to specify nearest neighbor interp 
   %  [outhdr, outimg] = nii_reslice_target(inhdr, inimg, tarhdr, interp)
   [img_hdr, img_nii] = nii_reslice_target(img_hdr, img_nii, atlas_hdr, 1); 
   spm_write_vol(img_hdr, img_nii);
   fprintf('Resliced roi %dx%dx%d img %dx%dx%d\n', size(atlas_nii,1),size(atlas_nii,2),size(atlas_nii,3), size(img_nii,1),size(img_nii,2),size(img_nii,3)); 
end
 
 
fprintf('Region\tMean\tVoxels\n');
for i = 1: numROI
   img_filt = img_nii(atlas_nii == i); %exclude voxels outside desired region)
   img_filt = img_filt(isfinite(img_filt)); %exclude voxels where intensity is not-a-number (no values)
   if isempty(img_filt), continue; end; %no voxels in this region!
   mn = mean(img_filt(:));
   fprintf('%d\t%g\t%d\n', i, mn, numel(img_filt) );    
end