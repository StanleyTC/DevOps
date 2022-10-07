//this function is for delete a item of our table

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
        const {
            data: { id },
        } = normalizeEvent(event);

        const params = {
            TableName: table,
            Key: {
                id: parseInt(id, 10),
            },
        };

        await dynamo.delete(params).promise();

        console.log({
            message: 'Record has been deleted',
            data: JSON.stringify(params),
        });

        return response(200, `Record ${id} has been deleted`);
    } catch (err) {
        console.error(err);
        return response(500, 'Something went wrong');
    }
};