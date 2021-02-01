# Kong plugin techincal task

## Task: 
Create a plugin. Upon receiving a request in Kong the plugin will reach out to a remote server, with a header from the incoming request. If the remote server returns a “200 OK”, the request is allowed to be proxied, on anything else the client should get the proper “40x” response.
 
## Use Case:  
Create an authentication plugin.
 
## Requirements: 
 
The remote server URL, and the incoming header are configurable. At a minimum there is 1 integration test.
 
### Extra credit requirements: 
 
1. Solid test coverage
1. Cache the response, for a configurable TTL
1. Retrieve a key (assume a JWT) from the remote server response and include that in a (configurable) header so it is proxied with the request to the backend.

## Enviroment

```
docker-compose build && docker-compose up -d
```


## Configuration

To use this plugin, create an API with some form of authentication:
```
curl -i -X POST \
    --url http://localhost:8001/services/ \
    --data 'name=headers-service' \
    --data 'url=http://mockbin.org'

curl -i -X POST \
    --url http://localhost:8001/services/headers-service/routes \
    --data 'name=headers-route' \
    --data 'paths[]=/headers' \
    --data 'strip_path=false'

curl -X POST http://localhost:8001/services/headers-service/plugins \
    --data name=mb-auth-plugin \
    --data config.hide_credentials=false
```

And a consumer:
```
curl http://localhost:8001/consumers/ \
	--data username=aladdin

curl -X POST http://localhost:8001/consumers/aladdin/basic-auth \
    --data username=aladdin \
    --data password=open-sesame
```

Now we can call the service:
```
curl --user aladdin:open-sesame http://localhost:8000/headers

curl --user aladdin:close-the-door http://localhost:8000/headers

curl http://localhost:8000/headers
```
