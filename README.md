This docker image compile [nginx-upload-module](https://github.com/fdintino/nginx-upload-module) as dynamic library, and initialize upload folder structure. It also use [nginx lua module](https://github.com/openresty/lua-nginx-module#nginx-api-for-lua) to process file after uploading.

### Usage
#### Pull image from Docker Hub
```
docker pull hankcp/nginx-upload:latest
```
#### Build image
```
docker build -t nginx-upload:latest
```
#### Run in container
```
docker run --name nginx-upload -v ./nginx/upload:/opt/upload -v ./nginx/log:/var/log/nginx -p 8070:8070 nginx-upload
```


### Volumn Mount Point
* /opt/upload
    * upload home directory
* /opt/res
    * extra static file resource
* /opt/script/extra
    * extra Lua script.
* /etc/nginx/conf.d/extra
    * extra Nginx config
* /var/log/nginx
    * nginx log

#### Use Network Port
8070