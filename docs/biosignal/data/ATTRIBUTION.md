# Data attribution

The three excerpts in this directory are cut from public PhysioNet recordings.
PhysioNet files are released under the **Open Data Commons Attribution License v1.0
(ODC-By 1.0)**; the licence of each record must be checked on its PhysioNet landing page
(`MANIFEST.json` lists exact source URLs and SHA-256 of the raw downloads).

| File | Signal | Source | Excerpt |
|---|---|---|---|
| `eeg_oz.csv` | EEG, scalp electrode Oz, eyes closed | Schalk G. *EEG Motor Movement/Imagery Dataset* v1.0.0, PhysioNet. DOI 10.13026/C28G6P. Subject S001, run R02 | 4 s from t = 10 s, 160 Hz |
| `emg_tibialis.csv` | EMG, needle electrode in tibialis anterior | *Examples of Electromyograms* (emgdb) v1.0.0, PhysioNet. Healthy 44 y male (data courtesy of S. Rutkove, MD) | 1 s of strongest activity, 4 kHz |
| `ecg_mitdb100.csv` | ECG, lead MLII | Moody GB, Mark RG. *The impact of the MIT-BIH Arrhythmia Database.* IEEE Eng Med Biol 20(3):45-50 (2001); Goldberger AL et al., *PhysioBank, PhysioToolkit, and PhysioNet*, Circulation 101(23):e215-e220 (2000). Record 100 | 4 s from t = 5 s, 360 Hz |

Processing (see `fetch_data.py`): converted to volts at the electrode using the
gain/units in the file headers, the mean of the window removed, time shifted to start
at 0. No filtering or resampling. The full records are not stored in the repo;
`python3 fetch_data.py` downloads them to `raw/` (git-ignored) and regenerates the CSVs.
