//this function will get all users

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
        const { pathParameters } = normalizeEvent(event);

        const params = {
            TableName: table,
        };
        let data = {};
        if (pathParameters && pathParameters['todoId']) { //check if we have todoID at our url,and if so, it will just fetch the todo
            data = await dynamo
                .get({
                    ...params,
                    Key: {
                        id: parseInt(pathParameters['todoId'], 10),
                    },
                })
                .promise();
        } else {
            data = await dynamo.scan(params).promise(); //scanning the table and getting all the data
        }

        console.log({ //login this informations in cloudwatch
            message: 'Records found',
            data: JSON.stringify(data),
        });

        return response(200, data); //if it works, we will receive line 38 message
    } catch (err) {
        console.error(err); //if it not works, line 45 will be sent
        return response(500, 'Something went wrong');
    }
};