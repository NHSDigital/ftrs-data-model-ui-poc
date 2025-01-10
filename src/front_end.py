# 'fastapi dev front_end.py --port 8100' to start the front_end

import ast
import boto3

from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

dynamodb = boto3.resource("dynamodb", endpoint_url='http://localhost:8000')
client = boto3.client('dynamodb', endpoint_url='http://localhost:8000')

# tables = ["healthcareService", "location", "organisation", "organisationAffiliation"]


app = FastAPI()

app.mount("/nhsuk-frontend", StaticFiles(directory="nhsuk-frontend-9.1.0"), name="nhsuk-frontend")


templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def read_item(request: Request):
    return templates.TemplateResponse(
        request=request, name="home.html"
    )

@app.get("/service/{id}", response_class=HTMLResponse)
async def read_item(request: Request, id: str):
    service = client.get_item(TableName='healthcareService', Key={'id':{'S':str(id)}})['Item']

    organisation = client.get_item(TableName='organisation', Key={'id':{'S':str(service['providedBy']['S'])}})
    location = client.get_item(TableName='location', Key={'id':{'S':str(service['location']['S'])}})


    return templates.TemplateResponse(
        request=request, name="service.html", 
        context={
            "service": service, 
            "organisation": organisation.get('Item', None),
            "location": location.get('Item', None)
        }
    )

@app.get("/services", response_class=HTMLResponse)
async def read_item(request: Request):
    response = client.scan(TableName="healthcareService")
    data = response['Items']

    return templates.TemplateResponse(
        request=request, name="services.html", context={"services": data}
    )

@app.get("/location/{id}", response_class=HTMLResponse)
async def read_item(request: Request, id: str):
    location = client.get_item(TableName='location', Key={'id':{'S':str(id)}})['Item']

    # Not all locations have latitude/longitude
    try:
        location['address']['S'] = ast.literal_eval(location['address']['S'].replace("\'", "\""))
        location['positionGCS']['S'] = ast.literal_eval(location['positionGCS']['S'])
    except:
        pass

    organisation = client.get_item(TableName='organisation', Key={'id':{'S':str(location['managingOrganisation']['S'])}})

    services = client.scan(
        ExpressionAttributeNames={
            '#n': 'name',
            '#id': 'id',
            '#category': 'category',
            '#type': 'type',
            '#location': "location"
        },
        ExpressionAttributeValues={
            ':l': {"S": str(id)}
        },
        FilterExpression='#location = :l',
        ProjectionExpression='#n, #id, #category, #type',
        TableName='healthcareService',
    )['Items']

    return templates.TemplateResponse(
        request=request, name="location.html", 
        context={
            "location": location,
            "organisation": organisation.get('Item', None),
            "services": services
        }
    )

@app.get("/locations", response_class=HTMLResponse)
async def read_item(request: Request):
    response = client.scan(TableName="location")
    data = response['Items']

    return templates.TemplateResponse(
        request=request, name="locations.html", context={"locations": data}
    )

def get_org(org_id):
    return client.get_item(TableName='organisation', Key={'id':{'S':str(org_id)}})['Item']

@app.get("/organisation/{id}", response_class=HTMLResponse)
async def read_item(request: Request, id: str):
    organisation = get_org(str(id))

    services = client.scan(
        ExpressionAttributeNames={
            '#n': 'name',
            '#id': 'id',
            '#category': 'category',
            '#type': 'type',
            '#providedBy': "providedBy"
        },
        ExpressionAttributeValues={
            ':p': {"S": str(id)}
        },
        FilterExpression='#providedBy = :p',
        ProjectionExpression='#n, #id, #category, #type',
        TableName='healthcareService',
    )['Items']

    locations = client.scan(
        ExpressionAttributeNames={
            '#id': 'id',
            '#n': 'name',
            '#address': 'address',
            '#primaryAddress': "primaryAddress",
            '#managingOrganisation': 'managingOrganisation'
        },
        ExpressionAttributeValues={
            ':m': {"S": str(id)}
        },
        FilterExpression='#managingOrganisation = :m',
        ProjectionExpression='#n, #id, #address, #primaryAddress',
        TableName='location',
    )['Items']

    org_affiliation_parents_scan = client.scan(
        ExpressionAttributeNames={
            '#id': 'id',
            '#code': 'code',
            '#organisation': 'organisation',
            '#participatingOrganisation': "participatingOrganisation"
        },
        ExpressionAttributeValues={
            ':p': {"S": str(id)}
        },
        FilterExpression='#participatingOrganisation = :p',
        ProjectionExpression='#id, #code, #organisation, #participatingOrganisation',
        TableName='organisationAffiliation',
    )

    org_affiliation_parents = [get_org(org_aff['organisation']['S']) | {'code': org_aff['code']} for org_aff in org_affiliation_parents_scan['Items']]

    org_affiliation_children_scan = client.scan(
        ExpressionAttributeNames={
            '#id': 'id',
            '#code': 'code',
            '#organisation': 'organisation',
            '#participatingOrganisation': "participatingOrganisation"
        },
        ExpressionAttributeValues={
            ':o': {"S": str(id)}
        },
        FilterExpression='#organisation = :o',
        ProjectionExpression='#id, #code, #organisation, #participatingOrganisation',
        TableName='organisationAffiliation',
    )

    org_affiliation_children = [get_org(org_aff['participatingOrganisation']['S']) | {'code': org_aff['code']} for org_aff in org_affiliation_children_scan['Items']]

    return templates.TemplateResponse(
        request=request, name="organisation.html", 
        context={
            "organisation": organisation,
            "services": services,
            "parent_orgs": org_affiliation_parents,
            "children_orgs": org_affiliation_children,
            "locations": locations
        }
    )

@app.get("/organisations", response_class=HTMLResponse)
async def read_item(request: Request):
    response = client.scan(TableName="organisation")
    data = response['Items']

    return templates.TemplateResponse(
        request=request, name="organisations.html", context={"organisations": data}
    )



@app.get("/")
async def root():
    return {"message": "Hello World"}

