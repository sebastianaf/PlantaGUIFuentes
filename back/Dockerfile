FROM debian:stretch

RUN apt-get update &&\
	apt-get -y install \
		git \
		wget \
		libgl1 && \
	rm -rf /var/lib/apt/lists/* && \
	mkdir /tool && \
	cd /tool && \
	wget https://github.com/MiniZinc/MiniZincIDE/releases/download/2.3.1/MiniZincIDE-2.3.1-bundle-linux-x86_64.tgz && \
	tar -zxvf MiniZincIDE-2.3.1-bundle-linux-x86_64.tgz && \
	mv /tool/MiniZincIDE-2.3.1-bundle-linux /tool/MiniZincIDE && \
	rm -rf MiniZincIDE-2.3.1-bundle-linux-x86_64.tgz

RUN apt-get update &&\    
    apt-get -y install\
                build-essential \
                zlib1g-dev \
                libncurses5-dev \
                libgdbm-dev \
                libnss3-dev \
                libssl-dev \
                libreadline-dev \
                libffi-dev && \
    wget https://www.python.org/ftp/python/3.7.3/Python-3.7.3.tar.xz && \
    tar -xf Python-3.7.3.tar.xz && \
    cd Python-3.7.3 && \
    ./configure --enable-optimizations && \
    make -j 8 && \
    make altinstall && \
    python3.7 --version && \
    apt-get -y install python3-pip

RUN export LC_ALL=C && \ 
    pip3 install flask && \
    pip3 install -U flask-cors
    #export LC_ALL=C && \
    #export LANG=C

WORKDIR /code

COPY . .

RUN export FLASK_APP=api/__init__.py

ENV PATH "$PATH:/tool/MiniZincIDE/bin"
ENV LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/tool/MiniZincIDE/lib"

CMD ["python3","api.py"]
#CMD ["flask","run","--host:0.0.0.0"]