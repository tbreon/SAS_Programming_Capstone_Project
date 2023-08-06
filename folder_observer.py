import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import saspy
import pandas as pd

# Specify the folder to monitor and the path to the SAS program file
folder_to_monitor = r'C:\Users\UBREOTR\Documents\GitHub\SAS_Programming_Capstone_Project\data'
sas_program_path = r'sasprogram.sas'

# Define a custom event handler
class MyEventHandler(FileSystemEventHandler):
    def on_created(self, event):
        # Check if a new file was created in the monitored folder
        if event.is_directory:
            return
        filepath = event.src_path

        # Execute the SAS program when a new file is created
        if filepath.endswith('.csv'):  # Specify the file extension to trigger the SAS program
            # Establish a connection to SAS OnDemand for Academics
            sas_cfg = saspy.SASconfig()
            sas = saspy.SASsession(cfgname='oda', options=sas_cfg)

            # Wait for the file to be fully written to disk
            time.sleep(1)

            # Read the SAS program file
            with open(sas_program_path, 'r') as file:
                sas_program = file.read()

            # Set the output directory to the same directory as the SAS program
            output_directory = r"/home/u59523816/My SAS Files/"

            # Specify the output file name
            output_filename = 'output.html'

            # Read the CSV file into a pandas DataFrame
            data = pd.read_csv(filepath)

            # Convert the pandas DataFrame to a SAS dataset
            sas.df2sd(data, table='cars')

            # Submit the SAS program with ODS HTML and specify the output file
            sas.submit(f'''
            ods html file="{os.path.join(output_directory, output_filename)}";
            {sas_program}
            ods html5 (id=saspy_internal) close;
            ods html close;
            ''')

            # Print the output from SAS to the console
            print(sas.lastlog())

            # Disconnect from SAS
            sas._endsas()

# Create an observer and attach the event handler
observer = Observer()
event_handler = MyEventHandler()
observer.schedule(event_handler, folder_to_monitor, recursive=False)

# Start the observer
observer.start()

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()

observer.join()
