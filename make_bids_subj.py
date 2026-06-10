#!/usr/bin/python

import os, sys, shutil, glob, mne

# right now need to use python 3.11 for this (do conda activate clean_eeg):
import matlab.engine 
    
fsdir = '/Applications/freesurfer/subjects'
bsprefix = "/Users/aaron/Documents/brainstorm_db/IEEG_visualization/data/"
opsceaprefix = "/Users/aaron/Documents/MATLAB/OPSCEA-main/OPSCEADATA"

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

def get_preop_mri(subjstr, subj_fsdir, preop_anat_path, ts1str, t1targetpath):
    t1mridir = os.path.join(subj_fsdir, "mri", "orig")
    t1sourcepath = os.path.join(t1mridir, "001.nii.gz")

    if not os.path.isfile(t1sourcepath):
        # convert MRI to NIFTI if necessary
        comm = "pushd .; cd " + t1mridir + "; /Applications/freesurfer/bin/mri_convert 001.mgz 001.nii.gz; popd"
        print(comm)
        os.system(comm)

    shutil.copy(t1sourcepath, t1targetpath)

def get_postop_ct(subjstr, subj_fsdir, postop_anat_path):
    ctlinkstr = subjstr + "_ses-postop_CT.nii.gz"
    ctdir = os.path.join(subj_fsdir, "ct")
    ctsourcepath = glob.glob(os.path.join(ctdir, '*.nii.gz'))[0]
    shutil.copy(ctsourcepath, os.path.join(postop_anat_path, ctlinkstr))

def get_seeg_channels(eng, bsprefix, subj, matfile):
    matfile_parts = matfile.split("/")
    bspath = os.path.join(bsprefix, subj, subj + "_" + matfile_parts[0], "channel.mat")
    ll = eng.get_seeg_channels(bspath)
    return list(map(lambda x: int(x), ll[0]))

def ieeg_json(task, description, chan_types, srate, dur, refpair):
    if len(refpair)==2:
        ref1 = refpair[0]
        ref2 = refpair[1]
    else:
        ref1 = "A5"
        ref2 = "A6"

    # to do: check hardwarefilters, add sz onset time and channels to taskdescription
    json_str =  "{\n" \
        + "\t\"TaskName\":\"" + task + "\",\n" \
        + "\t\"InstitutionName\":\"University of Colorado Hospital\",\n" \
        + "\t\"InstitutionAddress\":\"1635 Aurora Ct, Aurora CO 80045\",\n" \
        + "\t\"Manufacturer\":\"Nihon Kohden\",\n" \
        + "\t\"ManufacturersModelName\":\"n/a\",\n" \
        + "\t\"TaskDescription\":\"" + description + "\",\n" \
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

def get_edfs(fullsubj, shortsubj, subjstr, bsprefix, reference_dict, subj_fsdir, postop_ieeg_path):
    # Start the MATLAB engine
    eng = matlab.engine.start_matlab()
    eng.addpath('/Users/aaron/Documents/school/4202/thalamic_seeg')
    mf = eng.get_sz_info(fullsubj)
    chan_types = get_seeg_channels(eng, bsprefix, shortsubj, mf['eegfiles'][0])
    # Stop the engine when finished
    eng.quit()

    try:
        refpair = reference_dict[fullsubj]
    except KeyError:
        print("Reference info not found for " + fullsubj)
        refpair = []

    for i,f in enumerate(mf['eegfiles']):
        fparts = f.split("/")
        dirfrag = shortsubj + "_" + fparts[0]
        edfsource_name =  dirfrag + ".edf"
        edfsource_path = os.path.join(subj_fsdir, "eeg", edfsource_name)
        raw = mne.io.read_raw_edf(edfsource_path, verbose=False)
        target_stem = subjstr + "_ses-postop_task-seizure%03d_ieeg" % i
        edftarget_name = target_stem + ".edf"
        edftarget_path = os.path.join(postop_ieeg_path, edftarget_name)
        shutil.copy(edfsource_path, edftarget_path)
        jsontarget_name  = target_stem + ".json"
        jsontarget_path = os.path.join(postop_ieeg_path, jsontarget_name)
        of = open(jsontarget_path, 'w')
        description = "sz_onset_time_s: " + str(mf['sz_onset_s'][0][i]) + "; IOZ: " + str(mf['ioz'])
        of.write(ieeg_json("Seizure", description, chan_types, raw.info.get("sfreq"), raw.duration, refpair))
        of.close()

    # 4) get resting state EEG
    edfsource_path = glob.glob(os.path.join(subj_fsdir, "eeg", "*resting.edf"))[0]
    target_stem = subjstr + "_ses-postop_task-resting_ieeg"
    edftarget_name = target_stem + ".edf"
    edftarget_path = os.path.join(postop_ieeg_path, edftarget_name)
    shutil.copy(edfsource_path, edftarget_path)
    jsontarget_name  = target_stem + ".json"
    jsontarget_path = os.path.join(postop_ieeg_path, jsontarget_name)
    raw = mne.io.read_raw_edf(edfsource_path, verbose=False)
    of = open(jsontarget_path, 'w')
    of.write(ieeg_json("Resting", "n/a", chan_types, raw.info.get("sfreq"), raw.duration, refpair))
    of.close()

