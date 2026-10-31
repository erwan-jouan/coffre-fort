FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
COPY coffre_fort/ coffre_fort/
EXPOSE 9371
ENV COFFRE_FORT_HOST=0.0.0.0
ENTRYPOINT ["python3", "main.py"]
CMD ["serve", "/data/secrets.yml.enc"]