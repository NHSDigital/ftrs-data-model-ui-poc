import json
import boto3
import pandas as pd
import numpy as np
from decimal import Decimal

dynamodb = boto3.resource("dynamodb", endpoint_url='http://localhost:8000')

org_xl = pd.ExcelFile("src/data/DoS_Pharmacy_Organisations.xlsx")
organisations = org_xl.parse("Organisations")

service_xl = pd.ExcelFile("src/data/service-related-data-20231004.xlsx")
services = service_xl.parse("service-data")

service_age_ranges = service_xl.parse("service-age-range")
service_genders = service_xl.parse("service-genders")
service_opening_times = service_xl.parse("standard-opening-days-times")

# service-age-range, "service_id	age_range_days_from	age_range_days_to"
# service-genders, "service_id	gender_id	gender_desc	gender_letter"
# standard-opening-days-times "service_id	dayid	starttime	endtime"

new_organisations = list()
new_organisation_affiliations = list()
new_locations = list()
new_services = list()
known_postcodes = list()

# create organisations
for index, organisation in organisations.iterrows():
    if organisation["Code"] not in [str(x["identifier"]) for x in new_organisations]:
        new_organisations.append(
            {
                "id": "OR" + str(np.random.randint(low=100000000000000, high=999999999999999, size=(1,))[0]),
                "identifier": [{"type": "ODSCode", "value": organisation["Code"]}],
                "active": True,
                "name": organisation["Name"],
                "telecom": None,
                "type":
                    organisation["Non Primary Role Name(s)"]
                    if organisation["Non Primary Role Name(s)"] == "INTEGRATED CARE BOARD"
                    else organisation["Primary Role Name"],
                "createdBy": "test_system_ignore",
                "createdDateTime": "2024-12-10T11:09:00",
                "modifiedBy": "test_system_ignore",
                "modifiedDateTime": "2024-12-10T11:09:00"
            }
        )

# print(new_organisations)

# create org affiliations
for index, organisation in organisations.iterrows():
    if organisation["PartOf"] is not np.nan:
        assigned_organisation = [x for x in new_organisations if organisation["Code"] in str(x["identifier"])][0]["id"]
        participatingOrganisation = [x for x in new_organisations if organisation["PartOf"] in str(x["identifier"])][0]["id"]

        new_organisation_affiliations.append(
            {
                "id": "OA" + str(np.random.randint(low=100000000000000, high=999999999999999, size=(1,))[0]),
                "active": True,
                "code": "Part Of",
                "organisation": participatingOrganisation,
                "participatingOrganisation": assigned_organisation,
                "createdBy": "test_system_ignore",
                "createdDateTime": "2024-12-10T11:09:00",
                "modifiedBy": "test_system_ignore",
                "modifiedDateTime": "2024-12-10T11:09:00"
            }
        )

# create locations
for index, organisation in organisations.iterrows():
    if organisation["Postcode"] not in known_postcodes:
        managing_org = [x for x in new_organisations if organisation["Code"] in str(x["identifier"])][0]["id"]
        key_service = None
        for index, service in services.iterrows():
            if service["postcode"] == organisation["Postcode"]:
                key_service = service

        if key_service is not None:
            positionGCS = {"latitude": Decimal(str(key_service["latitude"])), "longitude": Decimal(str(key_service["longitude"]))}
            address_name = key_service["publicname"]
        else:
            positionGCS = None
            address_name = None

        new_locations.append({
            "id": "LO" + str(np.random.randint(low=100000000000000, high=999999999999999, size=(1,))[0]),
            "active": True,
            "name": address_name if address_name else organisation["Name"],
            "address": {
                "city": organisation["Town"],
                "line": [organisation["Address Line 1"]],
                "district": None,
                "postalCode": organisation["Postcode"]
            },
            "managingOrganisation": managing_org,
            "positionGCS": positionGCS,
            "positionReferenceNumber": None,
            "primaryAddress": True,
            "partOf": None,
            "createdBy": "test_system_ignore",
            "createdDateTime": "2024-12-10T11:09:00",
            "modifiedBy": "test_system_ignore",
            "modifiedDateTime": "2024-12-10T11:09:00"
        })

        known_postcodes.append(organisation["Postcode"])