def get_electrode_info(bsprefix, shortsubj, subjstr, t1targetpath, postop_ieeg_path):
    bs_electrode_path = os.path.join(bsprefix, shortsubj, shortsubj + "_electrodes.tsv")
    electrodes_tsv_path = os.path.join(postop_ieeg_path, subjstr + "_ses-postop_space-MNI_electrodes.tsv")
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

    coords_json_path = os.path.join(postop_ieeg_path, subjstr + "_ses-postop_space-MNI_coordsystem.json")
    of = open(coords_json_path, 'w')
    of.write(electrode_json_str)
    of.close()

def get_recon_pdf(subj_opsceadir, shortsubj, postop_ieeg_path, subjstr):
    reconpath = os.path.join(subj_opsceadir, "Imaging", "Recon", shortsubj + "_recon.pdf")
    recontargetpath = os.path.join(postop_ieeg_path, subjstr + "_ses-postop_photo.pdf")
    shutil.copy(reconpath, recontargetpath)

def do_all(fullsubj, topdir, fsdir, bsprefix, opsceaprefix, reference_dict):
    hasshort = ['UCHSN230406', 'UCHGG230823', 'UCHVG230719', 'UCHDR220801', 'UCHAK240403']
    if fullsubj in hasshort:
        shortsubj = fullsubj[:5]
    else:
        shortsubj = fullsubj
    subjstr = "sub-" + fullsubj
    subj_fsdir = os.path.join(fsdir, shortsubj)
    subj_opsceadir = os.path.join(opsceaprefix, shortsubj)

    dirs = {"preop_anat": os.path.join(topdir, subjstr, "ses-preop", "anat"),
            "postop_anat": os.path.join(topdir, subjstr, "ses-postop", "anat"),
            "postop_ieeg": os.path.join(topdir, subjstr, "ses-postop", "ieeg")}

    print("***** Exporting: " + fullsubj)
    # make dirs
    for d in dirs.values():
        if not os.path.exists(d):
            os.makedirs(d)

    # 1) get preop MRI
    t1str = subjstr + "_ses-preop_acq-iso_T1w.nii.gz"
    t1targetpath = os.path.join(dirs["preop_anat"], t1str)
    get_preop_mri(subjstr, subj_fsdir, dirs["preop_anat"], t1str, t1targetpath)

    # 2) get postop CT
    get_postop_ct(subjstr, subj_fsdir, dirs["postop_anat"])

    # 3) get seizure + resting state EDFs
    get_edfs(fullsubj, shortsubj, subjstr, bsprefix, reference_dict, subj_fsdir, dirs["postop_ieeg"])

    # 4) get electrode info
    if fullsubj=="UCHCV220919":
        shortsubj = "UCHCV220919v2"
        subj_opsceadir = os.path.join(opsceaprefix, shortsubj)
    get_electrode_info(bsprefix, shortsubj, subjstr, t1targetpath, dirs["postop_ieeg"])

    # 5) get recon pdf
    get_recon_pdf(subj_opsceadir, shortsubj, dirs["postop_ieeg"], subjstr)

if __name__=="__main__":

    if len(sys.argv)==3:
        topdir = sys.argv[2]
        subjlist = [sys.argv[1]]
    else:
        if len(sys.argv)==2:
            topdir = "/Users/aaron/Downloads/thalamic_seeg_exports/rawdata"
            subjlist = [sys.argv[1]]
        else:
            topdir = "/Users/aaron/Downloads/thalamic_seeg_exports/rawdata"
            subjlist = ["UCHAK240403", "UCHAM250108", "UCHDR220801",
                        "UCHDR240313", "UCHGG230823", "UCHSM240205",
                        "UCHSN230406", "UCHVG230719", "UCHCV220919"]

            # to be analyzed: UCHJR250122, UCHTD250331

    for s in subjlist:
        do_all(s, topdir, fsdir, bsprefix, opsceaprefix, reference_dict)
