FROM alpine:3.12.1
RUN apk update
RUN apk add gcc g++ make git patch perl perl-dev curl wget perl-app-cpanminus
RUN apk add --no-cache bash
RUN cpanm Mojolicious Readonly Carp Data::Dumper FindBin
ENV PERL5LIB=/usr/local/lib/perl5
ENV PATH=/usr/local/bin:$PATH
WORKDIR /usr/local/esl/script
# perl esl-app-start daemon -m production -p -l http://192.168.1.32:8821
CMD ["perl", "esl-app-start", "daemon", "-m", "production", "-p", "-l", "http://192.168.1.32:8821"]