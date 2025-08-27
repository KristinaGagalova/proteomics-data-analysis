# Various experiments in proteomics

## Overall technology differences 

## 1) MS/MS
MS/MS means you fragment ions and record MS2 spectra. DDA, DIA, PRM, SRM are different ways of choosing which ions to fragment, so each of them produces MS2 data (i.e., each is a form of MS/MS).
```
(LC–MS run)
      │
   MS1 survey  ──>  a chooser decides which ions to fragment  ──>  MS2 spectra (MS/MS)
                    └─ DDA: top-N peaks right now
                    └─ DIA: sweep wide m/z windows (fragment everything in each window)
                    └─ PRM: a preset list of target m/z (high-res MS2)
                    └─ SRM: preset transitions on a triple quad (low-res MS2 traces)
```
## Quick gloss
* DDA (data-dependent): After each MS1, pick the top N precursors, isolate narrowly, fragment → MS2.
* DIA (data-independent): Step through wide, tiled windows, fragment everything in each window → MS2 that software deconvolves.
* PRM (parallel reaction monitoring): Targeted list; record full MS2 at high resolution for each target.
* SRM/MRM (selected/multiple reaction monitoring): On a triple quadrupole, follow predefined precursor→fragment transitions (tandem, but very targeted).

## 2) MALDI-TOF(/TOF)
MALDI-TOF = Matrix-Assisted Laser Desorption/Ionization + Time-of-Flight analyzer. Typically used without LC, often MS1-only for peptide mass fingerprinting, MALDI imaging, and rapid microbial ID. It’s not the LC–ESI top‑N DDA setup.
MALDI-TOF/TOF adds a second TOF stage to perform MS/MS (fragmentation) in a MALDI context. Still MS/MS, but acquisition and sample handling differ (spot on target plate vs. gradient LC), and common LC workflows (e.g., match‑between‑runs, DIA windows, TMT SPS‑MS3) generally don’t apply.

* How to recognize in files
LC–ESI systems: look for electrospray ionization, analyzers like Orbitrap, quadrupole, time-of-flight, and many ms level="2" scans.
MALDI systems: look for matrix-assisted laser desorption/ionization and analyzers time-of-flight; classic MALDI-TOF runs may have few or no MS2 unless it’s TOF/TOF.

## More details on fragment choice in fragments - MS/MS
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
* Repeat.
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

## Cheat-sheet of technologies side by side
| Aspect          | DDA (LFQ)         | DIA (LFQ)            | TMT/iTRAQ (MS2)     | TMT (SPS-MS3)                 |
| --------------- | ----------------- | -------------------- | ------------------- | ----------------------------- |
| Scan logic      | Top-N precursors  | Wide, tiled windows  | Top-N (MS2)         | Top-N with extra MS3          |
| Missing values  | More              | Few                  | Few within plex     | Few within plex               |
| Multiplexing    | No                | No                   | Yes (10–18)         | Yes (10–18)                   |
| Quant source    | MS1 intensities   | Deconvolved MS2      | Reporter ions @ MS2 | Reporter ions @ MS3 (cleaner) |
| Throughput      | Medium–High       | High for cohorts     | Very high per run   | High (slower than MS2)        |
| Cost/complexity | Low–Medium        | Medium (software)    | Higher (labels)     | Highest (labels + MS3)        |
| Best for        | General discovery | Cohorts, consistency | Many samples, PTMs  | Many samples, best accuracy   |


## Why it matters
Because the instrument only fragments the top N at each moment, some lower-intensity peptides may be missed—that’s why DDA can have more missing values across runs than DIA.
But each MS2 targets a single precursor, so IDs are usually very clean.

## How to spot it in your mzML
You’ll see a repeating pattern of one ms level="1" spectrum followed by N ms level="2" spectra, each MS2 carrying a selected precursor m/z and a narrow isolation window.

## Protein modifications
You can “see” some PTMs from almost any LC–MS/MS dataset, but for reliable identification and site-level quant you usually need a PTM-specific protocol (enrichment and/or special fragmentation). Here’s how it breaks down:

## 1) What works without a special protocol (opportunistic)
Common/stable mods (Oxidation M, Acetyl protein N-term, Carbamidomethyl C) are routinely detected in any DDA/DIA run.
You can run an open search on your current mzML to discover unexpected mass shifts; then do a targeted closed search for the real analysis. (Still, sensitivity for low-stoichiometry PTMs will be limited without enrichment.)

## 2) When you really want a PTM-specific protocol
### Phosphorylation (pS/T/Y)
Enrich: IMAC/TiO₂/Fe-NTA.
Fragmentation: HCD with stepped NCE is fine; EThcD improves localization.
Acq. modes: DDA (classic) or DIA (now very good, esp. library-free).
Search: add Phospho(STY), limit max variable mods/peptide, site-level FDR; report localization prob thresholds (e.g., ≥0.75/0.9).
Quant: LFQ, TMT (often SPS-MS3), or DIA; use MSstatsPTM to adjust for protein abundance.
### Ubiquitin remnant (K-ε-GG / diGly +114.0429)
Enrich: anti-K-ε-GG antibodies.
Fragmentation: HCD DDA; TMT works very well for coverage.
Search: GlyGly(K) variable mod; cap mods/peptide; site-level reporting.
### Acetylation (Kac +42.0106; N-term)
Enrich: anti-acetyl-lysine (histone workflows often include derivatization).
Fragmentation: HCD; EThcD helps for combinatorial histone marks.
Search: Acetyl(K) + Acetyl(Protein N-term); consider methyl states for histones.
### Glycosylation (N- and O-glyco; labile)
Enrich: HILIC/lectins; consider PNGase F for N-glyco (mind deamidation artifacts).
Fragmentation: HCD for oxonium ions plus EThcD for site/backbone.
Search: dedicated engines (MSFragger-Glyco, pGlyco/Byonic); require diagnostic ions; site-level FDR with glycan form + site.
ADP-ribosylation & other labile PTMs
Enrich: specific chemistries/antibodies.
Fragmentation: ETD/EThcD is often essential.

Comment: General proteome DDA/DIA usually won’t localize these well without a targeted method.

## How acquisition strategy affects PTMs
DDA (top-N): excellent IDs, widely used for phospho/diGly/acetyl with enrichment. Missing values can be higher across many samples.
DIA: great reproducibility; phospho-DIA is strong (site scores/classes supported). Glyco/very labile PTMs are improving but still benefit from ETD-based DDA libraries.
TMT (MS2 or SPS-MS3): superb for multiplexed PTM studies (phospho, ubiquitylome); SPS-MS3 reduces ratio compression.
PRM/SRM: for validating known PTM sites (targeted, not discovery).
MALDI-TOF: typically not used for large-scale PTM mapping; MALDI-TOF/TOF can do MS/MS on selected peptides but lacks LC separation and routine localization depth seen in LC–ESI methods.

## Minimal “if all you have is a regular proteome run”
* Run an open search (find mass shifts).
* Pick the PTM(s) you care about → closed search with that PTM as a variable mod; cap total variable mods per peptide.
* Require localization (ptmRS/PTMProphet/etc.) and control site-level FDR.
* Interpret cautiously: without enrichment your coverage of true PTM sites is limited and biased to abundant peptides.
