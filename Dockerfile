# Use the Python 3.8 image
FROM python:3.8-slim-buster

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy Python script to container
COPY my_script.py .

# Run the Python script
CMD ["python", "my_script.py"]