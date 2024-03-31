# Use the smallest official Python base image (based on Alpine Linux)
# Use 3.10-alpine to avoid conflict with 'tenacity' python package
FROM python:3.10-alpine

# Set environment variables PYTHONDONTWRITEBYTECODE and PYTHONUNBUFFERED to prevent writing .pyc files and to ensure that Python output is sent straight to the terminal
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python"]
CMD ["src/mega_auth.py"]
