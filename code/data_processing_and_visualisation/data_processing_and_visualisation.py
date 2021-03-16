
# coding: utf-8

# # Supplementary file: The Invasive Respiratory Infection Surveillance (IRIS) Initiative reveals significant reductions in invasive bacterial infections during the COVID-19 pandemic
# 
# ## Code required to reproduce data summaries, Figures 1-3, Supplementary Figures 2-4, and input files used in statistical analyses.

# In[1]:


import pandas as pd
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import matplotlib.ticker as plticker
import numpy as np
import pathlib
import seaborn as sns
import time

from matplotlib import cm
from matplotlib import colors
from matplotlib.colors import LinearSegmentedColormap

plt.rcParams['svg.fonttype'] = 'none' # Ensure SVGs contain editable text
sns.set_style('whitegrid')
sns.set_palette('pastel')


# In[2]:


# Define study period and years
STUDY_START = '2018-01-01'
STUDY_END = '2020-05-31'
STUDY_YEARS = [2018, 2019, 2020]

# List all IRIS countries for use in Google COVID-19 Community Mobility Reports analyses
# England, Scotland, Wales, and Northern Ireland to be grouped as United Kingdom
IRIS_COUNTRIES = ['Belgium', 'Brazil', 'Canada', 'China', 'Czech Republic', 'Denmark', 'Finland', 'France', 
                  'Germany', 'Hong Kong', 'Iceland', 'Ireland', 'Israel', 'Luxembourg', 'Netherlands', 'New Zealand',
                  'Poland', 'South Africa', 'South Korea', 'Spain', 'Sweden', 'Switzerland', 'United Kingdom',
]


# ## Read data files
# 
# We analysed the following datasets:
# 
#  - PubMLST IRIS bacterial isolate data for *S. pneumoniae*, *H. influenzae*, *N. meningitidis*, and *S. agalactiae* (downloaded 13/10/2020)
#  - Oxford COVID-19 Government Response Tracker (OxCGRT) dataset (downloaded 13/10/2020)
#  - Google COVID-19 Community Mobility Reports dataset (downloaded 13/10/2020)
#  
# Note that 'year' and 'week' in downstream analyses are based on ISO 8601 year- and week-numbering. For IRIS bacterial isolate data,  ISO year ('isoyear_sampled') and ISO week ('week_sampled') fields were populated in PubMLST by BIGSdb software based on sampling date ('date_sampled').  For the other datasets, dates were assigned to ISO year and ISO week using the strftime method (see below).

# In[3]:


### Read data files ###

# Load IRIS bacterial isolate datasets exported from PubMLST, specifying the organism for each
iris_sp = pd.read_excel('IRIS_Sp_13102020.xlsx', parse_dates=['date_sampled', 'date_received'])
iris_sp['species'] = 'S. pneumoniae'

iris_hi = pd.read_excel('IRIS_Hi_13102020.xlsx', parse_dates=['date_sampled', 'date_received'])
iris_hi['species'] = 'H. influenzae'

iris_nm = pd.read_excel('IRIS_Nm_13102020.xlsx', parse_dates=['date_sampled', 'date_received'])
iris_nm['species'] = 'N. meningitidis'

iris_sa = pd.read_excel('IRIS_Sa_13102020.xlsx', parse_dates=['date_sampled', 'date_received'])
iris_sa['species'] = 'S. agalactiae'

# Load OxCGRT dataset
grt = pd.read_csv(
    "oxcgrt_13102020.csv",
    parse_dates=['Date'],
    low_memory=False,
)

# Load Google COVID-19 Community Mobility Reports dataset
google_data = pd.read_csv(
    "global_mobility_report_13102020.csv",
    parse_dates=["date"],
    low_memory=False,
)


# ## Set up output directories

# In[4]:


### Set up output directories ###

# Create parent output directory
path = pathlib.Path("IRIS_manuscript_outputs_{}".format(time.strftime("%Y%m%d-%H%M%S")))
path.mkdir()

# Create a sub-directory for each figure and one for data and summaries
figureone = path/"figure_1"
figureone.mkdir()

figuretwo = path/"figure_2"
figuretwo.mkdir()

figurethree = path/"figure_3"
figurethree.mkdir()

