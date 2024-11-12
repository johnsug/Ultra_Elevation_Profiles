import streamlit as st
import pandas as pd
import plotly.graph_objects as go
from st_aggrid import AgGrid, GridOptionsBuilder

# Read in results
results = pd.read_csv('2024_Medals.csv')

## Read in Races
races = pd.read_csv('2024_Race_List.csv')

## xref dictionary
races_xref = {'abr': ['WSER', 'WTM', 'UTMB', 'ACs', '200+'], 
              'race':['Western States', 'World Trail Majors', 'UTMB', 
                      'American Classics', '200+']} 
xref = pd.DataFrame.from_dict(races_xref)

# Display the data in Streamlit
st.title('Ultramarathon Majors Medal Tracker')
series = st.radio(label='Race Series', 
                  options=['Western States', 'World Trail Majors', 'UTMB', 
                           'American Classics', '200+'],  
                  horizontal=True)

report_view = st.radio(label='View', options=['Nationality', 'Sponsor', 'Coach'], horizontal=True)

# Map the selected radio button value to the abbreviation in xref DataFrame
selected_race_abr = xref.loc[xref['race'] == series, 'abr'].values[0]

# Filter the data based on the mapped abbreviation using pandas query()
filtered_race_list = races.query('Category == @selected_race_abr')['Race']

## start medals table
filtered_results = results.query('Race in @filtered_race_list').copy()

# recode
filtered_results['Rank'] = filtered_results['Rank'].\
  replace(['F', 'M'], '', regex=True).\
  replace('1', 'Gold', regex=True).\
  replace('2', 'Silver', regex=True).\
  replace('3', 'Bronze', regex=True)

## dynamic data slicing ##################################################
if report_view == 'Nationality':

  # find counts
  pvt = filtered_results[['Nationality', 'Rank']].\
    value_counts().\
    reset_index().\
    rename(columns={0: "count"})

  # pivot
  pvt = pvt.\
    pivot_table(index=['Nationality'], columns=['Rank'], values='count', fill_value=0).\
    reset_index()

  # total column
  pvt = pvt.rename(columns={'Gold': '🥇', 'Silver': '🥈', 'Bronze': '🥉'})
  pvt['🏆'] = pvt['🥇'] + pvt['🥈'] + pvt['🥉']
  pvt = pvt.sort_values(['🏆', '🥇', '🥈', '🥉'], ascending=[False, False, False, False])
  pvt = pvt[['Nationality', '🥇', '🥈', '🥉', '🏆']]
  ## set index
  pvt = pvt.set_index('Nationality')

if report_view == 'Sponsor': ##################################################

  # find counts
  pvt = filtered_results[['Main Sponsor', 'Rank']].\
    value_counts().\
    reset_index().\
    rename(columns={0: "count"})

  # pivot
  pvt = pvt.\
    pivot_table(index=['Main Sponsor'], columns=['Rank'], values='count', fill_value=0).\
    reset_index()

  # total column
  pvt = pvt.rename(columns={'Gold': '🥇', 'Silver': '🥈', 'Bronze': '🥉'})
  pvt['🏆'] = pvt['🥇'] + pvt['🥈'] + pvt['🥉']
  pvt = pvt.sort_values(['🏆', '🥇', '🥈', '🥉'], ascending=[False, False, False, False])
  pvt = pvt[['Main Sponsor', '🥇', '🥈', '🥉', '🏆']]
  ## set index
  pvt = pvt.set_index('Main Sponsor')

if report_view == 'Coach': ##################################################

  # find counts
  pvt = filtered_results[['Coach', 'Rank']].\
    value_counts().\
    reset_index().\
    rename(columns={0: "count"})

  # pivot
  pvt = pvt.\
    pivot_table(index=['Coach'], columns=['Rank'], values='count', fill_value=0).\
    reset_index()

  # total column
  pvt = pvt.rename(columns={'Gold': '🥇', 'Silver': '🥈', 'Bronze': '🥉'})
  pvt['🏆'] = pvt['🥇'] + pvt['🥈'] + pvt['🥉']
  pvt = pvt.sort_values(['🏆', '🥇', '🥈', '🥉'], ascending=[False, False, False, False])
  pvt = pvt[['Coach', '🥇', '🥈', '🥉', '🏆']]
  ## set index
  pvt = pvt.set_index('Coach')


# Display the styled DataFrame 'pvt' in Streamlit
st.subheader('Medals')
st.write(pvt)

# List races as text separated by commas
st.write(f'**Race List:** {", ".join(filtered_race_list)}')

# Write races
st.write('**Full Results:**')
st.write(filtered_results) #.set_index(['Date', 'Race', 'Rank']))


