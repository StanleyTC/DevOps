//function that we create to assemble our response, since our API needs a specific 
//format to be able to return a value, and this is defined through the response

module.exports = function (status, body) {
    return {
        statusCode: status,
        body: JSON.stringify(body),
        headers: {
            'Content-Type': 'application/json',
        },
    };
};