datasummaries = path/"data_and_summaries"
datasummaries.mkdir()

# Create sub-directory within data_and_summaries for publication datasets
# The datasets in this sub-directory were used in downstream statistical analyses
datasets = datasummaries/"publication_datasets"
datasets.mkdir()


# ## Processed IRIS bacterial isolate data
# 
# To start, we processed the IRIS bacterial isolate data as follows:
# 
# - Merged organism-specific datasets exported from PubMLST into a single dataframe
# - Excluded isolates from outside the study period
# 
# 
# We also updated subsequent dataframes/summaries to indicate that Iceland reported no *N. meningitidis* isolates during the study period.

# In[5]:


### Process IRIS bacterial isolate data ###

# Rename 'diagnosis' column in S. pneumoniae dataframe to match other datasets
iris_sp.rename(columns={"diagnosis": "disease"}, inplace=True)

# Merge organism-specific dataframes into single dataframe containing only key columns
key_cols = ['id', 'isolate', 'aliases', 'species', 'country', 'continent', 'year', 'date_sampled', 
            'isoyear_sampled', 'week_sampled', 'date_received', 'non_culture']
iris_orgs = pd.concat([iris_sp.reindex()[key_cols], 
                       iris_hi.reindex()[key_cols], 
                       iris_nm.reindex()[key_cols], 
                       iris_sa.reindex()[key_cols],
])

# Replace PubMLST country names to match OxCGRT
iris_orgs.replace({
    'The Netherlands': 'Netherlands', 
    'China [Hong Kong]': 'Hong Kong',
    'UK [Scotland]': 'Scotland', 
    'UK [England]': 'England',
    'UK [Northern Ireland]': 'Northern Ireland', 
    'UK [Wales]': 'Wales'}, 
    inplace=True
)

# Exclude data from outside the study period
iris_orgs = iris_orgs.loc[iris_orgs['date_sampled'] >= STUDY_START, :]
iris_orgs = iris_orgs.loc[iris_orgs['date_sampled'] <= STUDY_END, :]


# ## Generated basic data summaries
# 
# We generated tables summarising the following:
# 
# - Number of participating IRIS laboratories per organism broken down by continent 
# - Total number of isolates per organism broken down by country
# - Total number of isolates per organism broken down by country and ISO year
# 
# Note that in these tables 'NaN' indicates no data were collected.  This is distinct from '0', which indicates that no isolates were received.
# 
# Tables were saved as: data_and_summaries/publication_summaries.xlsx

# In[6]:


### Generate basic data summaries ###

# Provide breakdown of IRIS laboratories per organism broken down by continent
lab_continent_breakdown = pd.pivot_table(iris_orgs, 
                               values='country', 
                               index=['continent'], 
                               columns=['species'], 
                               aggfunc=lambda x: len(x.dropna().unique()), 
                               margins=True,
)

# Add 1 to Europe N. meningitidis total to account for Iceland
lab_continent_breakdown.loc[pd.IndexSlice['Europe'], ['N. meningitidis']] = lab_continent_breakdown.loc[pd.IndexSlice['Europe'], ['N. meningitidis']] + 1
lab_continent_breakdown


# In[7]:


# Provide total number of isolates per organism broken down by country
country_breakdown = pd.pivot_table(iris_orgs, values='isolate', index=['country'], columns=['species'], aggfunc='count', margins=True)

# Assign 0 to Iceland N. meningitidis
country_breakdown.loc[pd.IndexSlice['Iceland'], ['N. meningitidis']] = 0

country_breakdown


# In[8]:


# Provide total number of isolates per organism broken down by country and year
country_time_breakdown = pd.pivot_table(iris_orgs, values='isolate', index=['country'], columns=['species', 'isoyear_sampled'], aggfunc='count', margins=True)

# Assign 0 to Iceland N. meningitidis
country_time_breakdown.loc[pd.IndexSlice['Iceland'], ['N. meningitidis']] = 0

# Write summaries to file
with pd.ExcelWriter(datasummaries/'publication_summaries.xlsx') as writer:  
    lab_continent_breakdown.to_excel(writer, sheet_name='lab_continent_breakdown')
    country_breakdown.to_excel(writer, sheet_name='country_breakdown')
    country_time_breakdown.to_excel(writer, sheet_name='country_time_breakdown')


