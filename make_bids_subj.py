#!/usr/bin/python

import os, sys, shutil, glob, mne

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
opsceaprefix = "/Users/aaron/Documents/MATLAB/OPSCEA-main/OPSCEADATA"
subj_opsceadir = os.path.join(opsceaprefix, shortsubj)

dirs = {"preop_anat": os.path.join(topdir, subjstr, "ses-preop", "anat"),
        "postop_anat": os.path.join(topdir, subjstr, "ses-postop", "anat"),
        "postop_ieeg": os.path.join(topdir, subjstr, "ses-postop", "ieeg")}

reference_dict = {"UCHJE260511": ["LFP5", "LFP6"],
                  "UCHKJ260323": ["LOF5", "LOF6"],
                  "UCHJG260311": ["ROF5", "ROF6"],
                  "UCHPS260218": ["RAH5", "RAH6"],
                  "UCHJB260128": ["LAH5", "LAH6"],
                  "UCHHT251212": ["LAC5", "LAC6"],
                  "UCHMP250618": ["LAMY5", "LAMY6"],
                  "UCHAV250423": ["RTP5", "RTP6"],
                  "UCHTD250331": ["LSO5", "LSO6"],
                  "UCHEO250312": ["LOF5", "LOF6"],
                  "UCHJR250122": ["ROF5", "ROF6"],
                  "UCHAM250108": ["LAMY5", "LAMY6"],
                  "UCHAK240403": ["LAI5", "LAI6"],
                  "UCHDR240313": ["LAC5", "LAC6"],
                  "UCHGG230823": ["RPT5", "RPT6"],
                  "UCHMM260302": ["LAST5", "LAST6"],
                  "UCHHM251002": ["LTP5", "LTP6"],
                  "UCHSM240205": ["LOF5", "LOF6"]}

# make dirs
for d in dirs.values():
    if not os.path.exists(d):
        os.makedirs(d)

# 1) get preop MRI
t1str = subjstr + "_ses-preop_acq-iso_T1w.nii.gz"
t1mridir = os.path.join(subj_fsdir, "mri", "orig")
t1sourcepath = os.path.join(t1mridir, "001.nii.gz")
t1targetpath = os.path.join(dirs["preop_anat"], t1str)

if not os.path.isfile(t1sourcepath):
    # convert MRI to NIFTI if necessary
    comm = "pushd .; cd " + t1mridir + "; /Applications/freesurfer/bin/mri_convert 001.mgz 001.nii.gz; popd"
    print(comm)
    os.system(comm)

shutil.copy(t1sourcepath, t1targetpath)

# 2) get postop CT
ctlinkstr = subjstr + "_ses-postop_CT.nii.gz"
ctdir = os.path.join(subj_fsdir, "ct")
ctsourcepath = glob.glob(os.path.join(ctdir, '*.nii.gz'))[0]
shutil.copy(ctsourcepath, os.path.join(dirs["postop_anat"], ctlinkstr))

def get_seeg_channels(eng, bsprefix, subj, matfile):
    matfile_parts = matfile.split("/")
    bspath = os.path.join(bsprefix, subj, subj + "_" + matfile_parts[0], "channel.mat")
    ll = eng.get_seeg_channels(bspath)
    return list(map(lambda x: int(x), ll[0]))

# 3) get seizure EDFs

# Start the MATLAB engine
eng = matlab.engine.start_matlab()
eng.addpath('/Users/aaron/Documents/school/4202/thalamic_seeg')
mf = eng.get_sz_eeg_mat(shortsubj)
chan_types = get_seeg_channels(eng, bsprefix, shortsubj, mf[0])
# Stop the engine when finished
eng.quit()

