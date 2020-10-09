FROM	alpine:3.12 as builder
RUN	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN	apk add build-base
RUN	apk add openssl-dev pcre-dev zlib-dev
WORKDIR	/nginx/
RUN	wget https://nginx.org/download/nginx-1.17.5.tar.gz
RUN	tar zxf nginx-1.17.5.tar.gz --strip-components 1
COPY	modules .
RUN	./configure --with-http_ssl_module \
		--add-module=nginx-rtmp-module \
		--add-module=nginx-client-module \
		--add-module=nginx-multiport-module \
		--add-module=nginx-toolkit-module \
	&& make && make install

FROM	alpine:3.12
RUN	sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN	apk add --no-cache openssl pcre zlib
WORKDIR	/usr/local/nginx
COPY	--from=builder /usr/local/nginx .
COPY	nginx.conf /usr/local/nginx/conf

EXPOSE	80 1935
CMD ["./sbin/nginx", "-g", "daemon off;"]

