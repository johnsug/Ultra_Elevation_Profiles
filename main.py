import streamlit as st
import pandas as pd
import numpy as np
import seaborn as sb

#import matplotlib.pyplot as plt

st.title('Interactive Ultramarathon Course Profiles')
st.write('Comparing the American Classics with the races in the Rocky Mountain Slam (and a few other races of interest)')

race_data = pd.read_csv('races.csv')#.\
#  query('event not in ["DC Peaks", "Snow Peaks 50", "Canyonlands 100", "Zion 100"]') ## "Bryce Canyon 100"
race_list = race_data['event'].unique()
default_races = ['Wasatch 100', 'Western States', 'Boston Marathon']

options = st.multiselect('Select races to display', race_list, default_races, max_selections=6)
chart_data = race_data.copy().query(f'event in {options}')
pal = sb.color_palette(palette="viridis", n_colors=len(options))

units = st.radio('Measurement System', ['Imperial', 'Metric'], horizontal=True)

if units == 'Imperial':
  st.line_chart(chart_data, x='miles', y='feet', color='event')

if units == 'Metric':
  st.line_chart(chart_data, x='km', y='meters', color='event')
