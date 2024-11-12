import streamlit as st
import pandas as pd
import numpy as np
import seaborn as sb

#import matplotlib.pyplot as plt

st.title('Interactive Ultramarathon Course Profiles')
st.write('Comparing the American Classics with the races in the Rocky Mountain Slam (and a few other races of interest)')

race_data = pd.read_csv('races.csv').\
  query('event not in ["Canyonlands 100", "Zion 100"]') ## "Bryce Canyon 100", "DC Peaks", "Snow Peaks 50"
race_list = race_data['event'].unique()
default_races = ['Wasatch 100', 'Western States', 'Boston Marathon']

options = st.multiselect('Select races to display', race_list, default_races, max_selections=6)
chart_data = race_data.copy().\
  query(f'event in {options}').\
  rename(columns={"event": "columns"})
pal = sb.color_palette(palette="viridis", n_colors=len(options))

units = st.radio('Measurement System', ['Imperial', 'Metric'], horizontal=True)

st.table(chart_data.head(5))

if units == 'Imperial':
  st.line_chart(chart_data, x='miles', y='feet', color='columns')
  #st.line_chart(race_data.copy().query('event == "Wasatch 100"'), x='miles', y='feet')
  #st.line_chart(race_data.copy().query('event == "UTMB"'), x='miles', y='feet')# , color='event', x_label='Distance
  #(Miles)', y_label='Vert (Ft)'

if units == 'Metric':
  st.line_chart(chart_data, x='km', y='meters') # color='event'
