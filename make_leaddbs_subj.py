#!/usr/bin/python

# set up BIDS directories for LEAD DBS

import os, sys, glob

subjname = sys.argv[1]
subjstr = "sub-" + subjname

fsdir = '/Applications/freesurfer/subjects'

leaddbsdir = os.path.join(fsdir, 'ThalSeegLeaddbs')
if not os.path.exists(leaddbsdir):
    os.makedirs(leaddbsdir)

jsonpath = os.path.join(leaddbsdir, "dataset_description.json")

if not os.path.isfile(jsonpath):
    json_str = "{\n" \
        +	"\t\"Name\": \"thal_seeg_leaddbs\",\n" \
        +	"\t\"BIDSVersion\": \"1.6.0\",\n" \
        +	"\t\"LEADVersion\": \"3.1\",\n" \
        +	"\t\"DatasetType\": \"raw\",\n" \
        +	"\t\"Reserved\": \"Tutor\"\n}"
    outf = open(jsonpath, 'w')
    outf.write(json_str)
    outf.close()

preopdir = os.path.join(leaddbsdir, 'rawdata', subjstr, 'ses-preop', 'anat')
postopdir = os.path.join(leaddbsdir, 'rawdata', subjstr, 'ses-postop', 'anat')

targetdirs = [os.path.join(leaddbsdir, 'derivatives'),
              os.path.join(leaddbsdir, 'sourcedata'),
              preopdir,
              postopdir]

for t in targetdirs:
    if not os.path.exists(t):
        os.makedirs(t)

# softlink to T1:
t1linkstr = subjstr + "_ses-preop_acq-iso_T1w.nii.gz"
t1mridir = os.path.join(fsdir, subjname, "mri", "orig")
t1sourcepath = os.path.join(t1mridir, "001.nii.gz")

if not os.path.isfile(t1sourcepath):
    # convert MRI to NIFTI if necessary
    comm = "pushd .; cd " + t1mridir + "; /Applications/freesurfer/bin/mri_convert 001.mgz 001.nii.gz; popd"
    print(comm)
    os.system(comm)

if not os.path.exists(os.path.join(preopdir, t1linkstr)):
    os.symlink(t1sourcepath, os.path.join(preopdir, t1linkstr))

# softlink to CT:
ctlinkstr = subjstr + "_ses-postop_CT.nii.gz"
ctdir = os.path.join(fsdir, subjname, "ct")
ctsourcepath = glob.glob(os.path.join(ctdir, '*.nii.gz'))[0]

if not os.path.exists(os.path.join(postopdir, ctlinkstr)):
    os.symlink(ctsourcepath, os.path.join(postopdir, ctlinkstr))