for index, service in services.iterrows():
    if service["type_desc"] != "Pharmacy Distance Selling":
        if service["postcode"] not in known_postcodes:
            location_id = "LO" + str(np.random.randint(low=100000000000000, high=999999999999999, size=(1,))[0])
            organisation_id = None

            new_locations.append({
                "id": location_id,
                "active": True,
                "name": service["publicname"],
                "address": {
                        "city": service["town"],
                        "line": [{"S": service["address"]}],
                        "district": None,
                        "postalCode": service["postcode"]
                },
                "managingOrganisation": None,
                "name": service["publicname"],
                "positionGCS": {"latitude": Decimal(str({service["latitude"]})), "longitude": Decimal(str({service["longitude"]}))},
                "positionReferenceNumber": None,
                "primaryAddress": False,
                "partOf": None,
                "createdBy": "test_system_ignore",
                "createdDateTime": "2024-12-10T11:09:00",
                "modifiedBy": "test_system_ignore",
                "modifiedDateTime": "2024-12-10T11:09:00"
            })
        else:
            location = [x for x in new_locations if service["postcode"] in x["address"]["postalCode"]][0]
            location_id = location["id"]
            organisation_id = location["managingOrganisation"]

        service_age_range = [x for id, x in service_age_ranges.iterrows() if x['service_id'] == service['id']][0]
        service_gender = [x['gender_desc'] for id, x in service_genders.iterrows() if x['service_id'] == service['id']]


        service_opening_time = [x for id, x in service_opening_times.iterrows() if x['service_id'] == service['id']]
        service_opening_time_dict = {}
        for item in service_opening_time:
            service_opening_time_dict[item['dayid']] = {'starttime': str(item['starttime']), 'endtime': str(item['endtime'])}

        # find and assign existing organisations if exist.
        new_services.append({
            "id": "HS" + str(np.random.randint(low=100000000000000, high=999999999999999, size=(1,))[0]),
            "identifier": [
                    {"type": "UID", "value": str(service['uid']), "use": "oldDoS"},
                    {"type": "ID", "value": str(service['id']), "use": "oldDoS"}
                ],
            "active": True,
            "name": service["publicname"],
            "category": "Pharmacy",
            "location": location_id,
            "providedBy": organisation_id,
            "type": service["type_desc"],
            "ageEligibilityCriteria": [
                    {"type": "yearsFrom", "value": Decimal(str(service_age_range['age_range_days_from']))},
                    {"type": "yearsTo", "value": Decimal(str(service_age_range['age_range_days_to']))}
                ],
            "openingTimes": [
                {"day": "Monday", "startTime": service_opening_time_dict[1]['starttime'], "endTime": service_opening_time_dict[1]['endtime']},
                {"day": "Tuesday", "startTime": service_opening_time_dict[2]['starttime'], "endTime": service_opening_time_dict[2]['endtime']},
                {"day": "Wednesday", "startTime": service_opening_time_dict[3]['starttime'], "endTime": service_opening_time_dict[3]['endtime']},
                {"day": "Thursday", "startTime": service_opening_time_dict[4]['starttime'], "endTime": service_opening_time_dict[4]['endtime']},
                {"day": "Friday", "startTime": service_opening_time_dict[5]['starttime'], "endTime": service_opening_time_dict[5]['endtime']}
            ],
            "publicInformation": str(service["publicreferralinstructions"]),
            "additionalServiceInformation": str(service["professionalreferralinfo"]),
            "referralRestrictions": str(service["restricttoreferrals"]),
            "referralRole": None,
            "sexEligibilityCriteria": {
                "Female": "Female" in service_gender,
                "Male": "Male" in service_gender,
                "Indeterminate": "Indeterminate" in service_gender
            },
            "telecom": [{"value": str(service["publicphone"]), "system": {"S": "phone"}}],
            "createdBy": "test_system_ignore",
            "createdDateTime": "2024-12-10T11:09:00",
            "modifiedBy": "test_system_ignore",
            "modifiedDateTime": "2024-12-10T11:09:00"
        })

table = dynamodb.Table("organisation")
for org in new_organisations:
    table.put_item(Item=org)


table = dynamodb.Table("organisationAffiliation")
for org_aff in new_organisation_affiliations:
    table.put_item(Item=org_aff)

table = dynamodb.Table("location")
for loc in new_locations:
    table.put_item(Item=loc)


table = dynamodb.Table("healthcareService")
for serv in new_services:
    table.put_item(Item=serv)

