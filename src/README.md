## Setting up data for running locally

Create a folder called "data" inside this "src" folder
Copy the following files from sharepoint into the data folder.

Services data: https://nhs.sharepoint.com/:x:/r/sites/msteams_73d944/Shared%20Documents/Dos%20Data/DOS%20Dataset/service-related-data-20231004.xlsx?d=wfad580d50e0c422ea60c97729f183473&csf=1&web=1&e=HJrgwv

Organisation data: https://nhs.sharepoint.com/:x:/r/sites/msteams_73d944/Shared%20Documents/Dos%20Data/DOS%20Dataset/DoS_Pharmacy_Organisations.xlsx?d=w926886aae4b04de2a68629c2bb2bc3c7&csf=1&web=1&e=ZemEoc


## How to run locally

Inside this src/ folder have two terminals open and run the following:
1. "docker-compose up"
2. "fastapi dev front_end.py --port 8100"

When docker has spun up you can generate the data by running the python script "generate_tables_from_xlsx_file".
