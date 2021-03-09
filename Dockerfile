FROM alpine:3.12

RUN apk add --no-cache curl bash jq

ADD ./attach_report_confluence.sh /usr/src/attach_report_confluence.sh
RUN chmod +x /usr/src/attach_report_confluence.sh

ENTRYPOINT ["/usr/src/attach_report_confluence.sh"]