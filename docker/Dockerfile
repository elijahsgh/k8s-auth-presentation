FROM python:3-alpine
RUN pip install requests
WORKDIR /serve
COPY simple-vault.py /serve
ENTRYPOINT ["python3", "simple-vault.py"]
