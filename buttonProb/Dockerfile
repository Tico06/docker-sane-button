###### Create a docker image for tif2pdf util
# 
#Commande à lancer
#
FROM alpine:edge
MAINTAINER Eric Grammatico <eric@grammatico.me>
LABEL name="alpine/buttonProb"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk --no-cache add at sane-utils sane-backend-epjitsu


