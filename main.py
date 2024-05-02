import streamlit as st
import pandas as pd
import numpy as np
#import matplotlib.pyplot as plt
#import seaborn as sb

race_data = pd.read_csv('races.csv')

races = ['Leadville', 'Wasatch', 'Western States', 'Angeles Crest', 'Boston', 
        'Hardrock', 'The Bear', 'Bighorn', 'Cascade Crest', 'IMTUF']
default_races = ['Leadville', 'Wasatch', 'Western States', 'Angeles Crest', 'Boston']

options = st.multiselect('Select races to display', races, default_races)

#st.write('You selected:', options)

## need a km/miles toggle
## need a ft/km toggle

st.line_chart(race_data, x='dist', y='vert', color='event')
