# Medial frontal cortex activity predicts information sampling in economic choice

### Kaanders, Nili, O'Reilly, & Hunt (2021)

## Behavioral Analysis Code

All code required to reproduce behavioral results and plots presented in the paper is in a Jupyter Notebook under `./code`

## Data

All behavioral data with descriptions of the variables is under `./data`
- Data is in a single csv file: `behavioral_data.csv`
- Variable names with descriptions can be found in `variable_definitions.doc`

## Task

All files used to run experimental task in Cogent are under `./task`
Cogent required Matlab to run and can be downloaded here: http://www.vislab.ucl.ac.uk/cogent.php
- `infotask_main.m` runs the task.
- the stimuli are in `./task/images`.
- `run_IG_trial.m` is used in the main task script to run a single trial.
- `make_blocks.m` is used in the main task script to pseudo-randomise cue presentation.
- `generate_schedule.m` is used in the main task script to generate variables necessary for each trial.
