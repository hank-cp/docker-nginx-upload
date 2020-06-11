FROM ubuntu:xenial

LABEL maintainer="true.cp@gmail.com" tag="nginx-upload"

ENV NGINX_VERSION 1.16.1-0+xenial1
ENV NGINX_SRC_VERSION 1.16.1
ENV UPLOAD_VERSION 2.3.0

COPY nginx.upload.conf /opt/upload.conf
COPY post_upload.lua /opt/script/post_upload.lua
COPY parser.lua /opt/script/parser.lua
COPY init_upload_dir.sh /opt/script/init_upload_dir.sh

RUN echo ">>>>>>>> 1. Installing prerequsitions <<<<<<<<" \
    && apt-get update \
    && apt-get install -y curl software-properties-common libpcre3 libpcre3-dev libssl-dev \
#    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends php \
    && add-apt-repository -y ppa:nginx/stable \
    && apt-get update \
    && apt-get install -y nginx=$NGINX_VERSION libnginx-mod-http-uploadprogress libnginx-mod-http-lua \
    && echo ">>>>>>>> 2. Download source code <<<<<<<<" \
    && mkdir /opt/httpUpload \
    && cd /opt/httpUpload \
    && curl https://codeload.github.com/fdintino/nginx-upload-module/tar.gz/$UPLOAD_VERSION --output nginx-upload-module.tar.gz \
    && tar zxf nginx-upload-module.tar.gz \
    && sed -i 's|#||g' /etc/apt/sources.list.d/nginx-ubuntu-stable-xenial.list \
    && apt-get update \
    && apt-get install -y dpkg-dev \
    && mkdir /opt/rebuildnginx \
    && cd /opt/rebuildnginx \
    && apt-get source nginx \
    && apt-get build-dep -y nginx \
    && echo ">>>>>>>> 3. Compile dynamic module <<<<<<<<" \
    && cd nginx-$NGINX_SRC_VERSION \
    && ./configure --with-compat --add-dynamic-module=/opt/httpUpload/nginx-upload-module-$UPLOAD_VERSION \
    && make modules \
    && cp objs/ngx_http_upload_module.so /etc/nginx/modules-available/ \
    && echo ">>>>>>>> 4. Update nginx configuration <<<<<<<<" \
    && sed -i '1 i\load_module /etc/nginx/modules-available/ngx_http_upload_module.so;' /etc/nginx/nginx.conf \
    && mv /opt/upload.conf /etc/nginx/conf.d/upload.conf \
    && nginx -t \
    && chmod +x /opt/script/init_upload_dir.sh \
    && echo ">>>>>>>> 5. Clean up <<<<<<<<" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache \
    && rm -rf /opt/rebuildnginx \
    && rm -rf /opt/httpUpload \
    && rm -rf /usr/lib/x86_64-linux-gnu \
    && rm -rf /usr/lib/gcc \


VOLUME /opt/upload /opt/res /opt/script/extra /etc/nginx/conf.d/extra /var/log/nginx

EXPOSE 80

ENTRYPOINT service nginx start && /opt/script/init_upload_dir.sh && tail -f /var/log/nginx/error.log
