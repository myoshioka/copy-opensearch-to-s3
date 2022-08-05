FROM python:3.8.13-buster

ENV APP_PATH=/code

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs

WORKDIR $APP_PATH

RUN npm install elasticdump
RUN pip install awscurl

COPY ./es-dump.sh ./