def ieeg_json(task, chan_types, srate, dur, refpair):
    if len(refpair)==2:
        ref1 = refpair[0]
        ref2 = refpair[1]
    else:
        ref1 = "A5"
        ref2 = "A6"

    # to do: check hardwarefilters
    json_str =  "{\n" \
        + "\t\"TaskName\":\"" + task + "\",\n" \
        + "\t\"InstitutionName\":\"University of Colorado Hospital\",\n" \
        + "\t\"InstitutionAddress\":\"1635 Aurora Ct, Aurora CO 80045\",\n" \
        + "\t\"Manufacturer\":\"Nihon Kohden\",\n" \
        + "\t\"ManufacturersModelName\":\"n/a\",\n" \
        + "\t\"TaskDescription\":\"n/a\",\n" \
        + "\t\"Instructions\":\"n/a\",\n" \
        + "\t\"iEEGReference\":\"Average of " + ref1 + " and " + ref2 + "\",\n" \
        + "\t\"SamplingFrequency\":" + str(srate) + ",\n" \
        + "\t\"PowerLineFrequency\":60,\n" \
        + "\t\"SoftwareFilters\":\"band pass between 0.016 Hz and " + str(f"{srate/3:.3f}") + " Hz\",\n" \
        + "\t\"HardwareFilters\":\"n/a\",\n" \
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
        + "\t\"iEEGGround\":\"Scalp electrode approximately at Cz\",\n" \
        + "\t\"iEEGPlacementScheme\":\"see recon and electrodes.tsv\",\n" \
        + "\t\"ElectricalStimulation\":false\n" \
        + "}"
    return json_str

try:
    refpair = reference_dict[fullsubj]
except KeyError:
    print("Reference info not found for " + fullsubj)
    refpair = []
    
for i,f in enumerate(mf):
    fparts = f.split("/")
    dirfrag = shortsubj + "_" + fparts[0]
    edfsource_name =  dirfrag + ".edf"
    edfsource_path = os.path.join(subj_fsdir, "eeg", edfsource_name)
    raw = mne.io.read_raw_edf(edfsource_path, verbose=False)
    target_stem = subjstr + "_ses-postop_task-seizure%03d_ieeg" % i
    edftarget_name = target_stem + ".edf"
    edftarget_path = os.path.join(dirs["postop_ieeg"], edftarget_name)
    shutil.copy(edfsource_path, edftarget_path)
    jsontarget_name  = target_stem + ".json"
    jsontarget_path = os.path.join(dirs["postop_ieeg"], jsontarget_name)
    of = open(jsontarget_path, 'w')
    of.write(ieeg_json("Seizure", chan_types, raw.info.get("sfreq"), raw.duration, refpair))
    of.close()

# 4) get resting state EEG
edfsource_path = glob.glob(os.path.join(subj_fsdir, "eeg", "*resting.edf"))[0]
target_stem = subjstr + "_ses-postop_task-resting_ieeg"
edftarget_name = target_stem + ".edf"
edftarget_path = os.path.join(dirs["postop_ieeg"], edftarget_name)
shutil.copy(edfsource_path, edftarget_path)
jsontarget_name  = target_stem + ".json"
jsontarget_path = os.path.join(dirs["postop_ieeg"], jsontarget_name)
raw = mne.io.read_raw_edf(edfsource_path, verbose=False)
of = open(jsontarget_path, 'w')
of.write(ieeg_json("Resting", chan_types, raw.info.get("sfreq"), raw.duration, refpair))
of.close()

# 5) get electrode info
bs_electrode_path = os.path.join(bsprefix, shortsubj, shortsubj + "_electrodes.tsv")
electrodes_tsv_path = os.path.join(dirs["postop_ieeg"], subjstr + "_ses-postop_space-MNI_electrodes.tsv")
shutil.copy(bs_electrode_path, electrodes_tsv_path)

bidst1path = "/".join(t1targetpath.split("/")[5:])
electrode_json_str = "{\n" \
    + "\t\"IntendedFor\": \"bids::" + bidst1path + "\",\n" \
    + "\t\"iEEGCoordinateSystem\": \"MNI\",\n" \
    + "\t\"iEEGCoordinateUnits\": \"mm\",\n" \
    + "\t\"iEEGCoordinateSystemDescription\": \"MNI\",\n" \
    + "\t\"iEEGCoordinateProcessingDescription\": \"none\",\n" \
    + "\t\"iEEGCoordinateProcessingReference\": \"n/a\"\n" \
    + "}"

coords_json_path = os.path.join(dirs["postop_ieeg"], subjstr + "_ses-postop_space-MNI_coordsystem.json")
of = open(coords_json_path, 'w')
of.write(electrode_json_str)
of.close()

# 6) get recon pdf
reconpath = os.path.join(subj_opsceadir, "Imaging", "Recon", shortsubj + "_recon.pdf")
recontargetpath = os.path.join(dirs["postop_ieeg"], subjstr + "_ses-postop_photo.pdf")
shutil.copy(reconpath, recontargetpath)
