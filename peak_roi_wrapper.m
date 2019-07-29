clear all
path = '/Users/lj4/Desktop';


cd (path);
d = dir ('c*');
for i = 1:length (d)
   if d(i).isdir
       subj_name{i} = d(i).name;
       fmri_fname = ['rmean' subj_name{i} '_mirr.nii'];
       fmri_pathname = [pwd '/' subj_name{i}];

       
       peak_roi_lj(fmri_fname, fmri_pathname);
       
   end
    
end