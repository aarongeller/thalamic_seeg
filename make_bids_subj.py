#!/usr/bin/python

import os, sys, shutil, glob

# right now need to use python 3.11 for this (do conda activate clean_eeg):
import matlab.engine 

fullsubj = sys.argv[1]
shortsubj = fullsubj[:5]

if len(sys.argv)<3:
    topdir = "/Users/aaron/Downloads/thalseeg_exports/rawdata"
else:
    topdir = sys.argv[2]
    
subjstr = "sub-" + fullsubj

fsdir = '/Applications/freesurfer/subjects'
subj_fsdir = os.path.join(fsdir, shortsubj)
bsprefix = "/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/"

dirs = {"preop_anat": os.path.join(topdir, subjstr, "ses-preop", "anat"),
        "postop_anat": os.path.join(topdir, subjstr, "ses-postop", "anat"),
        "postop_ieeg": os.path.join(topdir, subjstr, "ses-postop", "ieeg")}
           
# make dirs
for d in dirs.values():
    if not os.path.exists(d):
        os.makedirs(d)

# get preop MRI
t1str = subjstr + "_ses-preop_acq-iso_T1w.nii.gz"
t1mridir = os.path.join(subj_fsdir, "mri", "orig")
t1sourcepath = os.path.join(t1mridir, "001.nii.gz")

if not os.path.isfile(t1sourcepath):
    # convert MRI to NIFTI if necessary
    comm = "pushd .; cd " + t1mridir + "; /Applications/freesurfer/bin/mri_convert 001.mgz 001.nii.gz; popd"
    print(comm)
    os.system(comm)

shutil.copy(t1sourcepath, os.path.join(dirs["preop_anat"], t1str))

# get postop CT
ctlinkstr = subjstr + "_ses-postop_CT.nii.gz"
ctdir = os.path.join(subj_fsdir, "ct")
ctsourcepath = glob.glob(os.path.join(ctdir, '*.nii.gz'))[0]
shutil.copy(ctsourcepath, os.path.join(dirs["postop_anat"], ctlinkstr))

def get_seeg_channels(eng, bsprefix, subj, matfile):
    matfile_parts = matfile.split("/")
    bspath = os.path.join(bsprefix, subj, subj + "_" + matfile_parts[0], "channel.mat")
    ll = eng.get_seeg_channels(bspath)
    return list(map(lambda x: int(x), ll[0]))

# get seizure EDFs
# Start the MATLAB engine
eng = matlab.engine.start_matlab()
eng.addpath('/Users/aaron/Documents/school/4202/thalamic_seeg')
mf = eng.get_sz_eeg_mat(shortsubj)
chan_types = get_seeg_channels(eng, bsprefix, shortsubj, mf[0])

def sz_ieeg_json(chan_types, srate, dur):
    # to do: check hardwarefilters, get ieegreference info
    json_str =  "{\n" \
        + "\t\"TaskName\":\"Seizure\",\n" \
        + "\t\"InstitutionName\":\"University of Colorado Hospital\",\n" \
        + "\t\"InstitutionAddress\":\"1635 Aurora Ct, Aurora CO 80045\",\n" \
        + "\t\"Manufacturer\":\"Nihon Kohden\",\n" \
        + "\t\"ManufacturersModelName\":\"n/a\",\n" \
        + "\t\"TaskDescription\":\"n/a\",\n" \
        + "\t\"Instructions\":\"n/a\",\n" \
        + "\t\"iEEGReference\":\"Average of A5 and A6\",\n" \
        + "\t\"SamplingFrequency\":" + str(srate) + ",\n" \
        + "\t\"PowerLineFrequency\":60,\n" \
        + "\t\"SoftwareFilters\":\"n/a\",\n" \
        + "\t\"HardwareFilters\":{\"Highpass RC filter\": {\"Half amplitude cutoff (Hz)\": 0.0159, \"Roll-off\": \"6dBOctave\"}},\n" \
        + "\t\"ElectrodeManufacturer\":\"DIXI\",\n" \
        + "\t\"ECOGChannelCount\":0,\n" \
        + "\t\"SEEGChannelCount\":" + str(chan_types[0]) + ",\n" \
        + "\t\"EEGChannelCount\":0,\n" \
        + "\t\"EOGChannelCount\":0,\n" \
        + "\t\"ECGChannelCount\":" + str(chan_types[2]) + ",\n" \
        + "\t\"EMGChannelCount\":0,\n" \
        + "\t\"MiscChannelCount\":" + str(chan_types[1]) + ",\n" \
        + "\t\"TriggerChannelCount\":0,\n" \
        + "\t\"RecordingDuration\":" + str(dur) + ",\n" \
        + "\t\"RecordingType\":\"continuous\",\n" \
        + "\t\"iEEGGround\":\"placed on the right mastoid\",\n" \
        + "\t\"iEEGPlacementScheme\":\"see recon and electrodes.tsv\",\n" \
        + "\t\"ElectricalStimulation\":false\n" \
        + "}"
    return json_str

def get_sr_dur(eng, bsprefix, subj, dirfrag):
    rawname1 = "@raw" + dirfrag
    rawname2 = "raw_" + dirfrag
    rawmatpath = os.path.join(bsprefix, subj, rawname1, "data_0" + rawname2 + ".mat")
    sd = eng.get_edf_sr_dur(rawmatpath)
    return sd[0]
    
for i,f in enumerate(mf):
    fparts = f.split("/")
    dirfrag = shortsubj + "_" + fparts[0]
    edfsource_name =  dirfrag + ".edf"
    edfsource_path = os.path.join(subj_fsdir, "eeg", edfsource_name)
    target_stem = subjstr + "_ses-postop_task-seizure%03d_ieeg" % i
    edftarget_name = target_stem + ".edf"
    edftarget_path = os.path.join(dirs["postop_ieeg"], edftarget_name)
    shutil.copy(edfsource_path, edftarget_path)
    jsontarget_name  = target_stem + ".json"
    jsontarget_path = os.path.join(dirs["postop_ieeg"], jsontarget_name)
    sd = get_sr_dur(eng, bsprefix, shortsubj, dirfrag)
    of = open(jsontarget_path, 'w')
    of.write(sz_ieeg_json(chan_types, sd[0], sd[1]))
    of.close()

# Stop the engine when finished
eng.quit()
