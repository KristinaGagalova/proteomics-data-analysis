## Various experiments in proteomics

## 1) DDA — Data-Dependent Acquisition (discovery, classic)
How it scans: Each cycle does a full MS1 scan, then picks the “top N” strongest precursor peaks to fragment (MS2).
What you get: Identified peptides for the selected precursors; others may be missed.
Quant options:
* Label-free (LFQ): compare MS1 intensities across runs.
* Isobaric tags (TMT/iTRAQ): see below (still often acquired as DDA).
Pros: High ID quality; simple to run; tons of tools.
Cons: Missing values across runs (stochastic selection); depth varies run-to-run.

## 2) DIA — Data-Independent Acquisition (coverage & consistency)
How it scans: Instead of picking peaks, it fragments everything in a series of wide, tiled m/z windows (e.g., 8–25 m/z), every cycle.
What you get: MS2 spectra that are mixtures; software deconvolves which fragments belong to which precursors.
Quant: Typically label-free (library-free or library-based analysis).
Pros: Fewer missing values, very reproducible quant, great for cohorts.
Cons: Heavier computation; site/PTM localization can be trickier without tailored methods.

## 3) Isobaric tags — TMT / iTRAQ (sample multiplexing)
What it is: You chemically label up to 10–18 samples so they co-elute and co-fragment; quantify by reporter ions (low m/z peaks unique per channel).
How it’s acquired:
* MS2 quant: reporter ions read at MS2 (simpler, but more interference).
* SPS-MS3 quant: an extra MS3 step reduces interference (“ratio compression”), preferred on Thermo tribrids.
Pros: Many samples per run; precise relative quant within a plex; great for PTM enrichments too.
Cons: Costs more; batch effects across plexes; MS2 mode can suffer interference; MS3 costs some ID/scan time.

## 4) Targeted — PRM / SRM (validation, few targets)
How it scans: Monitors predefined peptides only (no discovery).
Pros: Very sensitive, very precise.
Cons: Not for discovery.

## How to tell them apart in your files (quick signs)
DIA: MS2 isolation windows are wide and patterned (e.g., 8–25 m/z stepping across the range).
DDA: MS2 isolation windows are narrow (~0.7–2.0 m/z) and tied to individual precursors.
TMT/iTRAQ present: Strong reporter peaks (~126–134 m/z for TMT/TMTpro; ~113–121 m/z for iTRAQ).
SPS-MS3: You actually see MS3 scans in the file.

## When to use which (rule-of-thumb)
Exploratory discovery / standard proteome profiling: DDA LFQ (or DIA if you want fewer missing values across many samples).
Large cohorts needing robust quant with low missingness: DIA.

Many samples but limited instrument time; precise within-batch relative quant: TMT (ideally SPS-MS3).
Confirm a shortlist of biomarkers: PRM/SRM.

## About M1 and M2 - What “top-N DDA” actually does
During a run, the instrument repeats the same little routine (a cycle) over and over while peptides elute from the LC:
* MS1 survey (look at everything).
The mass spec scans a whole m/z range (e.g., 350–1,650) and records all peaks = precursor ions.

* Rank peaks by strength.
From that MS1, it sorts peaks by intensity, applies simple filters (charge 2–6, not on exclude list, above a minimum intensity).
* Pick the “top N”.
It chooses the top N remaining peaks (e.g., N=10, 15, 20).
* Isolate & break them one by one.
For each chosen peak, the quadrupole isolates a narrow window (≈0.7–2.0 m/z) around that m/z, fragments it (e.g., HCD), and records a MS2 spectrum (the fragments used to identify the peptide).
# Repeat.
After N MS2s, it does another MS1 and repeats the process the whole chromatographic run.

Tiny timeline:
```
[ MS1 ] → [ MS2 #1 ] [ MS2 #2 ] … [ MS2 #N ] → [ MS1 ] → repeat …
```
* Key knobs you’ll see in methods
Top N: how many MS2 per cycle (e.g., Top15).
Isolation width: how narrow the quad targets (≈0.7–1.6 m/z typical).
Dynamic exclusion: once a precursor is fragmented, don’t pick it again for X seconds (e.g., 20–60 s), so you sample more unique peptides.

AGC / max injection time / resolution / NCE: control signal quality and speed.

## Why it matters
Because the instrument only fragments the top N at each moment, some lower-intensity peptides may be missed—that’s why DDA can have more missing values across runs than DIA.
But each MS2 targets a single precursor, so IDs are usually very clean.

## How to spot it in your mzML
You’ll see a repeating pattern of one ms level="1" spectrum followed by N ms level="2" spectra, each MS2 carrying a selected precursor m/z and a narrow isolation window.