# ### Saved merged IRIS bacterial isolate dataset
# 
# We saved the merged IRIS bacterial isolate dataset for use in statistical analyses (data_and_summaries/datasets/publication_dataset_iris.csv).  
# 
# Column headers are shown below, with each row in the dataframe corresponding to a bacterial isolate.

# In[9]:


# Save merged IRIS bacterial isolate dataset for use in statistical analyses
iris_orgs.to_csv(datasets/'publication_dataset_iris.csv', index=False, date_format='%Y-%m-%d')
iris_orgs.head(0)


# ## Figure 1. Cumulative curves depicting the number of isolates collected by IRIS laboratories each week from 1 January 2018 through 31 May 2020.
# 
# We aggregated the IRIS bacterial isolate data by species, ISO year, and ISO week to generate global annual cumulative isolate counts for each organism.
# 
# Figure 1 and the underlying data were saved to directory figure_1.

# In[10]:


### Calculate and visualise global annual cumulative isolate counts for each organism ###

# Strip unnecessary metadata columns
iris_orgs.drop(columns=['continent'], inplace=True)

# Calculate total number of isolates per ISO year and week for each organism
base_weekly_counts = pd.pivot_table(iris_orgs, values='isolate', index=['species', 'isoyear_sampled', 'week_sampled'], aggfunc='count')

# Calculate cumulative isolate count per ISO year for each organism
base_weekly_counts['Cumulative isolate count'] = base_weekly_counts.groupby(level=[0,1]).cumsum()


# In[11]:


# Generate figure showing cumulative isolate count per study year faceted on organism
# Add annotation to indicate WHO declaration of COVID-19 pandemic (11/03/2020, ISO week 11)

# Flatten multi-index and clean column names in preparation for graphing
weekly_counts = base_weekly_counts.reset_index()
weekly_counts.rename(columns={"isolate": "Count", "isoyear_sampled": "Year sampled", "week_sampled": "Week of year"}, inplace=True)

# Generate per organism isolate counts to add to facet plot titles
title_counts = weekly_counts.groupby(['species']).sum()['Count'].to_dict()

# Define colour palette and line style
line_styles = {'color': ['#000000', '#000000', '#000000'], 'linestyle': [':', '--' ,'-']}

# Set up facet plot
plt.clf()
g = sns.FacetGrid(weekly_counts, 
        col='species',  
        col_order=['S. pneumoniae', 'H. influenzae', 'N. meningitidis', 'S. agalactiae'],
        hue='Year sampled', 
        hue_kws=line_styles,
        sharey=False,
        margin_titles=True,
)

# Add line graphs
g = g.map(plt.plot,
        'Week of year', 
        'Cumulative isolate count',
).add_legend(title='Year')

# Make labels human-readable (adapted from https://cduvallet.github.io/posts/2018/11/facetgrid-ylabel-access)
for ax in g.axes.flat:
    # Enlarge x and y-axis labels
    ax.set_xlabel(ax.get_xlabel(), fontsize='x-large')
    ax.set_ylabel(ax.get_ylabel(), fontsize='x-large')

    # Make axis labels human-readable, add per organism isolate count, and italicize
    if ax.get_title():
        species_title = ax.get_title().split('=')[1]
        n = title_counts[ax.get_title().split('=')[1].strip()]
        ax.set_title("{} (n={})".format(species_title, n),
                     fontsize='xx-large', style='italic')
        
    # Add red, dashed vertical line to mark WHO declaration of COVID-19 pandemic (ISO week 11)
    ax.axvline(x=11, color='#ED0000', linestyle='--')
        
# Save as PNG and SVG        
g.savefig(figureone/"figure_1.png", bbox_inches="tight", dpi=300)        
g.savefig(figureone/"figure_1.svg", bbox_inches="tight")        

plt.show()


# In[12]:


# Reformat data to give count per year for reuse and/or supplementary files
weekly_by_year = base_weekly_counts.unstack(level=1)['isolate']

