# Pipeline for proteomics data analysis

## 0) Eexperiment type

* DDA label-free (most common): LFQ across runs.
* Isobaric tags (TMT/iTRAQ): reporter-ion quant.
* DIA (SWATH etc.): library-free or library-based quant.
If unsure: assume DDA label-free.

## 1) Convert vendor .raw → open format

Why: portability, QC, and many tools require mzML.

Tools:
* ProteoWizard msconvert (GUI/CLI)
* ThermoRawFileParser (fast, headless)
Output: mzML (profile or centroided; most search engines accept centroided)

Tips:
* Keep original RAWs.
* Centroid on MS2 for Orbitrap HCD; leave MS1 profile if you plan feature finding.

## 2) QC the raw data
* Goal: catch instrument/run issues before deep analysis.
* Tools: PTXQC, RawTools, MSQC.
* Check: ID rate, MS1/MS2 counts, mass accuracy, TIC stability, chromatography, missed cleavages, digestion efficiency, iRT spike-in stability (if used).

## 3) Build/choose the protein database
* Start: UniProt reference proteome for your organism (+ isoforms if needed).
* Add: common contaminants (cRAP), decoys (search tools can generate).
* If species-specific project: append your custom FASTA (six-frame if discovery). Add both expected species and possible biological contaminations as a control.    

## 4) Search & FDR control (pick one ecosystem)
### A) Fast, accurate, easy (recommended for DDA)
* FragPipe suite (GUI) = MSFragger (search) + Philosopher (validation) + IonQuant/Label-Free Quant:
* Enzyme: Trypsin/P (2 missed cleavages)
* Fixed mods: Carbamidomethyl (C)
* Variable mods: Oxidation (M), Acetyl (Protein N-term)
* (Add Phospho (S/T/Y) if PTM study)

Tolerances (Orbitrap HCD):
* Precursor: 10–20 ppm
* Fragment: 0.02 Da (Orbitrap MS2) or 0.5 Da (ion trap)
* FDR: 1% at PSM/peptide/protein with target–decoy (PeptideProphet/ProteinProphet)
* Protein inference: Occam’s razor (default)

### B) All-in-one alternative
* MaxQuant (LFQ via MaxLFQ) with Perseus downstream.

### C) Other solid engines
* Comet/X!Tandem + Percolator (FDR rescoring)
* OpenMS workflows (KNIME / CLI)
* SearchGUI + PeptideShaker (multi-engine meta-analysis)

## 5) Quantification
* DDA, label-free
* FragPipe IonQuant or MaxQuant LFQ
* Match-between-runs (MBR): helpful but evaluate false transfers; prefer library-based matching when possible.
* Isobaric (TMT/iTRAQ)

Enable reporter-ion extraction:
* FragPipe (TMT-Integrator) or MaxQuant TMT
* Set correction factors from the kit
* Normalization: channel-wise, batch correction across plexes; consider MSstatsTMT downstream.

DIA
* Tools: DIA-NN (excellent library-free or library-based), Spectronaut, EncyclopeDIA.
* Use iRT peptides or empirical iRT for retention alignment.
* Library-free (pseudo-library) is strong on modern data.

## 6) Post-processing, normalization, and missing values
Normalize:
* LFQ: global intensity normalization (median/quantile).
* TMT: within-run normalization + batch correction across plexes.
Missing values:
* MCAR (random): low-impact imputation (e.g., KNN).
* MNAR (low-abundance dropouts): left-censored imputation (e.g., DEP’s “MinProb”).
Avoid aggressive imputation before QC plots; analyze pattern first.

## 7) Statistics & differential analysis
R packages:
* MSstats (LFQ/DIA), MSstatsTMT (TMT), DEP (easy LFQ), limma pipeline on log-transformed intensities.
* Design matrix: encode condition, batch, and pairing (if applicable).
* Multiple testing: Benjamini–Hochberg FDR at protein (or peptide) level.
* Outputs: volcano plots, heatmaps, PCA, sample QC dendrograms.

## 8) Annotation & pathway biology
* Map UniProt IDs ↔ gene symbols.
* Enrichment: clusterProfiler, g:Profiler, reactomePA, GSEA.
* Optionally integrate with proteoform/PTM site data (localization with ptmRS/Ascore/PTMProphet before site-level tests).

## 9) Reporting & reproducibility
* Save: parameter files, software versions, FASTA checksums, QC reports, FDR tables.
* Containerize for reuse: nf-core/proteomics pipelines (DDA, DIA, TMT), Galaxy workflows, or Nextflow/Snakemake around FragPipe/DIA-NN.
* Organize outputs per run: raw/, mzML/, id/, quant/, stats/, reports/.

Quickstarts
A) DDA label-free with FragPipe (GUI)
* Convert .raw → mzML (msconvert).

In FragPipe:
* Load mzML files; add FASTA (with contaminants).
* “MSFragger”: set enzyme/mods/tolerances as above.
* “Philosopher”: FDR at 1% (PSM/peptide/protein).
* “IonQuant”: enable LFQ; optionally enable MBR.

Export protein groups + intensities.
* In R: DEP/MSstats for stats; BH-FDR; plots.

### B) TMT (FragPipe)
* Same as above, but enable TMT-Integrator:
* Set reporter set (e.g., TMTpro 16/18-plex), correction factors, normalization.
* Export channel intensities → MSstatsTMT for differential testing.

### C) DIA with DIA-NN
* Convert .raw → mzML (profile MS1 ok).
* DIA-NN: library-free or use a spectral library (Pan- or project-specific).
* Export protein matrix → MSstats for inference.
* Sensible defaults (Orbitrap HCD, tryptic)
* Enzyme: Trypsin/P; missed cleavages: 2
* Fixed: Carbamidomethyl (C)
* Variable: Oxidation (M), Acetyl (Protein N-term)
* Precursor tol: 10–20 ppm; Fragment tol: 0.02 Da (Orbitrap MS2)
* FDR: 1% at PSM/peptide/protein
* Min peptides per protein: 1–2 (report both; prefer ≥2 unique for claims)

Pitfalls to avoid
* Searching the wrong FASTA (species/mismatch).
* Forgetting contaminants/decoys.
* Over-using MBR (can inflate IDs); always verify with QC plots.
* Mixing centroiding settings across samples.
* Imputing before checking missingness mechanism.

## Refereces:
[Deutsch EW. File formats commonly used in mass spectrometry proteomics. Molecular & cellular proteomics. 2012 Dec 1;11(12):1612-21.](https://www.sciencedirect.com/science/article/pii/S1535947620334575)
