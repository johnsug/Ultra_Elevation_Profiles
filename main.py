import streamlit as st
import pandas as pd
import numpy as np
#import matplotlib.pyplot as plt
#import seaborn as sb

st.title('Interactive Ultramarathon Course Profiles')
st.write('Comparing American Classics with races in the Rocky Mountain Slam')

race_data = pd.read_csv('races.csv')
race_list = race_data['event'].unique()
default_races = ['Wasatch 100', 'Western States', 'Boston Marathon']

#races = ['Leadville', 'Wasatch', 'Western States', 'Angeles Crest', 'Boston', 
#        'Hardrock', 'The Bear', 'Bighorn', 'Cascade Crest', 'IMTUF']
#default_races = ['Leadville', 'Wasatch', 'Western States', 'Angeles Crest', 'Boston']

options = st.multiselect('Select races to display', race_list, default_races)
chart_data = race_data.copy().query(f'event in {options}')

units = st.radio('Measurement System', ['Imperial', 'Metric'], horizontal=True)

if units == 'Imperial':
  st.line_chart(chart_data, x='miles', y='feet', color='event')

if units == 'Metric':
  st.line_chart(chart_data, x='km', y='meters', color='event')