# Save global weekly isolate counts to file
with pd.ExcelWriter(figureone/'figure_1_data.xlsx', datetime_format='yyyy-mm-dd') as writer:  
    weekly_counts.to_excel(writer, index=False, sheet_name='figure_1_data')
    weekly_by_year.reset_index().to_excel(writer, index=False, sheet_name='figure_1_counts_by_year')


# ## Figure 2 and Supplementary Figures 2-4. Annual cumulative curves of invasive disease isolates submitted to IRIS laboratories from 1 January 2018 through 31 May 2020.
# 
# We combined bacterial isolate data with the OxCGRT Stringency Index, a measure of the stringency of COVID-19 containment measures in each country, in Figure 2 (*S. pneumoniae*) and Supplementary Figures 2-4 (*H. influenzae*, *N. meningitidis*, and *S. agalactiae*, respectively).
# 
# ### Processed IRIS bacterial isolate data
# 
# We aggregated IRIS bacterial isolate data by species, country, ISO year, and ISO week to generate weekly cumulative isolate counts.  We backfilled zero values for weeks where no isolates were received.  The structure of the dataframe can be seen below.

# In[13]:


### Calculate and visualise per country annual cumulative isolate counts for each organism in combination with OxCGRT Stringency Index ###
## Begin by processesing IRIS bacterial isolate data

# Aggregate IRIS bacterial isolate data and determine weekly cumulative isolate count per country
iris_summary = pd.pivot_table(
                    iris_orgs, 
                    values='isolate', 
                    index=['species', 
                        'country', 
                        'isoyear_sampled', 
                        'week_sampled'], 
                    aggfunc='count'
)
iris_summary['cumulative sum'] = iris_summary.groupby(level=[0,1,2]).cumsum()

# Rename columns for clarity/ahead of graphing
iris_summary.rename(columns={"isolate": "count", "cumulative sum": "Cumulative isolate count"}, inplace=True,)
iris_summary.rename_axis(index=['species', 'country', 'Year sampled', 'Week of year'], inplace=True)


# In[14]:


# Create dataframe that records a zero value in weeks when no bacterial isolates were received
# Get lists of all species and countries in IRIS bacterial isolate exports
species = iris_summary.index.get_level_values('species').unique().to_list()
countries = iris_summary.index.get_level_values('country').unique().to_list()

# Create dummy index with a row per possible species, country, study year, and study week
full_index = pd.MultiIndex.from_product(
    [species, countries, STUDY_YEARS, np.arange(1, 53)],
    names=['species', 'country', 'isoyear_sampled', 'week_sampled']
)

# Reindex iris_summary dataframe to include all rows from dummy index
iris_summary = iris_summary.reindex(full_index)

# Determine which countries didn't submit any data for each organism
countries_to_drop = iris_summary.groupby(['species','country']).sum()
countries_to_drop = countries_to_drop.loc[countries_to_drop['count'] == 0].reset_index()
countries_to_drop = {tuple(x) for x in countries_to_drop[['species', 'country']].values}

# Account for Iceland which recovered no N. meningitidis during the study period
countries_to_drop.remove(('N. meningitidis', 'Iceland'))

# Remove entries for which data were never provided from dummy dataframe
countries_filter = [key[0:2] not in countries_to_drop for key in iris_summary.index]
iris_summary = iris_summary.loc[countries_filter, :].copy()

# Backfill zeros for weeks when no isolates were received (2020 needs special treatment as it is a partial year)
blanks_to_fill = iris_summary.loc[pd.IndexSlice[:, :, [2018, 2019], :], :].fillna(0)
iris_summary.loc[blanks_to_fill.index, :] = blanks_to_fill
blanks_to_fill = iris_summary.loc[pd.IndexSlice[:, :, [2020], list(range(0,23))], :].fillna(0)
iris_summary.loc[blanks_to_fill.index, :] = blanks_to_fill

# Update the cumulative isolate counts column
iris_summary['Cumulative isolate count'] = iris_summary.groupby(level=[0,1,2]).cumsum()
iris_summary.head(2)


# ### Processed OxCGRT data
# 
# We extracted IRIS countries from the global OxCGRT dataset and excluded data that fell outside the study period. We assigned individual dates to ISO year ('year') and ISO week ('week') to match the IRIS bacterial isolate count data.  
# 
# We saved the OxCGRT dataset for use in statistical analyses (data_and_summaries/publication_datasets/publication_dataset_oxcgrt.csv).

