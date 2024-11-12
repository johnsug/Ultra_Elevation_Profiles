import streamlit as st
import pandas as pd
import numpy as np
import seaborn as sb
import altair as alt

# load and prepare data
st.title('Interactive Ultramarathon Course Profiles')
st.write('Comparing the American Classics with the races in the Rocky Mountain Slam (and a few other races of interest)')

race_data = pd.read_csv('races.csv').\
  query('event not in ["Canyonlands 100", "Zion 100"]')
race_list = race_data['event'].unique()
default_races = ['Western States', 'Wasatch 100', 'Boston Marathon']

# select races to display
options = st.multiselect('Select races to display', race_list, default_races, max_selections=6)

# filter chart data
chart_data = race_data.copy().\
  query(f'event in {options}').\
  rename(columns={"event": "columns"})

# select display measurments
units = st.radio('Measurement System', ['Imperial', 'Metric'], horizontal=True)

# chart configs
if units == 'Imperial':
   chart = alt.Chart(chart_data).mark_line().encode(
     x=alt.X('miles', title='Miles'), 
     y=alt.Y('feet', title='Elevation (Feet)'), 
     color=alt.Color('columns:N', scale=alt.Scale(scheme='viridis'), legend=None)
   ).properties(width=700, height=400)

if units == 'Metric':
  chart = alt.Chart(chart_data).mark_line().encode(
     x=alt.X('km', title='Kilometers'), 
     y=alt.Y('meters', title='Elevation (Meters)'), 
     color=alt.Color('columns:N', scale=alt.Scale(scheme='viridis'), legend=None)
   ).properties(width=700, height=400)

# display Altair chart
st.altair_chart(chart)
