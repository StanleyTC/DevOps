//responsible for normalizing the event (payload) we receive, and will pass to our lambda

const normalizeEvent = event => {
    return {
        method: event['requestContext']['http']['method'],
        data: event['body'] ? JSON.parse(event['body']) : {},
        querystring: event['queryStringParameters'] || {},
        pathParameters: event['pathParameters'] || {},
    };
};

module.exports = normalizeEvent;