# In[15]:


## Move on to processing OxCGRT data

# OxCGRT provides UK data in aggregated format AND separately for the 4 nations
# In OxCGRT dataset, 'CountryName' is United Kingdom with individual nation under under 'RegionName'
# Replaced 'United Kingdom' with relevant 'RegionName'
uk = ['England', 'Scotland', 'Wales', 'Northern Ireland']
for gov in uk:
    grt.loc[(grt['RegionName'] == gov), 'CountryName'] = gov
    
# Check all IRIS countries listed in OxCGRT
set(iris_summary.reset_index()['country'].unique()) - set(grt['CountryName'])


# In[16]:


# Extract IRIS countries from OxCGRT
grt_iris = grt.loc[grt['CountryName'].isin(countries), :].copy()

# Convert OxCGRT Date column to pandas dates and generate ISO weeks
grt_iris['Date'] = pd.to_datetime(grt_iris['Date'], format='%Y%m%d')
grt_iris['week'] = grt_iris['Date'].dt.strftime('%V').astype('int')
grt_iris['year'] = grt_iris['Date'].dt.year

# Drop any data from after the end of the study period
grt_iris = grt_iris.loc[grt_iris['Date'] <= STUDY_END]

# Save interim dataframe for use in statistical analyses
grt_iris.to_csv(datasets/'publication_dataset_oxcgrt.csv', index=False, date_format='%Y-%m-%d')

grt_iris.head(1)


# ### Processed OxCGRT cont.
# 
# In this study, we focused on the OxCGRT Stringency Index.  We aggregated the OxCGRT data by country, ISO year, and ISO week, calculating the weekly mean for each of the four policy indices and the nine component indicators that comprise the Stringency Index.  
# 
# We then merged the OxCGRT data with the IRIS bacterial isolate data based on country, ISO year, and ISO week (figure_2/figure_2_data.csv).  The structure of the resulting dataframe can be seen below.

# In[17]:


# Calculate mean of IRIS indices and indicators used in Stringency Index per week
grt_iris_indices = grt_iris.groupby(['CountryName', 'year', 'week'])    [['StringencyIndex', 
      'GovernmentResponseIndex', 
      'ContainmentHealthIndex', 
      'EconomicSupportIndex',
      'C1_School closing', 
      'C2_Workplace closing', 
      'C3_Cancel public events',
      'C4_Restrictions on gatherings',
      'C5_Close public transport',
      'C6_Stay at home requirements',
      'C7_Restrictions on internal movement',
      'C8_International travel controls',
      'H1_Public information campaigns',
     ]]\
    .mean()

# Rename IRIS indices and indicators ahead of graphing
grt_iris_indices.rename(columns={
    'StringencyIndex': 'Stringency Index', 
    'GovernmentResponseIndex': 'Government Response Index',
    'ContainmentHealthIndex': 'Containment Health Index', 
    'EconomicSupportIndex': 'Economic Support Index',
    'C1_School closing': 'School closing', 
    'C2_Workplace closing': 'Workplace closing', 
    'C3_Cancel public events': 'Cancel public events',
    'C4_Restrictions on gatherings': 'Restrictions on gatherings',
    'C5_Close public transport': 'Close public transport',
    'C6_Stay at home requirements': 'Stay at home requirements',
    'C7_Restrictions on internal movement': 'Restrictions on internal movement',
    'C8_International travel controls': 'International travel controls',
    'H1_Public information campaigns': 'Public information campaigns',
}, inplace=True)


# In[18]:


# Merge IRIS organism data with OxCGRT indices
merged_iris_grt = pd.merge(
        iris_summary.reset_index(), 
        grt_iris_indices.reset_index(), 
        how='left', 
        left_on=['country', 'isoyear_sampled', 'week_sampled'], 
        right_on=['CountryName', 'year', 'week'],
)

# Clean names in preparation for graphing
merged_iris_grt.rename(columns={"isoyear_sampled": "Year sampled", "week_sampled": "Week of year"}, inplace=True)

# Save merged data to file
merged_iris_grt.to_csv(figuretwo/"figure_2_data.csv", index=False)

