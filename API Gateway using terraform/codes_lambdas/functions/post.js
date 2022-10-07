//responsible for creating item/user at out table

const AWS = require('aws-sdk');//importing aws sdk, so, it will not be necessary to install any dependencies
const dynamo = new AWS.DynamoDB.DocumentClient();//importing our dynamo
const ssm = new AWS.SSM();

const normalizeEvent = require('/opt/nodejs/normalizer');//importing files we created, in this case, normalizer
const response = require('/opt/nodejs/response');//importing files we created, in this case, response

exports.handler = async event => {  //our handler
    if (process.env.DEBUG) {    //in this if, I will check if the debug is enabled, and if it is, I will log the event that I receive
        console.log({
            message: 'Received event',
            data: JSON.stringify(event),
        });
    }

    try {
        const { Parameter: { Value: table } } = await ssm.getParameter({ Name: process.env.TABLE }).promise();
        const { data } = normalizeEvent(event);

        const params = {
            TableName: table,
            Item: { 
                ...data, //data we will pass at our requisition
                created_at: new Date().toISOString(), //creation date
            },
        };

        await dynamo.put(params).promise(); //calling dynamo put function to be able to create item

        console.log({
            message: 'Record has been created',
            data: JSON.stringify(params),
        });

        return response(201, `Record ${data.id} has been created`); //if everything works, return 201 with the message it worked
    } catch (err) {
        console.error(err);
        return response(500, 'Something went wrong'); //if something won't work, send error 500 with 'Something went wrong' message
    }
};