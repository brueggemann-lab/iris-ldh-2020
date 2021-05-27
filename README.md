# iris-ldh-2020

Investigation of changes in rates of invasive bacterial disease during the early phase of the COVID-19 pandemic.

[Brueggemann AB, Jansen van Rensburg MJ, Shaw D, McCarthy N, Jolley KA, Maiden MCJ, van der Linden MPG et al. "Changes in the incidence of invasive disease due to *Streptococcus pneumoniae*, *Haemophilus influenzae*, and *Neisseria meningitidis* during the COVID-19 pandemic in 26 countries and territories in the Invasive Respiratory Infection Surveillance Initiative: a prospective analysis of surveillance data." The Lancet Digital Health 3, no. 6 (2021): e360-e370.](https://www.thelancet.com/journals/landig/article/PIIS2589-7500(21)00077-7/fulltext)


## Guide to raw data files

### Case data for invasive bacterial infections provided by members of the IRIS Initiative
* _Note: It is not possible to share these data because doing so would risk identifying individual cases of invasive disease._ 
* dummy_iris_sp_13102020.xlsx - dummy _S. pneumoniae_ dataset provided to show data format (one per organism, downloaded from PubMLST)

### Oxford COVID-19 Government Response Tracker (OxCGRT)
* oxcgrt_13102020.csv - analysed dataset (downloaded 13/10/2020)
* [Most recent dataset available here](https://www.bsg.ox.ac.uk/research/research-projects/covid-19-government-response-tracker)

### Google COVID-19 Community Mobility Reports (Google CCMR)
* global_mobility_report_13102020.csv.zip - analysed dataset (downloaded 13/10/2020)
* [Most recent dataset available here](https://www.google.com/covid19/mobility/)


## Guide to code files

Code files are organised in sub-directories corresponding to indvidual analyses/figures as follows:

### ./code/data_processing_and_visualisation
Processing and visualisation of invasive disease data, OxCGRT data, and Google CCMR data (Figures 1-3 and S2-S4).

> `data_processing_and_visualisation.py` - Python export of Jupyter Notebook, input files in ./data

> `data_processing_and_visualisation.html` - HTML export of Jupyter Notebook (to be viewed in web browser)

### ./code/interrupted_time_series
Interrupted time series analyses (Figure S1)

> `interrupted_time_series_all_pathogens.do` - STATA file, analysis of combined data across countries for each pathogen

> `mixed_effects_interrupted_time_series.do` - STATA file, analysis of per country data for _S. pneumoniae_

### ./code/meta-analysis
Interrupted time series with meta-analysis of per country estimates for _S. pneumoniae_ (Figure 4)

> `meta-analysis.do` - STATA file 

> `meta-analysis_forest_plot.R` - R code to generate forest plots for meta-analysis

## License

Distributed under the GNU General Public License v3.0. See `LICENSE` for more information.


## Contact

* Melissa Jansen van Rensburg - melissa.jansenvanrensburg@ndph.ox.ac.uk / @theflyingturtle
* Noel McCarthy - noel.mccarthy@tcd.ie
* David Shaw - david.shaw2@dph.ox.ac.uk
* Angela Brueggemann - angela.brueggemann@ndph.ox.ac.uk / @angelabrueggemann