merged_iris_grt.head(1)


# ### Generated Figure 2 and Supplementary Figures 2-4
# 
# Figures were saved (as PNG and SVG) in directory figure_2 as follows:
# 
# - *S. pneumoniae*: figure_2_Spneumoniae
# - *H. influenzae*: figure_2_Hinfluenzae
# - *N. meningitidis*: figure_2_Nmeningitidis
# - *S. agalactiae*: figure_2_Sagalactiae
# 
# Underlying data can be found in the same directory (figure_2_data).

# In[19]:


## Generate figures combining IRIS cumulative isolate counts with OxCGRT Stringency Index
## For each organism, generate a facet plot faceted on country
## For each country, plot cumulative line graphs showing cumulative isolate count per year in foreground
## For each country, plot Stringency Index as bar graph in the background

# Create copy of IRIS-OxCGRT dataframe and add dummy bar graph column
iris_oxcgrt_bar = merged_iris_grt.loc[merged_iris_grt['Year sampled'].isin([2018, 2019, 2020])].copy()
iris_oxcgrt_bar['mock_bar'] = 0

# Set bar height for weeks covered by OxCGRT to 100
oxcgrt_period = (iris_oxcgrt_bar['Year sampled'] == 2020) & (iris_oxcgrt_bar['Week of year'] <= 22)
iris_oxcgrt_bar.loc[oxcgrt_period, 'mock_bar'] = 100

# Set up bar graph colour mapping
def hextofloats(h):
    '''Takes a hex rgb string (e.g. #ffffff) and returns an RGB tuple (float, float, float).'''
    return tuple(int(h[i:i + 2], 16) / 255. for i in (1, 3, 5)) # skip '#'

base_palette = {
    0:  "#d6debf",
    10: "#aecea1",
    20: "#98C59A",
    30: "#82bb92",
    40: "#5ea28d",
    50: "#54938C",
    60: "#49838a",
    70: "#3e5f7e",
    80: "#383c65",
    90: "#2b1e3e",
    100: "#000000",
#    -9: "#d9cdc3",
}
palette = pd.DataFrame({k: hextofloats(v) for k, v in base_palette.items()}).T
palette.columns = "red green blue".split()
palette.index = palette.index / 100

cmap = LinearSegmentedColormap('CustomColours', {
    name: [
        (index, color, color)
        for index, color
        in colors.iteritems()
    ]
    for name, colors
    in palette.iteritems()
})

# Apply colour mapping to Stringency Index data
iris_oxcgrt_bar['mock_colour'] = iris_oxcgrt_bar['Stringency Index']    .round(-1)    .fillna(-9)    .astype('int')    .map(base_palette)


# In[20]:


# Define function that will handle the background bar graph
def facetgrid_two_axes(*args, **kwargs):
    if kwargs['label'] != 2020:
        return

    data = kwargs.pop('data')
    alpha = kwargs.pop('alpha', 0.65)
    kwargs.pop('color')
    ax = plt.gca()
    ax2 = ax.twinx()
    ax2.set_zorder(ax.get_zorder() - 1) # Position ax in front of ax2
    ax.patch.set_visible(False) # Hide the 'canvas'

    s = data.loc[data['Year sampled'] == 2020]
    
    # Set up bar graph
    ax2.bar(
        s['Week of year'].values,
        s['mock_bar'].values,
        color=cmap(s['Stringency Index'] / 100),
        alpha=alpha,
        edgecolor="none",
        width=1.0,
    )
    
    # Hide grid and y-axis labels for bar graph
    ax2.grid(False)
    ax2.set_yticks([])
    ax.grid(b=False, axis='x')


# In[21]:


from matplotlib.ticker import MaxNLocator 

# Prepare data for graphing
iris_oxcgrt_bar_copy = iris_oxcgrt_bar.copy()
iris_oxcgrt_bar_copy = iris_oxcgrt_bar_copy.sort_values(by=['species', 'country', 'Year sampled', 'Week of year'])

# Update colour palette to set 2020 to red to improve visibility
line_styles = {'color': ['#000000', '#000000', '#ED0000'], 'linestyle': [':', '--' ,'-']}

# Generate facet plots for each organism
for species in iris_oxcgrt_bar_copy['species'].unique():
    print(species)
    
    # Generate per country counts to use in plot titles
    title_counts = iris_oxcgrt_bar_copy.loc[iris_oxcgrt_bar_copy['species'] == species].groupby(['country']).sum()['count'].astype(int).to_dict()
    
    plt.clf()
    main_axes = plt.gca()
    main_axes.axis('off')
    
    # Set up to graph only countries with data for species being processed
    species_filter = iris_oxcgrt_bar_copy['species'] == species
    countries_with_data_for_this_species = iris_oxcgrt_bar_copy[species_filter].country.unique()
    
    # Set up facet grid and then generate bar and line graphs
    g = sns.FacetGrid(
        iris_oxcgrt_bar_copy[iris_oxcgrt_bar_copy['country'].isin(countries_with_data_for_this_species) & species_filter], 
        col='country',
        hue='Year sampled',
        col_wrap=5,
        dropna=False,
        sharey=False,
        margin_titles=True,
        hue_kws=line_styles,
    )
    g.map_dataframe(facetgrid_two_axes)             .set_axis_labels("Week of year", "Cumulative isolate count")
    g.map(plt.plot, 'Week of year', 'Cumulative isolate count').add_legend()
    
    # Make adjustments to axes and labels
    for ax in g.axes.flat:  
        # Make x and y-axis labels larger
        ax.set_xlabel(ax.get_xlabel(), fontsize='x-large')
        ax.set_ylabel(ax.get_ylabel(), fontsize='x-large')
        
        # Override fractional y-axis ticks
        ax.get_yaxis().set_major_locator(MaxNLocator(integer=True))
                     
        # Make facet titles human-readable, add per country isolate count, and italicize
        if ax.get_title():
            country_title = ax.get_title().split('=')[1]
            n = title_counts[ax.get_title().split('=')[1].strip()]
            ax.set_title("{} (n={})".format(country_title, n),
                         fontsize='xx-large') 
        
        if ax.texts:
            # Modify the right ylabel text
            txt = ax.texts[0]
            ax.text(txt.get_unitless_position()[0], txt.get_unitless_position()[1],
                    txt.get_text().split('=')[1],
                    transform=ax.transAxes,
                    va='center',
                    fontsize='xx-large')
            # Remove the original text
            ax.texts[0].remove()
       
    plt.savefig(figuretwo/"figure_2_{}.png".format(species.replace(". ", "")), bbox_inches="tight")
    plt.savefig(figuretwo/"figure_2_{}.svg".format(species.replace(". ", "")), bbox_inches="tight")
    
    plt.show()


# ## Figure 3. Assessment of the movement of people in IRIS countries using Google COVID-19 Community Mobility Reports data
# 
# We visualised country-level changes in human behaviour between 15/02/2020 and 31/05/2020 based Google's COVID-19 Community Mobility Reports.  Note that Google COVID-19 Community Mobility Reports data starts 15/02/2020 (see https://www.google.com/covid19/mobility/).  We focused on two place categories: residential and workplaces.  
# 
# ### Processed Google COVID-19 Community Mobility Reports data
# 
# When we checked whether all IRIS countries were included in the Google COVID-19 Community Mobility Reports dataset, we found that:
# 
# - Data were not available for China or Iceland
# - England, Scotland, Wales, and Northern Ireland were presented as the United Kingdom
# 
# We extracted data for all IRIS countries included in the global Google COVID-19 Community Mobility Reports dataset and retained only national level data.  We excluded data from beyond the study period, and dates were assigned to ISO year and ISO week as before.
# 
# We saved the Google dataset for use in statistical analyses (data_and_summaries/publication_datasets/publication_dataset_google.csv).

# In[22]:


### Visualise country-level changes in human behaviour based on Google's COVID-19 Community Mobility Reports ###
## Begin by processesing Google data

# Check all IRIS countries listed in Google dataset
set(IRIS_COUNTRIES) - set(google_data['country_region'])


# In[23]:


# Update Google country names to match IRIS and OxCGRT
google_data.replace({'country_region': {'Czechia': 'Czech Republic'}}, inplace=True)

# Check all IRIS countries listed in OxCGRT
set(IRIS_COUNTRIES) - set(google_data['country_region'])


# In[24]:


# Extract IRIS countries
google_iris = google_data.loc[google_data['country_region'].isin(IRIS_COUNTRIES), :].copy()
google_iris.head()

# Drop regional data
google_iris = google_iris[google_iris['sub_region_1'].isna()]

# Drop metropolitan data
google_iris = google_iris[google_iris['metro_area'].isna()]

# Drop data from outside the study period
google_iris = google_iris.loc[google_iris['date'] <= STUDY_END, :]

# Sort alphabetically by country and then by date
google_iris = google_iris.sort_values(by=['country_region', 'date'])

# Rename place category columns to be more readable
google_iris.rename(columns={
    'retail_and_recreation_percent_change_from_baseline': 'Retail and recreation', 
    'grocery_and_pharmacy_percent_change_from_baseline': 'Grocery and pharmacy',
    'parks_percent_change_from_baseline': 'Parks', 
    'transit_stations_percent_change_from_baseline': 'Transit stations',
    'workplaces_percent_change_from_baseline': 'Workplaces',
    'residential_percent_change_from_baseline': 'Residential',
}, inplace=True)

google_iris.head(1)


# In[25]:


# Temporarily add ISO8601 week column for modelling
google_iris['week'] = google_iris['date'].dt.strftime('%V').astype('int')

# Save interim dataframe for use in modelling
google_iris.to_csv(datasets/'publication_dataset_google.csv')

# Revert to previous set of columns
google_iris.drop(columns=['week'], inplace=True)


# ### Generated Figure 3.
# 
# We visualised per country changes in movement in the residential and workplaces categories. We plotted daily data as line graphs and added annotation to indicate the WHO declaration of the COVID-19 pandemic (11/03/2020, ISO week 11).
# 
# Figure and underlying data can be found in directory figure_3.

# In[26]:


## Generate facet plot faceted on country showing line graphs for residential and workplaces data

# Convert all data to long form ahead of graphing
google_iris_long = pd.melt(google_iris, id_vars=['country_region', 'date'], value_vars=['Retail and recreation',
       'Grocery and pharmacy', 'Parks', 'Transit stations', 'Workplaces',
       'Residential'], var_name='Metric', value_name='Percent change')

# Keep only residential and workplaces
google_res_work = google_iris_long.loc[(google_iris_long['Metric'] == 'Residential') | (google_iris_long['Metric'] == 'Workplaces')]

# Save to file
google_res_work.to_csv(figurethree/'figure_3_data.csv')

google_res_work.head(2)


# In[27]:


# Set up facet plot
plt.clf()
g = sns.FacetGrid(google_res_work, 
        col='country_region',  
        sharey=True,
        hue='Metric',
        palette=['#ED0000', '#011352'],
        margin_titles=True,
        col_wrap=5,
)

g = g.map(plt.plot,
        'date', 
        'Percent change',
).add_legend()

# Make labels human-readable
for ax in g.axes.flat:  
    # Make x and y-axis labels slightly larger
    ax.set_xlabel(ax.get_xlabel().replace('date', 'Time (days)'), fontsize='x-large')
    ax.set_ylabel(ax.get_ylabel().replace('Percent change', 'Percentage change\nrelative to baseline'), fontsize='x-large')

    # Make labels human-readable
    if ax.get_title():
        ax.set_title(ax.get_title().split('=')[1],
                     fontsize='xx-large')

    # Convert x-axis dates to human-readable format and auto rotate/pad along axis
    ax.xaxis.set_major_formatter(mdates.DateFormatter('%b %-d'))
    for label in ax.get_xticklabels():
        label.set_ha('right')
        label.set_rotation(30)


    # Remove vertical gridlines
    ax.grid(False, axis='x')

    # Emphasise 0 on y axis
    ax.axhline(y=0, color='grey')

    # Add vertical line at start of week 11
    ax.axvline(x='2020-03-09', color='black', linestyle='--')

# Save as PNG and SVG
plt.savefig(figurethree/"figure_3.png", bbox_inches="tight")
plt.savefig(figurethree/"figure_3.svg", bbox_inches="tight")

plt.show()


# In[28]:


get_ipython().system('pwd')

